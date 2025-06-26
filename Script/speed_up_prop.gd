extends Area2D

@export var despawn_time: float = 5.0  # Time before item disappears if not picked up

var is_touched : bool=false
var time_alive: float = 0.0

var velocity = Vector2(0, 0)
const GRAVITY = 200
const FLOOR_Y = 250
var bounced = false

func _ready() -> void:
	add_to_group("pickup_items")  # Add to group for counting active items
	$AnimationPlayer.play("IdleFloat")
	
func _process(delta):
	rotation += 0.05 * delta  # 每帧缓慢旋转
	
func _physics_process(delta: float) -> void:
	if is_touched:
		queue_free()
	else:
		time_alive += delta
		if time_alive >= despawn_time:
			queue_free()
			
		if position.y < FLOOR_Y:
			# 模拟重力
			if not bounced:
				velocity.y += GRAVITY * delta
				position.y += velocity.y * delta

			if position.y >= FLOOR_Y:
				position.y = FLOOR_Y
				velocity.y = -velocity.y * 0.4  # 反弹一次，速度减弱
				bounced = true
		
func _on_body_entered(body: Node2D) -> void:
	#确保撞到的是玩家
	if (body is CharacterBody2D) and (not is_touched):
		body.apply_speed_up()  # Call player's method to handle boost
		is_touched = true
