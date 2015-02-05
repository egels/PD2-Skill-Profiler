-- Load libraries
if not GetPersistScript('CustomMenuClass') then
  AddPersistScript('CustomMenuClass', 'lib/Lua/SkillProfiler/CustomMenu/CustomMenuClass.lua')
end
if not GetPersistScript('Utils') then
  AddPersistScript('Utils', 'lib/Lua/SkillProfiler/CustomMenu/Utils.lua')
end
-- Load skill profiler
if not GetPersistScript('SkillProfiler') then
  AddPersistScript('SkillProfiler', 'lib/Lua/SkillProfiler/SkillProfiler.lua')
end
if not GetPersistScript('SkillMenu') then
  AddPersistScript('SkillMenu', 'lib/Lua/SkillProfiler/SkillMenu.lua')
end
RegisterScript('lib/Lua/SkillProfiler/SPlocalizationmanager.lua',
               2, 'lib/managers/localizationmanager')
RegisterScript('lib/Lua/SkillProfiler/SPmenumanager.lua',
               2, 'lib/managers/menumanager')
