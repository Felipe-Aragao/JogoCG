extends Node3D

@export var cena_sururu: PackedScene
@export var quantidade: int = 180
@export var tamanho_lagoa_x: float = 180.0 
@export var tamanho_lagoa_z: float = 180.0 
@export var altura_agua: float = 0.23 # 
@onready var pasta_coletaveis = $Coletaveis
@onready var count = $CanvasLayer/Count
@onready var coletaMusic = $ColetaMusic

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	coletaMusic.play()
	# O randomize() garante que as posições sejam sempre diferentes 
	randomize() 
	espalhar_sururus()
func _process(delta: float):
	if coletaMusic.playing and coletaMusic.get_playback_position() >= 350:
		coletaMusic.play(0)
	count.text = "Sururu: %d" % Global.sururuEstoque
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		
		get_tree().change_scene_to_file("res://scenes/mundo/mundo.tscn")

func espalhar_sururus() -> void:
	if cena_sururu == null:
		return
		
	for i in range(quantidade):
		var novo_sururu = cena_sururu.instantiate()
		
		var pos_x = randf_range(-tamanho_lagoa_x / 2, tamanho_lagoa_x / 2)
		var pos_z = randf_range(-tamanho_lagoa_z / 2, tamanho_lagoa_z / 2)
		
		novo_sururu.position = Vector3(pos_x, altura_agua, pos_z)
		
		pasta_coletaveis.add_child(novo_sururu)
