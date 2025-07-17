extends ColorRect

var grow_speed: float = 1.0
var max_thickness: float = 0.05  # Thickness at size=0
var min_thickness: float = 0.0 # Thickness at size=1
var is_ripple_active: bool = false  # Performance gatekeeper

func _ready():
	# No mouse mode needed for mobile
	reset_ripple()

func _process(delta):
	# Only run calculations when needed
	if !is_ripple_active:
		return
	# Grow the ripple
	var current_size = material.get_shader_parameter("size")
	var new_size = min(current_size + grow_speed * delta, 1.5)
	material.set_shader_parameter("size", new_size)
	# Calculate dynamic thickness (inverse of size)
	var thickness = lerp(max_thickness, min_thickness, new_size)
	material.set_shader_parameter("thickness", thickness)
	# Check for completion
	if new_size >= 1.5:
		reset_ripple()

func _input(event):
	# Handle both mouse and touch inputs
	if event is InputEventScreenTouch or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		if event.pressed:
			start_ripple(event.position)

func start_ripple(position):
	#var uv_pos = position / Vector2(get_viewport().size)
	var uv_pos = position / Vector2(get_global_rect().size)
	material.set_shader_parameter("center", uv_pos)
	print(position)
	print(Vector2(get_viewport().size))
	print(uv_pos)
	material.set_shader_parameter("size", 0.0)
	material.set_shader_parameter("thickness", max_thickness)
	is_ripple_active = true

func reset_ripple() -> void:
	# Stop calculations until next click
	material.set_shader_parameter("size", 0.0)
	material.set_shader_parameter("thickness", max_thickness)
	is_ripple_active = false
