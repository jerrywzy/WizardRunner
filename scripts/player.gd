extends CharacterBody2D


@export var speed: float = 400
@export var speed_increase = 1.0001
var boosted_speed = 1200
var default_speed = 400
var max_speed = 900
var direction = 1
var upthrust = -200
var allow_input: bool = true
var dying_animation = false
var potions: int = 0
var barrier_active: bool = false

var barrier_scene: PackedScene = load("res://scenes/barrier.tscn")

signal player_died
signal player_dying

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func ready():
	pass

func _physics_process(delta):
	if allow_input:
		$AnimationPlayer.play("run")
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			$AnimationPlayer.play("fall")

		# Handle jump.
		if Input.is_action_pressed("fly"):
			$AudioStreamPlayer.stream = load("res://assets/Swish.mp3")
			$AudioStreamPlayer.play()
			velocity.y = upthrust
			$AnimationPlayer.play("fly")
		
		velocity.x = direction * speed
		if speed < max_speed:
			speed *= speed_increase
		move_and_slide()
	
		if Input.is_action_just_pressed("boost") and not barrier_active:
			if potions > 20:
				pickup("Barrier")
				potions -= 20
				
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("Enemy"):
				die()
				
		
	elif not allow_input:
		if not is_on_floor():
			velocity.y += gravity * delta
			velocity.x = direction * speed
			move_and_slide()
			$AnimationPlayer.play("hit")
			
		if is_on_floor() and dying_animation:
			$AudioStreamPlayer.stream = load("res://assets/body_thud_short.mp3")
			$AudioStreamPlayer.play()
			$AnimationPlayer.play("dead")
			dying_animation = false
	
func die():
	$AudioStreamPlayer.stream = load("res://assets/hit_sound.mp3")
	$AudioStreamPlayer.play()
	allow_input = false
	player_dying.emit()
	dying_animation = true
	$Sprite2D.material.set_shader_parameter("progress", 1)
	$HitTimer.start()
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "dead":
		player_died.emit()

func _on_hit_timer_timeout():
	$Sprite2D.material.set_shader_parameter("progress", 0)

func pickup(power):
	if power == "Barrier":
		var current_speed = speed
		if barrier_active:  # if there is an active barrier
			$PickupAudio.stream = load("res://assets/Ancient_Game_Dark_Magic_Buff_2_Fantasy_Tonal_Accent_Hit_Stab.mp3")
			$PickupAudio.play()
			$BarrierTimer.stop()
			$BarrierTimer.start()
	
		else:  # if no current barrier
			barrier_active = true
			$PickupAudio.stream = load("res://assets/Ancient_Game_Dark_Magic_Buff_2_Fantasy_Tonal_Accent_Hit_Stab.mp3")
			$PickupAudio.play()
			var barrier = barrier_scene.instantiate() as Node2D
			add_child(barrier)
			speed = boosted_speed
			var tween = get_tree().create_tween()
			tween.tween_property($CPUParticles2D, "modulate:a", 1, 1)
			$BarrierTimer.start()
			await $BarrierTimer.timeout 
			# finish
			var speed_tween_2 = get_tree().create_tween()
			speed_tween_2.tween_property(self, "speed", current_speed, 1)
			var tween2 = get_tree().create_tween()
			tween2.tween_property($CPUParticles2D, "modulate:a", 0, 1.5)
			barrier.queue_free() 
			barrier_active = false
		
	if power == "Potion":
		$PickupAudio.stream = load("res://assets/Coin Pickup Sound Effect Short.mp3")
		$PickupAudio.play()
		potions += 1
		
		
