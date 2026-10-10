extends CharacterBody3D

var velocidade = 5.0
const FORCA_PULO = 3.5
var gravidade = ProjectSettings.get_setting("physics/3d/default_gravity")
var sensibilidade_rato = 0.003
@export var som_terra: AudioStream
@export var som_agua: AudioStream

# Pega a referência do nó da câmera 
@onready var camera = $Camera3D

func _ready():
	# Esconde e prende o cursor no centro da tela
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if Global.venda : return 
	if event is InputEventMouseMotion:
		# Rotaciona o corpo inteiro no eixo Y 
		rotate_y(-event.relative.x * sensibilidade_rato)
		# Rotaciona apenas a câmera no eixo X 
		camera.rotate_x(-event.relative.y * sensibilidade_rato)
		# Trava a rotação da câmera para não capotar para trás
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):
	if global_position.y < -5.0:
		# Reposiciona o jogador no ponto de origem
		global_position = Vector3(0, 1, 0)
		# Zera a inércia da queda para que não atravesse o chão ao reaparecer
		velocity = Vector3.ZERO
	# Aplica a gravidade
	if not is_on_floor():
		velocity.y -= gravidade * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = FORCA_PULO

	# Obtém o vetor 2D das teclas pressionadas (WASD)
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Converte o input 2D num vetor de direção 3D, respeitando a rotação atual do personagem
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * velocidade
		velocity.z = direction.z * velocidade
	else:
		velocity.x = move_toward(velocity.x, 0, velocidade)
		velocity.z = move_toward(velocity.z, 0, velocidade)
	var direcao = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Função nativa do CharacterBody3D para aplicar a velocidade e lidar com colisões
	move_and_slide()
	# Aplicação do Som
	if is_on_floor() and direcao != Vector2.ZERO:
		# Toca o som apenas se ele ainda não estiver a ser reproduzido
		if not $SomPassos.playing:
			$SomPassos.play()
	else:
		# Se parar de andar ou saltar, interrompe o som imediatamente
		$SomPassos.stop()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		velocidade = 2.0
		$SomPassos.stream = som_agua

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == self:
		velocidade = 5.0
		$SomPassos.stream = som_terra
