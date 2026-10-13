extends CanvasLayer

signal finalizado(sucesso: bool)

@export var velocidade_cursor := 450.0

@onready var barra: ColorRect = $Barra
@onready var zona_alvo: ColorRect = $Barra/ZonaAlvo
@onready var cursor: ColorRect = $Barra/Cursor

var _direcao := 1.0

# Sorteia posição do alvo
func _ready() -> void:
	var limite_alvo := barra.size.x - zona_alvo.size.x
	zona_alvo.position.x = randf_range(0.0, limite_alvo)
	cursor.position.x = 0.0

# Move cursor em ping-pong
func _process(delta: float) -> void:
	var limite_cursor := barra.size.x - cursor.size.x
	cursor.position.x += _direcao * velocidade_cursor * delta
	
	if cursor.position.x >= limite_cursor:
		cursor.position.x = limite_cursor
		_direcao = -1.0
	elif cursor.position.x <= 0.0:
		cursor.position.x = 0.0
		_direcao = 1.0

# Checa acerto no Espaço
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		
		var centro_cursor := cursor.position.x + (cursor.size.x / 2.0)
		var inicio_alvo := zona_alvo.position.x
		var fim_alvo := zona_alvo.position.x + zona_alvo.size.x
		
		var acertou := centro_cursor >= inicio_alvo and centro_cursor <= fim_alvo
		finalizado.emit(acertou)
		queue_free()
