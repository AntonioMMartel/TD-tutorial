extends Node
class_name PathGenerator

var _grid_lenght: int
var _grid_height: int
var _min_path_size: int

var _path: Array[Vector2i]


var path_config:PathGeneratorConfig = preload("res://Resources/basic_path_config.tres")

func _init():
	_grid_lenght = path_config.map_length
	_grid_height = path_config.map_height
	_min_path_size = path_config.min_path_size
	generate_path()


# Por donde pasan los bichos
func generate_path():
	while _path.size() < _min_path_size:
		_path.clear() # Regenerates path
		
		var x:int = 0
		var y:int = int(_grid_height / 2)
			
		
			
		while x < _grid_lenght:
	#		Si ya existe esa coordenada del path no lo pongas
			if not _path.has(Vector2i(x, y)):
				_path.append(Vector2i(x,y))
				
	#		Valor aleatorio para que sea mas original el path

			var choice:int = randi_range(0, 2)
			
	#		En valores pares de x o 1/3 veces vamos a añadir path en el eje y y no en el x
			if choice == 0 or x % 2 == 0 or x == _grid_lenght - 1:
				x += 1
	#		Else sube o baja
			elif choice == 1 and y < _grid_height - 2 and not _path.has(Vector2i(x, y+1)):
				y += 1
			elif choice == 2 and y > 1 and not _path.has(Vector2i(x, y - 1)):
				y -= 1
		
		
		
	return _path

func get_tile_rotation_score(tile: Vector2i) -> Array:
	var score:Array = []
	var x = tile.x
	var y = tile.y
	if _path.has(Vector2i(x,y-1)): score += ["Up"]
	if _path.has(Vector2i(x+1,y)): score += ["Right"]
	if _path.has(Vector2i(x,y+1)): score += ["Down"]
	if _path.has(Vector2i(x-1,y)): score += ["Left"]
	
	return score
	
func get_path_route():
	return _path
	
func get_map_height():
	return _grid_height


func get_map_length():
	return _grid_lenght
	
# Square area
func is_area_free(center: Vector2i, area:int, center_offset:Vector2i = Vector2i(0,0), ignore:Array[Vector2i] = []):
	center += center_offset
	for x in range(center.x-area, center.x+area + 1):
		for y in range(center.y-area, center.y+area + 1):
			if not ignore.has(Vector2i(x,y)):
				if _path.has(Vector2i(x,y)):
					return false
			if 0 > x or x > _grid_lenght - 1 or 0 > y or y > _grid_height - 1:
				return false
	return true

func get_loop_candidates() -> Dictionary:
	var loop_candidates = {}
	for path_tile in _path:
		if is_area_free(path_tile, 2, Vector2i(1,-1), get_tile_neighbours(path_tile)):
			loop_candidates[path_tile] = "Right-Up"
		elif is_area_free(path_tile, 2, Vector2i(1,1), get_tile_neighbours(path_tile)):
			loop_candidates[path_tile] = "Right-Down"
		elif is_area_free(path_tile, 2, Vector2i(-1,1), get_tile_neighbours(path_tile)):
			loop_candidates[path_tile] = "Down"
		elif is_area_free(path_tile, 2, Vector2i(-1,-1), get_tile_neighbours(path_tile)):
			loop_candidates[path_tile] = "Up"
		
	return loop_candidates

func add_loops(loop_candidates:Dictionary, number_of_loops:int = 1):
	# All path tiles that are loop candidates
	
	for loop_candidate in loop_candidates.keys():
		var count = 0
		var loop = []
		var x = loop_candidate.x
		var y = loop_candidate.y
		# Select what type of loop will be made
		if loop_candidates[loop_candidate] == "Right-Down":
			loop = [loop_candidate, Vector2i(x+1,y), Vector2i(x+2,y), # Right
					Vector2i(x+2,y+1), Vector2i(x+2,y+2), # Up
					Vector2i(x+1,y+2), Vector2i(x,y+2), # Left
					Vector2i(x,y+1)] # Down
		elif loop_candidates[loop_candidate] == "Right-Up":
			loop = [loop_candidate, Vector2i(x+1,y), Vector2i(x+2,y), # Right
					Vector2i(x+2,y-1), Vector2i(x+2,y-2), # Down
					Vector2i(x+1,y-2), Vector2i(x,y-2), # Left
					Vector2i(x,y-1)] # Up
		elif loop_candidates[loop_candidate] == "Up":
			loop = [loop_candidate, Vector2i(x,y-1), Vector2i(x,y-2), # Down
					Vector2i(x-1,y-2), Vector2i(x-2,y-2), # Left
					Vector2i(x-2,y-1), Vector2i(x-2,y), # Up
					Vector2i(x-1,y)] # Right
		elif loop_candidates[loop_candidate] == "Down":
			loop = [loop_candidate, Vector2i(x,y+1), Vector2i(x,y+2), # Up
					Vector2i(x-1,y+2), Vector2i(x-2,y+2), # Left
					Vector2i(x-2,y+1), Vector2i(x-2,y), # Down
					Vector2i(x-1,y)] # Right

		# Add loop
		
		# Divide _path array in two parts
		var first_half = _path.slice(0, _path.find(loop_candidate))
		var second_half = _path.slice(_path.find(loop_candidate))

		first_half.append_array(loop)
		first_half.append_array(second_half)
		
		_path = first_half

# Includes also itself
func get_tile_neighbours(tile:Vector2i)  -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = [tile]
	var x = tile.x
	var y = tile.y
	if _path.has(Vector2i(x,y-1)): neighbours.append(Vector2i(x, y-1))
	if _path.has(Vector2i(x+1,y)): neighbours.append(Vector2i(x+1, y))
	if _path.has(Vector2i(x,y+1)): neighbours.append(Vector2i(x, y+1))
	if _path.has(Vector2i(x-1,y)): neighbours.append(Vector2i(x-1, y))

	return neighbours
	
	

	
	
	
	
	
