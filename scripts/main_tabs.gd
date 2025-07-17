extends TabContainer

@onready var circle: PanelContainer = $Circle
@onready var pool: PanelContainer = $Pool
@onready var log: PanelContainer = $Log
@onready var settings: PanelContainer = $Settings
@onready var circle_main: Polygon2D = $Circle/CircleMargin/CircleMain
@onready var circle_outline: Polygon2D = $Circle/CircleMargin/CircleOutline

@onready var pool_option_button: OptionButton = $Settings/SettingsMargin/SettingsVBox/PoolHBox/PoolOptionButton
@onready var interval_option_button: OptionButton = $Settings/SettingsMargin/SettingsVBox/IntervalHBox/IntervalOptionButton
@onready var psa_option_button: OptionButton = $Settings/SettingsMargin/SettingsVBox/PSAHBox/PSAOptionButton
@onready var language_option_button: OptionButton = $Settings/SettingsMargin/SettingsVBox/LanguageHBox/LanguageOptionButton
@onready var reset_button: Button = $Settings/SettingsMargin/SettingsVBox/ResetHBox/ResetButton
@onready var uv_index_check_button: CheckButton = $Settings/SettingsMargin/SettingsVBox/UVIndexHBox/UVIndexCheckButton


@onready var on_stand_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/OnStandHBox/OnStandNumberLabel
@onready var up_time_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/UpTimeHBox/UpTimeNumberLabel
@onready var down_time_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/DownTimeHBox/DownTimeNumberLabel
@onready var stats_psa_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/StatsPSAHBox/StatsPSANumberLabel

@onready var pool_label: Label = $Pool/PoolMargin/PoolVBox/PoolLabel
@onready var pool_display: TextureRect = $Pool/PoolMargin/PoolVBox/PoolDisplay
@onready var positions_v_box: VBoxContainer = $Pool/PoolMargin/PoolVBox/ScrollContainer/PositionsVBox

@export var time_tracker: TimeTracker

var rotation_duration: float = 1.0  # Seconds per full rotation
var circle_offset: Vector2 = Vector2(87.0, 97.0)
var is_rotating: bool = false
var target_rotation: float = 0.0
var active_tween: Tween = null

#Guard Rotation Cycle Variables!
var on_stand_number: int
var guard_rotate_factor: int = 1


var cycle_degree: int = 5
#var cycle_start: bool = false
var last_cycle_switch: int = -1
#var time_minutes: int

func _on_cycles_required(cycle_count: int):
	for i in range(cycle_count):
		update_cycle()

