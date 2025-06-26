extends Control

@export var MenuPanel : Panel
var game 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game = get_tree().current_scene

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			if not get_tree().paused:
				_pause()
			else:				
				_resume()
				

func _pause() -> void:
	get_tree().paused = true
	MenuPanel.visible = true
	game.flag_is_paused = true
	
func _resume() -> void:
	get_tree().paused = false
	MenuPanel.visible = false
	game.flag_is_paused = false
	
func _quit() -> void:
	var score : int = get_tree().current_scene.score
	ScoreManager.save_temp_score(score)
	get_tree().quit()
