extends TabContainer

@onready var circle: PanelContainer = $Circle
@onready var pool: PanelContainer = $Pool
@onready var log: PanelContainer = $Log
@onready var settings: PanelContainer = $Settings
@onready var circle_main: Polygon2D = $Circle/CircleMargin/CircleMain
@onready var circle_outline: Polygon2D = $Circle/CircleMargin/CircleOutline

@onready var pool_option_button: OptionButton = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/PoolHBox/PoolOptionButton
@onready var interval_option_button: OptionButton = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/IntervalHBox/IntervalOptionButton
@onready var psa_option_button: OptionButton = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/PSAHBox/PSAOptionButton
@onready var language_option_button: OptionButton = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/LanguageHBox/LanguageOptionButton
@onready var reset_button: Button = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/ResetHBox/PlaceholderMargin/ResetButton
@onready var uv_index_check_button: CheckButton = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/UVIndexHBox/UVIndexCheckButton
@onready var force_cycle_button: Button = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/ForceCycleHBox/ForceCycleButton
@onready var rotation_lock_check_button: CheckButton = $Settings/SettingsMargin/ScrollContainer/SettingsVBox/RotationLockHBox/RotationLockCheckButton

@onready var on_stand_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/OnStandHBox/OnStandNumberLabel
@onready var up_time_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/UpTimeHBox/UpTimeNumberLabel
@onready var down_time_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/DownTimeHBox/DownTimeNumberLabel
@onready var stats_psa_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/StatsPSAHBox/StatsPSANumberLabel
@onready var rate_number_label: Label = $Circle/CircleMargin/StatsMargin/ScrollContainer/StatsVBox/RateHBox/RateNumberLabel

@onready var pool_label: Label = $Pool/PoolMargin/PoolVBox/PoolLabel
@onready var pool_display: TextureRect = $Pool/PoolMargin/PoolVBox/PoolDisplay
@onready var positions_v_box: VBoxContainer = $Pool/PoolMargin/PoolVBox/ScrollContainer/PositionsVBox

@onready var next_shift_label: Label = $Log/LogMargin/ScrollContainer/LogVBox/NextShiftHBox/NextShiftTextureProgressBar/NextShiftLabel
@onready var next_shift_texture_progress_bar: TextureProgressBar = $Log/LogMargin/ScrollContainer/LogVBox/NextShiftHBox/NextShiftTextureProgressBar
#@onready var test_texture_rect: TextureRect = $Log/LogMargin/ScrollContainer/LogVBox/TestTextureRect
@onready var last_log_label: Label = $Log/LogMargin/ScrollContainer/LogVBox/LastLogHBox/LastLogLabel

@onready var lock_image: Sprite2D = $Circle/LockImage

var gradient = Gradient.new()
var gradient_texture = GradientTexture1D.new()
var interval_for_calculations: int

#@export var time_tracker: TimeTracker

var rotation_duration: float = 0.5  # Seconds per full rotation
var circle_offset: Vector2 = Vector2(88.0, 97.0)
#var is_rotating: bool = false
var target_rotation: float = 0.0
var active_tween: Tween = null

#Guard Rotation Cycle Variables!
var on_stand_number: int
var guard_rotate_factor: int = 1


#var cycle_degree: int = 2
#var cycle_start: bool = false
#var last_cycle_switch: int = -1
#var time_minutes: int

#@onready var IntervalSelection : int = LoadManager.get_rotation_interval()

#func _on_cycles_required(cycle_count: int):
	#for i in range(cycle_count):
		#update_cycle()
		#print("I received request " + str(i + 1) + " to update a cycle!")

