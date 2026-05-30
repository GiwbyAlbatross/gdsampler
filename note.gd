extends Node2D

const _log12base = log(12)

@export var note: int # what note this is, in MIDI
@export var audiostream: AudioStream # the sample
@export var base := 60 # what note the sample is, in MIDI
@export var release := 0.22
@export var root := 60 # the root of the chord, or my code's best guess for it at least.
@export var intevalcolours: PackedColorArray

@onready var asp: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var part: GPUParticles2D = $GPUParticles2D
@onready var light: PointLight2D = $PointLight2D

#@export var velocity: int = 0
var velocity := 0
var active := false

signal note_on(velocity: int)
signal note_off()

func log12(x: float) -> float:
	return log(x) * _log12base

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	part.emitting = false
	light.enabled = false
	asp.stream = audiostream
	asp.pitch_scale = pow(2.0, (note - base) / 12.0)
	connect(&"note_off", _note_off)
	connect(&"note_on",  _note_on)
	#print(asp.volume_linear)

func _note_on(_velocity: int):
	#print("note on")
	velocity = _velocity
	active = true
	asp.volume_linear = pow(_velocity / 128.0, 1.21)
	part.lifetime = 100.0 / _velocity
	asp.playing = true
	part.emitting = true
	light.enabled = true
	
func _note_off():
	#3print("note off")
	active = false
	#asp.playing = false
	part.emitting = false
	light.enabled = false

func setroot(pitch: int):
	light.color = intevalcolours[(note - pitch) % 12]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		asp.volume_linear *= clamp(1.0 - delta / release, 0.0, 1.0)
