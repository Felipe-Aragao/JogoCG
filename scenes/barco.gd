extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.1

@export_group("Movement")
@export var move_speed := 18.0
@export var reverse_speed := 8.0
@export var acceleration := 15.0
@export var deceleration := 8.0
@export var rotation_speed := 1.5
@export var turn_smoothness := 5.0
@export_range(0.0, 1.0) var min_turn_ratio := 0.15

var _camera_input_direction := Vector2.ZERO
var _current_speed := 0.0
var _current_steering := 0.0

@onready var _camera_pivot: Node3D = %Pivot
@onready var _skin: Node3D = %BoatSkin

# Captura ou solta mouse
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Lê movimento do mouse
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

# Atualiza física do barco
func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Rotaciona câmera horizontalmente
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
	# Lê acelerador e leme
	var throttle := Input.get_axis("move_down", "move_up")
	var steering := Input.get_axis("move_left", "move_right")
	
	# Calcula velocidade e desaceleração
	var max_speed := move_speed if throttle >= 0.0 else reverse_speed
	var target_speed := throttle * max_speed
	var accel_rate := acceleration if throttle != 0.0 else deceleration
	_current_speed = move_toward(_current_speed, target_speed, accel_rate * delta)
	
	# Suaviza virada do leme
	_current_steering = move_toward(_current_steering, steering, turn_smoothness * delta)
	var speed_ratio := clampf(absf(_current_speed) / move_speed, 0.0, 1.0)
	var speed_factor := lerpf(min_turn_ratio, 1.0, speed_ratio)
	rotate_y(-_current_steering * rotation_speed * speed_factor * delta)
	
	# Inclina casco na curva
	_skin.rotation.z = lerpf(_skin.rotation.z, _current_steering * speed_ratio * 0.15, 6.0 * delta)
	
	# Aplica velocidade ao casco
	var forward := transform.basis.z
	velocity.x = forward.x * _current_speed
	velocity.z = forward.z * _current_speed
	move_and_slide()
	
	# Reduz velocidade ao bater
	if is_on_wall():
		_current_speed = velocity.dot(forward)

# Trava barco na pesca
func set_pescando(ativo: bool) -> void:
	_current_speed = 0.0
	_current_steering = 0.0
	velocity = Vector3.ZERO
	set_physics_process(not ativo)
