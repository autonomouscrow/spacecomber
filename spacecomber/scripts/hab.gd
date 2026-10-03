extends CharacterBody2D

const W_ENGINE_NORMAL_SCENE = preload("res://prefabs/w_engine_normal.tscn")

@export var engine_speed_mult: float = 300.0
@export var engine_rot_mult: float = 1
@export var rotation_speed: float

var health: int = 100
var shield: int = 100
var crystal_fuel: int = 100
var wood_juice: int = 100
var wood: int = 100
var iron: int = 100
var nimine: int = 100
var corpse: int = 9999

var w_engine_vel: Vector2 = Vector2.ZERO
var w_engine_rot_vel: float = 0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	rotation += direction * rotation_speed * delta
		
	if Input.is_action_just_pressed("ui_accept"):
		var w_engine = W_ENGINE_NORMAL_SCENE.instantiate()
		add_child(w_engine) 
		
	if Input.is_action_just_pressed("debug_interact"):
		get_w_engine()

	if Input.is_physical_key_pressed(KEY_W):
		var real_w_engine_vel = w_engine_vel.rotated(rotation)
		velocity.x += real_w_engine_vel.x * engine_speed_mult * delta
		velocity.y += real_w_engine_vel.y * engine_speed_mult * delta
		rotation += w_engine_rot_vel * engine_rot_mult * delta

	move_and_slide()


func get_w_engine() -> void:
	var w_engines = get_children_with_meta(self, "component_type", "w_engine")
	
	var total_thrust: Vector2 = Vector2.ZERO
	var total_torque: float = 0
	for engine in w_engines:
		var r_vec: Vector2 = engine.position
		var distance: float = r_vec.length()
		
		if distance == 0.0:
			return
			
		var r_hat: Vector2 = r_vec.normalized() # Unit vector pointing from engine to self
		
		var thrust_direction: Vector2 = Vector2.RIGHT.rotated(engine.rotation)
		var thrust_vector: Vector2 = -1*thrust_direction
		
		var radial_magnitude: float = thrust_vector.dot(r_hat)
		var radial_vector: Vector2 = r_hat * radial_magnitude
		
		var torque: float = r_vec.cross(thrust_vector)
	
		total_thrust += thrust_vector
		total_torque += torque
		
	w_engine_vel = total_thrust
	w_engine_rot_vel = total_torque
	
func get_children_with_meta(parent: Node, meta_key: String, target_value) -> Array[Node]:
	var matching_children: Array[Node] = []
	
	for child in parent.get_children():
		# has_meta() prevents errors if the key doesn't exist on a child
		if child.has_meta(meta_key) and child.get_meta(meta_key) == target_value:
			matching_children.append(child)
			
	return matching_children
