extends Control
@export var pupil_limit_x := 2
@export var pupil_limit_y := 1.5

func _ready():
	ScoreManager.try_save_high_score()
	$VBoxContainer/Button_Start.pressed.connect(_on_start_pressed)
	$VBoxContainer/Button_Quit.pressed.connect(_on_quit_pressed)
	eye_L_center = $FOX/Pupil_L.global_position
	eye_R_center = $FOX/Pupil_R.global_position
	var high_score = ScoreManager.get_high_score()
	$VBoxContainer/HighScoreLabel.text = "High Score: %d" % high_score
	var menu_music = preload("res://AssetBundle/Audio/Sketchbook 2024-11-29.ogg")
	BgmManager.play_music(menu_music)


func _on_start_pressed():
	# 1. 防止重复点击
	$VBoxContainer/Button_Start.disabled = true
	$VBoxContainer/Button_Quit.disabled = true
	# 2. 淡出音乐（假设你有 BgmManager.fade_out_music()）
	await BgmManager.fade_out_music(1)
	await get_tree().create_timer(0.3).timeout  # 可选延迟
	# 4. 切换场景
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
