extends Node3D

@onready var telaVenda = $CanvasLayer
@onready var legenda = $HUD/Legenda
@onready var iconeEnter = $HUD/IconeEnter
@onready var clientes = $Clientes
@onready var jogador: CharacterBody3D = $CharacterBody3D
var jogadorPertoTenda: bool = false
var jogadorPertoBarco: bool = false
var _transform_inicial_jogador: Transform3D


var mapa_nomes = {
	"Zumbi dos Palmares": "Zumbi",
	"Nise da Silveira": "Nise",
	"Graciliano Ramos": "Graciliano",
	"Marechal Deodoro da Fonseca": "Marechal",
	"Hermeto Pascoal": "Hermeto",
	"Dandara dos Palmares": "Dandara"
}

# Inicializa cena do mundo
func _ready() -> void:
	_transform_inicial_jogador = jogador.global_transform
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

# Processamento a cada frame
func _process(delta: float) -> void:
	pass

func _on_area_3d_2_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D": 
		jogadorPertoTenda = true
		legenda.text = ""
		if not Global.venda:
			iconeEnter.visible = true


func _on_area_3d_2_body_exited(body: Node3D) -> void:
	if body.name == "CharacterBody3D": 
		jogadorPertoTenda = false
		iconeEnter.visible = jogadorPertoBarco and not Global.venda
		if Global.sururuEstoque <= 0: legenda.text = "Siga para o Barco para avançar."
		else :  legenda.text = "Ainda podemos fazer dinheiro!"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interagir") and not Global.venda:
		if jogadorPertoTenda:
			abrir_loja()
		elif jogadorPertoBarco:
			ir_para_fechamento()

func abrir_loja():
	Global.venda = true
	jogador.velocity = Vector3.ZERO
	jogador.global_transform = _transform_inicial_jogador
	jogador.camera.rotation = Vector3.ZERO
	telaVenda.visible = true
	clientes.visible = true
	legenda.visible = false
	iconeEnter.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	telaVenda.get_child(0).entrada.grab_focus()
	telaVenda.get_child(0).fade_in_music()


func _on_area_barco_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D":
		jogadorPertoBarco = true
		legenda.text = ""
		if not Global.venda:
			iconeEnter.visible = true

func _on_area_barco_body_exited(body: Node3D) -> void:
	if body.name == "CharacterBody3D":
		jogadorPertoBarco = false
		iconeEnter.visible = jogadorPertoTenda and not Global.venda
		if Global.sururuEstoque <= 0: legenda.text = "Siga para o Barco para avançar."
		else :  legenda.text = "Ainda podemos fazer dinheiro!"

func ir_para_fechamento() -> void:
	Global.venda = false
	iconeEnter.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	# Abre tela de fechamento
	Transicao.mudar_cena("res://scenes/fechamento/fechamentos.tscn")
