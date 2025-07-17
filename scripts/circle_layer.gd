extends CanvasLayer

func _ready() -> void:
	visible = false

func _on_next_button_button_up() -> void:
	visible = true
