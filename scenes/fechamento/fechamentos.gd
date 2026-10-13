extends Control
@onready var saldos = $MarginContainer/VBoxContainer/Saldos
@onready var custos = $MarginContainer/VBoxContainer/Custos
@onready var aluguel = $MarginContainer/VBoxContainer/Aluguel
@onready var faturamento = $MarginContainer/VBoxContainer/Faturamento
@onready var confirma = $"MarginContainer/VBoxContainer/ButtonAvançar/confirma"
@onready var lucro = $MarginContainer/VBoxContainer/Lucro
@onready var feedback = $MarginContainer/VBoxContainer/Feedback
@onready var click = $ClickSound
var custoAluguel: float = Global.dinheiro*4/10
var custoFixo: float = 15.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirma.text = "Confirmar"
	saldos.text = "--- FECHAMENTO DO DIA ---\nSaldo Inicial do Dia: R$ %.2f\nSaldo Atual: R$ %.2f" % [Global.dinheiroInicioDia, Global.dinheiro]
	custos.text = "O aluguel da tenda custa no mínimo R$ %.2f. O seu custo fixo é de R$ %d\nDigite quanto você vai pagar:" % [custoAluguel, custoFixo]
	aluguel.placeholder_text = "Valor pago no aluguel"
	faturamento.placeholder_text = "Calcule o faturamento"
	lucro.placeholder_text = "Calcule o lucro"
	feedback.text = ""
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_avançar_pressed() -> void:
	click.play()
	var valor_pago = float(aluguel.text.strip_edges().replace(",", "."))
	var faturamento_usuario = float(faturamento.text.strip_edges().replace(",", "."))
	var lucro_usuario = float(lucro.text.strip_edges().replace(",", "."))
	
	var faturamento_real = Global.dinheiro - Global.dinheiroInicioDia
	var lucro_real = faturamento_real - valor_pago
	
	#Aluguel 
	if valor_pago < custoAluguel + custoFixo:
		feedback.text = "Custos errados!" 
		return
		
	#Faturamento = Saldo Atual - Saldo Inicial
	if not is_equal_approx(faturamento_usuario, faturamento_real):
		feedback.text = "Faturamento incorreto! Lembre-se: Faturamento é apenas o que entrou"
		return
		
	# Lucro = Faturamento - Custos Pagos
	if not is_equal_approx(lucro_usuario, lucro_real):
		feedback.text = "Lucro incorreto! Lembre-se: Lucro é o seu Faturamento menos os Custos que você pagou."
		return
		
	# Acertou
	Global.dinheiro -= valor_pago
	if Global.dinheiro < 0:
			Transicao.mudar_cena("res://scenes/menu/menu_over.tscn")
			return
	Global.dinheiroInicioDia = Global.dinheiro 
	Global.diaAtual += 1
	
	
	Transicao.mudar_cena("res://scenes/game.tscn")
