extends CharacterBody2D

var speed = 45
var player_chase = false
var player = null

var health = 0
var max_health = 0
var player_in_attack_zone = false

var can_take_damage = true

signal enemy_died

var orb = preload("res://scenes/orb_collectable.tscn")

func _ready() -> void:
	if Global.enemy_data.has(Global.level):
		apply_enemy_stats()
	else:
		Global.get_enemy_stats()
		Global.enemy_stats_ready.connect(_on_enemy_stats_ready)

func _on_enemy_stats_ready(level):
	if level == Global.level:
		apply_enemy_stats()

func apply_enemy_stats():
	if Global.enemy_data.has(Global.level):
		var enemy_list = Global.enemy_data[Global.level]
		for enemy in enemy_list:
			if enemy.has("name") and enemy["name"] == "Eye":
				health = enemy["health"]
				max_health = health
				print("Eye stats: Health =", health)
				return
		print("Eye stats not found for level ", Global.level)
	else:
		print("No enemy data found for level ", Global.level)

func _physics_process(delta):
	deal_with_damage()
	update_health()

	if player_chase:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("attack")

		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false

func enemy():
	pass

func _on_enemy_3_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = true

func _on_enemy_3_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_attack_zone = false

func deal_with_damage():
	if player_in_attack_zone and (Global.player_current_attack1 or Global.player_current_attack2):
		if can_take_damage:
			$take_damage_cooldown.start()
			can_take_damage = false

			if Global.player_current_attack1:
				health -= 50
			elif Global.player_current_attack2:
				health -= 10

			print("Eye enemy health = ", health)

			if health <= 0:
				print("Eye enemy dead")
				var orb_instance = orb.instantiate()
				orb_instance.global_position = $Marker2D.global_position
				get_parent().add_child(orb_instance)
				die()

func _on_take_damage_cooldown_timeout() -> void:
	can_take_damage = true

func update_health():
	var healthbar = $healthbar
	healthbar.value = health
	healthbar.max_value = max_health
	healthbar.visible = health < max_health

func get_enemy_type():
	return "Eye"

func die():
	emit_signal("enemy_died")
	queue_free()

func apply_stats(stats: Dictionary):
	if stats.has("health"):
		health = stats["health"]
		max_health = health