func _ready() -> void:
	# Add colors with explicit offsets
	gradient.colors = [Color("00ff00"), Color("ffff00"), Color("ff0000")]  # Explicit array
	gradient.offsets = [0.0, 0.5, 1.0]  # Must match colors array length
	# Assign gradient to the texture
	gradient_texture.gradient = gradient
	#var width : int = 156
	#var height : int = 247
	#var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	# Fill each pixel column with the gradient color
	#for x in width:
		#var progress = float(x) / (width - 1)  # Normalize to 0.0–1.0
		#var color = gradient.sample(progress)
		#for y in height:  # Fill the entire column (for a horizontal gradient)
			#image.set_pixel(x, y, color)
	#test_texture_rect.texture = ImageTexture.create_from_image(image)
	#if time_tracker:
		#time_tracker.cycles_required.connect(_on_cycles_required)
	#var time_config = ConfigFile.new()
	#var _time_err = time_config.load("user://time_config.cfg")
	#if not ResourceLoader.exists("user://time_config.cfg"):
		#print("Time Config file not found, creating new one...")
		# Set default values
		#config.set_value("rotation", "guard_factor", 1)
		#time_config.save("user://time_config.cfg")
	var config = ConfigFile.new()
	var _err = config.load("user://app_config.cfg")
	current_tab = LoadManager.get_current_tab()
	#print(current_tab)
	var pool : int = LoadManager.get_pool()
	var buddies : Array = LoadManager.get_guard_names()
	pool_option_button.select(pool)
	var psa_selection : int = LoadManager.get_guard_psa()
	var interval_selection : int = LoadManager.get_rotation_interval()
	interval_for_calculations = interval_selection
	interval_option_button.select(interval_selection)
	psa_option_button.select(psa_selection)
	language_option_button.select(LoadManager.get_language())
	uv_index_check_button.button_pressed = LoadManager.get_uv_index()
	rotation_lock_check_button.button_pressed = LoadManager.get_rotation_lock()
	lock_image.visible = rotation_lock_check_button.button_pressed
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
	#print(replace_factor)
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
		#print("Sides: " + str(sides))
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
	#print(buddies)
	for name in guard_list:
		var new_label = Label.new()
		var new_label2 = Label.new()
		new_label.text = " " + str(name) + " "
		new_label2.text = " " + str(guard_list.find(name) + 1) + " "
		new_label.add_theme_font_size_override("font_size", 5)
		new_label2.add_theme_font_size_override("font_size", 5)
		new_label.add_theme_color_override("font_color", Color("000000"))
		new_label2.add_theme_color_override("font_color", Color("000000"))
		#var font = new_label.get_theme_default_font()
		#var font2 = new_label2.get_theme_default_font()
		#var string_size = font.get_string_size(new_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, new_label.get_theme_font_size("font_size"))
		#var string_size2 = font2.get_string_size(new_label2.text, HORIZONTAL_ALIGNMENT_LEFT, -1, new_label2.get_theme_font_size("font_size"))
		#var center_offset = Vector2(string_size.x / 2, font.get_ascent())
		#var center_offset2 = Vector2(string_size2.x / 2, font2.get_ascent())
		#print(circle_main.polygon)
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
		#print("New Label Size: " + str(new_label.size))
		#new_label.position -= new_label.size * 0.5
		circle_main.add_child(new_label)
		circle_outline.add_child(new_label2)
		new_label.position = circle_main.polygon[guard_list.find(name)]# - new_label.size# - center_offset# + Vector2(-2.0, 10.5)
		new_label2.position = circle_outline.polygon[guard_list.find(name)]# - new_label2.size# - center_offset# + Vector2(-2.0, 10.5)
		new_label.position -= new_label.size * 0.5
		new_label2.position -= new_label2.size * 0.5
		new_label.pivot_offset += new_label.size * 0.5
		new_label2.pivot_offset += new_label2.size * 0.5
		#print("New Label Size: " + str(new_label.size))
	#cycle_start = true
	# At the end of your _ready() function:
	#var rotating_labels = circle_main.get_children()
	#var numbered_labels = circle_outline.get_children()
	#apply_shader_to_rotating_labels(rotating_labels, numbered_labels)
	var minutes: int = LoadManager.get_time_minutes()
	var hours: int = LoadManager.get_time_hours()
	var break_hours: Array = LoadManager.get_time_break_hours()
	run_cycles(hours, minutes, break_hours)
	#minutes = minutes - (minutes % (5 * interval_for_calculations + 15))
	#var minutes_zero: String = ""
	#if minutes < 10:
		#minutes_zero = "0"
	#last_log_label.text = "Last log time: " + str(hours) + ":" + minutes_zero + str(minutes) + " "

