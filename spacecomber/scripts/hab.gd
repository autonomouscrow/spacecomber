extends CharacterBody2D

const W_ENGINE_NORMAL_SCENE = preload("res://prefabs/w_engine_normal.tscn")

@export var speed: float = 300.0
@export var engine_rot_mult: float = 1
@export var rotation_speed: float

var health: int = 100
var crystal_fuel: int = 100
var wood_juice: int = 100
var wood: int = 100
var iron: int = 100
var nimine: int = 100
var corpse: int = 9999

var w_engine_vel: Vector2
var w_engine_rot_vel: float

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	rotation += direction * rotation_speed / 18
		
	if Input.is_action_just_pressed("ui_accept"):
		var w_engine = W_ENGINE_NORMAL_SCENE.instantiate()
		add_child(w_engine) 

	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


#func get_w_engine() -> void:
	#var w_engines = get_children_with_meta(self, "component_type", "w_engine")
	#
	#var total_thrust: Vector2 = Vector2.ZERO
	#var total_torque: float = 0
	#for engine in w_engines:
		#var r_vec: Vector2 = -engine.position
		#var distance: float = r_vec.length()
		#
		#if distance == 0.0:
			#return
			#
		#var r_hat: Vector2 = r_vec.normalized() # Unit vector pointing from engine to self
		#
		#var thrust_direction: Vector2 = Vector2.RIGHT.rotated(engine.rotation)
		#var thrust_vector: Vector2 = thrust_direction
		#
		#var radial_magnitude: float = total_thrust_vector.dot(r_hat)
		#var radial_vector: Vector2 = r_hat * radial_magnitude
		#
		#var torque: float = r_vec.cross(total_thrust_vector)
	#
		#
	
func get_children_with_meta(parent: Node, meta_key: String, target_value) -> Array[Node]:
	var matching_children: Array[Node] = []
	
	for child in parent.get_children():
		# has_meta() prevents errors if the key doesn't exist on a child
		if child.has_meta(meta_key) and child.get_meta(meta_key) == target_value:
			matching_children.append(child)
			
	return matching_children
