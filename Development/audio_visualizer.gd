extends Node2D

var spectrum: AudioEffectSpectrumAnalyzerInstance
@export var visualizer_sprites: Array[Node2D]  # Assign sprites in the inspector

# Define frequency ranges for each sprite
var frequency_bands = [
	{"low": 20, "high": 60},     # Sub-bass
	{"low": 60, "high": 250},    # Bass
	{"low": 250, "high": 500},   # Low mids
	{"low": 500, "high": 2000},  # Mids
	{"low": 2000, "high": 4000}, # Upper mids
	{"low": 4000, "high": 6000}, # Presence
	{"low": 6000, "high": 20000} # Brilliance
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	spectrum = AudioServer.get_bus_effect_instance(bus_idx, 0) as AudioEffectSpectrumAnalyzerInstance


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spectrum:
		update_visualizer()
		
func get_amplitude(low_freq: float, high_freq: float) -> float:	
	# Get the average amplitude in the frequency range
	var amplitude = spectrum.get_magnitude_for_frequency_range(low_freq, high_freq)
	
	# Normalize the value (experiment with scaling
	return amplitude.length() * 100.0 # Scale factor
	
func update_visualizer():
	# Adjust scale based on amplitude
	for i in range(visualizer_sprites.size()):
		var band = frequency_bands[i]
		var amplitude = get_amplitude(band.low, band.high)
		
		visualizer_sprites[i].scale = Vector2(1.0, 1.0 + amplitude)
