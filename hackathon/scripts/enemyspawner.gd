extends Node2D

# Preload enemy scenes
var goblin_scene = preload("res://scenes/goblin.tscn")
var skeleton_scene = preload("res://scenes/skeleton.tscn")
var mushroom_scene = preload("res://scenes/mushroom.tscn")
var eye_scene = preload("res://scenes/eye.tscn")

var enemies_per_type = 1
var total_alive = 0
var spawn_markers: Array[Marker2D] = []

func _ready():
	randomize()

	# Collect all Marker2D children (or use a group for flexibility)
	for child in get_children():
		if child is Marker2D:
			spawn_markers.append(child)
			print("Found spawn marker at: ", child.global_position)

	if spawn_markers.is_empty():
		push_error("❌ No Marker2D nodes found for spawning! Add them as children of this node.")
	else:
		spawn_enemies()

# Spawning enemies based on the types and level
func spawn_enemies():
	for i in range(enemies_per_type):
		spawn_enemy(goblin_scene)
		spawn_enemy(skeleton_scene)
		spawn_enemy(eye_scene)
		spawn_enemy(mushroom_scene)

# Spawning a single enemy
func spawn_enemy(scene: PackedScene):
	if spawn_markers.is_empty():
		push_error("❌ Cannot spawn enemy: No spawn markers available.")
		return

	var enemy = scene.instantiate()
	var spawn_marker = spawn_markers.pick_random()
	enemy.position = spawn_marker.global_position

	# Assign stats based on the scene and current level
	var enemy_name = scene.resource_path.get_file().get_basename().capitalize()  # e.g., "Goblin"
	var enemy_stats = Global.enemy_data.get(Global.level, []).filter(func(e): return e.name == enemy_name)
	if enemy_stats.size() > 0 and enemy.has_method("apply_stats"):
		enemy.apply_stats(enemy_stats[0])  # Pass the dictionary to the enemy

	print("✅ Spawning ", enemy_name, " at: ", enemy.position)

	# Defer adding the enemy to the parent to avoid frame conflicts
	get_parent().add_child.call_deferred(enemy)
	enemy.add_to_group("enemies")

	# Connect the enemy's death signal
	if enemy.has_signal("enemy_died"):
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))

	total_alive += 1

# Listener for enemy stats readiness
func _on_enemy_stats_ready_with_level(fetched_level):
	if fetched_level == Global.level:
		print("📦 Enemy stats received for level ", Global.level)
		spawn_enemies()

# Handling enemy death and updating the total_alive counter
func _on_enemy_died():
	total_alive -= 1
	print("total alive", total_alive)
	if total_alive <= 0:
		next_level()

# Moving to the next level and handling level progression
func next_level():
	Global.level += 1
	enemies_per_type += 1  # Increase the number of enemies per type each level
	total_alive = 0  # Reset the alive counter

	print("⚔️ Level Up! Now level ", Global.level)
	
	# Fetch enemy stats if not available for the new level
	if not Global.enemy_data.has(Global.level):
		# Connect the signal for when stats are ready and request them
		Global.enemy_stats_ready.connect(_on_enemy_stats_ready_with_level, CONNECT_ONE_SHOT)
		Global.get_enemy_stats()  # Request stats from the backend
	else:
		# If stats are already available, spawn enemies immediately
		_on_enemy_stats_ready_with_level(Global.level)
