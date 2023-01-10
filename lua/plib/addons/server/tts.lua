plib.Require( 'sound_extensions' )

util.AddNetworkString( 'PLib - TTS' )

local player_GetHumans = player.GetHumans
local net_WriteString = net.WriteString
local net_WriteEntity = net.WriteEntity
local table_insert = table.insert
local net_Start = net.Start
local net_Send = net.Send
local hook_Run = hook.Run
local SysTime = SysTime
local ipairs = ipairs

local antiSpam = CreateConVar( 'sv_chat_tts_antispam', '1', FCVAR_ARCHIVE, ' - TTS anti-spam protection.', 0, 1 )
local antiSpamDelay = CreateConVar( 'sv_chat_tts_antispam_delay', '1', FCVAR_ARCHIVE, ' - TTS anti-spam block delay.', 0, 60 )
hook.Add('PlayerSay', 'PLib - TTS', function( speaker, text, isTeam )
    if (speaker:GetInfoNum( 'cl_chat_tts', 0 ) ~= 1) then return end
    if speaker:IsSpeaking() then return end

    if antiSpam:GetBool() then
        if (SysTime() < (speaker.PLibTTS or 0)) then
            speaker.PLibTTS = SysTime() + antiSpamDelay:GetFloat() * 2
            return
        end

        speaker.PLibTTS = SysTime() + antiSpamDelay:GetFloat()
    end

    local listeners = { speaker }
    local speakerTeam = speaker:Team()
    local speakerIndex = speaker:EntIndex()
    for _, listener in ipairs( player_GetHumans() ) do
        if (speakerIndex == listener:EntIndex()) then continue end
        if not listener:TestPVS( speaker ) then continue end
        if isTeam and (speakerTeam ~= listener:Team()) then continue end
        if not hook_Run( 'PlayerCanHearPlayersVoice', listener, speaker ) then continue end
        if not hook_Run( 'PlayerCanSeePlayersChat', text, isTeam, listener, speaker ) then continue end
        table_insert( listeners, listener )
    end

    if (#listeners > 0) then
        net_Start( 'PLib - TTS' )
            net_WriteEntity( speaker )
            net_WriteString( text )
        net_Send( listeners )
    end
end)