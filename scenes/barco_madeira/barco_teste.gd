extends CharacterBody3D

var velocidade = 6.0
var vel_rotacao = 1.5
@onready var som_agua = $SomAgua # Puxa o nó do som
# Puxa o nó da animação 
@onready var animacao = $AnimationPlayer 

func _physics_process(delta: float) -> void:
	# 1. Movimentação e Rotação
	var rotacao = Input.get_axis("move_right", "move_left")
	rotate_y(rotacao * vel_rotacao * delta)

	var movimento = Input.get_axis("move_down", "move_up")
	var direcao = -transform.basis.z * movimento
	
	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade
	velocity.y = 0 
	
	# 2. Lógica da Animação dos Remos
	# Se estiver a andar ou a rodar, executa a animação
	if movimento != 0 or rotacao != 0:
		animacao.play("Remar") 
		if not som_agua.playing:
			som_agua.play()
	else:
		# Quando solta as teclas, a animação "RESET" força o remo a voltar à posição parada inicial
		animacao.play("RESET")
		som_agua.stop()
	
		
	
	move_and_slide()
