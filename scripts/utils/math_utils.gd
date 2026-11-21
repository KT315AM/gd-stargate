class_name MathUtils
extends RefCounted


static func apply_spread(vector: Vector3, angle: float, basis: Basis = Basis.IDENTITY) -> Vector3:

    if is_zero_approx(angle):
        return vector

    angle = abs(angle)
    var random_x := randf_range(-angle, angle)
    var random_y := randf_range(-angle, angle)
    vector = vector.rotated(basis.x, random_x)
    vector = vector.rotated(basis.y, random_y)

    return vector


static func apply_spread_deg(vector: Vector3, angle_deg: float, basis: Basis = Basis.IDENTITY) -> Vector3:
    return apply_spread(vector, deg_to_rad(angle_deg), basis)