extends Control

@onready var wallet_input = $VBoxContainer/LineEdit
@onready var submit_button = $VBoxContainer/submit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_submit_pressed() -> void:
	var address = wallet_input.text.strip_edges()
	
	if address.begins_with("0x") and address.length() == 42:
		Global.player_wallet = address
		print("Wallet saved:", address)
		get_tree().change_scene_to_file("res://scenes/world.tscn")
	else:
		print("Invalid wallet address")
		
