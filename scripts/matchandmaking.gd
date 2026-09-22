extends Node2D

const MAP_1 = preload("uid://bymwcyrqq7kgc")
const MAP_2 = preload("uid://dwcbtb74d07bd")
const PLAYER = preload("uid://ct1ysgutbxa0y")

@onready var _3: Node2D = $"MatchMaking/PlayerPoints/3"
@onready var _4: Node2D = $"MatchMaking/PlayerPoints/4"
@onready var _5: Node2D = $"MatchMaking/PlayerPoints/5"
@onready var _6: Node2D = $"MatchMaking/PlayerPoints/6"
@onready var anims: AnimationPlayer = $MatchMaking/Anims
@onready var match_making: Node2D = $MatchMaking
@onready var match_node: Node2D = $Match
@onready var start: TextureButton = $MatchMaking/Start
@onready var back: TextureButton = $MatchMaking/Back
@onready var controls: TextureButton = $MatchMaking/Controls
@onready var death_timer: Timer = $"Death Timer"
@onready var bomb_on: Sprite2D = $"HUD/Bomb On"
@onready var outfit_1: AnimatedSprite2D = $"HUD/Outfit 1"
@onready var outfit_2: AnimatedSprite2D = $"HUD/Outfit 2"
@onready var outfit_3: AnimatedSprite2D = $"HUD/Outfit 3"
@onready var outfit_4: AnimatedSprite2D = $"HUD/Outfit 4"
@onready var outfit_5: AnimatedSprite2D = $"HUD/Outfit 5"
@onready var outfit_6: AnimatedSprite2D = $"HUD/Outfit 6"
@onready var timer: Label = $HUD/Timer
@onready var winner_title: Sprite2D = $HUD/Winner
@onready var w_1: Node2D = $"HUD/Winner/1"
@onready var w_2: Node2D = $"HUD/Winner/2"
@onready var w_3: Node2D = $"HUD/Winner/3"
@onready var w_4: Node2D = $"HUD/Winner/4"
@onready var w_5: Node2D = $"HUD/Winner/5"
@onready var w_6: Node2D = $"HUD/Winner/6"

var player1: Player
var player2: Player
var player3: Player
var player4: Player
var player5: Player
var player6: Player

var match_running := false
var players_alive := 0
var winner: Player

# This function sets up the scene.
func _ready() -> void:
	Transition.scene_in()
	start.grab_focus()

# This function gives the bomb randomly to another player.
func random_bomb() -> void:
	var living = []
	if player1 != null: living.append(player1)
	if player2 != null: living.append(player2)
	if player3 != null: living.append(player3)
	if player4 != null: living.append(player4)
	if player5 != null: living.append(player5)
	if player6 != null: living.append(player6)
	if living.is_empty():
		return
	var chosen = living.pick_random()
	outfit_1.visible = false
	outfit_2.visible = false
	outfit_3.visible = false
	outfit_4.visible = false
	outfit_5.visible = false
	outfit_6.visible = false
	for p in living:
		if p != null:
			p.IS_TAGGER = false
	chosen.IS_TAGGER = true
	if chosen == player1: outfit_1.visible = true
	elif chosen == player2: outfit_2.visible = true
	elif chosen == player3: outfit_3.visible = true
	elif chosen == player4: outfit_4.visible = true
	elif chosen == player5: outfit_5.visible = true
	elif chosen == player6: outfit_6.visible = true
	death_timer.start()
	anims.play("timer")

func kill_player(player) -> void:
	if player == null:
		return
	player.queue_free()
	players_alive -= 1

# This function does the match instatiation.
func _on_start_pressed() -> void:
	Transition.scene_out()
	await get_tree().create_timer(1.0).timeout
	instantiate_everything()
	await get_tree().create_timer(0.1).timeout
	Transition.scene_in()
	await get_tree().create_timer(1.0).timeout
	start_match()

func show_winner() -> void:
	bomb_on.visible = false
	timer.visible = false
	outfit_1.visible = false
	outfit_2.visible = false
	outfit_3.visible = false
	outfit_4.visible = false
	outfit_5.visible = false
	outfit_6.visible = false
	death_timer.stop()
	w_1.visible = false
	w_2.visible = false
	w_3.visible = false
	w_4.visible = false
	w_5.visible = false
	w_6.visible = false
	if player1 != null:
		winner = player1
		w_1.visible = true
	elif player2 != null:
		winner = player2
		w_1.visible = true
	elif player3 != null:
		winner = player3
		w_1.visible = true
	elif player4 != null:
		winner = player4
		w_1.visible = true
	elif player5 != null:
		winner = player5
		w_1.visible = true
	elif player6 != null:
		winner = player6
		w_1.visible = true
	winner_title.visible = true
	await get_tree().create_timer(10.0).timeout
	match_end()