func _ready() -> void:
	if time_tracker:
		time_tracker.cycles_required.connect(_on_cycles_required)
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	current_tab = LoadManager.get_current_tab()
	print(current_tab)
	var pool : int = LoadManager.get_pool()
	var buddies : Array = LoadManager.get_guard_names()
	pool_option_button.select(pool)
	var interval_selection : int = LoadManager.get_rotation_interval()
	var psa_selection : int = LoadManager.get_guard_psa()
	interval_option_button.select(interval_selection)
	psa_option_button.select(psa_selection)
	language_option_button.select(LoadManager.get_language())
	uv_index_check_button.button_pressed = LoadManager.get_uv_index()
	var stands : int = LoadManager.get_rotation_on_stand()
	var breaking : int = LoadManager.get_rotation_down_guards()
	var replace_factor : int = LoadManager.get_rotation_guard_factor()
	if pool == 0:
		pool_label.text = "San Pedro Springs Pool"
		pool_display.texture = load("res://icons/pools/san_pedro/san_pedro.png")
	elif pool == 1:
		pool_label.text = "Lady Bird Johnson Pool"
		pool_display.texture = load("res://icons/pools/lbj/lbj.png")
	# Here's The Most Important One Probably!
	calculate_rotation_details(buddies, interval_selection, psa_selection)
	# ---------------------------------------
	calculate_pool_tab_labels(buddies, stands, psa_selection)
	print(replace_factor)
	calculate_circle_tab_labels(buddies, stands, breaking, replace_factor, interval_selection, psa_selection)
	#var err = config.load("user://app_config.cfg")
	#match err:
		#OK: print("Loaded successfully")
		#ERR_FILE_NOT_FOUND: print("File missing, creating new one")
		#ERR_FILE_CANT_OPEN:
			#printerr("Failed to open file (corrupted/locked?)")
			#reset_config() # Recreate file
		#_: printerr("Unknown error: ", err)
	if config.load("user://app_config.cfg") == OK:
	#if true:
		var points2 = []
		var points3 = []
		var radius2 = 70
		var radius3 = 80
		var sides = LoadManager.get_guard_num()
		print("Sides: " + str(sides))
		for i in range(sides):
			var angle: float = (i * (2 * PI / sides)) - (PI / 2)
			points2.append(Vector2(cos(angle), sin(angle)) * radius2)
			points3.append(Vector2(cos(angle), sin(angle)) * radius3)
		circle_main.polygon = points2
		circle_outline.polygon = points3
		circle_main.color = Color("#6affff")
		circle_outline.color = Color("#cccccc")
		circle_main.position = circle_offset
		circle_outline.position = circle_offset
	var guard_list = buddies
	print(buddies)
	for name in guard_list:
		var new_label = Label.new()
		var new_label2 = Label.new()
		new_label.text = " " + str(name) + " "
		new_label2.text = " " + str(guard_list.find(name) + 1) + " "
		new_label.add_theme_font_size_override("font_size", 5)
		new_label2.add_theme_font_size_override("font_size", 5)
		new_label.add_theme_color_override("font_color", Color("000000"))
		new_label2.add_theme_color_override("font_color", Color("000000"))
		var font = new_label.get_theme_default_font()
		var font2 = new_label2.get_theme_default_font()
		var string_size = font.get_string_size(new_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, new_label.get_theme_font_size("font_size"))
		var string_size2 = font.get_string_size(new_label2.text, HORIZONTAL_ALIGNMENT_LEFT, -1, new_label2.get_theme_font_size("font_size"))
		var center_offset = Vector2(string_size.x / 2, font.get_ascent())
		var center_offset2 = Vector2(string_size2.x / 2, font2.get_ascent())
		print(circle_main.polygon)
		new_label.position = circle_main.polygon[guard_list.find(name)] - center_offset + Vector2(-2.0, 10.5)
		new_label2.position = circle_outline.polygon[guard_list.find(name)] - center_offset + Vector2(-2.0, 10.5)
		#print(circle_main.polygon)
		#print(circle_main.polygon[guard_list.find(name)])
		#print(new_label.position)
		#print(guard_list.size())
		var background = StyleBoxFlat.new()
		var background2 = StyleBoxFlat.new()
		background.bg_color = Color("ffff00")  # RGB color (yellow)
		if guard_list.find(name) < stands:
			background2.bg_color = Color("ff0000")  # RGB color (red)
		elif guard_list.find(name) < stands + psa_selection:
			background2.bg_color = Color("ff00ff")  # RGB color (magenta)
		else:
			background2.bg_color = Color("00ff00")  # RGB color (green)
		background.corner_radius_bottom_left = 2
		background.corner_radius_bottom_right = 2
		background.corner_radius_top_left = 2
		background.corner_radius_top_right = 2
		background2.corner_radius_bottom_left = 2
		background2.corner_radius_bottom_right = 2
		background2.corner_radius_top_left = 2
		background2.corner_radius_top_right = 2
		new_label.add_theme_stylebox_override("normal", background)
		new_label2.add_theme_stylebox_override("normal", background2)
		new_label.scale = Vector2(2.0, 2.0)
		new_label2.scale = Vector2(2.0, 2.0)
		circle_main.add_child(new_label)
		circle_outline.add_child(new_label2)
	#cycle_start = true

