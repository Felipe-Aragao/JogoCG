extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Barco": 
		Global.sururuEstoque += 1
		print("Pegou um sururu! Estoque: ", Global.sururuEstoque)
		body.get_node("SomColeta").play()
		queue_free() # Faz a bolinha desaparecer
