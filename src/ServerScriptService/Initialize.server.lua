local Modules = script.Parent.Modules
local ModulesContainer = {}

for _, Module in Modules:GetChildren() do
   ModulesContainer[Module.Name] = require(Module)
   if ModulesContainer[Module.Name].Init then ModulesContainer[Module.Name]:Init() end 
end