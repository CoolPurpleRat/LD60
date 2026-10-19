@tool
extends MeshInstance3D
class_name vineDrawer
@export_tool_button("Redraw vines") var redrawVines:Callable=_generate_vine
@export var path: Path3D

@export_group("Vine Settings")
##How smooth the vine's circular thickness is.
@export_range(4, 32, 1) var radial_resolution: int = 8
##The thickness at the start of the vine.
@export_range(0.1, 1, 0.1) var base_radius: float = 0.1
##Tapers the vine towards the end (0 = tapers to a fine point, 1 = uniform thickness).
@export_range(0.0, 1.0, 0.01) var tip_taper_ratio: float = 0.0
##Distance between lengthwise slices of the vine. Lower values mean smoother curves.
@export_range(0.02, 1, 0.01) var step_distance: float = 0.05

@export_group("Node Bulge Settings")
##Multiplier applied to the radius directly at the path points (targets).
@export_range(1.0, 4.0, 0.01) var node_thickness_mult: float = 2.0
##Multiplier applied to the radius at the thinnest midpoint between nodes.
@export_range(0, 1.0, 0.01) var mid_thinness_mult: float = 0.5
##How sharp or spread out the bulbous shape around each node is.
@export_range(0, 5.0, 0.01) var bulge_falloff_power: float = 2.0

@export_group("Organic Variation")
##Introduces organic squiggliness to the vine path.
@export_range(0, 1, 0.01) var noise_amplitude: float = 0.05
##Controls the frequency of the noise ripples.
@export_range(0, 10, 0.1) var noise_frequency: float = 2.0


func _generate_vine() -> void:
	if not is_instance_valid(path) or not is_instance_valid(path.curve):
		return
	
	var curve: Curve3D = path.curve
	var total_length := curve.get_baked_length()
	if total_length < 0.01:
		return

	#Precompute the baked distance along the curve for every control point
	var point_count := curve.point_count
	var node_distances: Array[float] = []
	for p in range(point_count):
		var p_pos := curve.get_point_position(p)
		var offset := curve.get_closest_offset(p_pos)
		node_distances.append(offset)

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var steps := int(total_length / step_distance)
	if steps < 2: 
		steps = 2

	#1. Generate Vertices, Normals, and UVs along the curve
	for i in range(steps + 1):
		var t := float(i) / steps
		var current_dist := t * total_length

		#Positional data along the curve
		var base_pos := curve.sample_baked(current_dist)
		var next_dist: float = min(current_dist + 0.01, total_length)
		var forward := (curve.sample_baked(next_dist) - base_pos).normalized()
		if forward == Vector3.ZERO:
			forward = Vector3.FORWARD

		#Stable perpendicular orientation frame (Frenet approximation)
		var up := Vector3.UP if abs(forward.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
		var right := forward.cross(up).normalized()
		up = right.cross(forward).normalized()

		#Determine normalized distance factor relative to the two surrounding path points
		var node_shape_factor := 0.0 #0.0 = midway between points, 1.0 = directly on a point
		if point_count > 1:
			for p in range(point_count - 1):
				var d_start := node_distances[p]
				var d_end := node_distances[p + 1]
				if current_dist >= d_start and current_dist <= d_end:
					var segment_len := maxf(d_end - d_start, 0.001)
					var segment_t := (current_dist - d_start) / segment_len
					#Cosine wave: 1.0 at segment_t = 0 and 1, drops to 0.0 at segment_t = 0.5
					node_shape_factor = (cos(segment_t * TAU) * 0.5 + 0.5)
					break

		#Shape the curve profile using exponential falloff
		var node_profile := pow(node_shape_factor, bulge_falloff_power)
		var thickness_factor := lerpf(mid_thinness_mult, node_thickness_mult, node_profile)

		#Apply procedural tapering and node sizing
		var taper := lerpf(base_radius, base_radius * tip_taper_ratio, t)
		var slice_radius := taper * thickness_factor

		#Noise displacement
		var noise_offset := Vector3.ZERO
		if noise_amplitude > 0.0:
			noise_offset = (sin(current_dist * noise_frequency) * right + cos(current_dist * noise_frequency) * up) * noise_amplitude

		var final_center := base_pos + noise_offset

		#Form circle slice
		for r in range(radial_resolution + 1):
			var angle := (float(r) / radial_resolution) * TAU
			var normal := (right * cos(angle) + up * sin(angle)).normalized()
			var vertex_pos := final_center + (normal * slice_radius)

			var local_vertex := to_local(vertex_pos)
			var uv := Vector2(float(r) / radial_resolution, current_dist)

			st.set_uv(uv)
			st.set_normal(to_local(vertex_pos + normal) - local_vertex)
			st.add_vertex(local_vertex)

	#2. Build the Indices
	var ring_vertices := radial_resolution + 1
	for i in range(steps):
		var current_ring := i * ring_vertices
		var next_ring := (i + 1) * ring_vertices

		for r in range(radial_resolution):
			var v0 := current_ring + r
			var v1 := current_ring + r + 1
			var v2 := next_ring + r
			var v3 := next_ring + r + 1

			#Triangle 1
			st.add_index(v0)
			st.add_index(v1)
			st.add_index(v2)

			#Triangle 2
			st.add_index(v1)
			st.add_index(v3)
			st.add_index(v2)

	st.generate_tangents()
	mesh = st.commit()
