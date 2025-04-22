extends CharacterBody2D

var current_enemy:CharacterBody2D = null

var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false

const speed = 200
var current_dir = "none"
var is_attacking = false

func _ready():
	$AnimatedSprite2D.play("idle")


func _physics_process(delta):
	attack()
	enemy_attack()
	player_movement(delta)
	current_camera()
	update_health()

func player_movement(delta):
	if is_attacking:
		return  # Don't move while attacking

	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		velocity.y = -speed
		velocity.x = 0

	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0

	move_and_slide()

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D

	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("run")
		elif movement == 0:
			if attack_ip == false:
				anim.play("idle")

	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("run")
		elif movement == 0:
			if attack_ip == false:
				anim.play("idle")

func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		current_enemy = body
		enemy_in_attack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		current_enemy = null
		enemy_in_attack_range = false


func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown and current_enemy:
		if current_enemy.has_method("get_enemy_type"):
			var enemy_type = current_enemy.get_enemy_type()

			if Global.enemy_data.has(Global.level):
				var enemy_list = Global.enemy_data[Global.level]
				for enemy in enemy_list:
					if enemy["name"] == enemy_type:
						var damage = enemy["damage"]
						print(enemy_type, "damage = ", damage)
						health -= damage
						print("Player health after", enemy_type, "attack = ", health)

						enemy_attack_cooldown = false
						$attack_cooldown.start()

						if health <= 0 and player_alive:
							player_alive = false
							send_stats_to_backend()
							$"../deathui".visible = true
							$"../score/Label".visible = false
							$"../deathui/VBoxContainer/Label2".text = "Score: " + str(Global.score)
							print("player is killed")



func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true 
	
func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack1"):
		Global.player_current_attack1 = true
		attack_ip = true
		
		if dir == "right":
			$AnimatedSprite2D.flip_h=false
			$AnimatedSprite2D.play("attack1")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h=true
			$AnimatedSprite2D.play("attack1")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("attack1")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("attack1")
			$deal_attack_timer.start()
	
	elif Input.is_action_just_pressed("attack2"):
		Global.player_current_attack2 = true
		attack_ip = true
		
		if dir == "right":
			$AnimatedSprite2D.flip_h=false
			$AnimatedSprite2D.play("attack2")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h=true
			$AnimatedSprite2D.play("attack2")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("attack2")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("attack2")
			$deal_attack_timer.start()


func _on_deal_attack_timer_timeout() -> void:
	$deal_attack_timer.stop()
	Global.player_current_attack1 = false
	Global.player_current_attack2 = false
	attack_ip = false

func current_camera():
	if Global.current_scene=="world":
		$world_camera.enabled=true
		$new_scene_camera.enabled=false
	elif Global.current_scene=="right_side_scene":
		$world_camera.enabled=false
		$new_scene_camera.enabled=true


func update_health():
	var healthbar = $healthbar
	healthbar.value = health 
	
	if health>=100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func _on_regin_timer_timeout() -> void:
	if health < 100:
		health += 20
		if health > 100:
			health = 100
	if health <= 0:
		health = 0
		
func send_stats_to_backend():
	var url = "http://localhost:3000/update"
	var http = $HTTPRequest
	http.request_completed.connect(self._on_http_request_request_completed)
	# Debugging the request to ensure it's happening
	print("Sending stats to backend...")
	
	var body = {
		"address": Global.player_wallet,
		"orbs": Global.score,
		"level": Global.level
	}
	 # Converting the body to JSON
	var json_body = JSON.stringify(body)
	print("Request Body: ", json_body)  # Debugging the JSON body

	# Setting headers (optional but good practice)
	var headers = [
		"Content-Type: application/json"
	]
	var err = http.request(url, headers,HTTPClient.METHOD_POST, json_body)
	if err != 0:
		print("Request error ",err)
	else :
		print("Request send Successfully")
		print("Requesting: ", url)
		print("Request body: ", json_body)
		print("Method: POST")

func _on_http_request_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	
	print("Request completed, result: ", result, "response_code: ", response_code)
	var response_text = body.get_string_from_utf8()
	var json = JSON.parse_string(response_text)

	if response_code == 200 and typeof(json) == TYPE_DICTIONARY:
		var tx_hash = json.get("txHash", "N/A")
		print("✅ Score submitted! TX:", tx_hash)
		
		var tx_hash_label = $"../deathui/VBoxContainer/Label3"
		tx_hash_label.text = "Transaction hash: " + tx_hash
		self.queue_free()
	else:
		print("❌ Server Response Failed: ", response_code, response_text)