func run_cycles(hours: int, minutes: int, break_hours: Array) -> void:
	var current_minutes: int = Time.get_time_dict_from_system()["minute"]
	var current_hours: int = Time.get_time_dict_from_system()["hour"]
	var rotation_value: int = 15
	if interval_for_calculations == 0:
		rotation_value = 15
	else:
		rotation_value = 20
	# Put the cycle calculation logic here
	print("Saved Hours: " + str(hours))
	print("Saved Minutes: " + str(minutes))
	print("Current Hours: " + str(current_hours))
	print("Current Minutes: " + str(current_minutes))
	var running_index: int = ((60 * current_hours + current_minutes) - (60 * hours + (minutes - (minutes % rotation_value)))) / rotation_value
	var some_array: Array = LoadManager.get_time_break_hours()
	for item in some_array:
		if 60 * int(item) < (60 * current_hours + current_minutes) && 60 * int(item) > (60 * hours + (minutes - (minutes % rotation_value))):
			running_index -= 1
			print("Subtracted 1 from the running_index!")
	print("Time Difference: " + str(((60 * current_hours + current_minutes) - (60 * hours + (minutes - (minutes % rotation_value))))))
	print("Running Index: " + str(running_index))
	for i in range(running_index):
		if !rotation_lock_check_button.button_pressed:
			update_cycle()

func calculate_pool_tab_labels(names: Array, stands: int, psa_selection: int) -> void:
	#Big Daddy Stand Count Label Code Up Next!
	if positions_v_box.get_child_count() < 2:
		for i in range(stands):
			var hbox = HBoxContainer.new()
			hbox.name = "Stand" + str(i + 1) + "HBox"
			var label1 = Label.new()
			label1.name = "Stand" + str(i + 1) + "Label"
			label1.text = " Stand " + str(i + 1) + " (Up) "
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
			hbox.name = "Stand" + str(stands + i + 1) + "HBox"
			var label1 = Label.new()
			label1.name = "Area" + str(stands + i + 1) + "Label"
			label1.text = " Area " + str(stands + i + 1) + " (PSA) "
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
		for i in range(names.size() - psa_selection - stands):
			var hbox = HBoxContainer.new()
			hbox.name = "Stand" + str(psa_selection + stands + i + 1) + "HBox"
			var label1 = Label.new()
			label1.name = "Spot" + str(psa_selection + stands + i + 1) + "Label"
			label1.text = " Spot " + str(psa_selection + stands + i + 1) + " (Down) "
			label1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label1.add_theme_color_override("font_color", Color("00ff00"))
			var label2 = Label.new()
			label2.name = "Guard" + str(psa_selection + stands + i + 1) + "Label"
			label2.text = " " + names[psa_selection + stands + i] + " "
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
	if stands % replace_factor != 0:
		up_time_number_label.text = " " + str(interval_selection * floori(float(stands) / float(replace_factor))) + " - " + str(interval_selection * ceili(float(stands) / float(replace_factor))) + " "
		#up_time_number_label.text = " " + str() + " - " + str() + " "
	else:
		up_time_number_label.text = " " + str(interval_selection * stands / replace_factor) + " "
	up_time_number_label.add_theme_color_override("font_color", Color("ff0000"))
	if breaking % replace_factor != 0:
		down_time_number_label.text = " " + str(interval_selection * floori(float(breaking) / float(replace_factor))) + " - " + str(interval_selection * ceili(float(breaking) / float(replace_factor))) + " "
	else:
		down_time_number_label.text = " " + str(interval_selection * breaking / replace_factor) + " "
	down_time_number_label.add_theme_color_override("font_color", Color("00ff00"))
	if psa_selection % replace_factor != 0:
		stats_psa_number_label.text = " " + str(interval_selection * floori(float(psa_selection) / float(replace_factor))) + " - " + str(interval_selection * ceili(float(psa_selection) / float(replace_factor))) + " "
	else:
		stats_psa_number_label.text = " " + str(interval_selection * psa_selection / replace_factor) + " "
	stats_psa_number_label.add_theme_color_override("font_color", Color("ff00ff"))
	rate_number_label.text = " " + str(replace_factor) + " "

