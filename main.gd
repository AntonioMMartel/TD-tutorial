extends Node3D

@export var path_corner:PackedScene # Will be rotated
@export var path_straight:PackedScene
@export var path_start:PackedScene
@export var misc_tiles:Array[PackedScene]
@export var path_crossing:PackedScene
@export var basic_enemy:PackedScene

@onready var camera = $Camera3D
const RAYCAST_LENGTH: float = 100

func _ready():
	_display_path(_create_path())
	_complete_grid()
	spawn_enemies()

func _physics_process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Espacio 3D del mundo (Viewport)
		var space_state = get_world_3d().direct_space_state
		# Posicion del raton
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		# El rayo aparece en origin (sacado en funcion de la perspectiva de la camara)
		var origin:Vector3 = camera.project_ray_origin(mouse_pos)
		# Y llega hasta end (en funcion de la perspectiva de la camara)
		var end:Vector3 = origin + camera.project_ray_normal(mouse_pos) * RAYCAST_LENGTH
		# Creas un rayo que vaya de origin a end
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		# Que choque con cosas
		query.collide_with_areas = true
		# Invoca el rayo
		var rayResult:Dictionary = space_state.intersect_ray(query)
		if rayResult.size() > 0:
			var co:CollisionObject3D = rayResult.get("collider")
			print(co.get_groups())

func _create_path() -> Array[Vector2i]:
	return PathGeneratorSingleton.get_path_route()
	
func spawn_enemies():
	for i in 20:
		await get_tree().create_timer(0.5).timeout
		var enemy = basic_enemy.instantiate()
		add_child(enemy)

#func move_enemy_in_path():
#	var enemy = enemy_ufo.instantiate()
#	var movement:Curve3D = Curve3D.new()
#	for tile in path_generator.get_path():
#		movement.add

func _complete_grid():
	for x in range(PathGeneratorSingleton.get_map_length()):
		for y in range(PathGeneratorSingleton.get_map_height()):
			if not PathGeneratorSingleton.get_path_route().has(Vector2i(x,y)):
				var tile:Node3D = misc_tiles.pick_random().instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)
				tile.global_rotation_degrees = Vector3(0, randi_range(0,3)*90, 0)

func _display_path(_path:Array[Vector2i]):
	
	for element in _path:
		var tile_rotation = Vector3(0, 0, 0)
		# Up, Left
		var tile:Node3D = path_corner.instantiate()
		var tile_rotation_score:Array = PathGeneratorSingleton.get_tile_rotation_score(element)
		
		
		if tile_rotation_score == ["Up", "Right", "Down", "Left"]:
			tile = path_crossing.instantiate()
			
		elif tile_rotation_score == ["Down", "Left"]:
			tile = path_corner.instantiate()
			tile_rotation = Vector3(0, 90, 0)
			
		elif tile_rotation_score == ["Right", "Down"]:
			tile = path_corner.instantiate()
			tile_rotation = Vector3(0, 180, 0)
			
		elif tile_rotation_score == ["Up", "Right"]:
			tile = path_corner.instantiate()
			tile_rotation = Vector3(0, 270, 0)
		
		elif tile_rotation_score == ["Right", "Left"]:
			tile = path_straight.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		
		elif tile_rotation_score == ["Up", "Down"]:
			tile = path_straight.instantiate()
			
	
		if tile_rotation_score == ["Left"]:
			tile = path_start.instantiate()
			tile_rotation = Vector3(0, 90, 0)
			
		if tile_rotation_score == ["Right"]:
			tile = path_start.instantiate()
			tile_rotation = Vector3(0, 270, 0)
			
		add_child(tile)
		tile.global_position = Vector3(element.x, 0, element.y)
		tile.global_rotation_degrees = tile_rotation
		
