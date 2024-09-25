---@class HelperFeedback: Helper
VCHelpers.Feedback = _Class:Create("HelperFeedback", Helper)

function VCHelpers.Feedback:PlayEffect(guid)
    Osi.PlayEffect(Osi.GetHostCharacter(), guid)
    Osi.PlaySound(Osi.GetHostCharacter(), guid)
    Osi.PlaySoundResource(Osi.GetHostCharacter(), guid)
end
