local C = VCHelpers.DecoderConstants
local Reader = VCHelpers.BinaryReader

local Decoder = {}
Decoder.__index = Decoder

local function u64_to_hex(lo, hi)
  return string.format("0x%08x%08x", hi, lo)
end

local function i64_to_string(lo, hi)
  local negative = hi >= 2147483648
  if not negative then
    return u64_to_hex(lo, hi)
  end

  local inv_lo = 4294967295 - lo
  local inv_hi = 4294967295 - hi
  inv_lo = inv_lo + 1
  if inv_lo >= 4294967296 then
    inv_lo = inv_lo - 4294967296
    inv_hi = (inv_hi + 1) % 4294967296
  end

  return "-" .. u64_to_hex(inv_lo, inv_hi)
end

local function maybe_byteswap_guid_tail(bytes, byte_swap_guids)
  if not byte_swap_guids then
    return bytes
  end

  local b = { string.byte(bytes, 1, 16) }
  for i = 9, 16, 2 do
    b[i], b[i + 1] = b[i + 1], b[i]
  end

  return string.char(table.unpack(b))
end

local function guid_to_dotnet_string(bytes)
  local b = { string.byte(bytes, 1, 16) }
  return string.format(
    "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
    b[4], b[3], b[2], b[1],
    b[6], b[5],
    b[8], b[7],
    b[9], b[10],
    b[11], b[12], b[13], b[14], b[15], b[16]
  )
end

local function decode_packed_version32(v)
  return {
    major = math.floor(v / 268435456) % 16,
    minor = math.floor(v / 16777216) % 16,
    revision = math.floor(v / 65536) % 256,
    build = v % 65536,
  }
end

local function decode_packed_version64(lo, hi)
  local major = math.floor(hi / 8388608) % 128
  local minor = math.floor(hi / 32768) % 256
  local revision = ((hi % 32768) * 2) + math.floor(lo / 2147483648)
  local build = lo % 2147483648

  return {
    major = major,
    minor = minor,
    revision = revision,
    build = build,
  }
end

local function decode_metadata_v5(reader)
  return {
    strings_uncompressed_size = reader:read_u32(),
    strings_size_on_disk = reader:read_u32(),
    nodes_uncompressed_size = reader:read_u32(),
    nodes_size_on_disk = reader:read_u32(),
    attributes_uncompressed_size = reader:read_u32(),
    attributes_size_on_disk = reader:read_u32(),
    values_uncompressed_size = reader:read_u32(),
    values_size_on_disk = reader:read_u32(),
    compression_flags = reader:read_u8(),
    unknown2 = reader:read_u8(),
    unknown3 = reader:read_u16(),
    metadata_format = reader:read_u32(),
    keys_uncompressed_size = 0,
    keys_size_on_disk = 0,
  }
end

local function decode_metadata_v6(reader)
  return {
    strings_uncompressed_size = reader:read_u32(),
    strings_size_on_disk = reader:read_u32(),
    keys_uncompressed_size = reader:read_u32(),
    keys_size_on_disk = reader:read_u32(),
    nodes_uncompressed_size = reader:read_u32(),
    nodes_size_on_disk = reader:read_u32(),
    attributes_uncompressed_size = reader:read_u32(),
    attributes_size_on_disk = reader:read_u32(),
    values_uncompressed_size = reader:read_u32(),
    values_size_on_disk = reader:read_u32(),
    compression_flags = reader:read_u8(),
    unknown2 = reader:read_u8(),
    unknown3 = reader:read_u16(),
    metadata_format = reader:read_u32(),
  }
end

local function compression_method_from_flags(flags)
  return flags % 16
end

local function method_name(method)
  if method == C.COMPRESSION_METHOD.None then
    return "none"
  elseif method == C.COMPRESSION_METHOD.Zlib then
    return "zlib"
  elseif method == C.COMPRESSION_METHOD.LZ4 then
    return "lz4"
  elseif method == C.COMPRESSION_METHOD.Zstd then
    return "zstd"
  end
  return "unknown"