func calculate_rotation_details(names: Array, intervals: int, psas: int) -> void:
	var on_stand_max : int = 1
	var guards_up : int = 1
	var guards_down : int = 1
	var guard_rate : int = 1
	if intervals == 0:
		on_stand_max = 4
		if names.size() == 4:
			if psas == 0:
				guard_rate = 1
				guards_up = 3
				guards_down = 1
			elif psas == 1:
				guard_rate = 1
				guards_up = 3
				guards_down = 0
			else:
				guard_rate = 1
				guards_up = 2
				guards_down = 0
		elif names.size() == 5:
			if psas == 0:
				guard_rate = 1
				guards_up = 4
				guards_down = 1
			elif psas == 1:
				guard_rate = 1
				guards_up = 4
				guards_down = 0
			else:
				guard_rate = 1
				guards_up = 3
				guards_down = 0
		elif names.size() == 6:
			if psas == 0:
				guard_rate = 1
				guards_up = 4
				guards_down = 2
			elif psas == 1:
				guard_rate = 1
				guards_up = 4
				guards_down = 1
			else:
				guard_rate = 1
				guards_up = 4
				guards_down = 0
		elif names.size() == 7:
			if psas == 0:
				guard_rate = 2
				guards_up = 5
				guards_down = 2
			elif psas == 1:
				guard_rate = 1
				guards_up = 4
				guards_down = 2
			else:
				guard_rate = 1
				guards_up = 4
				guards_down = 1
		elif names.size() == 8:
			if psas == 0:
				guard_rate = 2
				guards_up = 6
				guards_down = 2
			elif psas == 1:
				guard_rate = 2
				guards_up = 5
				guards_down = 2
			else:
				guard_rate = 1
				guards_up = 4
				guards_down = 2
				# Or rate 2, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
		elif names.size() == 9:
			if psas == 0:
				guard_rate = 2
				guards_up = 7
				guards_down = 2
			elif psas == 1:
				guard_rate = 2
				guards_up = 6
				guards_down = 2
			else:
				guard_rate = 2
				guards_up = 5
				guards_down = 2
		elif names.size() == 10:
			if psas == 0:
				guard_rate = 2
				guards_up = 8
				guards_down = 2
			elif psas == 1:
				guard_rate = 2
				guards_up = 7
				guards_down = 2
			else:
				guard_rate = 2
				guards_up = 6
				guards_down = 2
		elif names.size() == 11:
			if psas == 0:
				guard_rate = 2
				guards_up = 8
				guards_down = 3
			elif psas == 1:
				guard_rate = 2
				guards_up = 8
				guards_down = 2
			else:
				guard_rate = 2
				guards_up = 7
				guards_down = 2
		elif names.size() == 12:
			if psas == 0:
				guard_rate = 2
				guards_up = 8
				guards_down = 4
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 3, everything else the same (But it would be MAD confusing!) Also gives some guards only 15 off
			elif psas == 1:
				guard_rate = 2
				guards_up = 8
				guards_down = 3
				# Or rate 3, everything else the same (But it would be MAD confusing!) Also gives some guards only 15 off
			else:
				guard_rate = 2
				guards_up = 8
				guards_down = 2
				# Or rate 3, everything else the same (But it would be MAD confusing!) Also gives some guards only 15 off
		elif names.size() == 13:
			if psas == 0:
				guard_rate = 2
				guards_up = 8
				guards_down = 5
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 3, everything else the same (But it would be MAD confusing!) Also gives some guards only 15 off
			elif psas == 1:
				guard_rate = 2
				guards_up = 8
				guards_down = 4
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 3, everything else the same (But it would be MAD confusing!) Also gives some guards only 15 off
			else:
				guard_rate = 2
				guards_up = 8
				guards_down = 3
				# Or rate 3, everything else the same (But it would be MAD confusing!) Also gives some guards only 15 off
		elif names.size() == 14:
			if psas == 0:
				guard_rate = 2
				guards_up = 8
				guards_down = 6
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 3, everything else the same (But it would be a little confusing because 2 goes in evenly)
			elif psas == 1:
				guard_rate = 2
				guards_up = 8
				guards_down = 5
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 3, everything else the same (But it would be a little confusing because 2 goes in evenly)
			else:
				guard_rate = 2
				guards_up = 8
				guards_down = 4
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 3, everything else the same (But it would be MAD confusing!) Also gives some guards only 15 off
		elif names.size() == 15:
			if psas == 0:
				guard_rate = 3
				guards_up = 8
				guards_down = 7
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 2, everything else the same (But it would be a little confusing because 3 goes in evenly)
			elif psas == 1:
				guard_rate = 3
				guards_up = 8
				guards_down = 6
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 2, everything else the same (But it would be a little confusing because 3 goes in evenly)
			else:
				guard_rate = 3
				guards_up = 8
				guards_down = 5
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives guards only 15 off)
				# Or rate 2, everything else the same (But it would be a little confusing because 3 goes in evenly)
		elif names.size() == 16:
			if psas == 0:
				guard_rate = 4
				guards_up = 8
				guards_down = 8
				# Or rate 2, everything else the same (For good UV, if guards want 60 off instead of 30 off)
				# Or rate 3, everything else the same (But it would be a little confusing because 4 goes in evenly)
			elif psas == 1:
				guard_rate = 2
				guards_up = 8
				guards_down = 7
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives some guards only 15 off-ish becuse two have 15 at PSA)
				# Or rate 3, everything else the same (But it would be a little confusing because 2 goes in evenly)
			else:
				guard_rate = 2
				guards_up = 8
				guards_down = 6
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives some guards only 15 off-ish becuse two have 15 at PSA)
				# Or rate 3, everything else the same (But it would be a little confusing because 2 goes in evenly)
		elif names.size() == 17:
			if psas == 0:
				guard_rate = 3
				guards_up = 8
				guards_down = 9
				# Or rate 2, everything else the same (For good UV, if guards want 60-75 off instead of 45 off)
				# Or rate 4, everything else the same (But it would be a little confusing because 1/4 of a group carries over instead of 2/3)
			elif psas == 1:
				guard_rate = 4
				guards_up = 8
				guards_down = 8
				# Or rate 2, everything else the same (For good UV, normally not good because it gives guards an extremely long period of time, 60 on / 60 off)
				# Or rate 3, everything else the same (But it would be a little confusing because the up and down guards are both % 4 == 0)
			else:
				guard_rate = 2
				guards_up = 8
				guards_down = 7
				# Or rate 4, everything else the same (For bad UV, normally not good because it gives some guards only 15 off-ish becuse two have 15 at PSA)
				# Or rate 3, everything else the same (But it would be a little confusing because 2 goes into the guards_up evenly)
		elif names.size() == 18:
			if psas == 0:
				guard_rate = 3
				guards_up = 8
				guards_down = 10
				# Or rate 2, everything else the same (For good UV, if guards want 75 off instead of 45-60 off)
				# Or rate 4, everything else the same (But it would be a little confusing because 3 goes in evenly)
			elif psas == 1:
				guard_rate = 3
				guards_up = 8
				guards_down = 9
				# Or rate 2, everything else the same (For good UV, normally not good because it gives guards an extremely long period of time, 60 on / 60-75 off)
				# Or rate 4, everything else the same (But it would be a little confusing because 3 goes in evenly)
			else:
				guard_rate = 3
				guards_up = 8
				guards_down = 8
				# Or rate 2, everything else the same (For bad UV, normally not good because it gives guards an extremely long period of time, 60 on / 60 off)
				# Or rate 4, everything else the same (But it would be a little confusing because 1 would carry over on an even shift where 2 could)
		elif names.size() == 19:
			if psas == 0:
				guard_rate = 4
				guards_up = 8
				guards_down = 11
				# Or rate 2, everything else the same (For good UV, if guards want 75-90 off instead of 30-45 off)
				# Or rate 3, everything else the same (But it would be a little confusing because 4 goes in evenly to the guards_up and there would be a 1/3 group carry instead of 3/4)
			elif psas == 1:
				guard_rate = 4
				guards_up = 8
				guards_down = 10
				# Or rate 2, everything else the same (For good UV, normally not good because it gives guards an extremely long period of time, 60 on / 75 off)
				# Or rate 3, everything else the same (But it would be a little confusing because 4 goes in evenly to the guards_up and there would be a 1/3 group carry instead of 3/4)
			else:
				guard_rate = 4
				guards_up = 8
				guards_down = 9
				# Or rate 2, everything else the same (For good UV, if guards want 60-75 off instead of 30-45 off)
				# Or rate 3, everything else the same (But it would be a little confusing because 4 goes in evenly to the guards_up and there would be a 1/3 group carry instead of 3/4)
		elif names.size() == 20:
			if psas == 0:
				guard_rate = 4
				guards_up = 8
				guards_down = 12
				# Or rate 3, everything else the same (But it doesn't go in evenly to most things, and there would be a group carry-over)
				# Or rate 5, everything else the same (But it doesn't go in evenly to most things)
			elif psas == 1:
				guard_rate = 4
				guards_up = 8
				guards_down = 11
				# Or rate 3, everything else the same (But it doesn't go in evenly to most things, and there would be a group carry-over)
				# Or rate 5, everything else the same (But it doesn't go in evenly to most things)
			else:
				guard_rate = 5
				guards_up = 8
				guards_down = 10
				# Or rate 3, everything else the same (But it doesn't go in evenly to most things, and there would be a group carry-over)
				# Or rate 4, everything else the same (But it would be a little confusing because 1 would carry over on an even shift where 2 could for psas and break)
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
		var rotation_value: int = 15
		if interval_for_calculations == 0:
			rotation_value = 15
		else:
			rotation_value = 20
		if next_shift_texture_progress_bar.max_value != rotation_value * 60:
			next_shift_texture_progress_bar.max_value = rotation_value * 60
		var time_seconds = Time.get_time_dict_from_system()["second"]
		var seconds_zero: String = ""
		if str(60 - time_seconds).length() == 1 || time_seconds == 0:
			seconds_zero = "0"
		var time_seconds2 = time_seconds
		if time_seconds == 0:
			time_seconds = 60
			#seconds_zero = "00"
		var time_minutes = Time.get_time_dict_from_system()["minute"]
		var time_minutes2 = time_minutes
		if time_seconds2 == 0:
			time_minutes2 += rotation_value - 1
		#print(time_minutes % 15)
		var time_hours = Time.get_time_dict_from_system()["hour"]
		var minutes: int = time_minutes - (time_minutes % (5 * interval_for_calculations + 15))
		var minutes_zero: String = ""
		if minutes < 10:
			minutes_zero = "0"
		if last_log_label.text != "Last log time: " + str(time_hours) + ":" + minutes_zero + str(minutes) + " ":
			last_log_label.text = "Last log time: " + str(time_hours) + ":" + minutes_zero + str(minutes) + " "
		if !rotation_lock_check_button.button_pressed:
			if next_shift_label.text != "Time until next shift: " + str(rotation_value - time_minutes2 % rotation_value - 1) + ":" + seconds_zero + str(60 - time_seconds) + " ":
				next_shift_label.text = "Time until next shift: " + str(rotation_value - time_minutes2 % rotation_value - 1) + ":" + seconds_zero + str(60 - time_seconds) + " "
		else:
			if next_shift_label.text != "Time until next shift: - ( HOLD ) - ":
				next_shift_label.text = "Time until next shift: - ( HOLD ) - "
		if next_shift_texture_progress_bar.value != (60 * (time_minutes % rotation_value)) + (time_seconds2):
			next_shift_texture_progress_bar.value = (60 * (time_minutes % rotation_value)) + (time_seconds2)
			#print(next_shift_texture_progress_bar.value)
			var progress = next_shift_texture_progress_bar.value / next_shift_texture_progress_bar.max_value
			#print(100.0 * progress)
			#print(progress)
			var new_texture = get_solid_color_progress_texture(progress)
			next_shift_texture_progress_bar.texture_progress = new_texture
			#test_texture_rect.texture = new_texture
			# Run Those Cycles!
			#print("Minute Side: " + str(rotation_value - time_minutes2 % rotation_value - 1))
			#print("Second Side: " + str(60 - time_seconds))
			if (rotation_value - time_minutes2 % rotation_value - 1) + (60 - time_seconds) == 0:
				var running_index_check: int = 1
				var some_array: Array = LoadManager.get_time_break_hours()
				for item in some_array:
					if int(item) == time_hours && time_minutes == 0:
						running_index_check -= 1
						print("Subtracted 1 from the running_index!")
				print("Running Index Check: " + str(running_index_check))
				for i in range(running_index_check):
					if !rotation_lock_check_button.button_pressed:
						update_cycle()
			#print("Gradient Colors: ", gradient.colors)
			#print("Gradient Offsets: ", gradient.offsets)
			#LoadManager.calculate_cycles_to_run()

