@tool
@icon("res://addons/TweenAnimator/icon.png")
## Call TweenAnimator.<animation>(node, optional param).
## For the Looping Tweens, call it a first time to toggle on and a second time to toggle off.
##
## The TweenAnimator class provides an easy-to-use set of static methods for animating Node CanvasItem and Labels properties in Godot.
## It includes various animation effects like fade, scale, shake, and more. 
## It can be used in both editor plugins and runtime code. 
## The class is designed to facilitate quick visual effects without needing to manually manage tweening logic and to be usable anywhere in a project.

class_name TweenAnimator extends EditorPlugin

# Global state dictionary to track node animations
static var node_tweens: Dictionary = {}

#region Animations Enum and animations_names Dictionnary
enum Animations {
	POP_IN,           PUNCH_IN,         PUNCH_OUT,        FADE_IN,        FADE_OUT,
	DROP_IN,          JUMP_SCARE,      
	SPIN,             SKEW,             WARP,             VANISH,         SHAKE,
	PULSATE,          JITTER,           WIGGLE_SCALE,     FLIP,           HOP,
	BLINK,            SQUASH,           STRETCH,          SNAP,           TYPEWRITER,
	COLOR_CYCLE,      HEARTBEAT,        SWING,            CHARGE_UP,      RICHOCHET,
	GLITCH,           SPOTLIGHT,        WAVE_DISTORT,     WIGGLE,         FLOAT_BOB,
	GLOW_PULSE,       TWIST,            SPOTLIGHT_ON,     SPOTLIGHT_OFF,  DISAPPEAR,
	ROTATE_HOP,       EXPLODE,          BLACK_HOLE,       
	MELT,             TV_SHUTDOWN,      HELICOPTER_CRAZY, CHAOS_SPIN_BOUNCE,
	IDLE_RUBBER,      BUBBLE_ASCEND,    CREEP_OUT
}

static var animation_names := {
	Animations.POP_IN: "pop_in",
	Animations.PUNCH_IN: "punch_in",
	Animations.PUNCH_OUT: "punch_out",
	Animations.FADE_IN: "fade_in",
	Animations.FADE_OUT: "fade_out",
	Animations.DROP_IN: "drop_in",
	Animations.JUMP_SCARE: "jump_scare",
	Animations.SPIN: "spin",
	Animations.SKEW: "skew",
	Animations.WARP: "warp",
	Animations.VANISH: "vanish",
	Animations.SHAKE: "shake",
	Animations.PULSATE: "pulsate",
	Animations.JITTER: "jitter",
	Animations.WIGGLE_SCALE: "wiggle_scale",
	Animations.FLIP: "flip",
	Animations.HOP: "hop",
	Animations.BLINK: "blink",
	Animations.SQUASH: "squash",
	Animations.STRETCH: "stretch",
	Animations.SNAP: "snap",
	Animations.TYPEWRITER: "typewriter",
	Animations.COLOR_CYCLE: "color_cycle",
	Animations.HEARTBEAT: "heartbeat",
	Animations.SWING: "swing",
	Animations.CHARGE_UP: "charge_up",
	Animations.RICHOCHET: "ricochet",
	Animations.GLITCH: "glitch",
	Animations.SPOTLIGHT: "spotlight",
	Animations.SPOTLIGHT_ON : "spotlight_on",
	Animations.SPOTLIGHT_OFF : "spotlight_off",
	Animations.WAVE_DISTORT: "wave_distort",
	Animations.WIGGLE: "wiggle",
	Animations.FLOAT_BOB: "float_bob",
	Animations.GLOW_PULSE: "glow_pulse",
	Animations.TWIST: "twist",
	Animations.DISAPPEAR : "disappear",
	Animations.ROTATE_HOP : "rotate_hop",
	Animations.EXPLODE : "explode",
	Animations.BLACK_HOLE : "black_hole",
	Animations.MELT: "melt",
	Animations.TV_SHUTDOWN: "tv_shutdown",
	Animations.HELICOPTER_CRAZY: "helicopter_crazy",
	Animations.CHAOS_SPIN_BOUNCE: "chaos_spin_bounce",
	Animations.IDLE_RUBBER: "idle_rubber",
	Animations.BUBBLE_ASCEND: "bubble_ascend",
	Animations.CREEP_OUT: "creep_out"
}
#endregion

