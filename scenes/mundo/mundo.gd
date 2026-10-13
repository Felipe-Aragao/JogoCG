extends Node3D

@onready var telaVenda = $CanvasLayer
@onready var legenda = $HUD/Legenda
@onready var clientes = $Clientes
var jogadorPertoTenda: bool = false


var mapa_nomes = {
	"Zumbi dos Palmares": "Zumbi",
	"Nise da Silveira": "Nise",
	"Graciliano Ramos": "Graciliano",
	"Marechal Deodoro da Fonseca": "Marechal",
	"Hermeto Pascoal": "Hermeto",
	"Dandara dos Palmares": "Dandara"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	telaVenda.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	telaVenda.get_child(0).clienteGerado.connect(_mostrar_cliente)
	clientes.visible = false
	call_deferred("abrir_loja")

func _mostrar_cliente(nomeCompleto: String) -> void:
	for cliente in clientes.get_children():
		cliente.visible = false
	var nomeCliente = mapa_nomes.get(nomeCompleto, "") 
	if nomeCliente != "" and clientes.has_node(nomeCliente):
		clientes.get_node(nomeCliente).visible = true
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
		if Global.sururuEstoque <= 0: legenda.text = "Siga para o Barco para avançar."
		else :  legenda.text = "Ainda podemos fazer dinheiro!"
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interagir") and jogadorPertoTenda and not Global.venda:
		abrir_loja()

func abrir_loja():
	Global.venda = true
	telaVenda.visible = true
	clientes.visible = true
	legenda.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	telaVenda.get_child(0).entrada.grab_focus()
	telaVenda.get_child(0).fade_in_music()


func _on_area_barco_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D": 
		
		Global.venda = false
		
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
		
		# Manda o jogador para a tela de cálculos financeiros
		Transicao.mudar_cena("res://scenes/fechamento/fechamentos.tscn")
