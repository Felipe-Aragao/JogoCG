extends Node3D

@export var multiplicador_pulso := 2

@onready var area_pesca: Area3D = $pesca
@onready var mesh: MeshInstance3D = $pesca/MeshInstance3D

var barco_em_cima := false

# Conecta sinais e animação
func _ready() -> void:
	area_pesca.body_entered.connect(_on_body_entered)
	area_pesca.body_exited.connect(_on_body_exited)
	_iniciar_animacao_pulso()

# Anima escala em loop
func _iniciar_animacao_pulso() -> void:
	var escala_inicial := mesh.scale
	var escala_aumentada := escala_inicial * Vector3(multiplicador_pulso, 1.0, multiplicador_pulso)
	var duracao := randf_range(0.6, 1.2)
	
	var tween := create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(mesh, "scale", escala_aumentada, duracao)
	tween.tween_property(mesh, "scale", escala_inicial, duracao)

# Detecta entrada do barco
func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D or body.name == "Barco":
		barco_em_cima = true

# Detecta saída do barco
func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D or body.name == "Barco":
		barco_em_cima = false

# Coleta ao pressionar Espaço
func _unhandled_input(event: InputEvent) -> void:
	if barco_em_cima and event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		coletar_ponto()

# Remove ponto atual
func coletar_ponto() -> void:
	queue_free()
