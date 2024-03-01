extends Node2D

@onready var screen_size = get_window().size
var skeleton_scene: PackedScene = load("res://scenes/skeleton.tscn")
var lightning_trap_scene: PackedScene = load("res://scenes/lightning_trap.tscn")
var fire_trap_scene: PackedScene = load("res://scenes/fire_trap.tscn")
var saw_trap_scene: PackedScene = load("res://scenes/saw_trap.tscn")
var saw_trap_scene_flat: PackedScene = load("res://scenes/saw_trap_2.tscn")
var potion_scene_a: PackedScene = load("res://scenes/potion_scene_a.tscn")
var potion_scene_b: PackedScene = load("res://scenes/potion_scene_b.tscn")
var potion_scene_c: PackedScene = load("res://scenes/potion_scene_c.tscn")
var potion_scene_d: PackedScene = load("res://scenes/potion_scene_d.tscn")
var obstacles: Array[PackedScene] = [lightning_trap_scene]
var obstacles_flat: Array[PackedScene] = [saw_trap_scene, fire_trap_scene]
var item_pickups: Array[PackedScene] = [potion_scene_a, potion_scene_b, potion_scene_c, potion_scene_d]
var score: int = 0
var high_score: int = 0
var score_modifier: int = 1000
var game_running = false

# initial game state
var player_pos = Vector2(175, 556)
var ground_pos = Vector2(0, 0)
var ceiling_pos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	game_running = false
	get_tree().paused = true
	$StartScreen.show()
	$GameOver.hide()
	$UI.hide()
	$Player.player_died.connect(end_game)
	$GameOver.restart_button_pressed.connect(new_game)
	$UI/HighScore.text = str("High Score: ") + str(high_score / score_modifier)
	$UI/Score.text = str("Score: 0")
	new_game()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_running:
		$UI.show()
		score += $Player.speed
		update_ui()
		
		if $Player.speed < $Player.max_speed:
			$Player.speed *= $Player.speed_increase
		
		# clean up
		for obj in get_tree().get_nodes_in_group("Obstacle"):
			if obj.global_position.x < $Player.global_position.x - 1000:
				obj.queue_free()
		for obj in get_tree().get_nodes_in_group("Pickup"):
			if obj.global_position.x < $Player.global_position.x - 5000:
				obj.queue_free()
	
	else: 
		if Input.is_action_pressed("start"):
			get_tree().paused = false
			$StartScreen.hide()
			$UI.show()
			game_running = true
	
	# if camera x position (middle of camera) is more than 1.5 screens away 
	# from Ground initial start position (left of ground)
	# ie camera is entire screen away from ground start position
	# move Ground position x an entire screen over
	if $Player/Camera2D.global_position.x - $Ground.position.x > screen_size.x * 2:
		$Ground.position.x += screen_size.x
		$Ceiling.position.x += screen_size.x
		
func update_ui():
	$UI/Score.text = str("Score: ") + str(score / score_modifier) 
	$UI/CurrentSpeed.text = str("Speed: ") + str(int($Player.speed)) 
	if $Player.potions <= $Player.max_potions:
		if $Player.potions >= 0 and $Player.potions <= 20:
			$UI/DashBar1.value = (float($Player.potions) / 20) * 100
			$UI/DashBar2.value = 0
			$UI/DashBar3.value = 0
		elif $Player.potions > 20 and $Player.potions <= 40:
			$UI/DashBar1.value = 100
			$UI/DashBar2.value = ((float($Player.potions) - 20) / 20) * 100
			$UI/DashBar3.value = 0
		else:
			$UI/DashBar1.value = 100
			$UI/DashBar2.value = 100
			$UI/DashBar3.value = ((float($Player.potions) - 40) / 20) * 100

func spawn_skeleton(number):
	for i in range(number):
		var player_current_pos = $Player.global_position
		var ahead_x = player_current_pos.x + randf_range(1200, 2000)
		var ahead_y = 500
		var skeleton = skeleton_scene.instantiate()
		add_child(skeleton)
		skeleton.position = Vector2(ahead_x, ahead_y)

