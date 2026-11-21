extends MeshInstance3D


func _enter_tree() -> void:
    mesh = ImmediateMesh.new()
    
    # Configure an unshaded material so the shapes ignore game lighting
    var mat := ORMMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.vertex_color_use_as_albedo = true
    material_override = mat

# func _process(_delta: float) -> void:
    # Clear the previous frame's drawings before building new ones
    # mesh.clear_surfaces()


# --- Helper Primitive Drawing Functions ---

func draw_line(start: Vector3, end: Vector3, color: Color = Color.RED) -> void:
    mesh.clear_surfaces()
    
    mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    mesh.surface_set_color(color)
    mesh.surface_add_vertex(start)
    mesh.surface_add_vertex(end)
    mesh.surface_end()


func draw_box(center: Vector3, size: Vector3, color: Color = Color.WHITE) -> void:
    mesh.clear_surfaces()
    
    var extents := size / 2.0
    var corners := [
        center + Vector3(-extents.x, -extents.y, -extents.z),
        center + Vector3(extents.x, -extents.y, -extents.z),
        center + Vector3(extents.x, extents.y, -extents.z),
        center + Vector3(-extents.x, extents.y, -extents.z),
        center + Vector3(-extents.x, -extents.y, extents.z),
        center + Vector3(extents.x, -extents.y, extents.z),
        center + Vector3(extents.x, extents.y, extents.z),
        center + Vector3(-extents.x, extents.y, extents.z),
    ]
    
    # Bottom face
    _draw_line_raw(corners[0], corners[1], color)
    _draw_line_raw(corners[1], corners[5], color)
    _draw_line_raw(corners[5], corners[4], color)
    _draw_line_raw(corners[4], corners[0], color)
    # Top face
    _draw_line_raw(corners[3], corners[2], color)
    _draw_line_raw(corners[2], corners[6], color)
    _draw_line_raw(corners[6], corners[7], color)
    _draw_line_raw(corners[7], corners[3], color)
    # Vertical pillars
    _draw_line_raw(corners[0], corners[3], color)
    _draw_line_raw(corners[1], corners[2], color)
    _draw_line_raw(corners[4], corners[7], color)
    _draw_line_raw(corners[5], corners[6], color)


func _draw_line_raw(start: Vector3, end: Vector3, color: Color) -> void:
    mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    mesh.surface_set_color(color)
    mesh.surface_add_vertex(start)
    mesh.surface_add_vertex(end)
    mesh.surface_end()
