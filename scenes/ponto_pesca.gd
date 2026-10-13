extends Node3D

@export var cena_minigame: PackedScene = preload("res://scenes/MinigamePesca.tscn")
@export var multiplicador_pulso := 2

@onready var area_pesca: Area3D = $pesca
@onready var mesh: MeshInstance3D = $pesca/MeshInstance3D
@onready var aviso_ui: CanvasLayer = $AvisoUI

var barco_atual: CharacterBody3D = null
var pescando := false

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
		barco_atual = body as CharacterBody3D
		aviso_ui.visible = not pescando

# Detecta saída do barco
func _on_body_exited(body: Node3D) -> void:
	if body == barco_atual:
		barco_atual = null
		aviso_ui.visible = false

# Inicia pesca no Espaço
func _unhandled_input(event: InputEvent) -> void:
	if barco_atual and not pescando and event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		iniciar_minigame()

# Abre tela do minigame
func iniciar_minigame() -> void:
	pescando = true
	aviso_ui.visible = false
	barco_atual.set_pescando(true)
	
	var minigame := cena_minigame.instantiate()
	get_tree().current_scene.add_child(minigame)
	minigame.finalizado.connect(_on_minigame_finalizado)

# Finaliza pesca e libera
func _on_minigame_finalizado(sucesso: bool) -> void:
	if barco_atual:
		barco_atual.set_pescando(false)
	
	if sucesso:
		queue_free()
	else:
		pescando = false
		aviso_ui.visible = barco_atual != null
