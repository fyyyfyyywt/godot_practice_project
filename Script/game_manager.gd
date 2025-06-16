extends Node2D

# Map Limit
const LEFT_BORDER := 312 
const RIGHT_BORDER := 1000  
const UPPPER_BORDER := 240  
const BOTTOM_BORDER := 440 

# Slime Scenes
@export var Slime : PackedScene
@export var GiantSlime : PackedScene
@export var FlySlime: PackedScene
@export var Slime_SpawnTimer : Timer

# UI Elements
@export var GameOverTimer : Timer
@export var UI_ScoreLabel : Label
@export var UI_GameOverLabel : Label

# Game State
var score : int = 0
var Flag_IsGameOver : bool = false
var round_time := 0.0  # 👈 当前这一局从0开始的计时器

# Props
var MAX_PICKUPS_ON_MAP := 3  
var AUTOSPAWN_INTERVAL := 10.0
var autospawn_timer := 0.0
var pickup_scene_speed := preload("res://Scenes/speed_up_prop.tscn")
var pickup_scene_fire := preload("res://Scenes/power_up_prop.tscn")

# Time Management for Spawn Interval Steps
var spawn_step_times = [30, 60, 90, 120, 150] # second marks
var spawn_intervals = [2.7, 2.4, 2.1, 1.8, 1.5] # matching intervals

# Called when the node enters the scene tree
func _ready() -> void:
	GameBalanceLoader.load_json("res://Data/balance_data.json")
	round_time = 0.0  # 👈 重新开始一局时重置计时器
	var player = get_tree().current_scene.get_node("Player")
	player.player_hit.connect(_on_player_hit)
	Slime_SpawnTimer.timeout.connect(generate_slime)
	Slime_SpawnTimer.stop()
	Slime_SpawnTimer.wait_time = 3.0
	Slime_SpawnTimer.start()

# Called every frame
func _process(delta: float) -> void:
	if not Flag_IsGameOver:
		round_time += delta  # 👈 用这个作为游戏节奏判断时间
		autospawn_timer += delta
		if autospawn_timer > AUTOSPAWN_INTERVAL:
			autospawn_timer = 0.0
			spawn_random_pickup()
		_update_spawn_interval()
	UI_ScoreLabel.text = "Score: " + str(score)

# Dynamic spawn interval control (step-based)
func _update_spawn_interval() -> void:
	for i in spawn_step_times.size():
		if round_time >= spawn_step_times[i]:
			Slime_SpawnTimer.wait_time = spawn_intervals[i]

func can_spawn_pickup():
	return get_tree().get_nodes_in_group("pickup_items").size() < MAX_PICKUPS_ON_MAP

func spawn_random_pickup() -> void:
	if not can_spawn_pickup(): return
	var rand = randi() % 2
	var pickup
	if (rand == 0):
		pickup = pickup_scene_speed.instantiate()
	else:
		pickup = pickup_scene_fire.instantiate()
	pickup.position = Vector2(randf_range(380, RIGHT_BORDER), randf_range(UPPPER_BORDER, BOTTOM_BORDER))
	add_child(pickup)

func spawn_pickup_from_enemy(pos: Vector2):
	if not can_spawn_pickup(): return
	var pickup
	if randf() < 0.2:
		if (randi() % 2 == 0):
			pickup = pickup_scene_fire.instantiate() 
		else: 
			pickup = pickup_scene_speed.instantiate()
		pickup.position = pos
		call_deferred("add_child", pickup)

func _create_slime_by_type(slime_type: String) -> Node2D:
	match slime_type:
		"slime":
			var slime = Slime.instantiate()
			slime.slime_speed = clamp(slime.slime_speed + 0.25 * score, 0, 120)
			slime.position = Vector2(1040, randi_range(UPPPER_BORDER, BOTTOM_BORDER))
			slime.target_position = Vector2(200, 272)
			return slime
		"giant":
			var slime = GiantSlime.instantiate()
			slime.add_to_group("giant_slime")
			slime.position = Vector2(1040, randi_range(UPPPER_BORDER, BOTTOM_BORDER))
			slime.target_position = Vector2(200, 272)
			return slime
		"fly":
			var slime = FlySlime.instantiate()
			slime.position = Vector2(randf_range(LEFT_BORDER, RIGHT_BORDER), 10)
			slime.landing_point = [Vector2(300, 400), Vector2(500, 360), Vector2(250, 450)][randi() % 3]
			return slime
	return null

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

func generate_slime():
	if Flag_IsGameOver:
		return	
		
	var row := GameBalanceLoader.get_row_by_time(round_time)
	var count: int = row.get("每波敌人数", 2)
	var weights: Dictionary = row.get("敌人类型权重", {"slime": 1.0})
	var interval: float = row.get("敌人刷新间隔（秒）", 2.5)

	for i in count:
		var slime_type := _roll_enemy_type(weights)
		var slime := _create_slime_by_type(slime_type)
		if slime:
			slime.slime_triggered_game_over.connect(_on_slime_triggered_game_over)
			add_child(slime)

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
	get_tree().reload_current_scene()