func calculate_pool_tab_labels(names: Array, stands: int, psa_selection: int) -> void:
	#Big Daddy Stand Count Label Code Up Next!
	if positions_v_box.get_child_count() < 2:
		for i in range(stands):
			var hbox = HBoxContainer.new()
			hbox.name = "Stand" + str(i + 1) + "HBox"
			var label1 = Label.new()
			label1.name = "Stand" + str(i + 1) + "Label"
			label1.text = "Stand " + str(i + 1)
			label1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label1.add_theme_color_override("font_color", Color("ff0000"))
			var label2 = Label.new()
			label2.name = "Guard" + str(i + 1) + "Label"
			label2.text = " " + names[i] + " "
			label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hbox.add_child(label1)
			hbox.add_child(label2)
			positions_v_box.add_child(hbox)
		for i in range(psa_selection):
			var hbox = HBoxContainer.new()
			hbox.name = "Stand" + str(i + 1) + "HBox"
			var label1 = Label.new()
			label1.name = "Stand" + str(stands + i + 1) + "Label"
			label1.text = "Stand " + str(stands + i + 1) + " (PSA)"
			label1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label1.add_theme_color_override("font_color", Color("ff00ff"))
			var label2 = Label.new()
			label2.name = "Guard" + str(stands + i + 1) + "Label"
			label2.text = " " + names[stands + i] + " "
			label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hbox.add_child(label1)
			hbox.add_child(label2)
			positions_v_box.add_child(hbox)
	else:
		var result : Array = []
		for child in positions_v_box.get_children():
			# Get all children of this child node
			var grandchildren = child.get_children()
			# Add every 2nd grandchild (indexes 1, 3, 5...)
			for i in range(1, grandchildren.size(), 2):
				#grandchildren[i].text = " " + names[i] + " "
				result.append(grandchildren[i])
		for i in result.size():
			result[i].text = " " + names[i] + " "
		#print(result)

func calculate_circle_tab_labels(names: Array, stands: int, breaking: int, replace_factor: int, interval_selection: int, psa_selection: int) -> void:
	#if replace_factor == 0:
		#replace_factor = 1
	interval_selection = (interval_selection * 5) + 15
	on_stand_number_label.text = " " + str(stands) + " "
	on_stand_number_label.add_theme_color_override("font_color", Color("ffff00"))
	if (stands + psa_selection) % replace_factor != 0:
		up_time_number_label.text = " " + str(floori(float(interval_selection) * float(stands) / float(replace_factor))) + " - " + str(ceili(float(interval_selection) * float(stands) / float(replace_factor))) + " "
	else:
		up_time_number_label.text = " " + str(interval_selection * (stands) / replace_factor) + " "
	up_time_number_label.add_theme_color_override("font_color", Color("ff0000"))
	if breaking % replace_factor != 0:
		down_time_number_label.text = " " + str(floori(float(interval_selection) * float(breaking) / float(replace_factor))) + " - " + str(ceili(float(interval_selection) * float(breaking) / float(replace_factor))) + " "
	else:
		down_time_number_label.text = " " + str(interval_selection * breaking / replace_factor) + " "
	down_time_number_label.add_theme_color_override("font_color", Color("00ff00"))
	stats_psa_number_label.text = " " + str(psa_selection) + " "
	stats_psa_number_label.add_theme_color_override("font_color", Color("ff00ff"))