# This function starts the match and does the countdown.
func start_match() -> void:
	anims.play("countdown")
	await get_tree().create_timer(3.0).timeout
	player1.CAN_CONTROL = true
	player2.CAN_CONTROL = true
	if player3 != null:
		player3.CAN_CONTROL = true
	if player4 != null:
		player4.CAN_CONTROL = true
	if player5 != null:
		player5.CAN_CONTROL = true
	if player6 != null:
		player6.CAN_CONTROL = true
	match_running = true
	random_bomb()
	bomb_on.visible = true
	timer.visible = true

# This function instatiates player with data provided.
func instantiate_player(outfit_number, controls_number, collision_layer, positon: Vector2):
	var instance  = PLAYER.instantiate()
	instance.OUTFIT = outfit_number
	instance.CONTROLS = controls_number
	instance.collision_layer = collision_layer
	instance.collision_mask = collision_layer
	match_node.add_child(instance)
	instance.global_position = positon
	return instance

# This function starts to instatiation process.
func instantiate_everything() -> void:
	var amount_of_players := 2
	if _3.get_child(1).visible:
		amount_of_players += 1
	if _4.get_child(1).visible:
		amount_of_players += 1
	if _5.get_child(1).visible:
		amount_of_players += 1
	if _6.get_child(1).visible:
		amount_of_players += 1
	var random_array = []
	for i in range(amount_of_players):
		random_array.append(i)
	random_array.shuffle()
	match_making.visible = false
	match_node.visible = true
	instantiate_map(1)
	player1 = instantiate_player(1, 1, 3, match_node.get_child(0).get_child(0).get_child(random_array[0]).global_position)
	player2 = instantiate_player(2, 2, 4, match_node.get_child(0).get_child(0).get_child(random_array[1]).global_position)
	if _3.get_child(1).visible:
		player3 = instantiate_player(3, 3, 5, match_node.get_child(0).get_child(0).get_child(random_array[2]).global_position)
	if _4.get_child(1).visible:
		player4 = instantiate_player(4, 4, 6, match_node.get_child(0).get_child(0).get_child(random_array[3]).global_position)
	if _5.get_child(1).visible:
		player5 = instantiate_player(5, 5, 7, match_node.get_child(0).get_child(0).get_child(random_array[4]).global_position)
	if _6.get_child(1).visible:
		player6 = instantiate_player(6, 6, 8, match_node.get_child(0).get_child(0).get_child(random_array[5]).global_position)
	players_alive = amount_of_players

# This function instantiaes the selected map.
func instantiate_map(map_number):
	var map
	match map_number:
		1:
			map = MAP_1
		2:
			map = MAP_2
	var instance  = map.instantiate()
	match_node.add_child(instance)

# This function takes the user back to the Main Menu.
func _on_back_pressed() -> void:
	Transition.scene_out()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/main menu.tscn")

# This function is the termination and deletion of the match.
func match_end():
	Transition.scene_out()
	await get_tree().create_timer(1.0).timeout
	for i in range(match_node.get_child_count()):
		match_node.get_child(i).queue_free()
	match_node.visible = false
	match_making.visible = true
	await get_tree().create_timer(0.5).timeout
	Transition.scene_in()
	start.grab_focus()
	winner = null
	winner_title.visible = false

# This function arranges the UI when a third player is added.
func _on_add_3_pressed() -> void:
	_3.get_child(0).visible = true
	_3.get_child(1).visible = true
	_3.get_child(2).visible = false
	_3.get_child(3).visible = true
	_4.get_child(2).visible = true
	_4.get_child(2).grab_focus()
	start.focus_neighbor_top = _4.get_child(2).get_path()
	back.focus_neighbor_top = _4.get_child(2).get_path()
	controls.focus_neighbor_top = _4.get_child(2).get_path()

# This function arranges the UI when a fourth player is added.
func _on_add_4_pressed() -> void:
	_4.get_child(0).visible = true
	_4.get_child(1).visible = true
	_4.get_child(2).visible = false
	_4.get_child(3).visible = true
	_5.get_child(2).visible = true
	_5.get_child(2).grab_focus()
	_3.get_child(3).focus_neighbor_right = _4.get_child(3).get_path()
	start.focus_neighbor_top = _5.get_child(2).get_path()
	back.focus_neighbor_top = _5.get_child(2).get_path()
	controls.focus_neighbor_top = _5.get_child(2).get_path()

# This function arranges the UI when a fifth player is added.
func _on_add_5_pressed() -> void:
	_5.get_child(0).visible = true
	_5.get_child(1).visible = true
	_5.get_child(2).visible = false
	_5.get_child(3).visible = true
	_6.get_child(2).visible = true
	_6.get_child(2).grab_focus()
	start.focus_neighbor_top = _6.get_child(2).get_path()
	back.focus_neighbor_top = _6.get_child(2).get_path()
	controls.focus_neighbor_top = _6.get_child(2).get_path()

