return {
    Copper = {
        HoldDuration = 2,
        RespawnTime = 30,
        GetAmount = function() return math.random(1, 2) end
    },
    Wood = {
        HoldDuration = 0.5,
        RespawnTime = 10,
        GetAmount = function() return math.random(2, 5) end
    },
    Stone = {
        HoldDuration = 1,
        RespawnTime = 15,
        GetAmount = function() return math.random(2, 3) end
    }
}