extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$deathui.visible=false
	if Global.first_time_game_load == true:
		$player.position.x  = Global.player_start_posx
		$player.position.y = Global.player_start_posy
		get_tree().current_scene.get_node("score/Label").text = " Score : 0 "
	else :
		$player.position.x  = Global.player_exit_rightside_posx
		$player.position.y = Global.player_exit_rightside_posy
		$player.get_node("AnimatedSprite2D").flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_tree().current_scene.get_node("score/Label").text = " Score : " + str(Global.score)
	change_scene()


func _on_transition_new_scene_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = true
		print("1")


func _on_transition_new_scene_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene = false
		
func change_scene():
	if Global.transition_scene == true:
		print(Global.transition_scene)
		if Global.current_scene == "world":
			Global.finish_changescene()
			get_tree().change_scene_to_file("res://scenes/right_side_scene.tscn")
			Global.first_time_game_load = false
			print(Global.transition_scene)
			print("2")
			


func _on_button_pressed() -> void:
	print("change scene")
	Global.level=1
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	$deathui.visible = false
