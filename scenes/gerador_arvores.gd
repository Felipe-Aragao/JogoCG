@tool
extends Node3D

@export_tool_button("Gerar Árvores") var botao_gerar = gerar_arvores
@export_tool_button("Limpar Árvores") var botao_limpar = limpar_arvores

@export var modelos_arvores: Array[PackedScene] = [
	preload("res://scenes/arvores/arvore1.tscn"),
	preload("res://scenes/arvores/arvore2.tscn")
]
@export var quantidade := 250
@export var distancia_minima := 8.0
@export var distancia_min_lagoa := 8.0
@export var distancia_max_lagoa := 220.0
@export var escala_minima := 2.0
@export var escala_maxima := 4.0
@export var afundar_no_chao := 0.25

# Remove árvores atuais
func limpar_arvores() -> void:
	for filho in get_children():
		filho.free()

# Garante cenas atualizadas
func _atualizar_modelos() -> void:
	# Verifica caminhos das cenas
	var recarregar := modelos_arvores.is_empty()
	for cena in modelos_arvores:
		if not cena or not cena.resource_path.begins_with("res://scenes/arvores/"):
			recarregar = true
			break
	
	# Recarrega cenas padrão
	if recarregar:
		modelos_arvores = [
			load("res://scenes/arvores/arvore1.tscn"),
			load("res://scenes/arvores/arvore2.tscn")
		]
	
	# Atualiza escala e alcance
	if escala_minima < 2.0:
		escala_minima = 2.0
		escala_maxima = 4.0
	if distancia_max_lagoa <= 65.0:
		distancia_max_lagoa = 220.0

# Espalha árvores na margem
func gerar_arvores() -> void:
	limpar_arvores()
	_atualizar_modelos()
	
	# Busca malha do terreno
	var malha_terreno := get_node_or_null("../Terreno/Terreno2/Terreno") as MeshInstance3D
	if not malha_terreno or not malha_terreno.mesh:
		push_warning("Malha do Terreno não encontrada.")
		return
	
	# Obtém triângulos da margem
	var dados := _coletar_triangulos_margem(malha_terreno)
	var triangulos: Array = dados["triangulos"]
	var pontos_borda: PackedVector2Array = dados["pontos_borda"]
	
	if triangulos.is_empty():
		push_warning("Nenhum triângulo de margem encontrado.")
		return
	
	var posicoes_ocupadas: PackedVector3Array = []
	var tentativas_maximas := quantidade * 50
	
	# Sorteia posições na margem
	for tentativa in range(tentativas_maximas):
		if posicoes_ocupadas.size() >= quantidade:
			break
		
		var tri: Dictionary = triangulos.pick_random()
		var ponto := _ponto_na_faixa_da_margem(tri)
		
		if not _esta_na_faixa_da_lagoa(ponto, pontos_borda):
			continue
		if not _respeita_distancia_minima(ponto, posicoes_ocupadas):
			continue
		
		posicoes_ocupadas.append(ponto)
		_instanciar_arvore(ponto, tri["normal"])
	
	print("Árvores geradas na margem: ", posicoes_ocupadas.size())

# Coleta triângulos da borda
func _coletar_triangulos_margem(malha_terreno: MeshInstance3D) -> Dictionary:
	var faces := malha_terreno.mesh.get_faces()
	var xform := malha_terreno.global_transform
	var triangulos: Array = []
	var pontos_borda := PackedVector2Array()
	
	# Filtra faces da terra
	for i in range(0, faces.size(), 3):
		var a_loc := faces[i]
		var b_loc := faces[i + 1]
		var c_loc := faces[i + 2]
		
		if a_loc.y < 0.03 or b_loc.y < 0.03 or c_loc.y < 0.03:
			continue
		
		var a := xform * a_loc
		var b := xform * b_loc
		var c := xform * c_loc
		
		# Ignora barrancos muito íngremes
		var normal := (b - a).cross(c - a).normalized()
		if absf(normal.y) < 0.7:
			continue
		
		var internos: Array[Vector3] = []
		var externos: Array[Vector3] = []
		
		# Separa vértices da margem
		for idx in range(3):
			var v_loc := faces[i + idx]
			var v_glob := xform * v_loc
			if v_loc.y <= 0.052:
				internos.append(v_glob)
				pontos_borda.append(Vector2(v_glob.x, v_glob.z))
			else:
				externos.append(v_glob)
		
		if not internos.is_empty():
			triangulos.append({
				"internos": internos,
				"externos": externos,
				"vertices": [a, b, c],
				"normal": normal
			})
	
	return {"triangulos": triangulos, "pontos_borda": pontos_borda}

# Sorteia ponto próximo lagoa
func _ponto_na_faixa_da_margem(tri: Dictionary) -> Vector3:
	var internos: Array = tri["internos"]
	var externos: Array = tri["externos"]
	
	# Sorteia em triângulo interno
	if externos.is_empty():
		var v: Array = tri["vertices"]
		var r1 := sqrt(randf())
		var r2 := randf()
		return v[0] * (1.0 - r1) + v[1] * (r1 * (1.0 - r2)) + v[2] * (r1 * r2)
	
	# Interpola da borda para fora
	var base: Vector3 = internos[0] if internos.size() == 1 else internos[0].lerp(internos[1], randf())
	var alvo: Vector3 = externos[0] if externos.size() == 1 else externos[0].lerp(externos[1], randf())
	
	var comprimento := base.distance_to(alvo)
	if comprimento <= 0.01:
		return base
	
	var dist := randf_range(distancia_min_lagoa, distancia_max_lagoa)
	var t := clampf(dist / comprimento, 0.0, 1.0)
	return base.lerp(alvo, t)

# Valida distância da lagoa
func _esta_na_faixa_da_lagoa(ponto: Vector3, pontos_borda: PackedVector2Array) -> bool:
	var p2d := Vector2(ponto.x, ponto.z)
	var menor_dist_sq := INF
	
	# Busca borda mais próxima
	for borda in pontos_borda:
		var d_sq := p2d.distance_squared_to(borda)
		if d_sq < menor_dist_sq:
			menor_dist_sq = d_sq
	
	var min_sq := distancia_min_lagoa * distancia_min_lagoa
	var max_sq := distancia_max_lagoa * distancia_max_lagoa
	return menor_dist_sq >= min_sq and menor_dist_sq <= max_sq

# Evita árvores mesmo local
func _respeita_distancia_minima(ponto: Vector3, ocupadas: PackedVector3Array) -> bool:
	var dist_quadrada := distancia_minima * distancia_minima
	for pos in ocupadas:
		if ponto.distance_squared_to(pos) < dist_quadrada:
			return false
	return true

# Cria árvore fixada chão
func _instanciar_arvore(posicao: Vector3, normal: Vector3) -> void:
	# Instancia cena sorteada
	var cena: PackedScene = modelos_arvores.pick_random()
	var arvore := cena.instantiate() as Node3D
	add_child(arvore)
	
	# Define escala e rotação
	var escala := randf_range(escala_minima, escala_maxima)
	arvore.scale = Vector3.ONE * escala
	arvore.rotation.y = randf() * TAU
	
	# Ajusta altura na ladeira
	var ny := clampf(absf(normal.y), 0.2, 1.0)
	var inclinacao := sqrt(maxf(0.0, 1.0 - ny * ny)) / ny
	var offset_y := -(afundar_no_chao + inclinacao * 0.5) * escala
	arvore.global_position = posicao + Vector3(0.0, offset_y, 0.0)
	
	# Registra nó no editor
	if Engine.is_editor_hint():
		arvore.owner = get_tree().edited_scene_root
