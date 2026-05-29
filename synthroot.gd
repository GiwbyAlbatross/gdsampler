extends Node2D

@export var note_scene: PackedScene
@export var audiostream: AudioStream
@export var base := 60

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.open_midi_inputs()
	
	# create notes
	for pitch in range(128):
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


func _note_on(note: int, velocity: int = 127):
	var ch = get_node(str(note))
	if ch == null: return
	ch.emit_signal(&"note_on", velocity)
func _note_off(note: int):
	var ch = get_node(str(note))
	if ch == null: return
	ch.emit_signal(&"note_off")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
