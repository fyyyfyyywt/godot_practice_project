extends Node2D

@export var Slime : PackedScene
@export var Bullet_Item : PackedScene
@export var spawn_timer : Timer
@export var game_over_timer : Timer
@export var score_label : Label
@export var gameover_label : Label
@export var item_spawn_interval: float = 5.0  # Time between item spawns
@export var max_active_items: int = 3  # Max unpicked items allowed

var score : int=0
var is_game_over : bool=false
var item_spawn_timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals from player and slimes
	var player = get_node("Player")  # Adjust node path as needed
	player.player_hit.connect(_on_player_hit)
	spawn_timer.timeout.connect(_new_slime)
	# Note: Slime signals are connected when instantiated


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_game_over:
		spawn_timer.wait_time -= 0.1 * delta
		spawn_timer.wait_time = clamp(spawn_timer.wait_time, 0.7, 3)
		
		#Handle item spawning
		item_spawn_timer += delta
		if item_spawn_timer > item_spawn_interval:
			if get_tree().get_nodes_in_group("bullet_items").size() < max_active_items:
				new_item()
				item_spawn_timer = 0.0
				
	score_label.text = "Score: " + str(score)
		
		
func _new_slime() -> void:
	if not is_game_over:
		var new_slime = Slime.instantiate()
		new_slime.position = Vector2(236,randf_range(-130,130))
		new_slime.slime_speed -= 0.25 * score
		new_slime.slime_triggered_game_over.connect(_on_slime_triggered_game_over)
		add_child(new_slime)
	
func new_item() -> void:
	if not is_game_over:
		@warning_ignore("shadowed_variable")
		var new_item = Bullet_Item.instantiate()
		new_item.position = Vector2(randf_range(-200,200),randf_range(-130,130))
		add_child(new_item)
	
func _game_over()->void:
	if not is_game_over:
		is_game_over = true
		get_node("Player").disable_input()  # Disable player input
		if game_over_timer.is_stopped():
			game_over_timer.start()
		gameover_label.visible = true
		if not $FailSound.playing:
			$FailSound.play()
		
func _on_player_hit() -> void:
	_game_over()

func _on_slime_triggered_game_over() -> void:
	_game_over()
	
func _on_game_over_timer_timeout() -> void:
	get_tree().reload_current_scene()
