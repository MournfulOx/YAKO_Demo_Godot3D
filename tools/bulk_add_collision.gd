@tool
extends EditorScript

# Run via Script editor -> File -> Run (Ctrl+Shift+X) while the target map
# scene is the currently open/active scene in the 3D viewport.
#
# Walks every descendant of TARGET_PATH (relative to the scene root) and,
# for each MeshInstance3D found, computes its WORLD-SPACE axis-aligned
# bounding box (by transforming the mesh's local AABB corners through its
# full global_transform), then creates a fresh, unscaled StaticBody3D at
# the scene root with a BoxShape3D sized/positioned to match.
#
# Why not just parent the collision under the mesh like before: this
# project uses Jolt Physics (see project.godot), which does not reliably
# apply inherited node scale to collision shapes the same way rendering
# does — both create_trimesh_collision() and a locally-parented BoxShape3D
# came out misaligned on this project's heavily-scaled/rotated building
# assets. Building the shape in world space up front and attaching it to
# an unscaled node sidesteps that entirely: there is no inherited scale
# left for Jolt to get wrong.
#
# Trade-off: still an axis-aligned box (not rotated to match the mesh's
# own orientation), so a rotated building's box will be generously
# oversized on the diagonal. Fine for "can't walk through it" purposes;
# not a precise hull.
#
# Leave TARGET_PATH empty ("") to process the whole scene. Point it at a
# specific container (e.g. "buildings") to scope it to just buildings and
# skip roads/sidewalks/props. Re-running is NOT idempotent (no "already
# has collision" check, since the generated bodies live in a separate
# container, not as children of the mesh) -- delete the previous
# "GeneratedCollision_<name>" node before re-running on the same target.

const TARGET_PATH := "buildings"

var _count := 0
var _root: Node
var _container: Node3D

func _run() -> void:
	var scene := get_scene()
	if scene == null:
		print("No scene currently open in the editor.")
		return

	var target: Node = scene
	if not TARGET_PATH.is_empty():
		target = scene.get_node_or_null(TARGET_PATH)
		if target == null:
			print("Path not found: ", TARGET_PATH)
			return

	_root = scene
	_count = 0

	_container = Node3D.new()
	_container.name = "GeneratedCollision_" + target.name
	scene.add_child(_container)
	_container.owner = _root

	_process_node(target)
	print("Added %d world-space box colliders under %s (target: %s)" % [_count, _container.name, target.name])

func _process_node(node: Node) -> void:
	for child in node.get_children():
		_process_node(child)

	if node is MeshInstance3D and node.mesh != null:
		var mesh_node := node as MeshInstance3D
		var aabb: AABB = mesh_node.mesh.get_aabb()
		if aabb.size.length() < 0.0001:
			return

		var gt: Transform3D = mesh_node.global_transform
		var world_min := Vector3(INF, INF, INF)
		var world_max := Vector3(-INF, -INF, -INF)
		for i in range(8):
			var corner := aabb.position + Vector3(
				aabb.size.x * float(i & 1),
				aabb.size.y * float((i >> 1) & 1),
				aabb.size.z * float((i >> 2) & 1)
			)
			var world_corner: Vector3 = gt * corner
			world_min = world_min.min(world_corner)
			world_max = world_max.max(world_corner)

		var world_size := world_max - world_min
		var world_center := (world_min + world_max) * 0.5

		var body := StaticBody3D.new()
		body.name = node.name + "_col"
		_container.add_child(body)
		body.owner = _root
		body.global_position = world_center

		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = world_size
		shape.shape = box
		body.add_child(shape)
		shape.owner = _root

		_count += 1
