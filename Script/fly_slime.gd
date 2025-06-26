extends Area2D

signal slime_triggered_game_over  # Signal for boundary or player collision

# --- 可调参数 ---
@export var fly_speed := 60.0                  # 飞行速度
@export var attack_speed := 100                 # 飞行速度
@export var landing_duration := 2.0           # 降落动画时间
@export var attack_range := 60.0              # 攻击范围
@export var damage := 1                       # 对玩家造成的伤害

# --- 内部状态 ---
var landing_point := Vector2.ZERO             # 降落目标点
var player
var state := "flying"
var landing_timer := 0.0
var is_dead : bool=false
var has_stopped :bool= false
var game_manager

func _ready():
	game_manager = get_node("/root/Node2D")
	player = get_tree().current_scene.get_node("Player")
	set_process(true)

func _physics_process(delta: float) -> void:
	if not is_dead and not has_stopped:
		match state:
			"flying":
				fly_to_landing(delta)
			"landing":
				landing_timer -= delta
				if landing_timer <= 0:
					state = "attacking"
			"idle":
				if player and position.distance_to(player.position) <= attack_range:
					state = "attacking"
			"attacking":
				position = position.move_toward(player.position, attack_speed * delta)
				$AnimatedSprite2D.play("attack")
	elif is_dead:
		$AnimatedSprite2D.play("die")
		await get_tree().create_timer(0.5,true).timeout
		queue_free()
						

func fly_to_landing(delta):
	var dir = (landing_point - position).normalized()
	position += dir * fly_speed * delta
	if position.distance_to(landing_point) < 8:
		state = "landing"
		landing_timer = landing_duration


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet") and not is_dead:
		game_manager.spawn_pickup_from_enemy(global_position)
		area.queue_free()
		$AudioStreamPlayer2D.play()
		is_dead = true
		get_parent().add_score(1)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead:
		if body.has_method("on_hit"):
			body.on_hit()
		emit_signal("slime_triggered_game_over")
	elif body.name == "house":  # 假设房子节点叫 House
		has_stopped = true
		emit_signal("slime_triggered_game_over")
