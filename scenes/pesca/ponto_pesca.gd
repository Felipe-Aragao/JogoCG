extends Node3D

@export var cena_minigame: PackedScene = preload("res://scenes/minigames/MinigamePesca.tscn")
@export var multiplicador_pulso := 2

const SOM_WATERSPLASH: AudioStream = preload("res://sounds/watersplash.wav")
const SOM_PICKUP: AudioStream = preload("res://sounds/pickup.wav")
const SOM_ERRO: AudioStream = preload("res://sounds/no.wav")

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
	_tocar_som(SOM_WATERSPLASH)
	
	var minigame := cena_minigame.instantiate()
	get_tree().current_scene.add_child(minigame)
	minigame.finalizado.connect(_on_minigame_finalizado)

# Finaliza pesca e libera
func _on_minigame_finalizado(sucesso: bool) -> void:
	if barco_atual:
		barco_atual.set_pescando(false)
	
	if sucesso:
		_tocar_som(SOM_PICKUP)
		var peixes := ["carapeba", "tainha", "tilapia", "bagre"]
		var escolhido: String = peixes.pick_random()
		var nome_exibicao := ""
		match escolhido:
			"carapeba":
				Global.carapebaEstoque += 1
				nome_exibicao = "Carapeba (500g)"
			"tainha":
				Global.tainhaEstoque += 1
				nome_exibicao = "Tainha (1kg)"
			"tilapia":
				Global.tilapiaEstoque += 1
				nome_exibicao = "Tilápia (500g)"
			"bagre":
				Global.bagreEstoque += 1
				nome_exibicao = "Bagre (200g)"
		var hud := get_tree().current_scene.get_node_or_null("HUD")
		if hud and hud.has_method("mostrar_coleta"):
			hud.mostrar_coleta("+1 " + nome_exibicao + " pescado!")
		queue_free()
	else:
		_tocar_som(SOM_ERRO)
		pescando = false
		aviso_ui.visible = barco_atual != null

func _tocar_som(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	get_tree().current_scene.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
