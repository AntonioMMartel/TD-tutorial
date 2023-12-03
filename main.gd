extends Node3D

@export var map_length: int = 16
@export var map_height: int = 9

@export var path_corner:PackedScene # Will be rotated
@export var path_straight:PackedScene
@export var path_start:PackedScene
@export var tile_empty:PackedScene

var path_generator: PathGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	path_generator = PathGenerator.new(map_length, map_height)
	_display_path()
	_complete_grid()

func _complete_grid():
	for x in range(map_length):
		for y in range(map_height):
			if not path_generator.get_path().has(Vector2i(x,y)):
				var tile:Node3D = tile_empty.instantiate()
				add_child(tile)
				tile.global_position = Vector3(x, 0, y)

func _display_path():
	var _path:Array[Vector2i] = path_generator.generate_path()
	
	
	while _path.size() < 35:
		_path = path_generator.generate_path()
	
	for element in _path:
		var tile_rotation = Vector3(0, 0, 0)
		# Up, Left
		var tile:Node3D = path_corner.instantiate()
		var tile_rotation_score:Array = path_generator.get_tile_rotation_score(element)
		
		if tile_rotation_score == ["Down", "Left"]:
			tile = path_corner.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		
		if tile_rotation_score == ["Right", "Down"]:
			tile = path_corner.instantiate()
			tile_rotation = Vector3(0, 180, 0)
			
		if tile_rotation_score == ["Up", "Right"]:
			tile = path_corner.instantiate()
			tile_rotation = Vector3(0, 270, 0)
		
		if tile_rotation_score == ["Right", "Left"]:
			tile = path_straight.instantiate()
			tile_rotation = Vector3(0, 90, 0)
		
		if tile_rotation_score == ["Up", "Down"]:
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
		

		
		
		
