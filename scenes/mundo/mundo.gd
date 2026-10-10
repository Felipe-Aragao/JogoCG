extends Node3D

@onready var telaVenda = $CanvasLayer
@onready var legenda = $HUD/Legenda
var jogadorPertoTenda: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	telaVenda.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_2_body_entered(body: Node3D) -> void:
	legenda.text = "Aperte ENTER para abrir o menu."
	if body.name == "CharacterBody3D": 
		jogadorPertoTenda = true


func _on_area_3d_2_body_exited(body: Node3D) -> void:
	if body.name == "CharacterBody3D": 
		jogadorPertoTenda = false
		if Global.sururuEstoque <= 0: legenda.text = "Retorne a tenda para avançar para o próximo dia."
		else :  legenda.text = "Temos dinheiro a fazer! Volte para a tenda."
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interagir") and jogadorPertoTenda and not Global.venda:
		abrir_loja()

func abrir_loja():
	Global.venda = true
	telaVenda.visible = true
	legenda.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	telaVenda.get_child(0).entrada.grab_focus()
	
