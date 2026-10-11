extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.1

@export_group("Movement")
@export var move_speed := 8.0
@export var reverse_speed := 3.5
@export var acceleration := 20.0
@export var rotation_speed := 2.0
@export_range(0.0, 1.0) var min_turn_ratio := 0.15

var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot: Node3D = %Pivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: Node3D = %BoatSkin

# Foco
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Captura o movimento dk mouse apenas com o foco
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
		


func _physics_process(delta: float) -> void:
	# Movimento Camera
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("move_left",
	 "move_right", "move_up", "move_down")
	
	# Giro dependente da velocidade (efeito leme)
	var current_speed: float = velocity.length()
	var speed_factor: float = lerpf(min_turn_ratio, 1.0, clampf(current_speed / move_speed, 0.0, 1.0))
	rotate_y(-raw_input.x * rotation_speed * speed_factor * delta)
	
	# Direção e velocidade alvo (velocidade reduzida ao dar ré)
	var forward := transform.basis.z
	var move_direction := forward * (-raw_input.y)
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	var target_speed: float = move_speed if raw_input.y <= 0.0 else reverse_speed
	velocity = velocity.move_toward(move_direction * target_speed, acceleration * delta)
	move_and_slide()
	
	
	