func get_solid_color_progress_texture(progress: float) -> Texture2D:
	# Sample color from gradient at current progress (0.0 to 1.0)
	var color = gradient.sample(progress)
	circle_main.material.set_shader_parameter("percentage", progress)
	circle_main.material.set_shader_parameter("effect_color", color)
	circle_outline.material.set_shader_parameter("color", color)
	# Create a 1x1 pixel image with the sampled color
	var image = Image.create(152, 17, false, Image.FORMAT_RGBA8)
	image.fill(color)
	# Convert to Texture2D
	var texture = ImageTexture.create_from_image(image)
	#print("Created New Texture!")
	return texture

func update_cycle() -> void:
	#print("Cycle Fired!")
	#last_cycle_switch = Time.get_time_dict_from_system()["second"]
	#if is_rotating:
		#return  # Prevent overlapping rotations
	#is_rotating = true
	LoadManager.save_time()
	#var minutes: int = Time.get_time_dict_from_system()["minute"]
	#var hours: int = Time.get_time_dict_from_system()["hour"]
	#var minutes: int = LoadManager.get_time_minutes()
	#var hours: int = LoadManager.get_time_hours()
	#minutes = minutes - (minutes % (5 * interval_for_calculations + 15))
	#var minutes_zero: String = ""
	#if minutes < 10:
		#minutes_zero = "0"
	#last_log_label.text = "Last log time: " + str(hours) + ":" + minutes_zero + str(minutes) + " "
	var buddies : Array = LoadManager.get_guard_names()
	var stands : int = LoadManager.get_rotation_on_stand()
	var psa_selection : int = LoadManager.get_guard_psa()
	var guard_factor : int = LoadManager.get_rotation_guard_factor()
	print(guard_factor)
	#var first_item = buddies.pop_front()  # Remove and get first element
	#buddies.append(first_item)  # Add it to the end
	for i in range(guard_factor):
		var last_item = buddies.pop_back()  # Remove & get the last element
		buddies.push_front(last_item)       # Insert it at the front
	if buddies.size() % guard_factor == 0 && guard_factor != 1: # Shift first guard_factor sized group whenever it is perfectly even with the total
		var first_buddies: Array = []
		for i in range(guard_factor):
			first_buddies.append(buddies[i])
		print("Here's the first buddies after cycling once: " + str(first_buddies))
		var last_item = first_buddies.pop_back()  # Remove & get the last element
		first_buddies.push_front(last_item)       # Insert it at the front
		for i in range(guard_factor):
			buddies[i] = first_buddies[i]
	LoadManager.save_guard_names(buddies)
	calculate_pool_tab_labels(buddies, stands, psa_selection)
	if buddies.size() % guard_factor == 0 && guard_factor != 1: # Now counter the label rotation by adjusting the list used back by guard_factor
		var adjusted_buddies = buddies
		for i in range(guard_factor):
			var last_item = adjusted_buddies.pop_front()  # Remove & get the first element
			adjusted_buddies.append(last_item)            # Insert it at the back
		calculate_circle_main_labels(adjusted_buddies, guard_factor)
		#calculate_circle_main_labels(buddies, guard_factor)
	else:
		#set_process_input(false)
		#circle_main_control.rotation = -circle_main.rotation  # Counter-rotate
		target_rotation += rad_to_deg(guard_factor * (2 * PI / circle_main.polygon.size()))  # Increment by the rotation interval number of times around the polygon's size
		print("Circle Rotation: " + str(circle_main.rotation_degrees))
		print("Target Rotation: " + str(target_rotation))
		if circle_main.rotation_degrees >= 360.0:
			circle_main.rotation_degrees -= 360.0
			target_rotation -= 360.0
			for child in circle_main.get_children():
				child.rotation_degrees += 360
		var tween = create_tween().bind_node(circle_main)
		# Smooth rotation animation
		tween.set_parallel(true)
		tween.tween_property(circle_main, "rotation_degrees", target_rotation, rotation_duration)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.set_ease(Tween.EASE_IN_OUT)
		#tween.tween_method(update_label_positions, 0.0, 1.0, rotation_duration)
		var label_tween = create_tween()
		label_tween.set_parallel(true)
		for child in circle_main.get_children():
			label_tween.set_trans(Tween.TRANS_LINEAR)
			label_tween.set_ease(Tween.EASE_IN_OUT)
			label_tween.tween_property(child, "rotation_degrees", -target_rotation, rotation_duration)
		force_cycle_button.disabled = false

