class_name menu extends Control

@onready var menu_layer: CanvasLayer = $MenuLayer
@onready var circle_layer: CanvasLayer = $CircleLayer
@onready var line_edit: LineEdit = $CircleLayer.get_child(0).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)
@onready var max_guards_label: Label = $CircleLayer.get_child(0).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(2)
@onready var min_guards_label: Label = $CircleLayer.get_child(0).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(3)
@onready var next_button: Button = $CircleLayer.get_child(0).get_child(1).get_child(1).get_child(1).get_child(0).get_child(0).get_child(1).get_child(0)

func _ready() -> void:
	menu_layer.visible = true
	circle_layer.visible = false

func _on_play_button_button_up() -> void:
	menu_layer.visible = false
	circle_layer.visible = true
	line_edit.visible = true
	max_guards_label.visible = false
	min_guards_label.visible = false
	next_button.visible = false
	#line_edit.grab_click_focus()

func _on_quit_button_button_up() -> void:
	get_tree().quit()
