extends Node2D

@export var move_speed := 2  # 移动速度（像素/秒）
@export var move_range := 20  # 移动范围（最大偏移量）

var direction := 1
var origin_x := 0.0
var origin_y := 0.0

func _ready():
	origin_x = position.x  # 记录初始位置
	origin_y= position.y
	
func _process(delta):
	position.x += direction * move_speed * delta
	#position.y = origin_y + sin(OS.get_ticks_msec() / 1000.0) * 3  # 小幅上下浮动
	if abs(position.x - origin_x) > move_range:
		direction *= -1  # 到达最大偏移后反向