#region Looping

## Goes through the colors.
static func color_cycle(node: CanvasItem, duration: float = 3.0) -> void:
	if _has_active_animation(node, "color_cycle"):
		_stop_animation(node, "color_cycle")
		node.modulate = Color.WHITE
		return
	
	var original_color = node.modulate
	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node]["original_color"] = original_color
	
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Cycle through hue values (keeping saturation and value consistent)
	var colors = [
		Color.from_hsv(0.0, 1.0, 1.0),  # Red
		Color.from_hsv(0.17, 1.0, 1.0), # Orange
		Color.from_hsv(0.33, 1.0, 1.0), # Yellow
		Color.from_hsv(0.5, 1.0, 1.0),  # Green
		Color.from_hsv(0.67, 1.0, 1.0), # Blue
		Color.from_hsv(0.83, 1.0, 1.0), # Purple
		Color.from_hsv(1.0, 1.0, 1.0)   # Back to Red
	]
	
	# Tween through each color
	for color in colors:
		tween.tween_property(node, "modulate", color, duration / colors.size())
	
	_store_animation(node, "color_cycle", tween)

## Simulates a heartbeat with two rhythmic pulses.
static func heartbeat(node: Node2D, strength: float = 0.2, interval: float = 1.0) -> void:
	if _has_active_animation(node, "heartbeat"):
		_stop_animation(node, "heartbeat")
		node.scale = Vector2.ONE
		return
	
	var original_scale = node.scale
	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node]["original_scale"] = original_scale
	
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	
	#// First beat (larger)
	tween.tween_property(node, "scale", original_scale * (1 + strength), 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
	#// Short pause
	tween.tween_property(node, "scale", original_scale, 0.1)
	
	#// Second beat (smaller)
	tween.tween_property(node, "scale", original_scale * (1 + strength * 0.6), 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, 0.1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		
	#// Rest period
	tween.tween_property(node, "scale", original_scale, interval - 0.6)
	
	_store_animation(node, "heartbeat", tween)

## Rotates the node back and forth like a pendulum.
static func swing(node: Node, angle: float = 30.0, duration: float = 1.0) -> void:
	if _has_active_animation(node, "swing"):
		_stop_animation(node, "swing")
		node.rotation_degrees = 0
		return
	
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(node, "rotation_degrees", angle, duration * 0.5)
	tween.tween_property(node, "rotation_degrees", -angle, duration)
	tween.tween_property(node, "rotation_degrees", 0, duration * 0.5)
	
	_store_animation(node, "swing", tween)

## Applies a wave-like distortion effect to the node.
static func wave_distort(node: CanvasItem, duration: float = 1.0, amplitude: float = 0.1) -> void:
	if _has_active_animation(node, "wave_distort"):
		_stop_animation(node, "wave_distort")
		node.scale = Vector2.ONE
		node.skew = 0
		return
	
	var original_scale = node.scale
	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node]["original_scale"] = original_scale
	
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Create wave effect by oscillating X and Y scale slightly out of phase
	tween.tween_property(node, "scale:x", original_scale.x * (1 + amplitude), duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * (1 - amplitude/2), duration * 0.25)
	tween.parallel().tween_property(node, "skew", amplitude/2, duration * 0.25)
	
	tween.tween_property(node, "scale:x", original_scale.x * (1 - amplitude/2), duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * (1 + amplitude), duration * 0.25)
	tween.parallel().tween_property(node, "skew", -amplitude/2, duration * 0.25)
	
	tween.tween_property(node, "scale:x", original_scale.x * (1 - amplitude), duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * (1 - amplitude/2), duration * 0.25)
	tween.parallel().tween_property(node, "skew", amplitude/2, duration * 0.25)
	
	tween.tween_property(node, "scale:x", original_scale.x, duration * 0.25)
	tween.parallel().tween_property(node, "scale:y", original_scale.y, duration * 0.25)
	tween.parallel().tween_property(node, "skew", 0.0, duration * 0.25)
	
	_store_animation(node, "wave_distort", tween)

## Slightly rotates the node back and forth.
static func wiggle(node: Node) -> void:
	if _has_active_animation(node, "wiggle"):
		_stop_animation(node, "wiggle")
		node.rotation_degrees = 0
		return
	
	var wiggle_tween: Tween = node.get_tree().create_tween()
	wiggle_tween.set_loops()
	wiggle_tween.tween_property(node, "rotation_degrees", 5.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wiggle_tween.tween_property(node, "rotation_degrees", -5.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wiggle_tween.tween_property(node, "rotation_degrees", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_store_animation(node, "wiggle", wiggle_tween)

## Makes the node float up and down in a looping motion.
static func float_bob(node: Node2D, height := 5.0, speed := 1.0) -> void:
	if _has_active_animation(node, "bobbing"):
		_stop_animation(node, "bobbing")
		return
	
	var original_pos := node.position
	var bob_tween: Tween = node.get_tree().create_tween()
	bob_tween.set_loops()
	bob_tween.tween_property(node, "position:y", original_pos.y - height, speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bob_tween.tween_property(node, "position:y", original_pos.y + height, speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_store_animation(node, "bobbing", bob_tween)
	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node]["original_pos"] = original_pos

## Gently pulses the node's scale and opacity in a loop.
static func glow_pulse(node: CanvasItem, scale_amt: float = 0.05, alpha_amt: float = 0.3, duration: float = 0.6) -> void:
	if _has_active_animation(node, "glow_pulse"):
		_stop_animation(node, "glow_pulse")
		node.scale = Vector2(1, 1)
		node.modulate.a = 1.0
		return

	var tween := node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "scale", Vector2(1 + scale_amt, 1 + scale_amt), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(node, "modulate:a", 1.0 - alpha_amt, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", Vector2(1, 1), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(node, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_store_animation(node, "glow_pulse", tween)

## Rotates a bit while doing a mini-hop, good for idle feedback.
static func rotate_hop(node: Node2D, angle: float = 15.0, height: float = 10.0, duration: float = 0.4) -> void:
	if _has_active_animation(node, "rotate_hop"):
		_stop_animation(node, "rotate_hop")
		node.rotation_degrees = 0
		return
	var start_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(node, "rotation_degrees", angle, duration * 0.25)
	tween.parallel().tween_property(node, "position:y", start_pos.y - height, duration * 0.25)
	tween.tween_property(node, "rotation_degrees", -angle, duration * 0.25)
	tween.parallel().tween_property(node, "position:y", start_pos.y + height, duration * 0.25)
	tween.tween_property(node, "rotation_degrees", 0, duration * 0.25)
	tween.parallel().tween_property(node, "position:y", start_pos.y, duration * 0.25)
	_store_animation(node, "rotate_hop", tween)

## Pure entropy : Spin, Random Jitter, Squash-Strech Bounce
static func chaos_spin_bounce(node: Node2D, bounce_scale: float = 0.2, spin_speed: float = 180.0, duration: float = 0.6) -> void:
	if _has_active_animation(node, "chaos_spin_bounce"):
		_stop_animation(node, "chaos_spin_bounce")
		node.rotation_degrees = 0
		node.scale = Vector2.ONE
		return

	if not node_tweens.has(node):
		node_tweens[node] = {}

	node_tweens[node]["original_scale"] = node.scale
	var original_scale = node.scale

	var tween = node.get_tree().create_tween()
	tween.set_loops()

	tween.parallel().tween_property(node, "rotation_degrees", node.rotation_degrees + spin_speed, duration).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(node, "scale", original_scale * Vector2(1.0 + randf_range(-bounce_scale, bounce_scale), 1.0 + randf_range(-bounce_scale, bounce_scale)), duration * 0.5)
	tween.tween_property(node, "scale", original_scale, duration * 0.5)

	_store_animation(node, "chaos_spin_bounce", tween)

## Makes object look like they're trying to fly off in a panic.
static func helicopter_crazy(node: Node2D, spin_speed: float = 1080.0, bob_height: float = 5.0, duration: float = 0.6) -> void:
	if _has_active_animation(node, "helicopter_crazy"):
		_stop_animation(node, "helicopter_crazy")
		node.position = node_tweens[node]["original_pos"]
		return

	if not node_tweens.has(node):
		node_tweens[node] = {}

	node_tweens[node]["original_pos"] = node.position
	var original_pos = node.position

	var tween = node.get_tree().create_tween()
	tween.set_loops()

	tween.parallel().tween_property(node, "rotation_degrees", node.rotation_degrees + spin_speed, duration).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(node, "position:y", original_pos.y - bob_height, duration * 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", original_pos.y + bob_height, duration * 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.3).set_trans(Tween.TRANS_SINE)

	_store_animation(node, "helicopter_crazy", tween)

## Makes objects drip down slowly and squash — like they're melting.
static func melt(node: Node2D, melt_distance: float = 20.0, duration: float = 2.0) -> void:
	if _has_active_animation(node, "melt"):
		_stop_animation(node, "melt")
		node.position = node_tweens[node]["original_pos"]
		node.scale = node_tweens[node]["original_scale"]
		return

	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node]["original_pos"] = node.position
	node_tweens[node]["original_scale"] = node.scale

	var original_pos = node.position
	var original_scale = node.scale

	var tween = node.get_tree().create_tween()
	tween.set_loops()

	tween.parallel().tween_property(node, "position:y", original_pos.y + melt_distance, duration * 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(node, "scale:y", original_scale.y * 1.3, duration * 0.5)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.5)
	tween.tween_property(node, "scale:y", original_scale.y, duration * 0.5)

	_store_animation(node, "melt", tween)

## Gives the object rubbery springy movement
static func idle_rubber(node: Node2D, strength: float = 0.1, duration: float = 0.6) -> void:
	if _has_active_animation(node, "rubber_frog"):
		_stop_animation(node, "rubber_frog")
		node.scale = Vector2.ONE
		node.position = node_tweens[node]["original_pos"]
		return

	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node]["original_pos"] = node.position

	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	tween.set_loops()

	tween.tween_property(node, "position:x", original_pos.x + 6, duration * 0.3)
	tween.parallel().tween_property(node, "scale", Vector2(1.1, 0.9), duration * 0.3)
	tween.tween_property(node, "position:x", original_pos.x - 6, duration * 0.3)
	tween.parallel().tween_property(node, "scale", Vector2(0.9, 1.1), duration * 0.3)
	tween.tween_property(node, "position:x", original_pos.x, duration * 0.3)
	tween.parallel().tween_property(node, "scale", Vector2.ONE, duration * 0.3)

	_store_animation(node, "rubber_frog", tween)

## Floats with a bit of distortion.
static func bubble_ascend(node: Node2D, height: float = 15.0, duration: float = 2.0) -> void:
	if _has_active_animation(node, "bubble_ascend"):
		_stop_animation(node, "bubble_ascend")
		node.position = node_tweens[node]["original_pos"]
		node.scale = Vector2.ONE
		return

	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node]["original_pos"] = node.position

	var original_pos = node.position

	var tween = node.get_tree().create_tween()
	tween.set_loops()

	tween.tween_property(node, "position:y", original_pos.y - height, duration * 0.6).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "scale:y", 0.95, duration * 0.3)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.4).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(node, "scale", Vector2.ONE, duration * 0.2)

	_store_animation(node, "bubble_ascend", tween)

#endregion

#region One-Shot Effects

## Object gets back in the dark where it belongs. Optionally resets after (mainly for test purpose).
static func creep_out(node: Node2D, duration: float = 1.0, restore_after_creep_out : bool = false) -> void:
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()

	tween.tween_property(node, "modulate", Color(0.2, 0.2, 0.2, 1), duration * 0.5)
	tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.5)
	tween.tween_property(node, "modulate:a", 0.0, duration * 0.3)

	if restore_after_creep_out :
		await tween.finished
		fade_in(node)

## Makes object look like they're being shutdown like a cartoon TV. Optionally resets after (mainly for test purpose).
static func tv_shutdown(node: Node2D, duration: float = 0.5, restore_after_tv_shutdown : bool = false) -> void:
	var original_scale = node.scale
	var tween = node.get_tree().create_tween()

	tween.tween_property(node, "scale", original_scale * Vector2(1.3, 0.7), duration * 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", original_scale * Vector2(0.7, 1.3), duration * 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", Vector2.ZERO, duration * 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	if restore_after_tv_shutdown :
		await tween.finished
		fade_in(node)
		node.scale = Vector2.ONE

## Spins and disappears.
static func black_hole(node: Node2D, duration: float = 0.8, restore_after_black_hole : bool = false) -> void:
	var tween = node.get_tree().create_tween()
	tween.parallel().tween_property(node, "scale", Vector2.ZERO, duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(node, "rotation_degrees", node.rotation_degrees + 720, duration)

	if restore_after_black_hole :
		await tween.finished
		node.rotation_degrees = 0
		pop_in(node)

## Boom! Optionally resets after (mainly for test purpose).
static func explode(node: Node2D, scale_amt: float = 1.8, duration: float = 0.4, restore_after_explode : bool = false) -> void:
	var tween := node.get_tree().create_tween()

	# Step 1: Pop outward quickly
	tween.tween_property(node, "scale", Vector2.ONE * scale_amt, duration * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Step 2: Add a slight rotation & wobble back
	tween.parallel().tween_property(node, "rotation_degrees", randf_range(-10, 10), duration * 0.2)
	tween.tween_property(node, "scale", Vector2.ONE * 0.5, duration * 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

	# Step 3: Fade out clean
	tween.parallel().tween_property(node, "modulate:a", 0.0, duration * 0.4).set_trans(Tween.TRANS_LINEAR)

	if restore_after_explode :
		await tween.finished
		node.rotation_degrees = 0
		pop_in(node)

## Makes the node shrink. Optionally resets after (mainly for test purpose).
static func disappear(node: Node2D, duration: float = 0.3, restore_after_disappear : bool = false) -> void:
	var tween = node.get_tree().create_tween()
	
	tween.tween_property(node, "scale", Vector2(0, 0), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(node, "modulate:a", 0.0, duration)
	
	if restore_after_disappear :
		await tween.finished
		pop_in(node)

## Reveals the label's text one character at a time.
static func typewriter(label: Control, speed: float = 0.05) -> void:
	var original_text = label.text
	label.visible_characters = 0
	
	var tween := label.get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	
	# Store original text for reference
	if not node_tweens.has(label):
		node_tweens[label] = {}
	node_tweens[label]["original_text"] = original_text
	
	# Tween visible characters count
	tween.tween_property(label, "visible_characters", original_text.length(), original_text.length() * speed)
	
	_store_animation(label, "typewriter", tween)

## Builds up energy visually before a release or action.
static func charge_up(node: CanvasItem, duration: float = 1.0) -> void:
	var original_scale = node.scale
	var original_color = node.modulate
	
	var tween = node.get_tree().create_tween()
	
	# Phase 1: Building energy
	tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(node, "modulate", Color(1.5, 1.5, 0.5, 1.0), duration * 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Phase 2: Small pulses while charging
	for i in range(3):
		var pulse_scale = 0.05 * (i + 1)
		tween.tween_property(node, "scale", original_scale * (0.8 + pulse_scale), duration * 0.1)
		tween.tween_property(node, "scale", original_scale * 0.8, duration * 0.1)
	
	# Phase 3: Release energy
	tween.tween_property(node, "scale", original_scale * 1.5, duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", Color(2.0, 2.0, 1.0, 1.0), duration * 0.2)
	
	# Phase 4: Return to normal
	tween.tween_property(node, "scale", original_scale, duration * 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate", original_color, duration * 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## Makes the node shrinks a bit and shake like it took a punch.
static func punch_out(node: CanvasItem, duration: float = 0.5, min_scale : float = 0.5) -> void:
	var original_scale = node.scale
	var original_pos = node.position
	
	# Get the parent to create a temporary viewport container
	var parent = node.get_parent()
	var original_index = node.get_index()
	
	# Store original texture (requires node to have a texture property like Sprite2D)
	var original_texture = null
	if node is Sprite2D:
		original_texture = node.texture
	
	var tween = node.get_tree().create_tween()
	
	# Approach 1: Quick scale down and up for a "pixelated" look
	# Scale down rapidly (makes it look pixelated when stretched back)
	tween.tween_property(node, "scale", original_scale * min_scale, duration * 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
	# Quick wobble while small (enhances the effect)
	for i in range(3):
		var jitter = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 5.0
		tween.tween_property(node, "position", original_pos + jitter, duration * 0.1)
		
	# Scale back up, slower
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "position", original_pos, duration * 0.1)

## Makes the node bounce around as if hitting walls.
static func ricochet(node: Node2D, strength: float = 30.0, bounces: int = 4, duration: float = 0.8) -> void:
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	
	# Generate random bounce directions
	for i in range(bounces):
		var random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var target_pos = original_pos + random_dir * strength
		
		# Bounce with diminishing strength
		var bounce_strength = strength * (1.0 - (i / float(bounces)))
		var bounce_time = duration / bounces
		
		tween.tween_property(node, "position", target_pos, bounce_time * 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Return to original position
	tween.tween_property(node, "position", original_pos, duration * 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## Simulates a digital glitch with color and position jitter.
static func glitch(node: CanvasItem, duration: float = 1.0, intensity: float = 10.0) -> void:
	var original_pos = node.position
	var original_color = node.modulate
	var tween = node.get_tree().create_tween()
	
	# Number of glitch frames
	var glitch_frames = 12
	
	for i in range(glitch_frames):
		# Random position offset
		var offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * intensity
		
		# Random color shift (RGB channel separation)
		var color_shift = Color(
			randf_range(0.8, 1.2),  # R
			randf_range(0.8, 1.2),  # G
			randf_range(0.8, 1.2),  # B
			1.0                     # A
		)
		
		# Tween to glitch position and color
		var glitch_time = duration / glitch_frames * 0.5
		tween.tween_property(node, "position", original_pos + offset, glitch_time)
		tween.parallel().tween_property(node, "modulate", color_shift, glitch_time)
		
		# Return to normal briefly
		tween.tween_property(node, "position", original_pos, glitch_time)
		tween.parallel().tween_property(node, "modulate", original_color, glitch_time)
	
	# Ensure we end in the original state
	tween.tween_property(node, "position", original_pos, 0.1)
	tween.parallel().tween_property(node, "modulate", original_color, 0.1)

## A fast zoom and shake effect for a startling impact.
static func jump_scare(node: Node2D, intensity: float = 1.3, duration: float = 0.4) -> void:
	var original_scale = node.scale
	var original_pos = node.position
	var tween = node.get_tree().create_tween()
	
	# Quick zoom in
	tween.tween_property(node, "scale", original_scale * intensity, duration * 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Violent shake
	for i in range(6):
		var shake_offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 10.0
		tween.parallel().tween_property(node, "position", original_pos + shake_offset, duration * 0.05)
		tween.tween_property(node, "position", original_pos, duration * 0.05)
	
	# Return to normal
	tween.parallel().tween_property(node, "scale", original_scale, duration * 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

## Activates the glowing spotlight effect
static func spotlight_on(node: CanvasItem, duration: float = 1.0) -> void:
	spotlight(node, duration, "on")

## Turns off the glowing spotlight effect.
static func spotlight_off(node: CanvasItem, duration: float = 1.0) -> void:
	spotlight(node, duration, "off")

## Highlights the node with a glowing effect, toggleable.
static func spotlight(node: CanvasItem, duration: float = 1.0, state : String = "on_off") -> void:
	var original_color = node.modulate
	var tween = node.get_tree().create_tween()
	
	# Create glow effect with color and intensity
	var glow_color = Color(1.5, 1.5, 1.5, 1.0)  # Bright white glow
	
	if state == "on_off" :
		# Build up the glow
		tween.tween_property(node, "modulate", glow_color, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
		# Hold the glow
		tween.tween_property(node, "modulate", glow_color, duration * 0.4)
		
		# Fade back to normal
		tween.tween_property(node, "modulate", original_color, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	elif state == "off" :
	# Fade back to normal
		tween.tween_property(node, "modulate", Color.WHITE, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	elif state == "on" :
		# Build up the glow
		tween.tween_property(node, "modulate", glow_color, duration * 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
		# Hold the glow
		tween.tween_property(node, "modulate", glow_color, duration * 0.4)

## Flips the node horizontally with a quick rotation.
static func flip(node: Node2D, duration: float = 0.4) -> void:
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale:x", -1.0, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale:x", 1.0, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Makes the node hop upward and land back down.
static func hop(node: Node2D, height: float = 20.0, duration: float = 0.4) -> void:
	var original_pos := node.position
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "position:y", original_pos.y - height, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position:y", original_pos.y, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

## Makes the node rapidly appear and disappear a few times.
static func blink(node: CanvasItem, duration: float = 0.1, times: int = 3) -> void:
	var tween := node.get_tree().create_tween()
	for i in range(times):
		tween.tween_property(node, "modulate:a", 0.0, duration)
		tween.tween_property(node, "modulate:a", 1.0, duration)

## Flattens the node vertically, then returns it to normal.
static func squash(node: Node2D, amount: float = 0.3, duration: float = 0.2) -> void:
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1 + amount, 1 - amount), duration * 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", Vector2(1, 1), duration * 0.5).set_trans(Tween.TRANS_SINE)

## Stretches the node vertically and then returns to original scale.
static func stretch(node: Node2D, amount: float = 0.3, duration: float = 0.2) -> void:
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1 - amount, 1 + amount), duration * 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", Vector2(1, 1), duration * 0.5).set_trans(Tween.TRANS_SINE)

## Scales the node up quickly, then resets it.
static func snap(node: Node2D, scale_amount: float = 1.3, duration: float = 0.1) -> void:
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(scale_amount, scale_amount), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1, 1), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

## Quickly toggles visibility to create a flashing effect.
static func flash(node: CanvasItem, flashes: int = 3, duration: float = 0.1) -> void:
	var tween := node.get_tree().create_tween()
	for i in range(flashes):
		tween.tween_property(node, "modulate", Color(1, 1, 1, 0), duration)
		tween.tween_property(node, "modulate", Color(1, 1, 1, 1), duration)

## Gradually increases the node's visibility from transparent to opaque.
static func fade_in(node: CanvasItem, duration: float = 0.5) -> void:
	node.modulate.a = 0.0
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

## Gradually fades the node out until it's fully transparent.
static func fade_out(node: CanvasItem, duration: float = 0.5) -> void:
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

## Twists the node in place with a quick rotation.
static func twist(node: Node2D, angle: float = 30.0, duration: float = 0.4) -> void:
	var start := node.rotation_degrees
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "rotation_degrees", start + angle, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "rotation_degrees", start, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

## Expands and contracts the node once with a pulse.
static func pulsate(node: Node2D, scale_factor: float = 1.2, duration: float = 0.5) -> void:
	var original_scale = node.scale
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * scale_factor, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Shakes the node slightly and rapidly for a jitter effect.
static func jitter(node: Node2D, amount: float = 3.0, duration: float = 0.1, times: int = 10) -> void:
	var original_position = node.position
	var tween := node.get_tree().create_tween()
	for i in range(times):
		var offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		tween.tween_property(node, "position", original_position + offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(node, "position", original_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Scales the node irregularly to create a wiggling effect.
static func wiggle_scale(node: Node2D, amount: float = 0.1, duration: float = 0.5) -> void:
	var original_scale = node.scale
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", original_scale * Vector2(1 + amount, 1 - amount), duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", original_scale, duration * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Rotates the node around its center one or more times.
static func spin(node: Node2D, revolutions: float = 1.0, duration: float = 0.5) -> void:
	var start_rotation = node.rotation_degrees
	var end_rotation = start_rotation + 360.0 * revolutions
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "rotation_degrees", end_rotation, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

## Quickly scales in the node from zero to full size, like it just appears.
static func pop_in(node: CanvasItem) -> void:
	node.scale = Vector2(0.0, 0.0)
	node.modulate.a = 0.0
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(node, "modulate:a", 1.0, 0.2)

## Skews the node along X and Y axes temporarily.
static func skew(node: Node2D, skew_x: float = 0.5, skew_y: float = 0.5, duration: float = 0.3) -> void:
	var tween := node.get_tree().create_tween()
	var target_scale := Vector2(1 + skew_x, 1 + skew_y)
	tween.tween_property(node, "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "scale", Vector2(1, 1), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).set_delay(duration)

## Warps the node with a quick distortion motion.
static func warp(node: Node2D) -> void:
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.2, 0.8), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

##  Fades out and scales down the node. Optionally resets after (mainly for test purpose).
static func vanish(node: CanvasItem, duration := 0.4, restore_after_fade : bool = false) -> void:
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(node, "scale", Vector2(0.0, 0.0), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# Restore original values after fade
	if restore_after_fade :
		await tween.finished
		pop_in(node)

## Quickly scales the node in with a slight bounce.
static func punch_in(node: Node2D, strength: float = 0.3, duration: float = 0.15) -> void:
	var original_scale = node.scale
	var punch_in = original_scale * (1 + strength)
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "scale", punch_in, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", original_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

## Moves the node back and forth rapidly for a shake effect.
static func shake(node: Node2D, amount: float = 10.0, shakes: int = 5, duration: float = 0.3) -> void:
	var original_pos = node.position
	var tween := node.get_tree().create_tween()
	for i in range(shakes):
		var offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))
		tween.tween_property(node, "position", original_pos + offset, duration / (shakes * 2))
		tween.tween_property(node, "position", original_pos, duration / (shakes * 2))

## Drops the node from above into its original position.
static func drop_in(node: CanvasItem, drop_height: float = 100.0, duration: float = 0.5) -> void:
	var start_pos = node.position - Vector2(0, drop_height)
	node.position = start_pos
	node.scale = Vector2(1.2, 0.8)
	node.modulate.a = 0.0
	
	var tween := node.get_tree().create_tween()
	tween.tween_property(node, "position", node.position + Vector2(0, drop_height), duration).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "scale", Vector2(1, 1), duration * 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(node, "modulate:a", 1.0, duration * 0.4)

#endregion

#region Helpers

static func _has_active_animation(node: Node, anim_type: String) -> bool:
	return node_tweens.has(node) and node_tweens[node].has(anim_type)

static func _store_animation(node: Node, anim_type: String, tween: Tween) -> void:
	if not node_tweens.has(node):
		node_tweens[node] = {}
	node_tweens[node][anim_type] = tween
	
	if not tween.is_connected("finished", _on_tween_finished):
		tween.connect("finished", _on_tween_finished.bind(node, anim_type))

static func _stop_animation(node: Node, anim_type: String) -> void:
	if _has_active_animation(node, anim_type):
		var tween = node_tweens[node][anim_type]
		tween.kill()
		
		if anim_type == "bobbing" and node_tweens[node].has("original_pos"):
			node.position = node_tweens[node]["original_pos"]
		
		node_tweens[node].erase(anim_type)
		
		if node_tweens[node].is_empty():
			node_tweens.erase(node)

static func _on_tween_finished(node: Node, anim_type: String) -> void:
	if _has_active_animation(node, anim_type):
		node_tweens[node].erase(anim_type)
		if node_tweens[node].is_empty():
			node_tweens.erase(node)

#endregion
