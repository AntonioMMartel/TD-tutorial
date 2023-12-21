extends Area3D
class_name Projectile

var starting_position:Vector3
var target:Node3D

@export var speed:float = 4
var lerp_pos:float = 0
@export var damage:int = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = starting_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if target != null and lerp_pos < 1:
		global_position = starting_position.lerp(Vector3(target.global_position.x, starting_position.y, target.global_position.z) , lerp_pos)
		lerp_pos += delta * speed 
	else:
		queue_free()