end

local function read_string_with_known_length(reader, length)
  if length <= 0 then
    return ""
  end

  local body = reader:read_bytes(length - 1)
  local term = reader:read_u8()
  assert(term == 0, "string is not null terminated")

  local last = #body
  while last > 0 and string.byte(body, last) == 0 do
    last = last - 1
  end

  return string.sub(body, 1, last)
end

local function read_names(data)
  local reader = Reader.new(data)
  local names = {}
  local num_hash_entries = reader:read_u32()
  for i = 1, num_hash_entries do
    local chain = {}
    names[i] = chain

    local count = reader:read_u16()
    for j = 1, count do
      local name_len = reader:read_u16()
      chain[j] = reader:read_bytes(name_len)
    end
  end

  return names
end

local function name_from_hash(names, hash_index)
  local name_index = math.floor(hash_index / 65536) + 1
  local name_offset = (hash_index % 65536) + 1
  local bucket = names[name_index]
  assert(bucket, "invalid name hash bucket")
  local s = bucket[name_offset]
  assert(s, "invalid name hash offset")
  return s, name_index, name_offset
end

local function read_nodes(data, long_nodes, names)
  local reader = Reader.new(data)
  local nodes = {}

  while reader:remaining() > 0 do
    local name_hash = reader:read_u32()
    local parent_index
    local first_attribute_index

    if long_nodes then
      parent_index = reader:read_i32()
      reader:read_i32()
      first_attribute_index = reader:read_i32()
    else
      first_attribute_index = reader:read_i32()
      parent_index = reader:read_i32()
    end

    local _, name_index, name_offset = name_from_hash(names, name_hash)
    nodes[#nodes + 1] = {
      parent_index = parent_index,
      first_attribute_index = first_attribute_index,
      name_index = name_index,
      name_offset = name_offset,
      key_attribute = nil,
    }
  end

  return nodes
end

