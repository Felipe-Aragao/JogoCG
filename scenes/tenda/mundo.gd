extends Node3D

@onready var telaVenda = $CanvasLayer
@onready var legenda = $HUD/Legenda
var jogadorPertoTenda: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	telaVenda.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_2_body_entered(body: Node3D) -> void:
	legenda.text = "Aperte ENTER para abrir o menu."
	if body.name == "CharacterBody3D": 
		jogadorPertoTenda = true


func _on_area_3d_2_body_exited(body: Node3D) -> void:
	if Global.sururuEstoque > 0: legenda.text = "Temos dinheiro a fazer! Volte para a tenda."
	legenda.text = "Avance para o próximo dia"
	if body.name == "CharacterBody3D": 
		jogadorPertoTenda = false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interagir") and jogadorPertoTenda and not Global.venda:
		legenda.visible = false
		abrir_loja()

func abrir_loja():
	Global.venda = true
	telaVenda.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	telaVenda.get_child(0).entrada.grab_focus()
	
