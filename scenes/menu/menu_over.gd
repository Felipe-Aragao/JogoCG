extends Control
@onready var over = $SoundOver
func _ready() -> void:
	over.play()
	modulate.a = 0.0
	
	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate:a", 1.0, 1.5)
	
	# 3. Espera a animação de entrada terminar, e depois aguarda os 5 segundos exigidos
	await tween_in.finished
	await get_tree().create_timer(5.0).timeout
	
	# 4. Fade-out: Anima o canal Alpha de 1.0 de volta para 0.0
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate:a", 0.0, 5)
	
	# 5. Espera o escurecimento terminar para não cortar a cena bruscamente
	await tween_out.finished
	
	# 6. Prepara o jogo para recomeçar limpando o Singleton
	resetar_dados_globais()
	
	# 7. Volta para o Menu Principal
	get_tree().change_scene_to_file("res://scenes/menu/menu_principal.tscn")

# Função vital de Engenharia de Software: Restaurar o Estado Inicial
func resetar_dados_globais() -> void:
	Global.dinheiro = 0.0 # ou o seu valor inicial padrão
	Global.diaAtual = 1
	Global.venda = false
	Global.sururuEstoque = 0
	Global.carapebaEstoque = 0
	Global.tainhaEstoque = 0
	Global.tilapiaEstoque = 0
	Global.bagreEstoque = 0
