class_name TimeTracker extends Node

func _ready() -> void:
	load_initial_scene()

func load_initial_scene() -> void:
	#print("Started!")
	#print("I run first here at load_manager.gd as the autoscript under load_initial_scene()!")
	#print("--------------------------------")
	var config = ConfigFile.new()
	#print("Save result: ", save_result)  # Should print 0 (OK)
	#print("Full path: ", ProjectSettings.globalize_path("user://app_data.cfg"))
	# Check if file exists using ResourceLoader
	if not ResourceLoader.exists("user://app_config.cfg"):
		print("Config file not found, creating new one...")
		#config.save("user://app_config.cfg")
		# Set default values
		#config.set_value("rotation", "guard_factor", 1)
	var _err = config.load("user://app_config.cfg")
	var scene_path = "res://scenes/menu.tscn"  # Default
	if config.load("user://app_config.cfg") == OK:
		var saved_scene = config.get_value("app", "current_scene", "")
		if ResourceLoader.exists(saved_scene):
			print(saved_scene)
			scene_path = saved_scene
		#else:
			#print("Resource Loader didn't have the saved_scene!")
	#else:
		#print("Wasn't Okay Loading! Resulting to default menu!")
	#var current_time = Time.get_unix_time_from_system()
	#var last_exit = config.get_value("time", "last_exit", current_time)
	#print(config.get_value("time", "last_exit", current_time))
	#print(current_time)
	#if cycles > 0:
		#emit_signal("cycles_required", cycles)
		#save_time()
	get_tree().change_scene_to_file(scene_path)
	#get_tree().change_scene_to_file("res://scenes/menu.tscn")

func save_current_scene(path: String) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "current_scene", path)
	config.save("user://app_config.cfg")

func save_guard_num(num: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "guard_number", num)
	config.save("user://app_config.cfg")

func get_guard_num() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "guard_number")

func save_guard_names(names: Array) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "guard_names", names)
	config.save("user://app_config.cfg")

func get_guard_names() -> Array:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "guard_names")

func save_current_tab(tab_index: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "current_tab", tab_index)
	config.save("user://app_config.cfg")
	#print("Config file just saved tab #: " + str(tab_index))

func get_current_tab() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "current_tab", 0)

func save_pool(pool: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "pool", pool)
	config.save("user://app_config.cfg")

func get_pool() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "pool", 0)

func save_rotation_interval(interval: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "rotation_interval", interval)
	config.save("user://app_config.cfg")

func get_rotation_interval() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "rotation_interval", 0)

func save_guard_psa(count: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "guard_psa", count)
	config.save("user://app_config.cfg")

func get_guard_psa() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "guard_psa", 0)

func save_uv_index(flag: bool) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "uv_index", flag)
	config.save("user://app_config.cfg")

func get_uv_index() -> bool:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "uv_index", false)

func save_language(lang: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "language", lang)
	config.save("user://app_config.cfg")

func get_language() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("app", "language", 0)

#func is_menu_passed(query: bool) -> void:
	#var config = ConfigFile.new()
	#var _err = config.load("user://app_config.cfg")
	#config.set_value("system", "menu_passed", query)
	#config.save("user://app_config.cfg")

func save_time() -> void:
	var time_config = ConfigFile.new()
	var _time_err = time_config.load("user://time_config.cfg")
	time_config.set_value("system", "time_seconds", Time.get_time_dict_from_system()["second"])
	time_config.set_value("system", "time_minutes", Time.get_time_dict_from_system()["minute"])
	time_config.set_value("system", "time_hours", Time.get_time_dict_from_system()["hour"])
	time_config.save("user://time_config.cfg")

func save_time_break_hours(break_hours: Array) -> void:
	var time_config = ConfigFile.new()
	var _time_err = time_config.load("user://time_config.cfg")
	time_config.set_value("system", "time_break_hours", break_hours)
	time_config.save("user://time_config.cfg")

func get_time_seconds() -> int:
	var time_config = ConfigFile.new()
	var _time_err = time_config.load("user://time_config.cfg")
	return time_config.get_value("system", "time_seconds", 0)

func get_time_minutes() -> int:
	var time_config = ConfigFile.new()
	var _time_err = time_config.load("user://time_config.cfg")
	return time_config.get_value("system", "time_minutes", 0)

func get_time_hours() -> int:
	var time_config = ConfigFile.new()
	var _time_err = time_config.load("user://time_config.cfg")
	return time_config.get_value("system", "time_hours", 0)

func get_time_break_hours() -> Array:
	var time_config = ConfigFile.new()
	var _time_err = time_config.load("user://time_config.cfg")
	return time_config.get_value("system", "time_break_hours", [])

func save_rotation_details(on_stand: int, down_guards: int, guard_factor: int) -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("rotation", "on_stand", on_stand)
	config.set_value("rotation", "down_guards", down_guards)
	config.set_value("rotation", "guard_factor", guard_factor)
	print("Printing the guard_factor: " + str(guard_factor))
	#print(config.get_value("rotation", "guard_factor", 0))
	config.save("user://app_config.cfg")
	#print(config.get_value("rotation", "guard_factor", 0))

func get_rotation_on_stand() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("rotation", "on_stand", 0)

func get_rotation_down_guards() -> int:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	return config.get_value("rotation", "down_guards", 0)

func get_rotation_guard_factor() -> int:
	print("Attempted to get rotation factor")
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	print("Error loading config file: ", _err)
	print(config.load("user://app_config.cfg"))
	print(config.has_section("rotation"))
	print(config.has_section_key("rotation", "guard_factor"))
	print(config.get_value("rotation", "guard_factor", 1))
	return config.get_value("rotation", "guard_factor", 1)

func is_menu_loaded() -> bool:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	if config.load("user://app_config.cfg") == OK:
		return true
	return false

#func _notification(what) -> void:
	#match what:
		#NOTIFICATION_WM_CLOSE_REQUEST:  # Desktop app closing
			#if cycles > 0:
				#save_time()
				#print("Saving Current Time!")
				#await get_tree().process_frame
				#get_tree().quit()  # Optional: ensure game quits after saving
		#NOTIFICATION_WM_GO_BACK_REQUEST:  # Android back button
			#if cycles > 0:
				#save_time()
				#print("Saving Current Time!")
				#await get_tree().process_frame
				#get_tree().quit()  # Optional: ensure game quits after saving
		#NOTIFICATION_APPLICATION_PAUSED:  # Mobile app minimized/backgrounded
			#if OS.get_name() in ["Android", "iOS"]:
				#if cycles > 0:
					#save_time()
				#print("Saving Current Time!")
				#await get_tree().process_frame
				#get_tree().quit()  # Optional: ensure game quits after saving         
		#NOTIFICATION_APPLICATION_RESUMED:  # Mobile app returning to foreground
			#if OS.get_name() in ["Android", "iOS"]:
				#calculate_cycles_to_run()

func restore_default_values() -> void:
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	config.set_value("app", "pool", 0)
	config.set_value("app", "rotation_interval", 0)
	config.set_value("app", "guard_psa", 0)
	config.set_value("app", "language", 0)
	config.set_value("app", "uv_index", false)
	config.save("user://app_config.cfg")
