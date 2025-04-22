extends Node

var player_current_attack1 = false
var player_current_attack2 = false

var current_scene = "world"
var transition_scene = false

var player_exit_rightside_posx = 624
var player_exit_rightside_posy = 250
var player_start_posx = 32
var player_start_posy = 51
var player_health = 0

var first_time_game_load = true 

var player_wallet = ""

var level = 1  # Initial level (can be updated as the player progresses)

var enemy_data = {}  # Stores enemy stats
var score = 0

signal enemy_stats_ready(level)

# Change scene based on the transition flag
func finish_changescene():
	if transition_scene:
		transition_scene = false
		if current_scene == "world":
			current_scene = "right_side_scene"
		else:
			current_scene = "world"

# Update the score on the screen
func add_score(value):
	score += value
	var score_label = get_tree().current_scene.get_node("score/Label")
	if score_label:
		score_label.text = " Score : " + str(score)

# Fetch stats for the enemy based on current level
func get_enemy_stats():
	# Avoid fetching if the stats are already cached for this level
	if enemy_data.has(level):
		print("Enemy data for level " + str(level) + " is already cached.")
		return  # Data already fetched for this level, no need to request again

	var http_request := HTTPRequest.new()
	add_child(http_request)

	# Store the level as metadata for the response handler
	http_request.set_meta("level", level)
	http_request.connect("request_completed", Callable(self, "_on_enemy_stats_received"))
	
	# Construct the URL with the level parameter
	var url = "http://localhost:3000/enemy-stats/" + str(level)
	var err = http_request.request(url)

	if err != OK:
		print("Failed to send HTTP request for level: " + str(level))  # Use print for logging in Godot

# Handle the response when enemy stats are received
func _on_enemy_stats_received(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var http_request := get_child(get_child_count() - 1)
	var level = http_request.get_meta("level")

	# If response is successful, process the stats
	if response_code == 200:
		var json := body.get_string_from_utf8()
		var parsed = JSON.parse_string(json)

		if parsed is Dictionary:
			var data = parsed
			if data is Dictionary and data.has("enemies"):
				# Store the stats in enemy_data dictionary
				enemy_data[level] = data["enemies"]
				print("Enemy stats for level ", level, ": ", data["enemies"])
				# Emit signal after storing
				emit_signal("enemy_stats_ready", level)
			else:
				print("Invalid response format, expected dictionary with 'enemies' key.")
		else:
			print("Failed to parse JSON for level " + str(level) + ": " + parsed.error_string)
	else:
		print("Failed to fetch stats for level " + str(level) + " (HTTP " + str(response_code) + ")")

	# Free the HTTP request once done
	http_request.queue_free()
