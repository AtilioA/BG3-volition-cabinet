local Reader = {}
Reader.__index = Reader

local function decode_float32_le(data, pos)
  local b1, b2, b3, b4 = string.byte(data, pos, pos + 3)
  local u = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
  local sign = 1
  if u >= 2147483648 then
    sign = -1
  end

  local exp = math.floor(u / 8388608) % 256
  local frac = u % 8388608

  if exp == 255 then
    if frac == 0 then
      return sign * math.huge
    end
    return 0 / 0
  end

  if exp == 0 then
    if frac == 0 then
      return sign * 0.0
    end
    return sign * frac * (2 ^ -149)
  end

  return sign * (1.0 + (frac / 8388608)) * (2 ^ (exp - 127))
end

local function decode_float64_le(data, pos)
  local b1, b2, b3, b4, b5, b6, b7, b8 = string.byte(data, pos, pos + 7)
  local lo = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
  local hi = b5 + b6 * 256 + b7 * 65536 + b8 * 16777216

  local sign = 1
  if hi >= 2147483648 then
    sign = -1
  end

  local exp = math.floor(hi / 1048576) % 2048
  local frac_hi = hi % 1048576
  local frac = frac_hi * 4294967296 + lo

  if exp == 2047 then
    if frac == 0 then
      return sign * math.huge
    end
    return 0 / 0
  end

  if exp == 0 then
    if frac == 0 then
      return sign * 0.0
    end
    return sign * frac * (2 ^ -1074)
  end

  return sign * (1.0 + (frac / 4503599627370496.0)) * (2 ^ (exp - 1023))
end

function Reader.new(data)
  assert(type(data) == "string", "binary input must be a Lua string")
  return setmetatable({
    data = data,
    pos = 1,
    len = #data,
  }, Reader)
end

function Reader:tell()
  return self.pos - 1
end

function Reader:seek(abs_pos)
  local p = abs_pos + 1
  assert(p >= 1 and p <= self.len + 1, "seek outside stream")
  self.pos = p
end

function Reader:remaining()
  return self.len - self.pos + 1
end

function Reader:read_bytes(n)
  assert(n >= 0, "negative read length")
  assert(self.pos + n - 1 <= self.len, "unexpected end of stream")
  local out = string.sub(self.data, self.pos, self.pos + n - 1)
  self.pos = self.pos + n
  return out
end

function Reader:read_u8()
  local b = string.byte(self.data, self.pos)
  assert(b ~= nil, "unexpected end of stream")
  self.pos = self.pos + 1
  return b
end

function Reader:read_i8()
  local u = self:read_u8()
  if u >= 128 then
    return u - 256
  end
  return u
end

function Reader:read_u16()
  local b1, b2 = string.byte(self.data, self.pos, self.pos + 1)
  assert(b2 ~= nil, "unexpected end of stream")
  self.pos = self.pos + 2
  return b1 + b2 * 256
end

function Reader:read_i16()
  local u = self:read_u16()
  if u >= 32768 then
    return u - 65536
  end
  return u
end

function Reader:read_u32()
  local b1, b2, b3, b4 = string.byte(self.data, self.pos, self.pos + 3)
  assert(b4 ~= nil, "unexpected end of stream")
  self.pos = self.pos + 4
  return b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
end

function Reader:read_i32()
  local u = self:read_u32()
  if u >= 2147483648 then
    return u - 4294967296
  end
  return u
end

function Reader:read_u64_parts()
  local lo = self:read_u32()
  local hi = self:read_u32()
  return lo, hi
end

function Reader:read_f32()
  local out = decode_float32_le(self.data, self.pos)
  self.pos = self.pos + 4
  return out
end

function Reader:read_f64()
  local out = decode_float64_le(self.data, self.pos)
  self.pos = self.pos + 8
  return out
end

return Reader
