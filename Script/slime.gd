extends Area2D

signal slime_triggered_game_over  # Signal for boundary or player collision

@export var slime_speed : float=50
@export var animator : AnimatedSprite2D
@export var SpeedUpProp : PackedScene

@export var target_position: Vector2  # 设置史莱姆要前进的目标点（通常是房子的坐标）

var is_dead : bool=false
var has_stopped :bool= false
var game_manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager = get_node("/root/Node2D")

func _physics_process(delta: float) -> void:
	if not is_dead and not has_stopped:
		position = position.move_toward(target_position, slime_speed * delta)		
		if position.distance_to(target_position) < 8:  # 到达目标区域附近就触发
			emit_signal("slime_triggered_game_over")
	elif is_dead:
		animator.play("die")
		await get_tree().create_timer(0.5).timeout
		queue_free()
		

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_dead:
		if body.has_method("on_hit"):
			body.on_hit()
		emit_signal("slime_triggered_game_over")
	elif body.name == "house":
		has_stopped = true
		emit_signal("slime_triggered_game_over")
	
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet") and not is_dead:
		game_manager.spawn_pickup_from_enemy(global_position)
		area.queue_free()
		$AudioStreamPlayer2D.play()
		is_dead = true
		get_parent().score += 1  #Notify GameManager of score increase	
	
