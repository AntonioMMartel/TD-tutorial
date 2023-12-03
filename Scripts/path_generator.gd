extends Object
class_name PathGenerator

var _grid_lenght: int
var _grid_height: int

var _path: Array[Vector2i]

func _init(length:int, height:int):
	_grid_lenght = length
	_grid_height = height

# Por donde pasan los bichos
func generate_path():
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
			
	
	get_loop_options()
		
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
	
func get_path():
	return _path
	
# Square area
func is_area_free(center: Vector2i, area:int, center_offset:Vector2i = Vector2i(0,0), ignore:Array[Vector2i] = []):
	center += center_offset
	for x in range(center.x-area, center.x+area):
		for y in range(center.y-area, center.y+area):
			if not ignore.has(Vector2i(x,y)):
				if _path.has(Vector2i(x,y)):
					return false
	
	print(true)
	return true

func get_loop_options() -> Dictionary:
	var loop_options = {}
	for path_tile in _path:
		if is_area_free(path_tile, 2, Vector2i(1,1), get_tile_neighbours(path_tile)):
			loop_options["Right-Up"] = path_tile
		if is_area_free(path_tile, 2, Vector2i(1,-1), get_tile_neighbours(path_tile)):
			loop_options["Right-Down"] = path_tile
		if is_area_free(path_tile, 2, Vector2i(-1,-1), get_tile_neighbours(path_tile)):
			loop_options["Down"] = path_tile
		if is_area_free(path_tile, 2, Vector2i(-1,1), get_tile_neighbours(path_tile)):
			loop_options["Up"] = path_tile
		
	return loop_options

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
	
	
	
	
	
	
	
	
