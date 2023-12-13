extends Node3D

@export var path_corner:PackedScene # Will be rotated
@export var path_straight:PackedScene
@export var path_start:PackedScene
@export var tile_empty:PackedScene
@export var path_crossing:PackedScene
@export var basic_enemy:PackedScene

func _ready():
	_display_path(_create_path())
	_complete_grid()
	spawn_enemies()
	

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
				var tile:Node3D = tile_empty.instantiate()
				
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)

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
		

		
		
		
