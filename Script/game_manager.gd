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

# UI
@export var GameOverTimer: Timer
@export var UI_ScoreLabel: Label
@export var UI_GameOverLabel: Label

# 游戏状态
var score: int = 0
var Flag_IsGameOver: bool = false
var round_time := 0.0

# 掉落道具
var MAX_PICKUPS_ON_MAP := 3  
var AUTOSPAWN_INTERVAL := 10.0
var autospawn_timer := 0.0
var pickup_scene_speed := preload("res://Scenes/speed_up_prop.tscn")
var pickup_scene_fire := preload("res://Scenes/power_up_prop.tscn")

# 启动游戏
func _ready() -> void:
	GameBalanceLoader.load_json("res://Data/balance_data.json")
	round_time = 0.0
	var player = get_tree().current_scene.get_node("Player")
	player.player_hit.connect(_on_player_hit)

	await get_tree().create_timer(1.0).timeout  # 開場緩衝
	await _start_wave_loop()

# 每帧处理
func _process(delta: float) -> void:
	if Flag_IsGameOver:
		return

	round_time += delta
	autospawn_timer += delta
	if autospawn_timer > AUTOSPAWN_INTERVAL:
		autospawn_timer = 0.0
		spawn_random_pickup()

	UI_ScoreLabel.text = "Score: " + str(score)

# 主波次循环（遞迴控制節奏）
func _start_wave_loop() -> void:
	while not Flag_IsGameOver:
		await _generate_slime_wave()
		await get_tree().create_timer(3.0).timeout  # 波與波之間緩衝

# 單波敵人生成
func _generate_slime_wave() -> void:
	var row := GameBalanceLoader.get_row_by_time(round_time)
	var count: int = row.get("每波敌人数", 2)
	var weights_raw = row.get("敌人类型权重", null)
	var weights: Dictionary

	if typeof(weights_raw) == TYPE_DICTIONARY:
		weights = weights_raw
	elif typeof(weights_raw) == TYPE_STRING:
		var fixed_str = weights_raw.replace("'", "\"")  # 修复单引号
		var parsed = JSON.parse_string(fixed_str)
		if parsed is Dictionary:
			weights = parsed
		else:
			push_error("敌人类型权重解析失败，使用默认值")
			weights = {"slime": 1.0}
	else:
		weights = {"slime": 1.0}
	var interval: float = row.get("敌人刷新间隔（秒）", 2.5)

	for i in count:
		if Flag_IsGameOver:
			return

		var slime_type := _roll_enemy_type(weights)
		var slime := _create_slime_by_type(slime_type)
		if slime:
			slime.slime_triggered_game_over.connect(_on_slime_triggered_game_over)
			add_child(slime)

		await get_tree().create_timer(interval).timeout

# 掉落道具相關
func can_spawn_pickup() -> bool:
	return get_tree().get_nodes_in_group("pickup_items").size() < MAX_PICKUPS_ON_MAP

func spawn_random_pickup() -> void:
	if not can_spawn_pickup():
		return
	var rand = randi() % 2
	var pickup = pickup_scene_speed.instantiate() if rand == 0 else pickup_scene_fire.instantiate()
	pickup.position = Vector2(randf_range(380, RIGHT_BORDER), randf_range(UPPER_BORDER, BOTTOM_BORDER))
	add_child(pickup)

func spawn_pickup_from_enemy(pos: Vector2) -> void:
	if not can_spawn_pickup():
		return
	if randf() < 0.2:
		var pickup = pickup_scene_fire.instantiate() if (randi() % 2 == 0) else pickup_scene_speed.instantiate()
		pickup.position = pos
		call_deferred("add_child", pickup)

# 敵人生成
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
			slime.position = Vector2(randf_range(LEFT_BORDER, RIGHT_BORDER), 10)
			slime.landing_point = [Vector2(300, 400), Vector2(500, 360), Vector2(250, 450)][randi() % 3]
			return slime
	return null

# 隨機敵人類型選擇
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

# Game Over 處理
func game_over() -> void:
	if Flag_IsGameOver:
		return
	Flag_IsGameOver = true
	get_node("Player").disable_input()
	if GameOverTimer.is_stopped():
		GameOverTimer.start()
	UI_GameOverLabel.visible = true
	if not $FailSound.playing:
		$FailSound.play()

func _on_player_hit() -> void:
	game_over()

func _on_slime_triggered_game_over() -> void:
	game_over()

func _on_game_over_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
