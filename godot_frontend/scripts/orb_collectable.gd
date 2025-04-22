extends StaticBody2D

var player_nearby = false
var player_node = null

func _ready() -> void:
	$popuplabel.visible = false 
	fallfromenemy()

func fallfromenemy():
	$AnimationPlayer.play("fallingfromenemy")
	await get_tree().create_timer(1).timeout

func _process(delta):
	if player_nearby and Input.is_action_just_pressed("collect_orb"):  # Press e
		$popuplabel.visible = false
		$AnimationPlayer.play("fade_orb")
		await get_tree().create_timer(0.3).timeout
		Global.add_score(1)
		print(Global.score)
		queue_free()


func _on_pickuparea_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_nearby = true
		player_node = body
		$popuplabel.visible = true


func _on_pickuparea_body_exited(body: Node2D) -> void:
	if body == player_node:
		player_nearby = false
		player_node = null
		$popuplabel.visible = false
