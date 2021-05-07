-- version 1.3
obs                        = obslua
next_scene_hotkey_id       = obs.OBS_INVALID_HOTKEY_ID
prev_scene_hotkey_id       = obs.OBS_INVALID_HOTKEY_ID
loop                       = false
preview                    = true

----------------------------------------------------------

function next_scene(pressed)
  if not pressed then
    return
  end
  local previewMode = false
  if preview and obs.obs_frontend_preview_program_mode_active() then
    previewMode = true
  end
  local scenes = obs.obs_frontend_get_scenes()
  local current_scene = nil
  local scene_function = nil
  if previewMode then
    current_scene = obs.obs_frontend_get_current_preview_scene()
    scene_function = obs.obs_frontend_set_current_preview_scene
  else
    current_scene = obs.obs_frontend_get_current_scene()
    scene_function = obs.obs_frontend_set_current_scene
  end
  local current_scene_name = obs.obs_source_get_name(current_scene)
  if scenes ~= nil then
    for i, scn in ipairs(scenes) do
      local loop_scene_name = obs.obs_source_get_name(scn)
      if current_scene_name == loop_scene_name then
        if scenes[i + 1] ~= nil then
          scene_function(scenes[i + 1])
          break
        elseif loop then
          scene_function(scenes[1])
          break
        end
      end
    end
  end
  obs.obs_source_release(current_scene)
  obs.source_list_release(scenes)
end

function previous_scene(pressed)
  if not pressed then
    return
  end
  local previewMode = false
  if preview and obs.obs_frontend_preview_program_mode_active() then
    previewMode = true
  end
  local scenes = obs.obs_frontend_get_scenes()
  local current_scene = nil
  local scene_function = nil
  if previewMode then
    current_scene = obs.obs_frontend_get_current_preview_scene()
    scene_function = obs.obs_frontend_set_current_preview_scene
  else
    current_scene = obs.obs_frontend_get_current_scene()
    scene_function = obs.obs_frontend_set_current_scene
  end
  local current_scene_name = obs.obs_source_get_name(current_scene)
  if scenes ~= nil then
    for i, scn in ipairs(scenes) do
      local loop_scene_name = obs.obs_source_get_name(scn)
      if current_scene_name == loop_scene_name then
        if scenes[i - 1] ~= nil then
          scene_function(scenes[i - 1])
          break
        elseif loop then
          scene_function(scenes[#scenes])
          break
        end
      end
    end
  end
  obs.obs_source_release(current_scene)
  obs.source_list_release(scenes)
end

--- Loaded on startup
function script_load(settings)
  print("Loading Next Scene script")
  --- Register hotkeys
  next_scene_hotkey_id = obs.obs_hotkey_register_frontend("next_scene.trigger", "Next Scene", next_scene)
  local next_hotkey_save_array = obs.obs_data_get_array(settings, "next_scene.trigger")
  obs.obs_hotkey_load(next_scene_hotkey_id, next_hotkey_save_array)
  obs.obs_data_array_release(next_hotkey_save_array)

  prev_scene_hotkey_id = obs.obs_hotkey_register_frontend("prev_scene.trigger", "Previous Scene", previous_scene)
  local prev_hotkey_save_array = obs.obs_data_get_array(settings, "prev_scene.trigger")
  obs.obs_hotkey_load(prev_scene_hotkey_id, prev_hotkey_save_array)
  obs.obs_data_array_release(prev_hotkey_save_array)
end

function script_save(settings)
  local next_hotkey_save_array = obs.obs_hotkey_save(next_scene_hotkey_id)
  obs.obs_data_set_array(settings, "next_scene.trigger", next_hotkey_save_array)
  obs.obs_data_array_release(next_hotkey_save_array)

  local prev_hotkey_save_array = obs.obs_hotkey_save(prev_scene_hotkey_id)
  obs.obs_data_set_array(settings, "prev_scene.trigger", prev_hotkey_save_array)
  obs.obs_data_array_release(prev_hotkey_save_array)
end

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
	local props = obs.obs_properties_create()
	obs.obs_properties_add_bool(props, "loop", "Loop Scenes List")
  obs.obs_properties_add_bool(props, "preview", "Change Preview")

	return props
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
	loop = obs.obs_data_get_bool(settings, "loop")
  preview = obs.obs_data_get_bool(settings, "preview")
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
	obs.obs_data_set_default_bool(settings, "loop", false)
  obs.obs_data_set_default_bool(settings, "preview", true)
end

-- A function named script_description returns the description shown to
-- the user
function script_description()
  return "When the \"Next Scene\" hotkey is triggered, OBS moves to the next scene in the scenes list. When the \"Previous Scene\" hotkey is triggered, OBS moves to the previous scene in the scenes list.\n\nIf \"Loop Scenes List\" is selected, then next scene and previous scene will cycle through the scenes list endlessly without stopping at the first or last scene.\n\nIf \"Change Preview\" is selected, then when in Studio Mode the hotkey will change the preview view rather than the program view."
end