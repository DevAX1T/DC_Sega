return {
    Name = 'audio',
    Description = 'Plays an audio',
    Group = 'Admin',
    Args = {
        {
            Name = 'option',
            Description = 'The option to select.',
            Type = 'audioOptions'
        },
        {
            Name = 'audio',
            Description = 'The audio to play.',
            Type = 'string',
            Optional = true
        }
    }
}