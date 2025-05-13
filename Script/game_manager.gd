extends Node2D

#Slime 
@export var Slime : PackedScene
@export var Slime_SpawnTimer : Timer

#Prop
@export var FireRateProp : PackedScene
@export var FireRateProp_SpawnTime: float = 5.0  # Time between item spawns
var FireRateProp_SpawnTimer: float = 0.0
@export var MaxActiveProps_Number: int = 3  # Max unpicked items allowed

@export var SpeedUpProp : PackedScene

#UI
@export var GameOverTimer : Timer
@export var UI_ScoreLabel : Label
@export var UI_GameOverLabel : Label
var score : int=0

#Game Over Flag
var Flag_IsGameOver : bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals from player and slimes
	var player = get_node("Player")  # Adjust node path as needed
	player.player_hit.connect(_on_player_hit)
	# Slime signals are connected when instantiated
	Slime_SpawnTimer.timeout.connect(generate_slime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Flag_IsGameOver:
		Slime_SpawnTimer.wait_time -= 0.1 * delta
		Slime_SpawnTimer.wait_time = clamp(Slime_SpawnTimer.wait_time, 0.7, 3)
		
		#Handle item spawning
		FireRateProp_SpawnTimer += delta
		if FireRateProp_SpawnTimer > FireRateProp_SpawnTime:
			if get_tree().get_nodes_in_group("fire_rate_props").size() < MaxActiveProps_Number:
				new_fire_rate_prop()
				new_speed_up_prop()
				FireRateProp_SpawnTimer = 0.0
				
	UI_ScoreLabel.text = "Score: " + str(score)
		
		
func generate_slime() -> void:
	if not Flag_IsGameOver:
		var slime = Slime.instantiate()
		slime.position = Vector2(236,randf_range(-130,130))
		slime.slime_speed -= 0.25 * score
		slime.slime_triggered_game_over.connect(_on_slime_triggered_game_over)
		add_child(slime)
	
func new_fire_rate_prop() -> void:
	if not Flag_IsGameOver:
		var FireRateBoost_Prop = FireRateProp.instantiate()
		FireRateBoost_Prop.position = Vector2(randf_range(-200,200),randf_range(-130,130))
		add_child(FireRateBoost_Prop)

func new_speed_up_prop() -> void:
	if not Flag_IsGameOver:
		var Speed_Up_Prop = SpeedUpProp.instantiate()
		Speed_Up_Prop.position = Vector2(randf_range(-200,200),randf_range(-130,130))
		add_child(Speed_Up_Prop)
		
func game_over()->void:
	if not Flag_IsGameOver:
		Flag_IsGameOver = true
		get_node("Player").disable_input()  # Disable player input
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