func spin_even_circle(guard_factor: int) -> void:
	target_rotation = rad_to_deg(guard_factor * (2 * PI / circle_main.polygon.size()))  # Set to the exact degrees of rotation needed for the first of the polygon's sides
	print("Circle Rotation: " + str(circle_main.rotation_degrees))
	print("Target Rotation: " + str(target_rotation))
	if circle_main.rotation_degrees >= rad_to_deg(guard_factor * (2 * PI / circle_main.polygon.size())):
		circle_main.rotation_degrees = 0
	#if circle_main.rotation_degrees >= 360.0:
		#circle_main.rotation_degrees -= 360.0
		#target_rotation -= 360.0
		#for child in circle_main.get_children():
			#child.rotation_degrees += 360
	var tween = create_tween().bind_node(circle_main)
	# Smooth rotation animation
	tween.set_parallel(true)
	tween.tween_property(circle_main, "rotation_degrees", target_rotation, rotation_duration)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	#tween.tween_method(update_label_positions, 0.0, 1.0, rotation_duration)
	var label_tween = create_tween()
	label_tween.set_parallel(true)
	for child in circle_main.get_children():
		label_tween.set_trans(Tween.TRANS_LINEAR)
		label_tween.set_ease(Tween.EASE_IN_OUT)
		label_tween.tween_property(child, "rotation_degrees", -target_rotation, rotation_duration)
	force_cycle_button.disabled = false