func spawn_obstacle(number):
	for i in range(number):
		var player_current_pos = $Player.global_position
		var ahead_x = player_current_pos.x + 1000
		var ahead_y = randf_range(150, 480)
		var obstacle_scene = obstacles[randi() % 1]
		var obstacle = obstacle_scene.instantiate()
		add_child(obstacle)
		obstacle.position = Vector2(ahead_x, ahead_y)
		obstacle.rotation_degrees = randf_range(45, 120)
		
func spawn_obstacle_flat(number):
	for i in range(number):
		var player_current_pos = $Player.global_position
		var ahead_x = player_current_pos.x + 1000
		var ceiling_ground_y = [120, 530]
		var ahead_y = ceiling_ground_y[randi() % 2]
		var obstacle_scene = obstacles_flat[randi() % 2]
		var obstacle = obstacle_scene.instantiate()
		add_child(obstacle)
		obstacle.position = Vector2(ahead_x, ahead_y)
		if ahead_y == 120:  # if on ceiling, flip y
			obstacle.scale.y = abs(obstacle.scale.y) * -1

func spawn_pickup():
	var player_current_pos = $Player.global_position
	var item_scene = item_pickups[randi() % 4]
	#if item_scene == potion_pickup_scene:
	var ahead_y = randf_range(140, 300)
		#for i in [50, 100, 150, 200, 250]:
	var ahead_x = player_current_pos.x + 1000  # + i
	var item = item_scene.instantiate()
	add_child(item)
	item.global_position = Vector2(ahead_x, ahead_y)
	#else:
		#var ahead_y = randf_range(140, 500)
		#var ahead_x = player_current_pos.x + 1000
		#var item = item_scene.instantiate()
		#add_child(item)
		#item.global_position = Vector2(ahead_x, ahead_y)
	
func _on_obstacles_spawn_timer_timeout():
	if game_running:
		var random_seconds = randf_range(1, 2)
		var random_number = randi_range(1, 2)  # random number to spawn multiples
		await get_tree().create_timer(random_seconds).timeout  # extra timer to randomize spawn behaviour
		spawn_obstacle(random_number)
		$ObstaclesSpawnTimer.start()

func _on_enemy_spawn_timer_timeout():
	if game_running:
		var random_seconds = randf_range(1, 2)
		var random_number = randi_range(1, 5)  # random number to spawn multiples
		await get_tree().create_timer(random_seconds).timeout # extra timer to randomize spawn behaviour
		spawn_skeleton(random_number)
		$EnemySpawnTimer.start()


func _on_obstacles_flat_spawn_timer_timeout():
	if game_running:
		var random_seconds = randf_range(1, 2)
		await get_tree().create_timer(random_seconds).timeout  # extra timer to randomize spawn behaviour
		spawn_obstacle_flat(1)
		$ObstaclesFlatSpawnTimer.start()
		

func _on_item_timer_timeout():
	if game_running:
		var random_seconds = randf_range(2, 3)
		await get_tree().create_timer(random_seconds).timeout  # extra timer to randomize spawn behaviour
		spawn_pickup()
		$ItemTimer.start()
	
func new_game():
	get_tree().paused = false
	game_running = false
	$AudioStreamPlayer.pitch_scale = 1
	score = 0
	$Player.speed = $Player.default_speed
	$Player.potions = 0
	$UI.hide()
	$UI/Score.text = str("Score: ") + str(score / score_modifier)
	$Player.allow_input = true
	$Player.position = player_pos
	$Ground.position = ground_pos
	$Ceiling.position = ceiling_pos
	# clean up
	for obj in get_tree().get_nodes_in_group("Obstacle"):
		obj.queue_free()
	for obj in get_tree().get_nodes_in_group("Enemy"):
		obj.queue_free()
	for obj in get_tree().get_nodes_in_group("Pickup"):
		obj.queue_free()
	$GameOver.hide()
	$StartScreen.show()
	
func check_scores():
	if score > high_score:
		high_score = score
		$UI/HighScore.text = str("High Score: ") + str(score / score_modifier) 
	$GameOver/MarginContainer/VBoxContainer/Score_High.text = str("Score: ") + str(score / score_modifier) + (" | High Score: ") + str( high_score / score_modifier)

func end_game():
	game_running = false
	check_scores()
	$GameOver.show()

func _on_player_player_dying():
	var tween = get_tree().create_tween()
	tween.tween_property($AudioStreamPlayer, "pitch_scale", 0, 0.5)


