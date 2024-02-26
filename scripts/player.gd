extends CharacterBody2D


var speed = 300.0
var direction = 1
var upthrust = -200.0
var allow_input: bool = true

signal player_died

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func ready():
	$FailSprite.hide()

func _physics_process(delta):
	if allow_input:
		$AnimationPlayer.play("run")
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			$AnimationPlayer.play("fall")

		# Handle jump.
		if Input.is_action_pressed("fly"):
			velocity.y = upthrust
			$AnimationPlayer.play("fly")
		
		velocity.x = direction * speed
		move_and_slide()
	
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("Enemy"):
				die()
	
	elif not allow_input:
		if not is_on_floor():
			velocity.y += gravity * delta
			velocity.x = direction * speed
			move_and_slide()
			$AnimationPlayer.play("fall")
			
		if is_on_floor():
			$AnimationPlayer.play("dead")
	
func die():
	allow_input = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "dead":
		$Sprite2D.hide()
		$FailSprite.show()
		player_died.emit()
