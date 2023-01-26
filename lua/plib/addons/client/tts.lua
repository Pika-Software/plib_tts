plib.Require( 'sound_extensions' )

CreateClientConVar( 'cl_chat_tts', '0', true, true, ' - Converts your text from chat to speech.', 0, 1 )
CreateClientConVar( 'cl_chat_tts_hide_messages', '0', true, true, ' - Blocks chat messages when using TTS.', 0, 1 )

local PLAYER = FindMetaTable( 'Player' )
PLAYER.SourceIsSpeaking = PLAYER.SourceIsSpeaking or PLAYER.IsSpeaking

function PLAYER:IsSpeaking()
    local channel = self.PLibTTS
    if IsValid( channel ) and (channel:GetState() == 1) then
        return true
    end

    return self:SourceIsSpeaking()
end

PLAYER.SourceVoiceVolume = PLAYER.SourceVoiceVolume or PLAYER.VoiceVolume
function PLAYER:VoiceVolume()
    local channel = self.PLibTTS
    if IsValid( channel ) and (channel:GetState() == 1) then
        local left, right = channel:GetLevel()
        return (left + right) / 2
    end

    return self:SourceVoiceVolume() or 0
end

local net_ReadString = net.ReadString
local cvars_Number = cvars.Number
local hook_Remove = hook.Remove
local sound_PlayTTS = sound.PlayTTS
local hook_Add = hook.Add
local IsValid = IsValid

local voiceChat = GetConVar( 'voice_modenable' )

net.Receive('PLib - TTS', function()
    if voiceChat:GetBool() then
        local ply = net.ReadEntity()
        if IsValid( ply ) and ply:Alive() then
            if ply:IsMuted() then return end
            if ply:SourceIsSpeaking() then return end
            sound_PlayTTS(net_ReadString(), '3d', function( channel )
                if IsValid( ply ) then
                    local prevChannel = ply.PLibTTS
                    if IsValid( prevChannel ) then
                        hook_Remove( 'Think', prevChannel )
                        prevChannel:Stop()
                    end

                    channel:SetEntity( ply )
                    ply.PLibTTS = channel

                    hook_Add('Think', channel, function( self )
                        if IsValid( ply ) and ply:Alive() and !ply:SourceIsSpeaking() and (self:GetState() == 1) then
                            self:SetVolume( cvars_Number( 'voice_scale', 0.5 ) )
                        else
                            hook_Remove( 'Think', self )
                            self:Stop()

                            if IsValid( ply ) then
                                hook.Run( 'PlayerEndVoice', ply )
                            end
                        end
                    end)

                    channel:Play()
                    hook.Run( 'PlayerStartVoice', ply )
                end
            end)
        end
    end
end)
