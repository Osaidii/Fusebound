extends Node2D

const PLAYER := preload("uid://ct1ysgutbxa0y")
const MAP_1 := preload("uid://bymwcyrqq7kgc")
const EXPLOSION = preload("uid://tyk4ukbrhgg8")

@onready var matchmaking: Node2D = %Matchmaking
@onready var match_node: Node2D = %Match
@onready var point_3: Node2D = %"Point 3"
@onready var point_4: Node2D = %"Point 4"
@onready var point_5: Node2D = %"Point 5"
@onready var point_6: Node2D = %"Point 6"
@onready var anims: AnimationPlayer = %Anims
@onready var start: TextureButton = %Start
@onready var back: TextureButton = %Back
@onready var controls: TextureButton = %Controls
@onready var death_timer: Timer = %"Death Timer"
@onready var bomb_text: Sprite2D = %"Bomb Text"
@onready var timer_text: Label = %"Timer Text"
@onready var winner_pop_up: Sprite2D = %"Winner Pop up"
@onready var b_1: AnimatedSprite2D = %"Bomb Outfit 1"
@onready var b_2: AnimatedSprite2D = %"Bomb Outfit 2"
@onready var b_3: AnimatedSprite2D = %"Bomb Outfit 3"
@onready var b_4: AnimatedSprite2D = %"Bomb Outfit 4"
@onready var b_5: AnimatedSprite2D = %"Bomb Outfit 5"
@onready var b_6: AnimatedSprite2D = %"Bomb Outfit 6"
@onready var w_1: Node2D = %"1"
@onready var w_2: Node2D = %"2"
@onready var w_3: Node2D = %"3"
@onready var w_4: Node2D = %"4"
@onready var w_5: Node2D = %"5"
@onready var w_6: Node2D = %"6"
@onready var back_to_menu: TextureButton = %"Back to Menu"
@onready var controls_panel: Node2D = %"Controls Panel"
@onready var back_from_controls: TextureButton = %"Back from Controls"

var match_running := false
var winner: Player

var players: Array[Player] = []
var bomb_indicators: Array[AnimatedSprite2D]
var win_indicators: Array[Node2D]

# This function sets up the scene.
func _ready() -> void:
	Transition.scene_in()
	start.grab_focus()
	players.resize(6)
	bomb_indicators = [b_1, b_2, b_3, b_4, b_5, b_6]
	win_indicators = [w_1, w_2, w_3, w_4, w_5, w_6]

# This function updates the timer.
func update_timer(number) -> void:
	timer_text.text = str(number)

# This function gives the bomb randomly to another player.
func random_bomb() -> void:
	if not match_running:
		return
	var living := get_living_players()
	if living.is_empty():
		return
	for i in bomb_indicators.size():
		bomb_indicators[i].visible = false
	for p in living:
		p.IS_TAGGER = false
	var chosen: Player = living.pick_random()
	chosen.IS_TAGGER = true
	var index := players.find(chosen)
	bomb_indicators[index].visible = true
	death_timer.start()
	anims.play("timer")
	anims.seek(0.0, true)

# This function kills a player.
func kill_player(player) -> void:
	if player == null:
		return
	var index := players.find(player)
	if index != -1:
		players[index] = null
	player.queue_free()
	var instance  = EXPLOSION.instantiate()
	match_node.add_child(instance)
	instance.global_position = player.global_position
	instance.emitting = true
	match_node.get_child(1).screen_shake(4, 0.75)
	await get_tree().create_timer(2.0).timeout
	instance.queue_free()

# This function shows the winner.
func show_winner() -> void:
	back_to_menu.visible = true
	back_to_menu.grab_focus()
	bomb_text.visible = false
	timer_text.visible = false
	for s in bomb_indicators:
		s.visible = false
	for s in win_indicators:
		s.visible = false
	death_timer.stop()
	var living := get_living_players()
	if living.is_empty():
		return
	winner = living[0]
	for p in living:
		if not p.IS_TAGGER:
			winner = p
			break
	var index := players.find(winner)
	if index == -1:
		return
	win_indicators[index].visible = true
	winner_pop_up.visible = true

# This function returns a list of players that are currently alive.
func get_living_players() -> Array[Player]:
	var living: Array[Player] = []
	for p in players:
		if p != null:
			living.append(p)
	return living

# This function starts the match and does the countdown.
func start_match() -> void:
	anims.play("countdown")
	await get_tree().create_timer(1.0).timeout
	match_node.get_child(1).screen_shake(1, 0.5)
	await get_tree().create_timer(1.0).timeout
	match_node.get_child(1).screen_shake(1, 0.5)
	await get_tree().create_timer(1.0).timeout
	match_node.get_child(1).screen_shake(1, 0.5)
	for p in get_living_players():
		p.CAN_CONTROL = true
	match_running = true
	bomb_text.visible = true
	timer_text.visible = true
	random_bomb()

