extends Node

@onready var player1 = $AudioStreamPlayer # First audio player
@onready var player2 = $AudioStreamPlayer2 # Second audio player
var fade_duration = 2.0 # Duration of the crossfade in seconds
var fade_timer = 0.0
var is_crossfading = false
var is_muted = false # Track mute state
var pre_mute_volume1 = -15.0
var pre_mute_volume2 = -15.0
var mute_button = null
var surface = preload("res://music/surface.mp3")
var deep = preload("res://music/deep.mp3")
var bossfight = preload("res://music/bossfight.mp3")
var hotzone = preload("res://music/hotzone.mp3")

var current_track = null
var next_track = null

func _ready():
	mute_button = get_node("/root/Node3D/UI/MuteButton")
	print(mute_button)
	if mute_button:
		mute_button.pressed.connect(_on_mute_button_pressed)
	# Start with surface music
	player1.stream = surface
	player2.stream = deep
	
	# Start playing the first track
	player1.volume_db = -15.0
	player2.volume_db = -15.0
	player1.play()
	current_track = surface

func _process(delta):
	if is_crossfading:
		fade_timer += delta
		var t = fade_timer / fade_duration
		
		# Interpolate volumes (linear decibels)
		player1.volume_db = lerp(-15.0, -80.0, t) # Fade out
		player2.volume_db = lerp(-80.0, -15.0, t) # Fade in
		
		if fade_timer >= fade_duration:
			is_crossfading = false
			player1.stop() # Stop the first track when fully faded out
			# Swap players for next crossfade
			var temp = player1
			player1 = player2
			player2 = temp
			current_track = next_track

func start_crossfade(new_track):
	if new_track == current_track:
		return # Don't crossfade if it's the same track
		
	next_track = new_track
	player2.stream = next_track
	player2.play()
	fade_timer = 0.0
	is_crossfading = true

func play_sound(sound_name: String):
	var sound_to_play
	match sound_name:
		"bossfight":
			sound_to_play = bossfight
		"deep":
			sound_to_play = deep
		"hotzone":
			sound_to_play = hotzone
		"surface":
			sound_to_play = surface
		_:
			print("Unknown sound: ", sound_name)
			return
	
	# Assign the sound and play it
	player1.stream = sound_to_play
	player1.play()


func _on_mute_button_pressed():
	if !is_muted:
		# Store current volumes and mute
		pre_mute_volume1 = player1.volume_db
		pre_mute_volume2 = player2.volume_db
		player1.volume_db = -80.0
		player2.volume_db = -80.0
		if mute_button:
			mute_button.text = "Unmute"
	else:
		# Restore previous volumes
		player1.volume_db = -15 # pre_mute_volume1
		player2.volume_db = -15 # pre_mute_volume2
		if mute_button:
			mute_button.text = "Mute"
	is_muted = !is_muted # Toggle mute state

#	0: Stage.SURFACE,
#	100: Stage.DEEP,
#	200: Stage.DEEPER,
#	300: Stage.SUPERDEEP,
#	400: Stage.HOT,
#	500: Stage.LAVA,
#	600: Stage.VOID
# surface =
# deep 
# bossfight
# hotzone =
func _on_character_body_3d_section_changed(sectionType):
	var track_to_play
	match sectionType:
		GameState.Stage.SURFACE:
			track_to_play = surface
		GameState.Stage.DEEP, GameState.Stage.DEEPER, GameState.Stage.SUPERDEEP:
			track_to_play = deep
		GameState.Stage.HOT, GameState.Stage.LAVA:
			track_to_play = hotzone
		GameState.Stage.VOID:
			track_to_play = bossfight
	
	start_crossfade(track_to_play)
