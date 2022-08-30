return {
    Name = 'shutdown',
    Description = 'Shuts down the server',
    Group = 'Admin',
    Args = {
        {
            Name = 'SoftShutdown',
            Description = 'Reboots the server',
            Type = 'boolean',
            Optional = true,
            Default = 'true'
        }
    }
}