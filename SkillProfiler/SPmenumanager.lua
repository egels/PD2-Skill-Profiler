getmetatable(PackageManager).__script_data = getmetatable(PackageManager).__script_data or getmetatable(PackageManager).script_data

getmetatable(PackageManager).insert_JobMenu = function(self, scriptdata)
    for k, v in ipairs(scriptdata[1]) do
        for k2, v2 in ipairs(v) do
            if v2.name == "skilltree" then
                table.insert(scriptdata[1][k], k2+1, {
                    name = "SkillProfiler_Menu",
                    text_id = "SkillProfilerMenu",
                    help_id = "SkillProfilerDesc",
                    sign_in = false,
                    callback = "SkillProfilerCallback",
                    _meta = "item"
                })
                break
            end
        end
    end
end

getmetatable(PackageManager).script_data = function(self, type_id, path_id, ...)
    local scriptdata = self:__script_data(type_id, path_id, ...)
    if type_id == Idstring("menu") and path_id == Idstring("gamedata/menus/start_menu") then
        self:insert_JobMenu(scriptdata)
    end
    return scriptdata
end

function MenuCallbackHandler:SkillProfilerCallback()
    --Your script or whatever you want to run.
    if SkillMenu and (not SkillMenu:isOpen()) then
      SkillMenu:open()
    end
end
