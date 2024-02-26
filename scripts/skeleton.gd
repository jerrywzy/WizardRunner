extends CharacterBody2D

var direction = -1
var speed = 100.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func ready():
	#var direction = [-1, 1][randi() % 2]   # use random index between 0 and 1 
	pass
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	velocity.x = direction * speed
	if direction < 0:
		$Sprite2D.flip_h = true
		
	move_and_slide()
	
