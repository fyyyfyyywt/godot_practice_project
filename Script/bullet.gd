extends Area2D

@export var bullet_speed: float = 300.0  # 子弹速度，适合快节奏
@export var direction: Vector2 = Vector2.ZERO
@export var lifetime: float = 2.0  # 子弹存活时间（秒）

var time_alive: float = 0.0

func _physics_process(delta: float) -> void:
	global_position += direction * bullet_speed * delta
	
	# 管理子弹生命周期
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()  # 超过存活时间销毁子弹
