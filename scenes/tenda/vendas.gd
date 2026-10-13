extends Control
signal clienteGerado(nomeCliente)

@onready var infoDia = $HBoxContainer/Estoque/MarginContainer/VBoxContainer/InfoDia
@onready var textoCliente = $HBoxContainer/Central/MarginContainer/TextoCliente
@onready var entrada = $HBoxContainer/Math/MarginContainer/VBoxContainer/Entrada
@onready var buttonConfirma = $HBoxContainer/Math/MarginContainer/VBoxContainer/ButtonConfirma
@onready var feedback = $HBoxContainer/Math/MarginContainer/VBoxContainer/Feedback
@onready var confirma = $HBoxContainer/Math/MarginContainer/VBoxContainer/ButtonConfirma/Confirma
@onready var ajuda = $HBoxContainer/Math/MarginContainer/VBoxContainer/ButtonAjuda/Ajuda
@onready var curiosidade = $HBoxContainer/Math/MarginContainer/VBoxContainer/Curiosidade
@onready var sair = $HBoxContainer/Math/MarginContainer/VBoxContainer/ButtonSair/Sair
@onready var timerTexto = $TimerTexto
@onready var somTexto = $SomTexto
@onready var musicaVenda = $MusicaVenda
@onready var infoDinheiro = $HBoxContainer/Estoque/MarginContainer/VBoxContainer/InfoDinheiro
@onready var infoEstoque = $HBoxContainer/Estoque/MarginContainer/VBoxContainer/InfoEstoque
@onready var infoPreco = $HBoxContainer/Estoque/MarginContainer/VBoxContainer/InfoPreco
var dica: String = ""
var precoPorcao: float = 5.0
var quantidadePedida: int = 0
var respostaCorreta: float = 0.0
var totalPorcoes: int = 0
var catalogo = {
	"sururu": {
		"preco": 5.0, 
		"gramas": 250, # 4 unidades = 1 kg
		"curiosidade": "Para conseguir 1 quilo de sururu limpo, as marisqueiras precisam de 8 a 10 quilos na casca!"
	},
	"carapeba": {
		"preco": 15.0, 
		"gramas": 500, # 2 unidades = 1 kg
		"curiosidade": "A carapeba é um dos peixes mais valorizados da culinária alagoana, servida geralmente frita."
	},
	"tainha": {
		"preco": 12.0, 
		"gramas": 1000, # 1 unidade = 1 kg
		"curiosidade": "A tainha é famosa pelas ovas e é um peixe clássico nas épocas frias da lagoa."
	},
	"tilápia": {
		"preco": 10.0, 
		"gramas": 500, # 2 unidades = 1 kg
		"curiosidade": "A tilápia adaptou-se incrivelmente bem às águas do Brasil e é fonte de rendimento forte."
	},
	"bagre": {
		"preco": 8.0, 
		"gramas": 200, # 5 unidades = 1 kg
		"curiosidade": "O bagre tem 'bigodes' que funcionam como sensores para caçar na lama do fundo da lagoa!"
	}
}

