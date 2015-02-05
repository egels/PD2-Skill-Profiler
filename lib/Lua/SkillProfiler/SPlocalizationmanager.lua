--Localization table with strings. Can be moved to another file to keep it clean.
_localization_strings = {
    SkillProfilerMenu = "Skill Profiler",
    SkillProfilerDesc = "Open Skill Profiler"
}

local old_func = LocalizationManager.text
function LocalizationManager.text(self, string_id, macros)
    return _localization_strings[string_id] or old_func(self, string_id, macros)
end
