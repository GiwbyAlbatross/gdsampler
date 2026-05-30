extends Node2D

@export var note_scene: PackedScene
@export var audiostream: AudioStream
@export var base := 60
@export var root := 60

var is_pressed: PackedByteArray = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.open_midi_inputs()
	
	# create notes
	for pitch in range(128):
		is_pressed.append(0)
		var notenode = note_scene.instantiate()
		notenode.note = pitch
		notenode.audiostream = audiostream
		notenode.base = base
		notenode.position.x = pitch * 8
		add_child(notenode)
		notenode.name = str(pitch)

func _input(input: InputEvent):
	if input is InputEventMIDI:
		# do smth
		#print(input)
		if input.message == MIDI_MESSAGE_NOTE_OFF or input.velocity == 0:
			_note_off(input.pitch)
		elif input.message == MIDI_MESSAGE_NOTE_ON:
			_note_on(input.pitch, input.velocity)
		#_print_midi_info(input)

func _print_midi_info(midi_event):
	print(midi_event)
	print("Channel ", midi_event.channel)
	print("Message ", midi_event.message)
	print("Pitch ", midi_event.pitch)
	print("Velocity ", midi_event.velocity)
	print("Instrument ", midi_event.instrument)
	print("Pressure ", midi_event.pressure)
	print("Controller number: ", midi_event.controller_number)
	print("Controller value: ", midi_event.controller_value)

func reevaluate_root():
	for i in range(128):
		if is_pressed.get(i) != 0:
			root = i
			break
	for child in get_children():
		child.setroot(root)

func _note_on(note: int, velocity: int = 127):
	is_pressed.set(note, 1)
	var ch = get_node(str(note))
	if ch == null: return
	ch.emit_signal(&"note_on", velocity)
	reevaluate_root()
func _note_off(note: int):
	is_pressed.set(note, 0)
	var ch = get_node(str(note))
	if ch == null: return
	ch.emit_signal(&"note_off")
	reevaluate_root()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