# This function instatiates player with data provided.
func instantiate_player(outfit_number, controls_number, spawn_position: Vector2) -> Player:
	var instance  = PLAYER.instantiate()
	instance.OUTFIT = outfit_number
	instance.CONTROLS = controls_number
	match_node.add_child(instance)
	instance.global_position = spawn_position
	instance.tag_changed.connect(_on_player_tag_changed)
	return instance

# This function starts to instatiation process.
func instantiate_match() -> void:
	var amount_of_players := 2
	if point_3.get_child(1).visible: amount_of_players += 1
	if point_4.get_child(1).visible: amount_of_players += 1
	if point_5.get_child(1).visible: amount_of_players += 1
	if point_6.get_child(1).visible: amount_of_players += 1
	matchmaking.visible = false
	match_node.visible = true
	var map_instance = instantiate_map()
	var spawn_container: Node2D = map_instance.get_child(0)
	amount_of_players = min(amount_of_players, spawn_container.get_child_count())
	amount_of_players = min(amount_of_players, players.size())
	var spawn_order := range(spawn_container.get_child_count())
	spawn_order.shuffle()
	for i in amount_of_players:
		var spawn_pos: Vector2 = spawn_container.get_child(spawn_order[i]).global_position
		var player: Player = instantiate_player(i + 1, i + 1, spawn_pos)
		players[i] = player
	var living := get_living_players()
	for i in living:
		for j in living:
			if i == j:
				continue
			i.add_collision_exception_with(j)

# This function instantiaes the map.
func instantiate_map():
	var instance: Node2D = MAP_1.instantiate()
	match_node.add_child(instance)
	return instance

# This function is the termination and deletion of the match.
func match_end() -> void:
	Transition.scene_out()
	await get_tree().create_timer(1.0).timeout
	back_to_menu.visible = false
	for i in range(1, match_node.get_child_count()):
		match_node.get_child(i).queue_free()
	match_node.visible = false
	matchmaking.visible = true
	await get_tree().create_timer(0.5).timeout
	Transition.scene_in()
	start.grab_focus()
	winner = null
	match_running = false
	timer_text.visible = false
	bomb_text.visible = false
	players.fill(null)
	winner_pop_up.visible = false

# This function arranges the UI when a third player is added.
func _on_add_3_pressed() -> void:
	point_3.get_child(0).visible = true
	point_3.get_child(1).visible = true
	point_3.get_child(2).visible = false
	point_3.get_child(3).visible = true
	point_4.get_child(2).visible = true
	point_4.get_child(2).grab_focus()
	start.focus_neighbor_top = point_4.get_child(2).get_path()
	back.focus_neighbor_top = point_4.get_child(2).get_path()
	controls.focus_neighbor_top = point_4.get_child(2).get_path()

# This function arranges the UI when a fourth player is added.
func _on_add_4_pressed() -> void:
	point_4.get_child(0).visible = true
	point_4.get_child(1).visible = true
	point_4.get_child(2).visible = false
	point_4.get_child(3).visible = true
	point_5.get_child(2).visible = true
	point_5.get_child(2).grab_focus()
	point_3.get_child(3).focus_neighbor_right = point_4.get_child(3).get_path()
	start.focus_neighbor_top = point_5.get_child(2).get_path()
	back.focus_neighbor_top = point_5.get_child(2).get_path()
	controls.focus_neighbor_top = point_5.get_child(2).get_path()

# This function arranges the UI when a fifth player is added.
func _on_add_5_pressed() -> void:
	point_5.get_child(0).visible = true
	point_5.get_child(1).visible = true
	point_5.get_child(2).visible = false
	point_5.get_child(3).visible = true
	point_6.get_child(2).visible = true
	point_6.get_child(2).grab_focus()
	start.focus_neighbor_top = point_6.get_child(2).get_path()
	back.focus_neighbor_top = point_6.get_child(2).get_path()
	controls.focus_neighbor_top = point_6.get_child(2).get_path()

# This function arranges the UI when a sixth player is added.
func _on_add_6_pressed() -> void:
	point_6.get_child(0).visible = true
	point_6.get_child(1).visible = true
	point_6.get_child(2).visible = false
	point_6.get_child(3).visible = true
	start.focus_neighbor_top = point_4.get_child(3).get_path()
	back.focus_neighbor_top = point_5.get_child(3).get_path()
	controls.focus_neighbor_top = point_6.get_child(3).get_path()
	point_5.get_child(3).focus_neighbor_right = point_6.get_child(3).get_path()
	point_3.get_child(3).focus_neighbor_bottom = point_6.get_child(3).get_path()
	start.grab_focus()

