extends CanvasLayer

signal finalizado(sucesso: bool)

const TECLAS := {
	KEY_W: preload("res://assets/keyboard/Dark/W_Key_Dark.png"),
	KEY_A: preload("res://assets/keyboard/Dark/A_Key_Dark.png"),
	KEY_S: preload("res://assets/keyboard/Dark/S_Key_Dark.png"),
	KEY_D: preload("res://assets/keyboard/Dark/D_Key_Dark.png"),
	KEY_Q: preload("res://assets/keyboard/Dark/Q_Key_Dark.png"),
	KEY_E: preload("res://assets/keyboard/Dark/E_Key_Dark.png"),
	KEY_F: preload("res://assets/keyboard/Dark/F_Key_Dark.png"),
	KEY_R: preload("res://assets/keyboard/Dark/R_Key_Dark.png"),
	KEY_C: preload("res://assets/keyboard/Dark/C_Key_Dark.png"),
	KEY_V: preload("res://assets/keyboard/Dark/V_Key_Dark.png")
}

@onready var container: HBoxContainer = $HBoxContainer

var _sequencia: Array[int] = []
var _icones: Array[TextureRect] = []
var _indice_atual := 0

# Sorteia cinco teclas
func _ready() -> void:
	var codigos := TECLAS.keys()
	
	for filho in container.get_children():
		if filho is TextureRect:
			var codigo: int = codigos.pick_random()
			_sequencia.append(codigo)
			filho.texture = TECLAS[codigo]
			_icones.append(filho)

# Verifica tecla pressionada
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	
	var key_event := event as InputEventKey
	var tecla := key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
	
	if not TECLAS.has(tecla):
		return
	
	get_viewport().set_input_as_handled()
	
	# Avança ou reinicia sequência
	if tecla == _sequencia[_indice_atual]:
		_icones[_indice_atual].modulate = Color(0.3, 1.0, 0.3, 0.45)
		_indice_atual += 1
		
		if _indice_atual >= _sequencia.size():
			finalizado.emit(true)
			queue_free()
	else:
		_indice_atual = 0
		for icone in _icones:
			icone.modulate = Color.WHITE
