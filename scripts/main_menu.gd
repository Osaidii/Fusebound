extends Node2D

const MATCHANDMAKING := preload("uid://sdkadgq6g1mq") as PackedScene

@onready var anims: AnimationPlayer = %Anims
@onready var play: TextureButton = %Play
@onready var settings: TextureButton = %Settings
@onready var exit: TextureButton = %Exit
@onready var back: TextureButton = %Back
@onready var window_button: OptionButton = %WindowButton
@onready var vsync_button: CheckButton = %"Vsync Button"
@onready var limit_button: CheckButton = %"Limit Button"
@onready var cap_button: OptionButton = %"Cap Button"
@onready var slider: HSlider = %Slider

var settings_dict := {
	"window_mode": 2,
	"vsync": true,
	"fps_limit": false,
	"fps_cap": 1,
	"master_volume": 8
}

const VOLUME_DB := [-80.0, -18.0, -15.0, -12.0, -9.0, -6.0, -3.0, 0.0, 3.0, 6.0, 9.0]

# This function sets up the scene.
func _ready() -> void:
	Transition.scene_in()
	play.grab_focus()
	var save_data: Dictionary = Saveload.get_settings()
	if save_data != {}:
		load_settings(save_data)

func load_settings(save_data) -> void:
	_on_window_button_item_selected(save_data["window_mode"])
	_on_vsync_button_toggled(save_data["vsync"])
	_on_limit_button_toggled(save_data["fps_limit"])
	_on_cap_button_item_selected(save_data["fps_cap"])
	_on_slider_value_changed(save_data["master_volume"])

func save(setting: String, value) -> void:
	settings_dict[setting] = value
	Saveload.save_settings(settings_dict)

# This function runs when play is pressed.
func _on_play_pressed() -> void:
	Transition.scene_out()
	await get_tree().create_timer(1.3).timeout
	get_tree().change_scene_to_packed(MATCHANDMAKING)

# This function runs when back is pressed.
func _on_back_pressed() -> void:
	anims.play("settings_off")
	play.grab_focus()

# This function runs when exit is pressed.
func _on_exit_pressed() -> void:
	Transition.scene_out()
	await get_tree().create_timer(1.3).timeout
	get_tree().quit()

# This function runs when settings is pressed.
func _on_settings_pressed() -> void:
	anims.play("settings")
	window_button.grab_focus()

# This button changes window mode based on user settings.
func _on_window_button_item_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	elif index == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif index == 3:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	save("window_mode", index)
	window_button.selected = index

# This button enables vsync based on user settings.
func _on_vsync_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		limit_button.button_pressed = false
		limit_button.disabled = true
		cap_button.disabled = true
	if !toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		limit_button.disabled = false
		cap_button.disabled = true
	save("vsync", toggled_on)
	vsync_button.button_pressed = toggled_on

# This button enables fps limit based on user settings.
func _on_limit_button_toggled(toggled_on: bool) -> void:
	if toggled_on and !vsync_button.button_pressed:
		cap_button.disabled = false
		Engine.max_fps = cap_button.selected
	else:
		cap_button.disabled = true
		Engine.max_fps = 0
	save("fps_limit", toggled_on)
	limit_button.button_pressed = toggled_on

# This button changes fps cap based on user settings.
func _on_cap_button_item_selected(index: int) -> void:
	var max_fps := 0
	if index == 0:
		max_fps = 30
	elif index == 1:
		max_fps = 60
	elif index == 2:
		max_fps = 120
	elif index == 3:
		max_fps = 180
	Engine.max_fps = max_fps
	save("fps_cap", index)
	cap_button.selected = index

# This button changes master volume based on user settings.
func _on_slider_value_changed(value: float) -> void:
	var idx := clampi(int(round(value)), 0, VOLUME_DB.size() - 1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), VOLUME_DB[idx])
	save("master_volume", value)
	slider.value = value
