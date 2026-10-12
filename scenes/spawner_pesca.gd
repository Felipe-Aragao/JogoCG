extends Area3D

@export var cena_ponto_pesca: PackedScene = preload("res://scenes/PontoPesca.tscn")
@export var quantidade_maxima := 1
@export var raio_seguranca := 3.0
@export var tolerancia_altura := 0.5
@export var offset_altura_visual := 0.3

@onready var caixa_spawn: CollisionShape3D = $CaixaSpawn
@onready var raycast: RayCast3D = $RayCast3D
@onready var barco: CharacterBody3D = $"../Barco"

var altura_agua := 0.0

func _ready() -> void:
	# Desativa colisão da caixa
	monitoring = false
	monitorable = false
	caixa_spawn.disabled = true
	
	# Configura raio de checagem
	raycast.enabled = false
	raycast.hit_from_inside = true
	raycast.target_position = Vector3(0, -200, 0)
	raycast.add_exception(barco)

func _physics_process(_delta: float) -> void:
	# Aguarda barco tocar água
	if not barco.is_on_floor():
		return
	
	set_physics_process(false)
	altura_agua = _medir_altura_agua_sob_barco()
	
	# Gera pontos iniciais
	for i in range(quantidade_maxima):
		criar_ponto_pesca()

# Mede altura da água
func _medir_altura_agua_sob_barco() -> float:
	raycast.global_basis = Basis.IDENTITY
	raycast.global_position = barco.global_position + Vector3(0, 50.0, 0)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		return raycast.get_collision_point().y
	
	return barco.global_position.y - 0.51

func criar_ponto_pesca() -> void:
	if not is_inside_tree():
		return
	
	# Calcula área de sorteio
	var box := caixa_spawn.shape as BoxShape3D
	var metade_tamanho := (box.size * caixa_spawn.global_basis.get_scale()) / 2.0
	var centro := caixa_spawn.global_position
	
	# Sorteia e instancia ponto
	for tentativa in range(50):
		var x := randf_range(centro.x - metade_tamanho.x, centro.x + metade_tamanho.x)
		var z := randf_range(centro.z - metade_tamanho.z, centro.z + metade_tamanho.z)
		
		if _ponto_eh_agua_valida(x, z):
			var novo_ponto := cena_ponto_pesca.instantiate() as Node3D
			get_tree().current_scene.add_child(novo_ponto)
			novo_ponto.global_position = Vector3(x, altura_agua + offset_altura_visual, z)
			novo_ponto.tree_exited.connect(_on_ponto_removido)
			return

func _ponto_eh_agua_valida(x: float, z: float) -> bool:
	# Pontos de checagem
	var direcoes := [
		Vector2.ZERO,
		Vector2(raio_seguranca, 0),
		Vector2(-raio_seguranca, 0),
		Vector2(0, raio_seguranca),
		Vector2(0, -raio_seguranca)
	]
	
	raycast.global_basis = Basis.IDENTITY
	
	for offset in direcoes:
		# Testa colisão vertical
		raycast.global_position = Vector3(x + offset.x, altura_agua + 80.0, z + offset.y)
		raycast.force_raycast_update()
		
		if not raycast.is_colliding():
			return false
		
		# Valida inclinação e altura
		var ponto_impacto := raycast.get_collision_point()
		var normal := raycast.get_collision_normal()
		
		var eh_plano := absf(normal.y) >= 0.95
		var esta_na_altura_da_agua := absf(ponto_impacto.y - altura_agua) <= tolerancia_altura
		
		if not eh_plano or not esta_na_altura_da_agua:
			return false
			
	return true

# Repõe ponto removido
func _on_ponto_removido() -> void:
	if is_inside_tree():
		criar_ponto_pesca.call_deferred()