# This function arranges the UI when the third player is removed.
func _on_remove_3_pressed() -> void:
	if point_4.get_child(0).visible == true:
		anims.play("remove error")
		return
	point_3.get_child(0).visible = false
	point_3.get_child(1).visible = false
	point_3.get_child(2).visible = true
	point_3.get_child(3).visible = false
	point_4.get_child(2).visible = false
	point_3.get_child(2).grab_focus()
	start.focus_neighbor_top = point_3.get_child(2).get_path()
	back.focus_neighbor_top = point_3.get_child(2).get_path()
	controls.focus_neighbor_top = point_3.get_child(2).get_path()
	point_3.get_child(3).focus_neighbor_right = point_4.get_child(2).get_path()

# This function arranges the UI when the fourth player is removed.
func _on_remove_4_pressed() -> void:
	if point_5.get_child(0).visible == true:
		anims.play("remove error")
		return
	point_4.get_child(0).visible = false
	point_4.get_child(1).visible = false
	point_4.get_child(2).visible = true
	point_4.get_child(3).visible = false
	point_5.get_child(2).visible = false
	point_3.get_child(3).grab_focus()
	start.focus_neighbor_top = point_4.get_child(2).get_path()
	back.focus_neighbor_top = point_4.get_child(2).get_path()
	controls.focus_neighbor_top = point_4.get_child(2).get_path()
	point_3.get_child(3).focus_neighbor_right = point_4.get_child(2).get_path()

# This function arranges the UI when the fifth player is removed.
func _on_remove_5_pressed() -> void:
	if point_6.get_child(0).visible == true:
		anims.play("remove error")
		return
	point_5.get_child(0).visible = false
	point_5.get_child(1).visible = false
	point_5.get_child(2).visible = true
	point_5.get_child(3).visible = false
	point_6.get_child(2).visible = false
	point_4.get_child(3).grab_focus()
	start.focus_neighbor_top = point_5.get_child(2).get_path()
	back.focus_neighbor_top = point_5.get_child(2).get_path()
	controls.focus_neighbor_top = point_5.get_child(2).get_path()
	point_4.get_child(3).focus_neighbor_right = point_5.get_child(2).get_path()
	point_3.get_child(3).focus_neighbor_right = point_4.get_child(3).get_path()

# This function arranges the UI when the sixth player is removed.
func _on_remove_6_pressed() -> void:
	point_6.get_child(0).visible = false
	point_6.get_child(1).visible = false
	point_6.get_child(2).visible = true
	point_6.get_child(3).visible = false
	point_5.get_child(3).grab_focus()
	start.focus_neighbor_top = point_6.get_child(2).get_path()
	back.focus_neighbor_top = point_6.get_child(2).get_path()
	controls.focus_neighbor_top = point_6.get_child(2).get_path()
	point_3.get_child(3).focus_neighbor_right = point_4.get_child(3).get_path()
	point_5.get_child(3).focus_neighbor_bottom = point_6.get_child(2).get_path()
	point_3.get_child(3).focus_neighbor_bottom = point_6.get_child(2).get_path()

# This function runs when the bomb emplodes.
func _on_death_timer_timeout() -> void:
	if not match_running:
		return
	var living := get_living_players()
	if living.size() - 1 <= 1:
		for p in living:
			if p.IS_TAGGER:
				kill_player(p)
				break
		await get_tree().process_frame
		show_winner()
		return
	for p in living:
		if p.IS_TAGGER:
			kill_player(p)
			break
	await get_tree().process_frame
	random_bomb()

# This function takes the user back to the Main Menu.
func _on_back_pressed() -> void:
	Transition.scene_out()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/main menu.tscn")

# This function does the match instatiation.
func _on_start_pressed() -> void:
	Transition.scene_out()
	await get_tree().create_timer(1.0).timeout
	instantiate_match()
	await get_tree().create_timer(0.1).timeout
	Transition.scene_in()
	await get_tree().create_timer(1.0).timeout
	start_match()

# this function runs when the back button is pressed after match ends.
func _on_back_to_menu_pressed() -> void:
	match_end()

# This function runs when the bomb is passed to a differenet player.
func _on_player_tag_changed() -> void:
	for i in bomb_indicators.size():
		bomb_indicators[i].visible = players[i] != null and players[i].IS_TAGGER
	match_node.get_child(1).screen_shake(1, 0.25)

func _on_back_from_controls_pressed() -> void:
	anims.play_backwards("controls")
	start.grab_focus()

func _on_controls_pressed() -> void:
	anims.play("controls")
	back_from_controls.grab_focus()
