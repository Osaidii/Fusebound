class_name Player
extends CharacterBody2D

@export_category("Instance")
@export var CONTROLS := 1
@export var OUTFIT := 1
@export_category("Stats")
@export var NORMAL_SPEED := 110
@export var TAGGER_SPEED := 140
@export var JUMP_VELOCITY := -240.0
@export_category("Data")
@export var CAN_CONTROL := false
@export var IS_TAGGER := false

@onready var bomb: Sprite2D = %Bomb
@onready var outfit_1: AnimatedSprite2D = %"Outfit 1"
@onready var outfit_2: AnimatedSprite2D = %"Outfit 2"
@onready var outfit_3: AnimatedSprite2D = %"Outfit 3"
@onready var outfit_4: AnimatedSprite2D = %"Outfit 4"
@onready var outfit_5: AnimatedSprite2D = %"Outfit 5"
@onready var outfit_6: AnimatedSprite2D = %"Outfit 6"
@onready var coyote_timer: Timer = %"Coyote Timer"
@onready var jump_buffer_timer: Timer = %"Jump Buffer timer"
@onready var hitbox_cooldown_timer: Timer = %"Hitbox Cooldown Timer"

var outfits := [6]
var animation: AnimatedSprite2D
var direction := 0.0
var coyote_time_activated := false
var hitbox_on_cooldown := false
var facing_right := true

# This function sets the player up.
func _ready() -> void:
	outfits = [outfit_1, outfit_2, outfit_3, outfit_4, outfit_5, outfit_6]
	for i in outfits:
		i.visible = false
	outfits[OUTFIT - 1].visible = true
	animation = outfits[OUTFIT - 1]

# This function contains all the player logic.
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Coyote time
	if is_on_floor():
		if coyote_time_activated:
			coyote_time_activated = false
			coyote_timer.stop()
	else:
		if !coyote_time_activated:
			coyote_timer.start()
			coyote_time_activated = true
	
	# Jump with Buffer
	if ((Input.is_action_just_pressed("up1") and CONTROLS == 1) or (Input.is_action_just_pressed("up2") and CONTROLS == 2) or (Input.is_action_just_pressed("up3") and CONTROLS == 3) or (Input.is_action_just_pressed("up4") and CONTROLS == 4) or (Input.is_action_just_pressed("up5") and CONTROLS == 5) or (Input.is_action_just_pressed("up6") and CONTROLS == 6)) and (!coyote_timer.is_stopped() or is_on_floor()):
		jump_buffer_timer.start()
	if is_on_floor() and !jump_buffer_timer.is_stopped():
		jump()
	elif velocity.y < 0.0:
		if CONTROLS == 1 and Input.is_action_just_released("up1"):
			velocity.y *= 0.5
		elif CONTROLS == 2 and Input.is_action_just_released("up2"):
			velocity.y *= 0.5
		elif CONTROLS == 3 and Input.is_action_just_released("up3"):
			velocity.y *= 0.5
		elif CONTROLS == 4 and Input.is_action_just_released("up4"):
			velocity.y *= 0.5
		elif CONTROLS == 5 and  Input.is_action_just_released("up5"):
			velocity.y *= 0.5
		elif CONTROLS == 6 and Input.is_action_just_released("up6"):
			velocity.y *= 0.5
	
	# Tagger Logic
	if IS_TAGGER:
		bomb.visible = true
	else:
		bomb.visible = false
	
	# Movement
	if CAN_CONTROL:
		if CONTROLS == 1:
			direction = Input.get_axis("left1", "right1")
		elif CONTROLS == 2:
			direction = Input.get_axis("left2", "right2")
		elif CONTROLS == 3:
			direction = Input.get_axis("left3", "right3")
		elif CONTROLS == 4:
			direction = Input.get_axis("left4", "right4")
		elif CONTROLS == 5:
			direction = Input.get_axis("left5", "right5")
		elif CONTROLS == 6:
			direction = Input.get_axis("left6", "right6")
		if direction:
			if IS_TAGGER:
				velocity.x = direction * TAGGER_SPEED
			elif !IS_TAGGER:
				velocity.x = direction * NORMAL_SPEED 
		else:
			velocity.x = move_toward(velocity.x, 0, 1200 * delta)
	move_and_slide()
	
	# Turn
	_face_direction()
	
	# Play animations
	_anims()

# This function makes the player jump.
func jump() -> void:
	if !CAN_CONTROL:
		return
	velocity.y = JUMP_VELOCITY
	coyote_timer.stop()
	coyote_time_activated = true

# This function flips sprite based on direction.
func _face_direction() -> void:
	if direction > 0 and !facing_right:
		animation.flip_h = false
		bomb.position.x = -6
		bomb.flip_h = false
		facing_right = true
	elif direction < 0 and facing_right:
		animation.flip_h = true
		bomb.position.x = 6
		bomb.flip_h = true
		facing_right = false

# This function plays all the animations.
func _anims() -> void:
	if !is_on_floor():
		animation.play("jump")
	elif velocity.x != 0:
		animation.play("run")
	else:
		animation.play("idle")

# This function checks whether another Player is Overlapping with this one.
func _on_hitbox_checker_body_entered(body: Node2D) -> void:
	print("smth entered")
	if body is Player:
		print("is player")
		if hitbox_on_cooldown:
			return
		hitbox_on_cooldown = true
		hitbox_cooldown_timer.start()
		if not self.IS_TAGGER and body.IS_TAGGER:
			IS_TAGGER = true
			body.IS_TAGGER = false
		elif self.IS_TAGGER and not body.IS_TAGGER:
			IS_TAGGER = false 
			body.IS_TAGGER = true

# This resets the collision after its once activated.
func _on_hitbox_cooldown_timer_timeout() -> void:
	hitbox_on_cooldown = false
