extends Control

@export var MenuPanel : Panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if not get_tree().paused:
				_pause()
			else:
				
				_resume()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _pause() -> void:
	get_tree().paused = true
	MenuPanel.visible = true
	
func _resume() -> void:
	get_tree().paused = false
	MenuPanel.visible = false
	
func _quit() -> void:
	get_tree().quit()
