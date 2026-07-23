extends Node

@export var target_paths: Array[NodePath] = []
@export var emission_energy: float = 0.8

func _ready() -> void:
	for path: NodePath in target_paths:
		var target := get_node_or_null(path)
		if target:
			_apply_glow(target)

func _apply_glow(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh: Mesh = node.mesh
		if mesh:
			for i: int in mesh.get_surface_count():
				var mat: Material = node.get_surface_override_material(i)
				if mat == null:
					mat = mesh.surface_get_material(i)
				# BaseMaterial3D, not StandardMaterial3D specifically — glTF/Sketchfab imports
				# commonly land as the sibling class ORMMaterial3D, which the narrower check missed
				if mat is BaseMaterial3D and not mat.emission_enabled and mat.albedo_texture != null:
					var glow_mat: BaseMaterial3D = mat.duplicate()
					glow_mat.emission_enabled = true
					glow_mat.emission_texture = mat.albedo_texture
					glow_mat.emission_energy_multiplier = emission_energy
					node.set_surface_override_material(i, glow_mat)
	for child in node.get_children():
		_apply_glow(child)
