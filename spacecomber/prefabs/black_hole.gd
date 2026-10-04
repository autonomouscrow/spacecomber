extends Node2D

@export var pull_strength: float = 500.0
@export var min_distance: float = 10.0 # Prevents objects from freaking out when too close

@onready var gravity_area: Area2D = $Area2D2

func _physics_process(delta: float) -> void:
	# Get all bodies currently inside the area
	var bodies = gravity_area.get_overlapping_bodies()
	
	for body in bodies:
		# Optional: Skip self if the black hole itself is a RigidBody
		if body == self:
			continue
			
		# Calculate direction vector from the body to the black hole
		var direction = global_position - body.global_position
		var distance = direction.length()
		
		# Prevent division by zero or jittering at the center
		if distance > min_distance:
			direction = direction.normalized()
			
			# Check how to apply force depending on the object type
			if body is RigidBody2D:
				# Apply a force towards the center
				# (Optional: divide by distance squared for realistic inverse-square gravity, 
				# or keep it constant for a steady pull)
				var force = direction * pull_strength
				body.apply_central_force(force)
				
			elif body.has_method("custom_pull"):
				# If you have custom characters that move via move_and_slide(),
				# you can call a custom method on them:
				body.custom_pull(direction * pull_strength * delta)

# Something reached the center of the black hole (the small inner Area2D).
# Connected in BlackHole.tscn; nothing happens there yet
func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.has_method("take_damage"):
		_body.take_damage(100000)
	if _body.has_method("disappear"):
		_body.disappear()
