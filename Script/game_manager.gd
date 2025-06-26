extends Node2D

# 地圖邊界
const LEFT_BORDER := 312 
const RIGHT_BORDER := 1000  
const UPPER_BORDER := 240  
const BOTTOM_BORDER := 440 

# Slime 预制体
@export var Slime: PackedScene
@export var GiantSlime: PackedScene
@export var FlySlime: PackedScene

# 掉落道具预制体
var pickup_scene_speed := preload("res://Scenes/speed_up_prop.tscn")
var pickup_scene_fire := preload("res://Scenes/power_up_prop.tscn")
var max_pickups_on_map := 3  
var autospawn_interval := 10.0
var autospawn_timer := 0.0

# UI组件
@onready var time_label = $UI/TimeLabel
@export var ui_score_label: Label
@export var ui_game_over_label: Label 
@export var GameOverTimer: Timer

# 状态标志
var flag_is_paused := false 
var flag_is_game_over: bool = false
var is_game_running := true

# 游戏变量
var survival_time := 0.0
var round_time := 0.0
var score: int = 0

# === 启动流程 ===
func _ready() -> void:
	var config = ConfigFile.new()
	config.load("user://saves/save_data.cfg")

	if not ScoreManager.has_seen_intro():
		await _play_intro_sequence()
		ScoreManager.mark_intro_seen()
		config.set_value("progress", "intro_seen", true)
		config.save("user://saves/save_data.cfg")

	# 背景音乐与配置
	var game_music = preload("res://AssetBundle/Audio/BGM.ogg")
	BgmManager.play_music(game_music)
	GameBalanceLoader.load_json("res://Data/converted_balance_data.json")

	# 初始化玩家监听
	$Player.player_hit.connect(_on_player_hit)

	await get_tree().create_timer(1.0).timeout
	await _start_wave_loop()

# === 每帧处理 ===
func _process(delta: float) -> void:
	if flag_is_game_over or flag_is_paused:
		return
	survival_time += delta
	round_time += delta
	autospawn_timer += delta

	if autospawn_timer > autospawn_interval:
		autospawn_timer = 0.0
		spawn_random_pickup()
	update_timer_label()

# === UI 更新函数 ===
func update_timer_label():

	time_label.text = "%.2f" % [survival_time]

func add_score(amount: int):
	score += amount
	ui_score_label.text = "Score:%d" % [score]
	ScoreManager.save_temp_score(score)

# === Intro 剧情播放 ===
func _play_intro_sequence() -> void:
	flag_is_paused = true
	toggle_player(false)
	var intro = preload("res://Scenes/IntroDialog.tscn").instantiate()
	add_child(intro)
	await intro.dialog_finished
	intro.queue_free()
	toggle_player(true)
	flag_is_paused = false

# === 玩家控制切换 ===
func toggle_player(enabled: bool) -> void:
	var p = $Player
	p.visible = enabled
	if enabled:
		p.can_move = true
	else:
		p.disable_input()

# === 掉落道具相关 ===
func can_spawn_pickup() -> bool:
	return get_tree().get_nodes_in_group("pickup_items").size() < max_pickups_on_map

func spawn_random_pickup() -> void:
	if flag_is_paused or not can_spawn_pickup():
		return
	var rand = randi() % 2
	var pickup = pickup_scene_speed.instantiate() if rand == 0 else pickup_scene_fire.instantiate()
	pickup.position = Vector2(randf_range(380, RIGHT_BORDER-50), randf_range(UPPER_BORDER, BOTTOM_BORDER))
	add_child(pickup)

func spawn_pickup_from_enemy(pos: Vector2) -> void:
	if not can_spawn_pickup():
		return
	if randf() < 0.2:
		var pickup = (pickup_scene_fire if randi() % 2 == 0 else pickup_scene_speed).instantiate()
		pickup.position = pos
		call_deferred("add_child", pickup)

# === 敌人生成控制 ===
func _start_wave_loop() -> void:
	while not flag_is_game_over:
		if flag_is_paused:
			await _wait_until_resume()
		await _generate_slime_wave()

func _generate_slime_wave() -> void:
	var row := GameBalanceLoader.get_row_by_time(round_time)
	var count: int = row.get("每波敌人数", 2)
	var weights: Dictionary = row.get("敌人类型权重", {"slime": 1.0})
	var interval: float = row.get("敌人刷新间隔（秒）", 2.5)

	if typeof(weights) != TYPE_DICTIONARY:
		push_error("⚠️ 敌人类型权重不是 Dictionary，使用默认值")
		weights = {"slime": 1.0}

	for i in count:
		if flag_is_game_over:
			return
		if flag_is_paused:
			await _wait_until_resume()
		var slime_type := _roll_enemy_type(weights)
		var slime := _create_slime_by_type(slime_type)
		if slime:
			slime.slime_triggered_game_over.connect(_on_slime_triggered_game_over)
			add_child(slime)
	await get_tree().create_timer(interval).timeout

func _roll_enemy_type(weights: Dictionary) -> String:
	var total := 0.0
	for v in weights.values():
		total += v
	var r := randf() * total
	var cumulative := 0.0
	for key in weights.keys():
		cumulative += weights[key]
		if r <= cumulative:
			return key
	return "slime"

func _create_slime_by_type(slime_type: String) -> Node2D:
	match slime_type:
		"slime":
			var slime = Slime.instantiate()
			slime.slime_speed = clamp(slime.slime_speed + 0.25 * score, 0, 120)
			slime.position = Vector2(1040, randi_range(UPPER_BORDER, BOTTOM_BORDER))
			slime.target_position = Vector2(200, 272)
			return slime
		"giant":
			var slime = GiantSlime.instantiate()
			slime.add_to_group("giant_slime")
			slime.position = Vector2(1040, randi_range(UPPER_BORDER, BOTTOM_BORDER))
			slime.target_position = Vector2(200, 272)
			return slime
		"fly":
			var slime = FlySlime.instantiate()
			slime.position = Vector2(randf_range(LEFT_BORDER, RIGHT_BORDER-10), 10)
			slime.landing_point = [Vector2(300, 400), Vector2(500, 360), Vector2(250, 450)][randi() % 3]
			return slime
	return null

# === 等待暂停解除 ===
func _wait_until_resume() -> void:
	while flag_is_paused and not flag_is_game_over:
		await get_tree().create_timer(0.1).timeout

# === Game Over 控制 ===
func game_over() -> void:
	if flag_is_game_over:
		return
	flag_is_game_over = true
	$Player.disable_input()
	if GameOverTimer.is_stopped():
		GameOverTimer.start()
	ui_game_over_label.visible = true
	if not $FailSound.playing:
		$FailSound.play()

func _notification(what):
	if what == Node.NOTIFICATION_WM_CLOSE_REQUEST:
		ScoreManager.save_temp_score(score)

func _on_player_hit() -> void:
	game_over()

func _on_slime_triggered_game_over() -> void:
	game_over()

func _on_game_over_timer_timeout() -> void:
	ScoreManager.save_temp_score(score)
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