func calculate_rotation_details(names: Array, intervals: int, psas: int) -> void:
	var on_stand_max : int = 1
	var guards_up : int = 1
	var guards_down : int = 1
	var guard_rate : int = 1
	if intervals == 0:
		on_stand_max = 4
		if names.size() == 4:
			guard_rate = 1
			guards_up = 3 - psas
			guards_down = 4 - guards_up - psas
		elif names.size() == 5:
			guard_rate = 1
			guards_up = 4 - psas
			guards_down = 5 - guards_up - psas
		elif names.size() == 6:
			pass
		elif names.size() == 7:
			pass
		elif names.size() == 8:
			pass
		elif names.size() == 9:
			pass
		elif names.size() == 10:
			pass
		elif names.size() == 11:
			pass
		elif names.size() == 12:
			pass
		elif names.size() == 13:
			pass
		elif names.size() == 14:
			pass
		elif names.size() == 15:
			pass
		elif names.size() == 16:
			pass
		elif names.size() == 17:
			pass
		elif names.size() == 18:
			pass
		elif names.size() == 19:
			pass
		elif names.size() == 20:
			pass
		elif names.size() == 21:
			pass
		elif names.size() == 22:
			pass
		elif names.size() == 23:
			pass
		elif names.size() == 24:
			pass
		else:
			pass
		LoadManager.save_rotation_details(guards_up, guards_down, guard_rate)
	else:
		on_stand_max = 3
		if names.size() == 4:
			pass
		elif names.size() == 5:
			pass
		elif names.size() == 6:
			pass
		elif names.size() == 7:
			pass
		elif names.size() == 8:
			pass
		elif names.size() == 9:
			pass
		elif names.size() == 10:
			pass
		elif names.size() == 11:
			pass
		elif names.size() == 12:
			pass
		elif names.size() == 13:
			pass
		elif names.size() == 14:
			pass
		elif names.size() == 15:
			pass
		elif names.size() == 16:
			pass
		elif names.size() == 17:
			pass
		elif names.size() == 18:
			pass
		elif names.size() == 19:
			pass
		elif names.size() == 20:
			pass
		elif names.size() == 21:
			pass
		elif names.size() == 22:
			pass
		elif names.size() == 23:
			pass
		elif names.size() == 24:
			pass
		else:
			pass

func _process(_delta: float) -> void:
	#if cycle_start:
		var time_minutes = Time.get_time_dict_from_system()["second"]
		#print(time_minutes % 15)
		if time_minutes % cycle_degree == 0 && time_minutes != last_cycle_switch:
			update_cycle()

func update_cycle() -> void:
	#print("Cycle Fired!")
	last_cycle_switch = Time.get_time_dict_from_system()["second"]
	if is_rotating:
		return  # Prevent overlapping rotations
	is_rotating = true
	var buddies : Array = LoadManager.get_guard_names()
	var stands : int = LoadManager.get_rotation_on_stand()
	var psa_selection : int = LoadManager.get_guard_psa()
	#var first_item = buddies.pop_front()  # Remove and get first element
	#buddies.append(first_item)  # Add it to the end
	var last_item = buddies.pop_back()  # Remove & get the last element
	buddies.push_front(last_item)       # Insert it at the front
	LoadManager.save_guard_names(buddies)
	calculate_pool_tab_labels(buddies, stands, psa_selection)
	#set_process_input(false)
	#circle_main_control.rotation = -circle_main.rotation  # Counter-rotate
	target_rotation += rad_to_deg((2 * PI / circle_main.polygon.size()))  # Increment by size degrees
	var tween = create_tween().bind_node(circle_main)
	# Smooth rotation animation
	tween.set_parallel(true)
	tween.tween_property(circle_main, "rotation_degrees", target_rotation, rotation_duration)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_method(update_label_positions, 0.0, 1.0, rotation_duration)
	# When complete, allow new triggers
	tween.tween_callback(func(): 
		is_rotating = false
		# Reset rotation if needed (for consecutive triggers)
		if circle_main.rotation_degrees >= 360:
			circle_main.rotation_degrees -= 360
		# Normalize rotation to prevent large numbers
		if target_rotation >= 360:
			target_rotation -= 360
		circle_main.rotation_degrees = snappedf(circle_main.rotation_degrees, rad_to_deg((2 * PI / circle_main.polygon.size())))
		#update_label_positions(1.0)  # Final position update
		#active_tween = null
		)