# This function arranges the UI when a sixth player is added.
func _on_add_6_pressed() -> void:
	_6.get_child(0).visible = true
	_6.get_child(1).visible = true
	_6.get_child(2).visible = false
	_6.get_child(3).visible = true
	start.focus_neighbor_top = _4.get_child(3).get_path()
	back.focus_neighbor_top = _5.get_child(3).get_path()
	controls.focus_neighbor_top = _6.get_child(3).get_path()
	_5.get_child(3).focus_neighbor_right = _6.get_child(3).get_path()
	_3.get_child(3).focus_neighbor_bottom = _6.get_child(3).get_path()
	start.grab_focus()

# This function arranges the UI when the third player is removed.
func _on_remove_3_pressed() -> void:
	if _4.get_child(0).visible == true:
		anims.play("remove error")
		return
	_3.get_child(0).visible = false
	_3.get_child(1).visible = false
	_3.get_child(2).visible = true
	_3.get_child(3).visible = false
	_4.get_child(2).visible = false
	_3.get_child(2).grab_focus()
	start.focus_neighbor_top = _3.get_child(2).get_path()
	back.focus_neighbor_top = _3.get_child(2).get_path()
	controls.focus_neighbor_top = _3.get_child(2).get_path()
	_3.get_child(3).focus_neighbor_right = _4.get_child(2).get_path()

# This function arranges the UI when the fourth player is removed.
func _on_remove_4_pressed() -> void:
	if _5.get_child(0).visible == true:
		anims.play("remove error")
		return
	_4.get_child(0).visible = false
	_4.get_child(1).visible = false
	_4.get_child(2).visible = true
	_4.get_child(3).visible = false
	_5.get_child(2).visible = false
	_4.get_child(2).grab_focus()
	start.focus_neighbor_top = _4.get_child(2).get_path()
	back.focus_neighbor_top = _4.get_child(2).get_path()
	controls.focus_neighbor_top = _4.get_child(2).get_path()
	_3.get_child(3).focus_neighbor_right = _4.get_child(2).get_path()

# This function arranges the UI when the fifth player is removed.
func _on_remove_5_pressed() -> void:
	if _6.get_child(0).visible == true:
		anims.play("remove error")
		return
	_5.get_child(0).visible = false
	_5.get_child(1).visible = false
	_5.get_child(2).visible = true
	_5.get_child(3).visible = false
	_6.get_child(2).visible = false
	_5.get_child(2).grab_focus()
	start.focus_neighbor_top = _5.get_child(2).get_path()
	back.focus_neighbor_top = _5.get_child(2).get_path()
	controls.focus_neighbor_top = _5.get_child(2).get_path()
	_4.get_child(3).focus_neighbor_right = _5.get_child(2).get_path()
	_3.get_child(3).focus_neighbor_right = _4.get_child(3).get_path()

# This function arranges the UI when the sixth player is removed.
func _on_remove_6_pressed() -> void:
	_6.get_child(0).visible = false
	_6.get_child(1).visible = false
	_6.get_child(2).visible = true
	_6.get_child(3).visible = false
	_6.get_child(2).grab_focus()
	start.focus_neighbor_top = _6.get_child(2).get_path()
	back.focus_neighbor_top = _6.get_child(2).get_path()
	controls.focus_neighbor_top = _6.get_child(2).get_path()
	_3.get_child(3).focus_neighbor_right = _4.get_child(3).get_path()
	_5.get_child(3).focus_neighbor_bottom = _6.get_child(2).get_path()
	_3.get_child(3).focus_neighbor_bottom = _6.get_child(2).get_path()

func _on_death_timer_timeout() -> void:
	if players_alive - 1 <= 1:
		show_winner()
		return
	var player: Player
	if player1 != null:
		if player1.IS_TAGGER:
			player = player1
			kill_player(player)
			player1 = null
	if player2 != null:
		if player2.IS_TAGGER:
			player = player2
			kill_player(player)
			player2 = null
	if player3 != null:
		if player3.IS_TAGGER:
			player = player3
			kill_player(player)
			player3 = null
	if player4 != null:
		if player4.IS_TAGGER:
			player = player4
			kill_player(player)
			player4 = null
	if player5 != null:
		if player5.IS_TAGGER:
			player = player5
			kill_player(player)
			player5 = null
	if player6 != null:
		if player6.IS_TAGGER:
			player = player6
			kill_player(player)
			player6 = null
	await get_tree().process_frame
	random_bomb()

func update_timer(number: int):
	timer.text = str(number)
	if number < 10:
		timer.self_modulate = Color(255, 0, 0)
	if number >= 10:
		timer.self_modulate = Color(255, 255, 255)