local function read_attributes_v2(data, names)
  local reader = Reader.new(data)
  local attributes = {}
  local prev_attribute_refs = {}
  local data_offset = 0

  while reader:remaining() > 0 do
    local name_hash = reader:read_u32()
    local type_and_length = reader:read_u32()
    local node_index = reader:read_i32()

    local _, name_index, name_offset = name_from_hash(names, name_hash)
    local type_id = type_and_length % 64
    local length = math.floor(type_and_length / 64)

    local attr = {
      name_index = name_index,
      name_offset = name_offset,
      type_id = type_id,
      length = length,
      data_offset = data_offset,
      next_attribute_index = -1,
    }

    local index = #attributes
    local key = node_index + 1
    local prev = prev_attribute_refs[key]
    if prev ~= nil and prev ~= -1 then
      attributes[prev + 1].next_attribute_index = index
    end
    prev_attribute_refs[key] = index

    attributes[#attributes + 1] = attr
    data_offset = data_offset + length
  end

  return attributes
end

local function read_attributes_v3(data, names)
  local reader = Reader.new(data)
  local attributes = {}

  while reader:remaining() > 0 do
    local name_hash = reader:read_u32()
    local type_and_length = reader:read_u32()
    local next_attribute_index = reader:read_i32()
    local offset = reader:read_u32()

    local _, name_index, name_offset = name_from_hash(names, name_hash)

    attributes[#attributes + 1] = {
      name_index = name_index,
      name_offset = name_offset,
      type_id = type_and_length % 64,
      length = math.floor(type_and_length / 64),
      data_offset = offset,
      next_attribute_index = next_attribute_index,
    }
  end

  return attributes
end

local function read_keys(data, names, nodes)
  local reader = Reader.new(data)
  while reader:remaining() > 0 do
    local node_index = reader:read_u32()
    local key_hash = reader:read_u32()
    local key_name = name_from_hash(names, key_hash)
    local node = nodes[node_index + 1]
    if node then
      node.key_attribute = key_name
    end
  end
end

local function read_int_vector(reader, n)
  local out = {}
  for i = 1, n do
    out[i] = reader:read_i32()
  end
  return out
end

local function read_float_vector(reader, n)
  local out = {}
  for i = 1, n do
    out[i] = reader:read_f32()
  end
  return out
end

local function read_matrix(reader, rows, cols)
  local values = {}
  for col = 1, cols do
    for row = 1, rows do
      values[#values + 1] = reader:read_f32()
    end
  end

  return {
    rows = rows,
    cols = cols,
    values = values,
    order = "column-major",
  }
end

local function read_translated_fs_string(self, reader)
  local str = {}
  if self.version >= C.LSF_VERSION.VerBG3 then
    str.version = reader:read_u16()
  else
    str.version = 0
    local value_len = reader:read_i32()
    str.value = read_string_with_known_length(reader, value_len)
  end

  local handle_len = reader:read_i32()
  str.handle = read_string_with_known_length(reader, handle_len)

  local arg_count = reader:read_i32()
  str.arguments = {}

  for i = 1, arg_count do
    local key_len = reader:read_i32()
    local key = read_string_with_known_length(reader, key_len)
    local arg_string = read_translated_fs_string(self, reader)
    local val_len = reader:read_i32()
    local value = read_string_with_known_length(reader, val_len)

    str.arguments[i] = {
      key = key,
      string = arg_string,
      value = value,
    }
  end

  return str
end

function Decoder:_read_attribute_value(type_id, length, values_reader)
  local T = C.ATTRIBUTE_TYPE

  if type_id == T.String or type_id == T.Path or type_id == T.FixedString
      or type_id == T.LSString or type_id == T.WString or type_id == T.LSWString then
    return read_string_with_known_length(values_reader, length)
  elseif type_id == T.TranslatedString then
    local ts = {}
    local gv = self.game_version
    local has_bg3_ts_prefix = self.version >= C.LSF_VERSION.VerBG3
      or (gv.major > 4)
      or (gv.major == 4 and gv.revision > 0)
      or (gv.major == 4 and gv.revision == 0 and gv.build >= 0x1A)

    if has_bg3_ts_prefix then
      ts.version = values_reader:read_u16()
    else
      ts.version = 0
      local vlen = values_reader:read_i32()
      ts.value = read_string_with_known_length(values_reader, vlen)
    end

    local hlen = values_reader:read_i32()
    ts.handle = read_string_with_known_length(values_reader, hlen)
    return ts
  elseif type_id == T.TranslatedFSString then
    return read_translated_fs_string(self, values_reader)
  elseif type_id == T.ScratchBuffer then
    return values_reader:read_bytes(length)
  elseif type_id == T.None then
    return nil
  elseif type_id == T.Byte then
    return values_reader:read_u8()
  elseif type_id == T.Short then
    return values_reader:read_i16()
  elseif type_id == T.UShort then
    return values_reader:read_u16()
  elseif type_id == T.Int then
    return values_reader:read_i32()
  elseif type_id == T.UInt then
    return values_reader:read_u32()
  elseif type_id == T.Float then
    return values_reader:read_f32()
  elseif type_id == T.Double then
    return values_reader:read_f64()
  elseif type_id == T.IVec2 then
    return read_int_vector(values_reader, 2)
  elseif type_id == T.IVec3 then
    return read_int_vector(values_reader, 3)
  elseif type_id == T.IVec4 then
    return read_int_vector(values_reader, 4)
  elseif type_id == T.Vec2 then
    return read_float_vector(values_reader, 2)
  elseif type_id == T.Vec3 then
    return read_float_vector(values_reader, 3)
  elseif type_id == T.Vec4 then
    return read_float_vector(values_reader, 4)
  elseif type_id == T.Mat2 then
    return read_matrix(values_reader, 2, 2)
  elseif type_id == T.Mat3 then
    return read_matrix(values_reader, 3, 3)
  elseif type_id == T.Mat3x4 then
    return read_matrix(values_reader, 3, 4)
  elseif type_id == T.Mat4x3 then
    return read_matrix(values_reader, 4, 3)
  elseif type_id == T.Mat4 then
    return read_matrix(values_reader, 4, 4)
  elseif type_id == T.Bool then
    return values_reader:read_u8() ~= 0
  elseif type_id == T.ULongLong then
    local lo, hi = values_reader:read_u64_parts()
    return {
      kind = "u64",
      lo = lo,
      hi = hi,
      hex = u64_to_hex(lo, hi),
    }
  elseif type_id == T.Long or type_id == T.Int64 then
    local lo, hi = values_reader:read_u64_parts()
    return {
      kind = "i64",
      lo = lo,
      hi = hi,
      hex = i64_to_string(lo, hi),
    }
  elseif type_id == T.Int8 then
    return values_reader:read_i8()
  elseif type_id == T.UUID then
    local raw = values_reader:read_bytes(16)
    local normalized = maybe_byteswap_guid_tail(raw, self.options.byte_swap_guids)
    return {
      kind = "uuid",
      raw = raw,
      text = guid_to_dotnet_string(normalized),
    }
  end

  error("unsupported attribute type id: " .. tostring(type_id))
end

function Decoder:_read_node(defn, values_reader)
  local node_name = self.names[defn.name_index][defn.name_offset]
  local node = {
    name = node_name,
    key_attribute = defn.key_attribute,
    attributes = {},
    children = {},
    children_by_name = {},
    parent = nil,
  }

  if defn.first_attribute_index ~= -1 then
    local attr = self.attributes[defn.first_attribute_index + 1]
    while true do
      values_reader:seek(attr.data_offset)
      local value = self:_read_attribute_value(attr.type_id, attr.length, values_reader)
      local attr_name = self.names[attr.name_index][attr.name_offset]
      node.attributes[attr_name] = {
        type_id = attr.type_id,
        type_name = C.ATTRIBUTE_NAME_BY_ID[attr.type_id] or ("Unknown(" .. tostring(attr.type_id) .. ")"),
        length = attr.length,
        value = value,
      }

      if attr.next_attribute_index == -1 then
        break
      end

      attr = self.attributes[attr.next_attribute_index + 1]
      assert(attr ~= nil, "broken attribute chain")
    end
  end

  return node
end

function Decoder:_build_tree(values_blob)
  local values_reader = Reader.new(values_blob)
  local instances = {}
  local resource = {
    metadata = {
      major = self.game_version.major,
      minor = self.game_version.minor,
      revision = self.game_version.revision,
      build = self.game_version.build,
    },
    metadata_format = self.metadata.metadata_format,
    regions = {},
    region_list = {},
  }

  for i = 1, #self.nodes do
    local defn = self.nodes[i]
    local node = self:_read_node(defn, values_reader)
    instances[i] = node

    if defn.parent_index == -1 then
      node.region_name = node.name
      resource.regions[node.name] = node
      resource.region_list[#resource.region_list + 1] = node
    else
      local parent = instances[defn.parent_index + 1]
      assert(parent ~= nil, "parent node missing")
      node.parent = parent
      parent.children[#parent.children + 1] = node

      local list = parent.children_by_name[node.name]
      if not list then
        list = {}
        parent.children_by_name[node.name] = list
      end
      list[#list + 1] = node
    end
  end

  return resource
end

function Decoder:_read_section(main_reader, section_name, size_on_disk, uncompressed_size, allow_chunked)
  if size_on_disk == 0 and uncompressed_size ~= 0 then
    return main_reader:read_bytes(uncompressed_size)
  end

  if size_on_disk == 0 and uncompressed_size == 0 then
    return ""
  end

  local method = compression_method_from_flags(self.metadata.compression_flags)
  local is_compressed = method ~= C.COMPRESSION_METHOD.None
  local chunked = (self.version >= C.LSF_VERSION.VerChunkedCompress) and allow_chunked
  local bytes_to_read = is_compressed and size_on_disk or uncompressed_size
  local payload = main_reader:read_bytes(bytes_to_read)

  if not is_compressed then
    return payload
  end

  local callback = self.options.decompress
  if type(callback) ~= "function" then
    error(
      "section '" .. section_name .. "' is compressed with " .. method_name(method)
      .. "; provide options.decompress(payload, expected_size, context)"
    )
  end

  local out = callback(payload, uncompressed_size, {
    method = method_name(method),
    method_id = method,
    compression_flags = self.metadata.compression_flags,
    chunked = chunked,
    section = section_name,
    lsf_version = self.version,
  })

  assert(type(out) == "string", "decompress callback must return a Lua string")
  if #out ~= uncompressed_size then
    error(
      "decompress callback returned unexpected length for section '" .. section_name
      .. "' (expected " .. tostring(uncompressed_size) .. ", got " .. tostring(#out) .. ")"
    )
  end

  return out
end

function Decoder:decode(binary)
  local reader = Reader.new(binary)

  local sig = reader:read_bytes(4)
  assert(sig == "LSOF", "invalid LSF signature")

  local version = reader:read_u32()
  assert(version >= C.LSF_VERSION.VerInitial and version <= C.LSF_VERSION.VerBG3Patch3,
    "unsupported LSF version: " .. tostring(version))
  self.version = version

  if version >= C.LSF_VERSION.VerBG3ExtendedHeader then
    local lo, hi = reader:read_u64_parts()
    self.game_version = decode_packed_version64(lo, hi)
    if self.game_version.major == 0 then
      self.game_version = { major = 4, minor = 0, revision = 9, build = 0 }
    end
  else
    self.game_version = decode_packed_version32(reader:read_u32())
  end

  if version < C.LSF_VERSION.VerBG3NodeKeys then
    self.metadata = decode_metadata_v5(reader)
  else
    self.metadata = decode_metadata_v6(reader)
  end

  local has_adjacency_data = version >= C.LSF_VERSION.VerExtendedNodes
    and self.metadata.metadata_format == C.METADATA_FORMAT.KeysAndAdjacency

  local names_blob = self:_read_section(reader, "names", self.metadata.strings_size_on_disk, self.metadata.strings_uncompressed_size, false)
  self.names = read_names(names_blob)

  local nodes_blob = self:_read_section(reader, "nodes", self.metadata.nodes_size_on_disk, self.metadata.nodes_uncompressed_size, true)
  self.nodes = read_nodes(nodes_blob, has_adjacency_data, self.names)

  local attrs_blob = self:_read_section(reader, "attributes", self.metadata.attributes_size_on_disk, self.metadata.attributes_uncompressed_size, true)
  if has_adjacency_data then
    self.attributes = read_attributes_v3(attrs_blob, self.names)
  else
    self.attributes = read_attributes_v2(attrs_blob, self.names)
  end

  local values_blob = self:_read_section(reader, "values", self.metadata.values_size_on_disk, self.metadata.values_uncompressed_size, true)

  if self.metadata.metadata_format == C.METADATA_FORMAT.KeysAndAdjacency then
    local keys_blob = self:_read_section(reader, "keys", self.metadata.keys_size_on_disk, self.metadata.keys_uncompressed_size, true)
    read_keys(keys_blob, self.names, self.nodes)
  end

  return self:_build_tree(values_blob)
end

M = {}

function M.decode(binary, options)
  local resolved_options = options or {}
  if resolved_options.byte_swap_guids == nil then
    resolved_options.byte_swap_guids = true
  end

  local d = setmetatable({
    options = resolved_options,
    version = nil,
    game_version = nil,
    metadata = nil,
    names = nil,
    nodes = nil,
    attributes = nil,
  }, Decoder)

  return d:decode(binary)
end

VCHelpers.Decoder = M
