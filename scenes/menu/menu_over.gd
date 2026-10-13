extends Control
@onready var over = $SoundOver
func _ready() -> void:
	over.play()
	modulate.a = 0.0
	
	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate:a", 1.0, 1.5)
	
	# Aguarda animação de entrada
	await tween_in.finished
	await get_tree().create_timer(5.0).timeout
	
	# Inicia fade out
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate:a", 0.0, 5)
	
	# Aguarda fim do fade
	await tween_out.finished
	
	# Reseta dados globais
	resetar_dados_globais()
	
	# Retorna ao menu principal
	get_tree().change_scene_to_file("res://scenes/menu/menu_principal.tscn")

# Restaura o estado inicial
func resetar_dados_globais() -> void:
	Global.dinheiro = 0.0 # Valor inicial padrão
	Global.dinheiroInicioDia = 0.0
	Global.diaAtual = 1
	Global.venda = false
	Global.sururuEstoque = 0
	Global.carapebaEstoque = 0
	Global.tainhaEstoque = 0
	Global.tilapiaEstoque = 0
	Global.bagreEstoque = 0
