extends Control

@onready var infoDia = $InfoDia
@onready var textoCliente = $TextoCliente
@onready var entrada = $Entrada
@onready var buttonConfirma = $ButtonConfirma
@onready var feedback = $Feedback
@onready var buttonProxDia = $ButtonProxDia
@onready var confirma = $ButtonConfirma/Confirma
@onready var proximoDia = $"ButtonProxDia/Próximo dia"
@onready var ajuda = $ButtonAjuda/Ajuda
@onready var curiosidade = $Curiosidade
@onready var sair = $ButtonSair/Sair

var dica: String = ""
var precoPorcao: float = 5.0
var quantidadePedida: int = 0
var respostaCorreta: float = 0.0
var totalPorcoes: int = 0
var unidades_medida = [
	{
		"singular": "balaio", 
		"plural": "balaios", 
		"fator": 20, 
		"curiosidade" : "O balaio é um cesto feito de palha trançada. Um balaio grande bem cheio pode carregar até 15 kg de sururu na casca!",
		"dica": "DICA: Um balaio cheio rende 5 quilos. Cada quilo rende 4 porções"
	},
	{
		"singular": "quilo", 
		"plural": "quilos", 
		"fator": 4, 
		"curiosidade": "Sabia que para conseguir 1 quilo de sururu limpo (despinicado), as marisqueiras precisam pescar cerca de 8 a 10 quilos de sururu na casca?",
		"dica": "1 quilo de sururu limpo (despinicado) rende exatamente 4 porções bem servidas."
	},
	{
		"singular": "porção", 
		"plural": "porções", 
		"fator": 1, 
		"curiosidade" : "Uma porção de caldo de sururu costuma levar cerca de 250 gramas de molusco, o ideal para um prato bem servido.",
		"dica": "O pedido já está em porções! É só multiplicar a quantidade pedida pelo preço da porção."
	},
	{
		"singular": "bacia", 
		"plural": "bacias", 
		"fator": 10, 
		"curiosidade" : "As bacias de alumínio são muito usadas para lavar a lama do sururu na beira da lagoa. Uma bacia média comporta até 5 quilos!",
		"dica":"Uma bacia média limpa equivale a 2,5 quilos. Sabe-se que 1 quilo são 4 porções."
	}
]
var frases_historicas = {
	"Zumbi dos Palmares": [
		"Preciso de %d %s de sururu para alimentar o quilombo. Quanto lhe devo?",
		"A resistência precisa de força! Separe %d %s. Qual o total?"
	],
	"Nise da Silveira": [
		"A verdadeira cura passa pelo afeto e por um bom caldo. Vou querer %d %s. Quanto fica a conta?",
		"Meus gatos adorariam o cheiro, mas é para os pacientes! Levo %d %s. Qual o valor?"
	],
	"Graciliano Ramos": [
		"Sem rodeios. Embrulhe %d %s. Diga logo o preço final.",
		"A seca é dura, mas a lagoa é farta. Quero %d %s.Quanto lhe devo?"
	],
	"Marechal Deodoro da Fonseca": [
		"Proclamo que levarei %d %s deste belo sururu! Apresente-me a conta, cidadão.",
		"Pela república e pela boa culinária alagoana! Encomendo %d %s. Qual o valor?"
	],
	"Hermeto Pascoal": [
		"Até as conchas fazem música! Bota %d %s pra mim. Que som dá esse total?",
		"Que sinfonia de sabores! Vou levar %d %s. Qual o resultado da partitura?"
	],
	"Dandara dos Palmares": [
		"Nenhuma guerreira luta com fome. Separe %d %s de sururu. Qual o valor para o nosso povo?",
		"A liberdade tem gosto de força e união. Levo %d %s. Qual é a conta?"
	]
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	atualizar_interface()
	gerar_novo_cliente()
	
	entrada.grab_focus()

func atualizar_interface():
	sair.text = "sair"
	ajuda.text = "Ajuda"
	proximoDia.text = "Proximo dia"
	confirma.text = "Confirmar"
	infoDia.text = "Dia: %d | Dinheiro: R$ %.2f | Estoque de sururu %d | Preço da porção: R$ %.2f" %[
		Global.diaAtual, Global.dinheiro, Global.sururuEstoque, precoPorcao
	]
	
func gerar_novo_cliente(): 
	entrada.text = ""
	feedback.text = ""
	if Global.sururuEstoque <= 0:
		textoCliente.text = "O estoque de sururu acabou! Avance para o próximo dia."
		entrada.visible = false
		buttonConfirma.visible = false
		return
	entrada.visible = true
	buttonConfirma.visible = true
	
	var tipoMedida = unidades_medida.pick_random()
	var multiplicador = tipoMedida["fator"]
	curiosidade.text = "CURIOSIDADE: %s" %tipoMedida["curiosidade"]
	var maxUnidade = Global.sururuEstoque / multiplicador
	
	if maxUnidade < 1 :
		tipoMedida = unidades_medida[2]
		multiplicador = 1
		maxUnidade = Global.sururuEstoque
	var maxPedido = min(4, maxUnidade)
	quantidadePedida = randi_range(1,maxPedido)
	
	totalPorcoes = quantidadePedida * multiplicador
	respostaCorreta = totalPorcoes * precoPorcao
	
	var personagens =frases_historicas.keys()
	var clienteEscolhido = personagens.pick_random()
	
	var frase = frases_historicas[clienteEscolhido].pick_random()
	
	var palavraMedida = tipoMedida["singular"] if quantidadePedida == 1 else tipoMedida["plural"]
	dica = tipoMedida["dica"]
	var textoFala = frase % [quantidadePedida,palavraMedida]
	textoCliente.text = "%s: %s" % [clienteEscolhido,textoFala]
	
func _process(delta: float) -> void:
	pass


func _on_button_confirma_pressed() -> void:
	var texto = entrada.text.strip_edges()
	if not texto.is_valid_float():
		feedback.text = "Digite apenas números!"
		return
	var respostaJogador = float(texto)
	if is_equal_approx(respostaJogador,respostaCorreta):
		Global.dinheiro += respostaCorreta
		Global.sururuEstoque -= totalPorcoes
		feedback.text = "Conta correta! O cliente pagou R$ %.2f e saiu satisfeito." %respostaCorreta
		atualizar_interface()
		
		await get_tree().create_timer(1.5).timeout
		gerar_novo_cliente()
	elif respostaJogador < respostaCorreta - 1:
		feedback.text = "Você errou, o cliente achou que era golpe pelo preço baixo! "
		await get_tree().create_timer(2).timeout
		gerar_novo_cliente()
	else:
		feedback.text ="Você errou a conta! O cliente achou caro e foi embora sem comprar."
		await get_tree().create_timer(2).timeout
		gerar_novo_cliente()


func _on_button_prox_dia_pressed() -> void:
	Global.diaAtual += 1 
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_button_ajuda_pressed() -> void:
	if Global.sururuEstoque <= 0:
		return
	feedback.text = dica


func _on_button_sair_pressed() -> void:
	Global.venda = false
	get_parent().visible = false 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
