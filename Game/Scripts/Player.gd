extends CharacterBody2D

signal hit(newHealth:float)

@export var gravityMultiplier : float = 1.2
@export var speed: float = 400
@export var jumpVelocity: float = -800
@export var levelController: LevelController
@export var levelScale: float = 1
@export var minCollisionAngle: float = 45
@export var healthPoints: int = 2 ##defaultHealth

var health: int
var was_on_floor: bool

@onready var collisionArea: Area2D = $CollisionArea
@onready var animationPlayer := $AnimationPlayer

@onready var jumpSound: AudioStreamPlayer = $"/root/Audio/Jump"
@onready var landingSound: AudioStreamPlayer = $"/root/Audio/Landing"
@onready var walkingSound: AudioStreamPlayer = $"/root/Audio/Walking"


func _ready() -> void:
	health = healthPoints
	levelController.restarting.connect(reset_health)

func _process(delta: float) -> void:
	##vertical movement
	if not is_on_floor():
		velocity += gravityMultiplier * delta * levelScale * get_gravity()
	else: 
		if not was_on_floor:
			Audio.play_sound(landingSound)
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Audio.play_sound(jumpSound)
		velocity.y = jumpVelocity * levelScale
		
	##horizontal movement
	var direction := Input.get_axis("MoveLeft", "MoveRight")
	if direction:
		if is_on_floor():
			if !walkingSound.playing:
				Audio.play_sound(walkingSound)
			walkingSound.stream_paused = false
		else: walkingSound.stream_paused = true
		velocity.x = direction * speed * levelScale
	else:
		walkingSound.stream_paused = true
		velocity.x = move_toward(velocity.x, 0, speed)
	
	##animation
	if velocity.y > 0:
		animationPlayer.current_animation = "Jump"
	elif velocity.y < 0: 
		animationPlayer.current_animation = "Fall"
	else:
		if velocity.x == 0:
			animationPlayer.current_animation = "Idle"
		else:
			animationPlayer.current_animation = "Run"

	if velocity.x<0:
		$PlayerSprite.flip_h = true
	elif velocity.x>0:
		$PlayerSprite.flip_h = false

	was_on_floor = is_on_floor()

	move_and_slide()
	
func _physics_process(delta: float) -> void:
	##box collisions
	if collisionArea.has_overlapping_areas():
		var areas = collisionArea.get_overlapping_areas()
		for area in areas:
			if area.get_parent().has_method("push"):
				var collisionVector = Vector2(position-area.get_parent().position)
				var angleToDown = abs(rad_to_deg(collisionVector.angle_to(Vector2.DOWN)))
				## angles to right and left are inverted, since we throw our collision vector FROM area.position -> self.position
				var angleToRightBox = abs(rad_to_deg(collisionVector.angle_to(Vector2.LEFT)))
				var angleToLeftBox = abs(rad_to_deg(collisionVector.angle_to(Vector2.RIGHT)))
				var minimalAngle = min(angleToDown, angleToRightBox, angleToLeftBox)
				if minimalAngle < minCollisionAngle:
					if minimalAngle == angleToDown:
						if minimalAngle < minCollisionAngle * 0.8:
							if area.get_parent().has_method("destroy"):
								add_collision_exception_with(area.get_parent())
								area.get_parent().destroy()
							on_hit()
					elif minimalAngle == angleToLeftBox:
						area.get_parent().push(-1) ##we write side here, remember?
					elif minimalAngle == angleToRightBox:
						area.get_parent().push(1)


func reset_health():
	health = healthPoints


func on_hit() -> void:
	health-=1
	hit.emit(health)
	if health<=0:
		levelController.lose()
