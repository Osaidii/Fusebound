extends CanvasLayer

@onready var transiton_player: AnimationPlayer = $"Transition Player"

# This Function is for Deactivating the Transiton Rectangle
func scene_in() -> void:
	transiton_player.play("in")

# This Function is for Activating the Transiton Rectangle
func scene_out() -> void:
	transiton_player.play("out")