func update_label_positions(progress: float):
	pass

func _on_restart_button_button_up() -> void:
	LoadManager.save_current_scene("res://scenes/menu.tscn")
	await LoadManager.restore_default_values()
	pool_option_button.select(LoadManager.get_pool())
	interval_option_button.select(LoadManager.get_rotation_interval())
	psa_option_button.select(LoadManager.get_guard_psa())
	language_option_button.select(LoadManager.get_language())
	uv_index_check_button.button_pressed = LoadManager.get_uv_index()
	var pool : int = LoadManager.get_pool()
	if pool == 0:
		pool_label.text = "San Pedro Springs Pool"
		pool_display.texture = load("res://icons/pools/san_pedro/san_pedro.png")
	elif pool == 1:
		pool_label.text = "Lady Bird Johnson Pool"
		pool_display.texture = load("res://icons/pools/lbj/lbj.png")
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_reset_button_button_up() -> void:
	await LoadManager.restore_default_values()
	pool_option_button.select(LoadManager.get_pool())
	interval_option_button.select(LoadManager.get_rotation_interval())
	psa_option_button.select(LoadManager.get_guard_psa())
	language_option_button.select(LoadManager.get_language())
	uv_index_check_button.button_pressed = LoadManager.get_uv_index()
	var pool : int = LoadManager.get_pool()
	if pool == 0:
		pool_label.text = "San Pedro Springs Pool"
		pool_display.texture = load("res://icons/pools/san_pedro/san_pedro.png")
	elif pool == 1:
		pool_label.text = "Lady Bird Johnson Pool"
		pool_display.texture = load("res://icons/pools/lbj/lbj.png")
	var buddies : Array = LoadManager.get_guard_names()
	var stands : int = LoadManager.get_rotation_on_stand()
	var breaking : int = LoadManager.get_rotation_down_guards()
	var replace_factor : int = LoadManager.get_rotation_guard_factor()
	var interval_selection : int = LoadManager.get_rotation_interval()
	var psa_selection : int = LoadManager.get_guard_psa()
	calculate_rotation_details(buddies, interval_selection, psa_selection)
	calculate_circle_tab_labels(buddies, stands, breaking, replace_factor, interval_selection, psa_selection)

func _on_pool_option_button_item_selected(index: int) -> void:
	LoadManager.save_pool(index)
	var pool : int = LoadManager.get_pool()
	if pool == 0:
		pool_label.text = "San Pedro Springs Pool"
		pool_display.texture = load("res://icons/pools/san_pedro/san_pedro.png")
	elif pool == 1:
		pool_label.text = "Lady Bird Johnson Pool"
		pool_display.texture = load("res://icons/pools/lbj/lbj.png")

func _on_interval_option_button_item_selected(index: int) -> void:
	LoadManager.save_rotation_interval(index)

func _on_psa_option_button_item_selected(index: int) -> void:
	LoadManager.save_guard_psa(index)
	var buddies : Array = LoadManager.get_guard_names()
	var stands : int = LoadManager.get_rotation_on_stand()
	var breaking : int = LoadManager.get_rotation_down_guards()
	var replace_factor : int = LoadManager.get_rotation_guard_factor()
	var interval_selection : int = LoadManager.get_rotation_interval()
	var psa_selection : int = LoadManager.get_guard_psa()
	calculate_rotation_details(buddies, interval_selection, psa_selection)
	calculate_circle_tab_labels(buddies, stands, breaking, replace_factor, interval_selection, psa_selection)

func _on_language_option_button_item_selected(index: int) -> void:
	LoadManager.save_language(index)

func _on_tab_changed(tab: int) -> void:
	print("Tab Changed!")
	LoadManager.save_current_tab(tab)
	print(tab)

func _on_uv_index_check_button_toggled(toggled_on: bool) -> void:
	LoadManager.save_uv_index(toggled_on)
