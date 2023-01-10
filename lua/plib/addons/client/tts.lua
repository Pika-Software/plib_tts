plib.Require( 'sound_extensions' )

CreateClientConVar( 'cl_chat_tts', '0', true, true, ' - Converts your text from chat to speech.', 0, 1 )

local net_ReadString = net.ReadString
local cvars_Number = cvars.Number
local hook_Remove = hook.Remove
local sound_PlayTTS = sound.PlayTTS
local hook_Add = hook.Add
local IsValid = IsValid

net.Receive('PLib - TTS', function()
    local ply = net.ReadEntity()
    if IsValid( ply ) then
        if ply:IsMuted() then return end
        if ply:IsSpeaking() then return end
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
                    if IsValid( ply ) and not ply:IsSpeaking() then
                        self:SetVolume( cvars_Number( 'voice_scale', 0.5 ) )
                    else
                        hook_Remove( 'Think', self )
                        self:Stop()
                    end
                end)
            end
        end)
    end
end)