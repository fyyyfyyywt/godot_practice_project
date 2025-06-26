extends Area2D

signal slime_triggered_game_over  # Signal for boundary or player collision

@export var hp := 3  # 巨型史莱姆默认需要3次攻击
@export var hp_Bar: ProgressBar
@export var kill_score := 3  # 杀死后加3分（而不是1分）
@export var slime_speed : float=30
@export var animator : AnimatedSprite2D
@export var target_position: Vector2  # 设置史莱姆要前进的目标点（通常是房子的坐标）

var is_dead : bool=false
var has_stopped :bool= false
var game_manager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_manager = get_node("/root/Node2D")

func _physics_process(delta: float) -> void:
	hp_Bar.value = hp
	if not is_dead and not has_stopped:
		position = position.move_toward(target_position, slime_speed * delta)		
		if position.distance_to(target_position) < 8:  # 到达目标区域附近就触发
			emit_signal("slime_triggered_game_over")
	elif is_dead:
		animator.play("die")
		await get_tree().create_timer(0.5,true).timeout
		queue_free()
		

func _on_body_entered(body: Node2D) -> void:
	#确保史莱姆撞到的是玩家
	if body.name == "Player" and not is_dead:
		if body.has_method("on_hit"):
			body.on_hit()
		emit_signal("slime_triggered_game_over")
	elif body.name == "house":  # 假设房子节点叫 House
		has_stopped = true
		emit_signal("slime_triggered_game_over")
		

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet") and not is_dead:
		area.queue_free()
		hp -= 1
		if hp <= 0:
			game_manager.spawn_pickup_from_enemy(global_position)
			$AudioStreamPlayer2D.play()
			is_dead = true
			get_parent().add_score(kill_score)
