if (not SkillMenu) and CustomMenuClass and SkillProfiler then
  -- Create utils functions
  function InitLoadDelMenus()
    -- Initialize 'Load' and 'Delete' menus with data from SkillProfiler
    SkillMenu:addMenu('load', {title = 'Load Skill Profile'})
    SkillMenu:addMenu('delete', {title = 'Delete Skill Profile'})
    local profile_names = SkillProfiler:get_profile_names()
    table.sort(profile_names)
    for i=1,#profile_names do
      SkillMenu:addOption('load', profile_names[i],
        {callback=CallbackLoadProfile,
         callbackData=profile_names[i]})
      SkillMenu:addOption('delete', profile_names[i],
        {callback=CallbackDelProfile,
         callbackData=profile_names[i]})
    end
  end

  -- Create callback functions
  function CallbackAddProfile()
    local profile_names = SkillProfiler:get_profile_names()
    local names_set = {}
    for _, name in pairs(profile_names) do
      names_set[name] = true
    end
    local i = 1
    local new_profile_name = ''
    repeat
      new_profile_name = 'Profile ' .. i
      i = i + 1
    until(names_set[new_profile_name] ~= true)
    SkillProfiler:add_profile(new_profile_name)
    InitLoadDelMenus()
    SkillMenu:refreshMenu()
    SkillProfiler:save_to_file()
  end
  function CallbackLoadProfile(name)
    if SkillProfiler:set_player_skills(name) then
      local menuoption = SkillMenu:getMenuOption('main', 'infobox')
      menuoption.text = 'Profile loaded'
      menuoption.textColor = Color.green
      SkillMenu:refreshMenu()
      SkillMenu:openMenu('main', 1)
    else
      local menuoption = SkillMenu:getMenuOption('main', 'infobox')
      menuoption.text = 'Error loading profile'
      menuoption.textColor = Color.red
      SkillMenu:refreshMenu()
      SkillMenu:openMenu('main', 1)
    end
  end
  function CallbackDelProfile(name)
    SkillProfiler:del_profile(name)
    local menuoption = SkillMenu:getMenuOption('main', 'infobox')
    menuoption.text = ''
    SkillMenu:openMenu('main', 1)
    InitLoadDelMenus()
    SkillMenu:refreshMenu()
    SkillProfiler:save_to_file()
  end

  -- Init menu
  SkillMenu = CustomMenuClass:new()
  SkillMenu:addMainMenu('main', {title = 'Skill Profiler'})
  SkillMenu:addMenu('load', {title = 'Load Skill Profile'})
  SkillMenu:addMenu('delete', {title = 'Delete Skill Profile'})
  -- Add main menu options
  SkillMenu:addOption('main', 'Add profile',
    {help='Add a new profile using your current skills',
     callback=CallbackAddProfile})
  SkillMenu:addMenuOption('main', 'Load profile', 'load',
    {help = 'Load a skill profile'})
  SkillMenu:addMenuOption('main', 'Delete profile', 'delete',
    {help = 'Delete a skill profile'})
  for i=1,(_maxRows*_maxColumns-4) do
    SkillMenu:addGap('main')
  end
  SkillMenu:addInformationOption('main', '', {name = 'infobox'})
  -- Load profiles
  if SkillProfiler:load_from_file() then
    InitLoadDelMenus()
    SkillMenu:refreshMenu()
  end
end
