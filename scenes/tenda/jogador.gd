extends CharacterBody3D

var velocidade = 5.0
const FORCA_PULO = 3.5
var gravidade = ProjectSettings.get_setting("physics/3d/default_gravity")
var sensibilidade= 0.003
@export var som_terra: AudioStream
@export var som_agua: AudioStream

# Referência da câmera
@onready var camera = $Camera3D

func _ready():
	# Prende cursor na tela
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _unhandled_input(event):
	if Global.venda : return 
	if event is InputEventMouseMotion:
		# Gira corpo no eixo Y
		rotate_y(-event.relative.x * sensibilidade)
		# Gira câmera no eixo X
		camera.rotate_x(-event.relative.y * sensibilidade)
		# Limita inclinação da câmera
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		

func _physics_process(delta):
	if Global.venda:
		return
	if global_position.y < -5.0:
		# Reposiciona jogador na origem
		global_position = Vector3(0, 1, 0)
		# Zera velocidade de queda
		velocity = Vector3.ZERO
	# Aplica a gravidade
	if not is_on_floor():
		velocity.y -= gravidade * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = FORCA_PULO

	# Lê direção de movimento
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Converte direção para 3D
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * velocidade
		velocity.z = direction.z * velocidade
	else:
		velocity.x = move_toward(velocity.x, 0, velocidade)
		velocity.z = move_toward(velocity.z, 0, velocidade)
	var direcao = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Aplica movimento e colisão
	move_and_slide()
	# Gerencia som de passos
	if is_on_floor() and direcao != Vector2.ZERO:
		# Inicia som de passos
		if not $SomPassos.playing:
			$SomPassos.play()
	else:
		# Interrompe som de passos
		$SomPassos.stop()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		velocidade = 2.0
		$SomPassos.stream = som_agua
		$SomPassos.volume_db = 0.0

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == self:
		velocidade = 5.0
		$SomPassos.stream = som_terra
		$SomPassos.volume_db = -12.0
