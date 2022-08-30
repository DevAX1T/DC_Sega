local SoundService = game:GetService("SoundService")


return function(context, option, audio)
    if option == 'play' then
        if not audio then
            return context:Reply('Audio not specified.')
        end
        if not tonumber(audio) then
            return context:Reply('Audio must be a nubmer.')
        end
        local CmdrAudio = SoundService:FindFirstChild('CmdrAudio')
        if CmdrAudio then
            CmdrAudio:Destroy()
        end
        CmdrAudio = Instance.new('Sound')
        CmdrAudio.Name = 'CmdrAudio'
        CmdrAudio.Parent = SoundService
        CmdrAudio.Volume = 1
        CmdrAudio.TimePosition = 0
        CmdrAudio.SoundId = 'rbxassetid://' .. audio
        CmdrAudio:Play()
        print('played')
    elseif option == 'stop' then
        local CmdrAudio = SoundService:FindFirstChild('CmdrAudio')
        if CmdrAudio then
            CmdrAudio:Destroy()
        end
    end
end