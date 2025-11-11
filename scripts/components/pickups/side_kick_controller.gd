extends Node

var input_dir: Vector2

# TODO: may need to check if player is assigned first
func _physics_process(delta: float) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer() and is_multiplayer_authority() and not MatchManager.game_paused:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
