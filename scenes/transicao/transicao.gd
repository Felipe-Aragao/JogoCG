extends CanvasLayer

@onready var cor_fundo = $ColorRect
func _ready() -> void:
	cor_fundo.modulate.a = 0.0
	cor_fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass

func mudar_cena(caminho_da_cena: String) -> void:
	cor_fundo.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween_escurecer = create_tween()
	tween_escurecer.tween_property(cor_fundo, "modulate:a", 1.0, 1.0)
	await tween_escurecer.finished # Espera a animação terminar
	
	get_tree().change_scene_to_file(caminho_da_cena)
	
	var tween_clarear = create_tween()
	tween_clarear.tween_property(cor_fundo, "modulate:a", 0.0, 0.5)
	await tween_clarear.finished # Espera terminar
	
	cor_fundo.mouse_filter = Control.MOUSE_FILTER_IGNORE
