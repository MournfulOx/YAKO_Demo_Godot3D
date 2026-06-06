import bpy, os, sys, re

args = sys.argv[sys.argv.index("--") + 1:]
models_dir = args[0]
textures_dir = args[1]
output_dir = args[2]

os.makedirs(output_dir, exist_ok=True)

for fname in sorted(os.listdir(models_dir)):
    if not fname.lower().endswith(".fbx"):
        continue

    m = re.match(r"building_(\d+)\.", fname)
    if not m:
        continue

    building_num = m.group(1).zfill(2)
    tex_path = os.path.join(textures_dir, f"building_{building_num}.png")

    if not os.path.exists(tex_path):
        print(f"SKIP (no texture): {fname}")
        continue

    src = os.path.join(models_dir, fname)
    dst = os.path.join(output_dir, fname.replace(".fbx", ".glb"))

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=src)

    tex_image = bpy.data.images.load(tex_path)

    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        for slot in obj.material_slots:
            mat = slot.material
            if mat is None:
                mat = bpy.data.materials.new(name=f"Mat_{building_num}")
                slot.material = mat
            mat.use_nodes = True
            nodes = mat.node_tree.nodes
            links = mat.node_tree.links
            nodes.clear()
            bsdf = nodes.new("ShaderNodeBsdfPrincipled")
            out  = nodes.new("ShaderNodeOutputMaterial")
            tex  = nodes.new("ShaderNodeTexImage")
            tex.image = tex_image
            links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
            links.new(tex.outputs["Color"], bsdf.inputs["Emission Color"])
            bsdf.inputs["Emission Strength"].default_value = 1.5
            links.new(bsdf.outputs["BSDF"],  out.inputs["Surface"])

    bpy.ops.export_scene.gltf(
        filepath=dst,
        export_format="GLB",
        export_image_format="AUTO",
    )
    print(f"OK: {fname} -> {os.path.basename(dst)}")
