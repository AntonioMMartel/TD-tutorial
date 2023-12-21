extends Node3D

var enemies_in_range:Array[Node3D]
var current_enemy:Node3D = null
var current_enemy_targeted:bool = false
var acquire_slerp_progress:float = 0

var last_fire_time:int = 0
@export var fire_rate_ms:int = 500
@export var projectile_scene:PackedScene

func _on_range_area_entered(area):
	
	if current_enemy == null:
		current_enemy = area
	enemies_in_range.append(area)


func _on_range_area_exited(area):
	
	enemies_in_range.erase(area)

func _on_searching_state_processing(delta):
	# First
	if enemies_in_range.size() > 0:
		current_enemy = enemies_in_range[0]
		$StateChart.send_event("to_acquiring_state")
	
	#Last
#	if enemies_in_range.size() > 0:
#		current_enemy = enemies_in_range[enemies_in_range.size() - 1]
#		$StateChart.send_event("to_acquiring_state")
		

func _on_acquiring_state_entered():
	acquire_slerp_progress = 0
	current_enemy_targeted = false
	
# Rota para ver a colega
func _on_acquiring_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		rotate_towards_target(current_enemy, delta)
	else: # If is killed while acquiring
		$StateChart.send_event("to_searching_state")
	

func rotate_towards_target(rtarget, delta):
	var target_vector = $Cannon.global_position.direction_to(Vector3(rtarget.global_position.x, global_position.y, rtarget.global_position.z))
	var target_basis:Basis = Basis.looking_at(target_vector)
	$Cannon.basis = $Cannon.basis.slerp(target_basis, acquire_slerp_progress)
	acquire_slerp_progress += delta
	if acquire_slerp_progress > 0:
		$StateChart.send_event("to_attacking_state")


func _on_attacking_state_physics_processing(delta):
	if current_enemy != null and enemies_in_range.has(current_enemy):
		$Cannon.look_at(current_enemy.global_position)
		attack()
	else:
		$StateChart.send_event("to_searching_state")

func attack():
	if Time.get_ticks_msec() > (last_fire_time+fire_rate_ms):
		var projectile:Projectile = projectile_scene.instantiate()
		projectile.starting_position = $Cannon/projectile_spawn.global_position
		projectile.target = current_enemy
		add_child(projectile)
		last_fire_time = Time.get_ticks_msec()
		

func _on_attacking_state_entered():
	last_fire_time = 0
