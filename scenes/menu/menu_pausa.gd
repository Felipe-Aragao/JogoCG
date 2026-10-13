extends CanvasLayer
@onready var click = $ClickSound
func _ready() -> void:
	# O menu já nasce invisível sem precisar que outros scripts mandem
	hide() 

# Ele mesmo escuta o teclado, independentemente da cena onde for colocado
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not Global.venda:
		alternar_pausa()

func alternar_pausa() -> void:
	if get_tree().paused:
		get_tree().paused = false
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		get_tree().paused = true
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_jogar_pressed() -> void:
	click.play()
	alternar_pausa()

func _on_button_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Transicao.mudar_cena("res://scenes/menu/menu_principal.tscn")
