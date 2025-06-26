extends CharacterBody2D

signal player_hit  # Signal for when the player is hit by an enemy

@export var move_speed: float = 150
@export var animator: AnimatedSprite2D
@export var fire_rate: float = 0.5  # Shooting interval (seconds)
@export var bullet_offset: float = 32  # Bullet spawn offset

@export var fire_rate_boost_duration: float = 10.0  # Duration of fire rate boost
@export var fire_rate_boost_amount: float = 0.1  # Amount to reduce fire rate by
@export var speed_boost_duration: float = 10.0

var base_fire_rate: float  # Store the default fire rate
var base_move_speed: float

var boost_timer: float = 0.0  # Track boost duration
var boost_stacks := 0

var speed_boost_timer: float = 0.0
var speed_boost_stacks := 0

var shoot_timer: float = 0.0  # 自动射击计时器
var can_move: bool = true  # Control player input during game over

var power_up_ui : Control
var stack_label:Label
var speed_stack_label:Label

@onready var pistol_scene = preload("res://Scenes/Weapon.tscn")
@onready var bullet_scene = preload("res://Scenes/bullet_pistol.tscn")

func _ready() -> void:
	base_fire_rate = fire_rate  # Store initial fire rate
	base_move_speed = move_speed
	
	power_up_ui = $"../UI/Items"
	stack_label = power_up_ui.get_node("VBoxContainer/PowerUP/Label")
	speed_stack_label = power_up_ui.get_node("VBoxContainer/SpeedUp/Label")
	
	var pistol = pistol_scene.instantiate()
	$WeaponHolder.add_child(pistol)
	
func _process(delta: float) -> void:
	if can_move:
		var angle = get_shoot_direction().angle()
		$AimUI.rotation = angle
		# --- 在 Weapon 实例化后，动态调整其贴图方向 ---
		var weapon = $WeaponHolder.get_node_or_null("Weapon")
		if weapon:
			weapon.rotation = angle
			if animator.flip_h:
				weapon.scale.y = -1
				$WeaponHolder.z_index = -5
			else:
				weapon.scale.y = 1
				$WeaponHolder.z_index = 1
			
		# Update shooting timer
		shoot_timer += delta
		if shoot_timer >= fire_rate:
			_spawn_bullet(get_shoot_direction())
			$FireSound.play()
			shoot_timer = 0.0  # Reset shooting timer

		# Running sound
		if velocity != Vector2.ZERO and not $RunningSound.playing:
			$RunningSound.play()
		elif velocity == Vector2.ZERO:
			$RunningSound.stop()
			
		if boost_stacks>0: 
			boost_timer -= delta
			if boost_timer <= 0:
				boost_stacks = 0
				fire_rate = base_fire_rate  # Revert to original fire rate
				power_up_ui.set_power_up_active("fire_rate", false)
			else:
				power_up_ui.update_fire_rate_timer(boost_timer, fire_rate_boost_duration)
		
		if speed_boost_stacks > 0:
			speed_boost_timer -= delta
			if speed_boost_timer <= 0:
				speed_boost_stacks = 0
				move_speed = base_move_speed
				power_up_ui.set_power_up_active("speed", false)
			else:
				power_up_ui.update_speed_timer(speed_boost_timer, speed_boost_duration)

func _physics_process(_delta: float) -> void:
	if can_move:
		velocity = Input.get_vector("Left", "Right", "Up", "Down") * move_speed
		var facing_left = (get_global_mouse_position() - global_position).normalized().x < 0
		animator.flip_h = facing_left
		if animator.flip_h:
			$player/Sprite2D.visible = true
		else:
			$player/Sprite2D.visible = false
		var offset = abs($WeaponHolder.position.x)
		if facing_left:
			$WeaponHolder.position.x =  offset 
		else: $WeaponHolder.position.x = -offset 
		
		if velocity == Vector2.ZERO:
			animator.play("idle")
		else:
			pass
			#animator.play("run")
	else:
		velocity = Vector2.ZERO
		#animator.play("over")
	move_and_slide()

func get_shoot_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()
	
func _spawn_bullet(direction: Vector2) -> void:
	var bullet_node = bullet_scene.instantiate() 
	if not bullet_node:
		push_error("❌ Failed to instantiate bullet!！")
		return
	bullet_node.global_position =  global_position + direction * bullet_offset 
	bullet_node.direction = direction
	bullet_node.rotation = direction.angle()
	get_parent().add_child(bullet_node)

func apply_fire_rate_boost() -> void:
	fire_rate = max(fire_rate - fire_rate_boost_amount, 0.1)  # Apply boost
	boost_stacks += 1
	boost_timer = fire_rate_boost_duration  # Start boost timer
	power_up_ui.set_power_up_active("fire_rate", true)
	if boost_stacks >=4:
		stack_label.text = "MAX" % boost_stacks
	else:
		stack_label.text = "×%d" % boost_stacks

func apply_speed_up() -> void:
	move_speed = min(move_speed+25, 250)
	speed_boost_stacks +=1
	speed_boost_timer = speed_boost_duration  # Start boost timer
	power_up_ui.set_power_up_active("speed", true)
	if speed_boost_stacks >=4:
		speed_stack_label.text = "MAX" % speed_boost_stacks
	else:
		speed_stack_label.text = "×%d" % speed_boost_stacks

func on_hit() -> void:
	emit_signal("player_hit")
		
func disable_input() -> void:
	can_move = false