var produtoAtual: String = ""
var frases_historicas = {
	"Zumbi dos Palmares": [
		"Preciso de %d %s de %s para alimentar o quilombo. Quanto lhe devo?",
        "A resistência precisa de força! Separe %d %s de %s. Qual o total?"
	],
	"Nise da Silveira": [
		"A verdadeira cura passa pelo afeto e por um bom prato. Vou querer %d %s de %s. Quanto fica a conta?",
        "Meus gatos adorariam o cheiro, mas é para os pacientes! Levo %d %s de %s. Qual o valor?"
	],
	"Graciliano Ramos": [
		"Sem rodeios. Embrulhe %d %s de %s. Diga logo o preço final.",
        "A seca é dura, mas a lagoa é farta. Quero %d %s de %s. Quanto lhe devo?"
	],
	"Marechal Deodoro da Fonseca": [
		"Proclamo que levarei %d %s deste belo %s! Apresente-me a conta, cidadão.",
        "Pela república e pela boa culinária alagoana! Encomendo %d %s de %s. Qual o valor?"
	],
	"Hermeto Pascoal": [
		"Até a natureza faz música! Bota %d %s de %s pra mim. Que som dá esse total?",
        "Que sinfonia de sabores! Vou levar %d %s de %s. Qual o resultado da partitura?"
	],
	"Dandara dos Palmares": [
		"Nenhuma guerreira luta com fome. Separe %d %s de %s. Qual o valor para o nosso povo?",
        "A liberdade tem gosto de força e união. Levo %d %s de %s. Qual é a conta?"
	]
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	atualizar_interface()
	call_deferred("gerar_novo_cliente")
	timerTexto.timeout.connect(_on_timer_texto_timeout)
	fade_in_music()
	#entrada.grab_focus()

func atualizar_interface():
	sair.text = "Sair"
	ajuda.text = "Ajuda"
	confirma.text = "Confirmar"
	infoDia.text = "Venda"
	infoDinheiro.text = "Dinheiro: R$ %.2f" % Global.dinheiro
	infoEstoque.text = "Estoque (Unidades):\nSururu: %d\nCarapeba: %d\nTainha: %d\nTilápia: %d\nBagre: %d" % [
		Global.sururuEstoque, 
		Global.carapebaEstoque, 
		Global.tainhaEstoque, 
		Global.tilapiaEstoque, 
		Global.bagreEstoque
	]
	infoPreco.text = "\nPreço %s: R$ %.2f" % [produtoAtual, precoPorcao]
	
func gerar_novo_cliente(): 
	entrada.text = ""
	feedback.text = ""
	entrada.visible = true
	buttonConfirma.visible = true
	var produtosDisponiveis = []
	if (Global.sururuEstoque * catalogo["sururu"]["gramas"]) >= 1000: produtosDisponiveis.append("sururu")
	if (Global.carapebaEstoque * catalogo["carapeba"]["gramas"]) >= 1000: produtosDisponiveis.append("carapeba")
	if (Global.tainhaEstoque * catalogo["tainha"]["gramas"]) >= 1000: produtosDisponiveis.append("tainha")
	if (Global.tilapiaEstoque * catalogo["tilápia"]["gramas"]) >= 1000: produtosDisponiveis.append("tilápia")
	if (Global.bagreEstoque * catalogo["bagre"]["gramas"]) >= 1000: produtosDisponiveis.append("bagre")
	
	if produtosDisponiveis.size() == 0:
		textoCliente.text = "Seu estoque de pescados está baixo e a clientela se mandou! Pressione 'Sair' e ande até o barco para avançar"
		entrada.visible = false
		buttonConfirma.visible = false
		produtoAtual = "sururu" 
		atualizar_interface()
		clienteGerado.emit("")
		return
	
	produtoAtual = produtosDisponiveis.pick_random()
	var infoProduto = catalogo[produtoAtual]
	
	precoPorcao = infoProduto["preco"]
	var gramasUnidade = infoProduto["gramas"]
	
	var estoque_do_produto = 0
	if produtoAtual == "sururu": estoque_do_produto = Global.sururuEstoque
	elif produtoAtual == "carapeba": estoque_do_produto = Global.carapebaEstoque
	elif produtoAtual == "tainha": estoque_do_produto = Global.tainhaEstoque
	elif produtoAtual == "tilápia": estoque_do_produto = Global.tilapiaEstoque
	elif produtoAtual == "bagre": estoque_do_produto = Global.bagreEstoque
	atualizar_interface()
	
	var max_kg_possivel = (estoque_do_produto * gramasUnidade) / 1000
	var maxPedido = min(4, max_kg_possivel) 
	
	quantidadePedida = randi_range(1, max(1, maxPedido))
	
	var gramas_totais = quantidadePedida * 1000
	var unidades_necessarias = gramas_totais / gramasUnidade
	
	totalPorcoes = unidades_necessarias 
	respostaCorreta = unidades_necessarias * precoPorcao
	
	dica = "DICA: 1 kg = 1000 gramas.\n1 unidade de %s pesa %d gramas.\nTransforme os kg em gramas." % [produtoAtual, gramasUnidade]
	curiosidade.text = "CURIOSIDADE: %s" % infoProduto["curiosidade"]
	
	var personagens = frases_historicas.keys()
	var clienteEscolhido = personagens.pick_random()
	clienteGerado.emit(clienteEscolhido)
	
	var frase = frases_historicas[clienteEscolhido].pick_random()
	var palavraMedida = "quilo" if quantidadePedida == 1 else "quilos"
	
	var textoFala = frase % [quantidadePedida, palavraMedida, produtoAtual]
	textoCliente.text = "%s: %s" % [clienteEscolhido, textoFala]
	textoCliente.visible_characters = 0
	timerTexto.start(0.04)
	
func _process(delta: float) -> void:
	if musicaVenda.playing and musicaVenda.get_playback_position() >=54.30:
		musicaVenda.play(0)


func _on_button_confirma_pressed() -> void:
	var texto = entrada.text.strip_edges()
	if not texto.is_valid_float():
		feedback.text = "Digite apenas números!"
		return
	var respostaJogador = float(texto)
	if is_equal_approx(respostaJogador,respostaCorreta):
		Global.dinheiro += respostaCorreta
		if produtoAtual == "sururu": Global.sururuEstoque -= totalPorcoes
		elif produtoAtual == "carapeba": Global.carapebaEstoque -= totalPorcoes
		elif produtoAtual == "tainha": Global.tainhaEstoque -= totalPorcoes
		elif produtoAtual == "tilápia": Global.tilapiaEstoque -= totalPorcoes
		elif produtoAtual == "bagre": Global.bagreEstoque -= totalPorcoes
		feedback.text = "Conta correta! O cliente pagou R$ %.2f e saiu satisfeito." %respostaCorreta
		atualizar_interface()
		
		await get_tree().create_timer(1.5).timeout
		gerar_novo_cliente()
	elif respostaJogador < respostaCorreta - 1:
		feedback.text = "Você errou! O cliente achou que era golpe pelo preço baixo! "
		await get_tree().create_timer(2).timeout
		gerar_novo_cliente()
	else:
		feedback.text ="Você errou a conta! O cliente achou caro e foi embora sem comprar."
		await get_tree().create_timer(2).timeout
		gerar_novo_cliente()


func _on_button_prox_dia_pressed() -> void:
	Global.diaAtual += 1 
	Global.venda = false
	fade_out_music(true)
	Transicao.mudar_cena("res://scenes/fechamento/fechamentos.tscn")


func _on_button_ajuda_pressed() -> void:
	if Global.sururuEstoque <= 0 && Global.bagreEstoque == 0 && Global.carapebaEstoque == 0 && Global.tilapiaEstoque == 0 && Global.tainhaEstoque == 0 :
		return
	feedback.text = dica


func _on_button_sair_pressed() -> void:
	Global.venda = false
	get_node("/root/Mundo/Clientes").visible = false
	get_parent().visible = false 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_node("/root/Mundo/HUD/Legenda").visible = true
	fade_out_music(true)

func _on_timer_texto_timeout() -> void:
	# Verifica se ainda há letras escondidas
	if textoCliente.visible_characters < textoCliente.text.length():
		textoCliente.visible_characters += 1
		var letraAtual = textoCliente.text[textoCliente.visible_characters -1]
		if letraAtual != "":
			somTexto.pitch_scale = randf_range(0.95, 1.05) 
			somTexto.play()
	else:
		timerTexto.stop()
func fade_in_music():
	if not musicaVenda.playing:
		musicaVenda.volume_db = - 80.0
		musicaVenda.play()
	var tween = create_tween()
	tween.tween_property(musicaVenda,"volume_db",-10,0.6)
func fade_out_music(pararFinal: bool = false):
	var tween = create_tween()
	tween.tween_property(musicaVenda, "volume_db",-80,1.5)
	if pararFinal:
		tween.tween_callback(musicaVenda.stop)
	return tween
	
