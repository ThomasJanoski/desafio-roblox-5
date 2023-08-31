local Remotes = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteInfo = {
    ["Data"] = {
        ["DataFunctions"] = {
            ["Get Player Data"] = function(Player: Player)
            end
        }
    }
}

local Connections = {
    ["RemoteEvent"] = function(Remote: RemoteEvent, Function)
        Remote.OnServerEvent:Connect(Function)
    end,
    ["RemoteFunction"] = function(Remote: RemoteFunction, Function)
        Remote.OnServerInvoke = Function
    end 
}

function Remotes:Init()
    for _, RemoteFolder in ReplicatedStorage.Remotes:GetChildren() do
        if not RemoteInfo[RemoteFolder.Name] then continue end

        for _, Remote in RemoteFolder:GetChildren() do
            local Base = RemoteInfo[RemoteFolder.Name][Remote.Name]
            if not Base then continue end

            Connections[Remote.ClassName](Remote, function(Player: Player, Message: string, Args: {})
                if not Base[Message] then return end
                return Base[Message](Player, Args)
            end)
        end
    end
end

return Remotes