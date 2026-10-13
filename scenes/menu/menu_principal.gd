extends Control

var cena_da_tenda = "res://scenes/game.tscn"
@onready var music = $MenuMusic
@onready var click = $ClickSound
func _ready():
	music.play()
func _on_button_jogar_pressed() -> void:
	click.play()
	Transicao.mudar_cena(cena_da_tenda)
	
	
func _on_button_sair_pressed() -> void:
	get_tree().quit()
