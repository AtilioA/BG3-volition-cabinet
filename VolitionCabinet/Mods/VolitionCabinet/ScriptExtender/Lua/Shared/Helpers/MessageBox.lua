---@class HelperMessageBox: Helper
VCHelpers.MessageBox = _Class:Create("HelperMessageBox", Helper)

--- Guess this is our life now
---@param eventId string
---@param content string
---@param force? number
---@param initiation? GUIDSTRING -- Initiation? More like initiation of the end times
---@param char1? GUIDSTRING
---@param char2? GUIDSTRING
---@param char3? GUIDSTRING
function VCHelpers.MessageBox:DustyMessageBox(eventId, content, initiation, char1, char2, char3, force)
    force = force or 1
    initiation = initiation or Osi.GetHostCharacter()
    char1 = char1 or ""
    char2 = char2 or ""
    char3 = char3 or ""
    Osi.ReadyCheckSpecific(eventId, content, force, initiation, char1, char2, char3)
end
