extends LineEdit

@onready var circle_layer: CanvasLayer = $"../../../../../../../.."
@onready var max_guards_label: Label = $"../../MaxGuardsLabel"
@onready var min_guards_label: Label = $"../../MinGuardsLabel"
@onready var next_button: Button = $"../../NextButtonMargin/NextButton"
@onready var circle: Polygon2D = $"../../../../../Circle"
@onready var label_group: PanelContainer = $"../../../../../../../LabelGroup"

var rotation_duration: float = 1.0  # Seconds per full rotation
var circle_offset: Vector2 = Vector2(90.0, 90.0)
var is_rotating: bool = false
var target_rotation : float = 0.0
var active_tween: Tween = null

var cycle_degree: int = 5
var cycle_start: bool = false
var last_cycle_switch: int = -1
#var time_minutes: int

func _ready() -> void:
	select_all_on_focus = true
	editable = true

func _on_text_changed(new_text) -> void:
	if circle.polygon.size() == 0:
		#print("Circle isn't visible!")
		if max_guards_label.visible:
			max_guards_label.visible = false
		if min_guards_label.visible:
			min_guards_label.visible = false
		#await _on_text_submitted(new_text)
		# Remove any non-numeric characters
		var filtered = ""
		for c in text:
			if c.is_valid_int() && filtered.length() < 2:  # or is_valid_float() for decimals
				filtered += c
		if filtered != text:
			text = filtered
			set_caret_column(filtered.length())
		#print("circle visible!")

func _on_text_submitted(new_text: String) -> void:
	if circle.polygon.size() == 0:
		#if Input.is_action_just_pressed("ui_text_submit"):
			if int(text) > 25:
				max_guards_label.visible = true
				#print("big number")
			elif int(text) < 4:
				min_guards_label.visible = true
				#print("small number")
			else:
				editable = false
				release_focus()
				if max_guards_label.visible:
					max_guards_label.visible = false
				if min_guards_label.visible:
					min_guards_label.visible = false
				if !next_button.visible:
					next_button.visible = true
		#print("circle visible!")

func _on_next_button_button_up() -> void:
	if next_button.visible:
		next_button.visible = false
	var points = []
	var radius = 35
	var sides = int(text)  # More sides = smoother circle
	for i in range(sides):
		#var angle: float
		#if sides % 2 == 0:
			#angle = i * (2 * PI / sides)
		#else:
		var angle: float = (i * (2 * PI / sides)) - (PI / 2)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	circle.polygon = points
	circle.color = Color("#6affff")
	circle.position = Vector2(40, 30)
	editable = true
	var guard_number = int(text)
	var guard_list = []
	for i in range(guard_number):
		text = ""
		placeholder_text = "Guard #" + str(i + 1) + "..."
		grab_click_focus()
		select_all()
		await text_submitted
		var new_label = Label.new()
		new_label.text = text
		guard_list.append(text)
		new_label.add_theme_font_size_override("font_size", 5)
		new_label.add_theme_color_override("font_color", Color("000000"))
		#print(circle.polygon)
		#print(circle.to_global(circle.polygon[i]))
		#new_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#new_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		#var label_center_offset = Vector2(new_label.size.x / 2, new_label.size.y / 2)
		#print(label_center_offset)
		var font = new_label.get_theme_default_font()
		var string_size = font.get_string_size(new_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, new_label.get_theme_font_size("font_size"))
		# Calculate center offset
		var center_offset = Vector2(string_size.x / 2, font.get_ascent())
		# Position label (polygon space to global space)
		new_label.position = circle.to_global(circle.polygon[i]) - center_offset + Vector2(0.0, 13.5)
		#new_label.position = Vector2(circle.to_global(circle.polygon[i]).x - 5.0, circle.to_global(circle.polygon[i]).y - 5.0)
		#print(new_label.position)
		var background = StyleBoxFlat.new()
		background.bg_color = Color("ffff00")  # RGB color (yellow)
		new_label.add_theme_stylebox_override("normal", background)
		circle_layer.add_child(new_label)
	for child in circle_layer.get_children():
		if child is Label:
			remove_child(child)
			child.queue_free()
	editable = false
	visible = false
	print("Reached the end of the menu.tscn! Now running the LoadManager under the line_edit.gd script!")
	LoadManager.save_current_scene("res://scenes/main_tabs.tscn")
	LoadManager.save_guard_num(guard_list.size())
	print("This is the guard_list: " + str(guard_list))
	LoadManager.save_guard_names(guard_list)
	LoadManager.save_current_tab(0)
	LoadManager.save_time()
	LoadManager.save_time_break_hours(["16", "18"])
	print("Loading completed. Changing scenes to main_tabs.tscn!")
	#LoadManager.is_menu_passed(true)
	get_tree().change_scene_to_file("res://scenes/main_tabs.tscn")
	#print("Reached this point!")
	#var config = ConfigFile.new()
	#var _err = config.load("user://app_config.cfg")
	#print(config.get_value("app", "guard_number", "Error. Does Not Exist."))
	
	# Here will be the break!

func _on_focus_entered() -> void:
	# iOS-specific fixes
	# Default behavior first
	if OS.has_feature('web') and OS.get_name() == "iOS":
		await get_tree().create_timer(1.15).timeout
		grab_focus()  # Secondary focus grab for iOS