func calculate_circle_main_labels(buddies: Array, guard_factor: int) -> void:
	print("Running the Circle Main label deletion process " + str(circle_main.get_children().size()) + " times!")
	for i in range(circle_main.get_children().size()):
		var child = circle_main.get_child(0)
		circle_main.remove_child(child)
		child.queue_free()
		print(i + 1)
	for name in buddies:
		var new_label = Label.new()
		new_label.text = " " + str(name) + " "
		new_label.add_theme_font_size_override("font_size", 5)
		new_label.add_theme_color_override("font_color", Color("000000"))
		var background = StyleBoxFlat.new()
		background.bg_color = Color("ffff00")  # RGB color (yellow)
		background.corner_radius_bottom_left = 2
		background.corner_radius_bottom_right = 2
		background.corner_radius_top_left = 2
		background.corner_radius_top_right = 2
		new_label.add_theme_stylebox_override("normal", background)
		new_label.scale = Vector2(2.0, 2.0)
		circle_main.add_child(new_label)
		new_label.position = circle_main.polygon[buddies.find(name)]
		new_label.position -= new_label.size * 0.5
		new_label.pivot_offset += new_label.size * 0.5
	spin_even_circle(guard_factor)

func apply_shader_to_rotating_labels(rotating_labels: Array, numbered_labels: Array):
	var viewport = SubViewport.new()
	viewport.size = get_viewport().size
	print(viewport.size)
	viewport.transparent_bg = true
	add_child(viewport)
	# Add your labels to the viewport
	for label in numbered_labels:
		var dup = label.duplicate()
		dup.position = label.global_position
		viewport.add_child(dup)
	await get_tree().process_frame
	#viewport.get_texture().get_image().save_png("user://viewport_debug.png")
	var shader = preload("res://shaders/label_overlap.gdshader")
	for label in rotating_labels:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		#mat.set_shader_parameter("number_labels", viewport.get_texture())
		#mat.set_shader_parameter("label_count", len(numbered_labels))
		#label.material = mat
		

