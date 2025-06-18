extends Control
@export var pupil_limit_x := 2
@export var pupil_limit_y := 1.5

func _ready():
	$VBoxContainer/Button_Start.pressed.connect(_on_start_pressed)
	$VBoxContainer/Button_Quit.pressed.connect(_on_quit_pressed)
	eye_L_center = $FOX/Pupil_L.global_position
	eye_R_center = $FOX/Pupil_R.global_position

func _on_start_pressed():
	# 替换为你的主游戏场景路径
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_quit_pressed():
	get_tree().quit()

var eye_L_center := Vector2.ZERO
var eye_R_center := Vector2.ZERO
	
func _physics_process(delta: float) -> void:
	var mouse = get_global_mouse_position()

	# 左眼
	var offset_L = mouse - eye_L_center
	offset_L.x = clamp(offset_L.x, -pupil_limit_x, pupil_limit_x)
	offset_L.y = clamp(offset_L.y, -pupil_limit_y, pupil_limit_y)
	var target_L = eye_L_center + offset_L
	$FOX/Pupil_L.global_position = $FOX/Pupil_L.global_position.lerp(target_L, 0.05)

	# 右眼
	var offset_R = mouse - eye_R_center
	offset_R.x = clamp(offset_R.x, -pupil_limit_x, pupil_limit_x)
	offset_R.y = clamp(offset_R.y, -pupil_limit_y, pupil_limit_y)
	var target_R = eye_R_center + offset_R
	$FOX/Pupil_R.global_position = $FOX/Pupil_R.global_position.lerp(target_R, 0.05)
