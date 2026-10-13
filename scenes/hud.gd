extends CanvasLayer

@onready var label_timer: Label = $TimerTexto
@onready var timer_pesca: Timer = $TimerPesca
@onready var musica_pesca: AudioStreamPlayer = $MusicaPesca
@onready var aviso_coleta: Label = $AvisoColeta

var _tween_aviso: Tween

func _ready() -> void:
	aviso_coleta.text = ""
	timer_pesca.timeout.connect(_on_timer_pesca_timeout)
	musica_pesca.finished.connect(func(): musica_pesca.play())
	if not musica_pesca.playing:
		musica_pesca.play()

func mostrar_coleta(mensagem: String) -> void:
	if _tween_aviso and _tween_aviso.is_running():
		_tween_aviso.kill()
	aviso_coleta.text = mensagem
	aviso_coleta.modulate.a = 1.0
	_tween_aviso = create_tween()
	_tween_aviso.tween_interval(2.0)
	_tween_aviso.tween_property(aviso_coleta, "modulate:a", 0.0, 0.5)

func _process(_delta: float) -> void:
	# Formata tempo restante MM:SS
	var tempo_restante := int(ceil(timer_pesca.time_left))
	var minutos := tempo_restante / 60
	var segundos := tempo_restante % 60
	label_timer.text = "%02d:%02d" % [minutos, segundos]

func _on_timer_pesca_timeout() -> void:
	# Encerra pesca e avança
	musica_pesca.stop()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Transicao.mudar_cena("res://scenes/mundo/mundo.tscn")
