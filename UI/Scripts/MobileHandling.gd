extends HBoxContainer

@onready var leftButton: Button = $LeftButton
@onready var rightButton: Button = $RightButton
@onready var leftTimer = $LTimer
@onready var rightTimer = $RTimer

var event = InputEventAction.new()

func _ready() -> void:
	print_debug("ready")
	leftButton.button_down.connect(_on_lb_pressed)
	rightButton.button_down.connect(_on_rb_pressed)
	leftButton.button_up.connect(_on_lb_released)
	rightButton.button_up.connect(_on_lb_released)
	print_debug("connected")


func _process(delta: float) -> void:
	event.pressed = true
	print_debug("process")
	Input.parse_input_event(event)
	print_debug(event.action)
	event.action = ""



func _on_lb_pressed():
	print_debug("lbpress")
	if leftTimer.is_stopped():
		event.action = "MoveLeft"
	else:
		event.action = "Jump"


func _on_lb_released():
	print_debug("lbrelease")
	leftTimer.start()


func _on_rb_pressed():
	print_debug("rbpress")
	if rightTimer.is_stopped():
		event.action = "MoveRight"
	else:
		event.action = "Jump"


func _on_rb_released():
	print_debug("rbrelease")
	rightTimer.start()
