# plib_tts
Addon converts player text chat messages into speech.

## Requires
- [gmod_plib](https://github.com/Pika-Software/gmod_plib)
- [plib_sound_extensions](https://github.com/Pika-Software/plib_sound_extensions)

## Hook Usage Example
Admin Only TTS
```lua
hook.Add('PlayerTTS', 'AdminOnlyTTS', function( ply )
    if ply:IsAdmin() then return end
    return false
end)
```