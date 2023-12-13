extends Node3D

var curve3d: Curve3D
var enemy_progress:float = 0
var enemy_speed:float = 5

# Called when the node enters the scene tree for the first time.
func _ready():

	curve3d = Curve3D.new()
	
#	PathGeneratorSingleton.get_path_route
	for element in PathGeneratorSingleton.get_path_route():

		#curve3d.add_point(Vector3(i.x, 0, i.y))
		curve3d.add_point(Vector3(element.x, 0, element.y))

	
	# Accede a los nodos del objeto
	$Path3D.curve = curve3d
	$Path3D/PathFollow3D.progress_ratio = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_spawning_state_entered():
	$AnimationPlayer.play("Spawn")
	await $AnimationPlayer.animation_finished
	$StateChart.send_event("to_travelling")

func _on_travelling_state_entered():
	pass

func _on_travelling_state_processing(delta):
	enemy_progress += delta * enemy_speed
	$Path3D/PathFollow3D.progress = enemy_progress
	
	if enemy_progress > PathGeneratorSingleton.get_path_route().size():
		$StateChart.send_event("to_despawning")

func _on_despawning_state_entered():
	
	$AnimationPlayer.play("Despawn")
	await $AnimationPlayer.animation_finished
	queue_free()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
