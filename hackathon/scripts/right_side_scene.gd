extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.get_node("score/Label").text = " Score : " + str(Global.score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	change_scene()


func _on_exit_point_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene= true
		print("4")
		


func _on_exit_point_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		Global.transition_scene= false
		

func change_scene():
	if Global.transition_scene == true:
		if Global.current_scene == "right_side_scene":
			Global.finish_changescene()
			get_tree().change_scene_to_file("res://scenes/world.tscn")
			print("5")
			
