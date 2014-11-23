-- http://www.unknowncheats.me/forum/payday-2/106995-skillprofiler-beta.html
-- https://bitbucket.org/gir489/payday-2-lua-repo/src/523b032ca8d46aa5a6b0f1dcdc13760f774b12a1/lib/managers/skilltreemanager.lua?at=master
if not SkillProfiler then
  SkillProfiler = {}

  SkillProfiler.filepath = 'skillprofiles.txt'
  SkillProfiler.profiles = {}
  SkillProfiler.tree_char = {'m', 'e', 't', 'g', 'f'}
  SkillProfiler.skill_char = {{'b','c','d'}, {'e','f','g'}, {'h','i','j'},
                              {'k','l','m'}, {'n','o','p'}, {'q','r','s'}}

  function SkillProfiler:load_from_file(filepath)
    --[[
      Load the skill profiles from a file.

      Args:
        filepath: Path to the file. Optional argument.
                  If it's not defined, a default path is used.

      Returns:
        true if profiles were loaded successfully, false otherwise
    --]]
    local filepath = filepath or self.filepath
    local file = io.open(filepath, 'r')
    if file then
      local lineiter = file:lines()
      while true do
        local line1 = lineiter()
        local line2 = lineiter()
        if line1 and line2 then
          line1 = line1:gsub('\r', '')
          line1 = line1:gsub('\n', '')
          line2 = line2:gsub('\r', '')
          line2 = line2:gsub('\n', '')
          self.profiles[line1] = line2
        else
          break
        end
      end
      file:close()
      return true
    else
      return false
    end
  end

  function SkillProfiler:save_to_file(filepath)
    --[[
      Save the skill profiles to a file.

      Args:
        filepath: Path to the file. Optional argument.
                  If it's not defined, a default path is used.

      Returns:
        true if profiles were saved successfully, false otherwise
    --]]
    local filepath = filepath or self.filepath
    local file = io.open(filepath, 'w')
    if file then
      for k,v in pairs(self.profiles) do
        file:write(k .. '\r\n')
        file:write(v .. '\r\n')
      end
      file:close()
      return true
    else
      return false
    end
  end

  function SkillProfiler:get_profile_names()
    --[[
      Return a list of defined profiles.
      Example: {'Profile 1', 'Profile 2'}
    --]]
    local names = {}
    local n = 0
    for key,_ in pairs(self.profiles) do
      n = n + 1
      names[n] = key
    end
    return names
  end

  function SkillProfiler:add_profile(name)
    --[[
      Add or overwrite a profile with the user's current skills.
    --]]
    local profile = {}
    for tree = 1,5 do
      if managers.skilltree:tree_unlocked(tree) then
        profile[#profile+1] = self.tree_char[tree]
        profile[#profile+1] = 'a'
        for tier = 1,6 do
          for i, skill_id in pairs(tweak_data.skilltree.trees[tree].tiers[tier]) do
            local skill_step = managers.skilltree:skill_step(skill_id)
            if skill_step == 1 then
              profile[#profile+1] = self.skill_char[tier][i]
            elseif skill_step == 2 then
              profile[#profile+1] = string.upper(self.skill_char[tier][i])
            end
          end
        end
        profile[#profile+1] = ':'
      end
    end
    profile[#profile+1] = ':'
    profile = table.concat(profile)
    self.profiles[name] = profile
  end

  function SkillProfiler:add_pd2skills_profile(name, url)
  end

  function SkillProfiler:del_profile(name)
    --[[
      Delete a profile.
    --]]
    self.profiles[name] = nil
  end

  function SkillProfiler:set_player_skills(profile_name)
    --[[
      Change the player's skills to those specified by a profile. Returns true
      if the profile was loaded successfully, false otherwise.

      Args:
        profile_name: Profile name to set.

      Returns:
        A tuple, where the first value is a boolean indicating if the profile
        was loaded successfully and the second value is a message indicating
        what went wrong if it didn't.
    --]]
    -- Check if profile exists
    local profile = self.profiles[profile_name]
    if not profile then
      return false, 'Profile doesn\'t exist'
    end
    profile = profile:gsub('.+\/', '')
    local tree_begin = 1
    local tree_end = string.find(profile, ':', tree_begin)
    if not tree_end then
      return true
    end
    -- Check if profile is valid and user has enough money
    local total_cost = 0
    local total_skill_points = 0
    for tree, _, skills_string in self:_iter_tree(profile) do
      local tree_skill_points = 1
      local tree_skills = {}
      for _, skill_tier, skill_index, skill_aced in self:_iter_skills(skills_string) do
        local tier_unlock_cost = managers.skilltree:tier_cost(tree, skill_tier)
        local skill_id = tweak_data.skilltree.trees[tree].tiers[skill_tier][skill_index]
        local prerequisites = tweak_data.skilltree.skills[skill_id]['prerequisites']
        local prerequisite_ok = not(prerequisites and prerequisites[1] and not tree_skills[prerequisites[1]])
        if tier_unlock_cost > tree_skill_points or not prerequisite_ok then
          return false, 'Invalid profile'
        else
          tree_skills[skill_id] = true
          local skill_cost = self:_skill_point_cost(skill_tier, skill_aced)
          tree_skill_points = tree_skill_points + skill_cost
          total_cost = total_cost + managers.money:get_skillpoint_cost(tree, skill_tier, skill_cost)
        end
      end
      total_skill_points = total_skill_points + tree_skill_points
    end
    total_cost = math.round(total_cost)
    local max_skill_points = managers.skilltree:points()
    for tree=1,5 do
      max_skill_points = max_skill_points + managers.skilltree:points_spent(tree)
    end
    if total_skill_points > max_skill_points then
      return false, 'Invalid profile'
    elseif total_cost > managers.money:total() then
      -- TODO: redo this calculation properly, accounting for infamy bonuses
      return false, 'Not enough money'
    end
    -- Assign skills
    managers.skilltree:reset_skilltrees()
    for tree, _, skills_string in self:_iter_tree(profile) do
      managers.skilltree:unlock_tree(tree)
      for _, skill_tier, skill_index, skill_aced in self:_iter_skills(skills_string) do
        local skill_id = tweak_data.skilltree.trees[tree].tiers[skill_tier][skill_index]
        local skill_cost = self:_skill_point_cost(skill_tier, skill_aced)
        local money_cost = managers.money:get_skillpoint_cost(tree, skill_tier, skill_cost)
        managers.money:deduct_from_total(money_cost)
        if skill_aced then
          managers.skilltree:unlock(tree, skill_id)
          managers.skilltree:unlock(tree, skill_id)
        else
          managers.skilltree:unlock(tree, skill_id)
        end
      end
    end
    return true
  end

  function SkillProfiler:char_to_tree(char)
    --[[
      Function to convert a char in a skill profile to its tree.
      Returns a number between 1 and 5 corresponding to the skill tree.
    --]]
    if not self.tree_char_reverse then
      self.tree_char_reverse = {}
      for k,v in pairs(self.tree_char) do
        self.tree_char_reverse[v] = k
      end
    end
    return self.tree_char_reverse[char]
  end

  function SkillProfiler:char_to_skill(char)
    --[[
      Function to convert a char in a skill profile to its corresponding skill.
      Returns a tuple with the format (tier, skill_index)
    --]]
    if not self.skill_char_reverse then
      self.skill_char_reverse = {}
      for tier, chars in pairs(self.skill_char) do
        for skill, c in pairs(chars) do
          self.skill_char_reverse[c] = {tier, skill}
        end
      end
    end
    return self.skill_char_reverse[char]
  end

  function SkillProfiler:debug_print(msg)
    --[[
      Function to write a message to a text file. Used for development and
      debug purposes.
    --]]
    local filepath = 'debug.log'
    local file = io.open(filepath, 'a')
    if file then
      file:write(tostring(msg) .. '\r\n')
      file:close()
      return true
    else
      return false
    end
  end

  function SkillProfiler:_iter_tree(profile)
    --[[
    Function to iterate over each skill tree in a profile.

    Args:
      profile: string describing a profile.

    Yields:
      A tuple for each skill tree, with the following format:
      (tree_number, tree_char, skills_string)
    --]]
    -- Tests to run:
    --  1. Valid string
    --  2. String with a random : added
    --  3. String ':' (empty profile)
    local tree_begin = 1
    local tree_end = string.find(profile, ':', tree_begin)
    return function()
      local tree_char = nil
      local tree = nil
      local skills_string = nil
      repeat
        if not tree_end then
          return
        end
        tree_char = profile:sub(tree_begin,tree_begin)
        tree = self:char_to_tree(tree_char)
        skills_string = profile:sub(tree_begin+1, tree_end-1)
        tree_begin = tree_end + 1
        tree_end = string.find(profile, ':', tree_begin)
      until(tree)
      return tree, tree_char, skills_string
    end
  end

  function SkillProfiler:_iter_skills(skills_string)
    --[[
    Function to iterate over each skill in a skills string.

    Args:
      skills_string: String describing the skills, as returned by _iter_tree

    Yields:
      A tuple for each skill, with the following format:
      (skill_char, skill_tier, skill_index, (bool)skill_aced)
    --]]
    local skill_array = {}
    for i=1,#skills_string do
      skill_array[#skill_array+1] = skills_string:sub(i,i)
    end
    table.sort(skill_array,
      function(e1, e2) return string.lower(e1) < string.lower(e2) end)
    local i=0
    return function()
      local skill_char = nil
      local skill_tier = nil
      local skill_index = nil
      local skill_aced = nil
      while i < #skill_array do
        i = i+1
        skill_char = skill_array[i]
        skill_aced = string.upper(skill_char) == skill_char
        local retval = self:char_to_skill(string.lower(skill_char))
        if retval then
          skill_tier = retval[1]
          skill_index = retval[2]
          return skill_char, skill_tier, skill_index, skill_aced
        end
      end
      return
    end
  end

  function SkillProfiler:_skill_point_cost(tier, skill_aced)
    --[[
      Function to get the skill points cost of a skill.

      Args:
        tier: Tier of the skill, between 1 and 6.
        skill_aced: boolean value that indicates whether the skill is aced or not.

      Returns:
        A number indicating the skill cost. Possiblevalues are 1, 4 and 12.
    --]]
    if tier < 4 and not skill_aced then
      return 1
    elseif tier < 4 and skill_aced then
      return 4
    elseif tier > 3 and not skill_aced then
      return 4
    elseif tier > 3 and skill_aced then
      return 12
    end
  end

  function SkillProfiler:run_tests()
    --[[
      Function used in development to test certain features before moving them
      to their appropriate place.
    --]]
    return -- All done!
  end
end