func _on_restart_button_button_up() -> void:
	LoadManager.save_current_scene("res://scenes/menu.tscn")
	await LoadManager.restore_default_values()
	pool_option_button.select(LoadManager.get_pool())
	interval_option_button.select(LoadManager.get_rotation_interval())
	psa_option_button.select(LoadManager.get_guard_psa())
	language_option_button.select(LoadManager.get_language())
	uv_index_check_button.button_pressed = LoadManager.get_uv_index()
	rotation_lock_check_button.button_pressed = LoadManager.get_rotation_lock()
	lock_image.visible = rotation_lock_check_button.button_pressed
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
	rotation_lock_check_button.button_pressed = LoadManager.get_rotation_lock()
	lock_image.visible = rotation_lock_check_button.button_pressed
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
	#print("Tab Changed!")
	LoadManager.save_current_tab(tab)
	#print(tab)

func _on_uv_index_check_button_toggled(toggled_on: bool) -> void:
	LoadManager.save_uv_index(toggled_on)

func _on_rotation_lock_check_button_toggled(toggled_on: bool) -> void:
	LoadManager.save_rotation_lock(toggled_on)
	lock_image.visible = rotation_lock_check_button.button_pressed
	if !toggled_on:
		LoadManager.save_time()

func _on_force_cycle_button_button_up() -> void:
	force_cycle_button.disabled = true
	update_cycle()

func _input(event: InputEvent) -> void:
	if event.is_action("Cycle"):
		if event.is_action_pressed("Cycle"):
			update_cycle()
