extends Button

@export var button_icon:Texture2D
@export var draggable:PackedScene
@export var instance:PackedScene
@export var _error_mat:Material

var _is_dragging:bool = false
var _current_draggable:Node
var _cam:Camera3D
const RAYCAST_LENGTH:float = 100
var _is_valid_location:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	icon = button_icon
	_current_draggable = draggable.instantiate()
	_current_draggable.visible = false
	add_child(_current_draggable)
	_cam = get_viewport().get_camera_3d()


func _physics_process(delta):
	# Raycast para ver dnd va a caer la torreta
	if _is_dragging:
		# Espacio 3d dnd esta el objeto
		var space_state = _current_draggable.get_world_3d().direct_space_state
		# Posicion del mouse
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		# Origen y proyeccion del rayo
		var origin:Vector3  =_cam.project_ray_origin(mouse_pos)
		var end:Vector3 = origin + _cam.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		# Que choque con cosas
		query.collide_with_areas = true
		# Invoca el rayo
		var rayResult:Dictionary = space_state.intersect_ray(query)
		if rayResult.size() > 0:
			var co:CollisionObject3D = rayResult.get("collider")
			if not (co.get_groups().size() < 1):
				if(co.get_groups()[0] != "tile_empty"):
					# Vamo a hacer que salga la sombra de la torreta 
					_is_valid_location = false
					_current_draggable.visible = true
					_current_draggable.global_position = Vector3(co.global_position.x, 0.2, co.global_position.z)
					set_child_mesh_error(_current_draggable)
				else:
					# Vamo a hacer que salga la sombra de la torreta 
					_current_draggable.visible = true
					_is_valid_location = true
					_current_draggable.global_position = Vector3(co.global_position.x, 0.2, co.global_position.z)
					clear_child_mesh_error(_current_draggable)
					
		else:
			_current_draggable.visible = false


# Va por los hijos del Nodo quitandoles el color rojo
func clear_child_mesh_error(n:Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			clear_mesh_error(c)
		
		if c is Node and c.get_child_count() > 0:
			clear_child_mesh_error(c)

func clear_mesh_error(mesh3d:MeshInstance3D):
	for si in mesh3d.mesh.get_surface_count():
		mesh3d.set_surface_override_material(si, null)

# Va por los hijos del Nodo poniendolos de color rojo
func set_child_mesh_error(n:Node):
	for c in n.get_children():
		if c is MeshInstance3D:
			set_mesh_error(c)
		
		if c is Node and c.get_child_count() > 0:
			set_child_mesh_error(c)

func set_mesh_error(mesh3d:MeshInstance3D):
	for si in mesh3d.mesh.get_surface_count():
		mesh3d.set_surface_override_material(si, _error_mat)

func _on_button_down():
	_is_dragging = true

func _on_button_up():
	_is_dragging = false
	_current_draggable.visible = false
	
	if _is_valid_location:
		var instanced_turret = instance.instantiate()
		instanced_turret.global_position = _current_draggable.global_position
		add_child(instanced_turret)
