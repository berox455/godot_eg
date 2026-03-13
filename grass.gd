extends Node

var time: float  # in seconds
var grass_eaten = 0
const scaling = 1.2
#pwr
var click_munch = 1  # when you click the grass
var munch = 0.1  # auto mouth click 0.1 for each per second
var dog_munch = 1  # munches 1 per second
var hen_munch = 1  # munches 1 per 0.1 second
var cow_munch = 800  # munches 500 per 10 seconds w child, 800 wo
#lvl
var mouth_lvl = 0
var dog_lvl = 0
var hen_lvl = 0
var cow_lvl = 0
#base cost
const mouth_base = 15
const dog_base = 100
const hen_base = 1100
const cow_base = 10000
#cost
var mouth_cost: float
var dog_cost: float
var hen_cost: float
var cow_cost: float
#LoadSave
const save_dir: String = "user://save.json"

var mr_save: Dictionary
var saving = 0
#other
var munching: int = 0
var num_velocity: int = 2  # the speed of numbers going up


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("User dir:", OS.get_data_dir())
	mr_save = _load()
	if len(mr_save) > 1:
		_unload()
	mouth_cost = _cost_calc(mouth_base, mouth_lvl)
	dog_cost = _cost_calc(dog_base, dog_lvl)
	hen_cost = _cost_calc(hen_base, hen_lvl)
	cow_cost = _cost_calc(cow_base, cow_lvl)
	
	$calf/button.hide()
	_mouth_label_update()
	_dog_label_update()
	_hen_label_update()
	_cow_label_update()
	
	if !(mouth_lvl > 4 or dog_lvl > 0):
		$dog/button.hide()
		
	if !(dog_lvl > 4 or hen_lvl > 0):
		$hen/button.hide()
		
	if !(hen_lvl > 4 or cow_lvl > 0):
		$cow/button.hide()
	$save/saving.visible_characters = saving


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if grass_eaten > 100:
		$eat_grass/grass_eaten.text = _abr(grass_eaten)
	else:
		$eat_grass/grass_eaten.text = "grass eaten: " + _abr(grass_eaten)
		
		
func _physics_process(delta: float) -> void:
	var children = $Click_numbers.get_children()
	for node in children:
		var temp = node.get_position()
		node.set_position(Vector2(temp.x, temp.y - num_velocity))


func _get_time() -> void:
	time += 0.1
	time = snapped(time, 0.1)
	
	#munching
	if time == floor(time):
		grass_eaten += munch * mouth_lvl
		if dog_lvl > 0:
			grass_eaten += dog_munch * dog_lvl
		if cow_lvl > 0 and int(floor(time)) % 10 == 0:
			grass_eaten += cow_munch * cow_lvl
	
	if hen_lvl > 0:
		grass_eaten += hen_munch * hen_lvl
	
	#saving
	if time == int(time) and int(time) % 120 == 0:
		_save()

	if saving >= 5:
		saving += 1
		if saving > 9:
			saving = 0
		$save/saving.visible_characters = saving
	
	if munching > 0:
		munching -= 1
	else:
		$eat_grass/Grass.show()
	
	var children = $Click_numbers.get_children()
	var i = 0
	for node in children:
		var col = node.get_theme_color("font_color")
		if col.a == 0:
			node.queue_free()
		elif col.a > 0.9:
			col.a -= 0.01
			node.add_theme_color_override("font_color", col)
		else:
			col.a -= 0.1
			node.add_theme_color_override("font_color", col)
		i += 1


func _abr(number: int) -> String:
	var k: float = 1000
	var m: float = 1000000
	var b: float = 1000000000
	var t: float = 1000000000000
	var q: float = 1000000000000000
	var output: float
	var modifier: String
	var limiter: float = 1
	
	number = float(number)
	
	if (number / q) > limiter:
		output = number / q
		modifier = "q"
	elif (number / t) > limiter:
		output = number / t
		modifier = "t"
	elif (number / b) > limiter:
		output = number / b
		modifier = "b"
	elif (number / m) > limiter:
		output = number / m
		modifier = "m"
	elif (number / k) > limiter:
		output = number / k
		modifier = "k"
	else:
		return str(number)
	return str(snapped(output, 0.01)) + modifier


func _save() -> void:
	_click_play()
	mr_save = {
	"grass_eaten": grass_eaten,
	"click_much": click_munch,
	"mouth_lvl": mouth_lvl,
	"dog_lvl": dog_lvl,
	"hen_lvl": hen_lvl,
	"cow_lvl": cow_lvl
	}
	
	var file = FileAccess.open(save_dir, FileAccess.WRITE)
	file.store_var(mr_save.duplicate())
	file.close()
	saving = 5
	

func _load() -> Dictionary:
	var save_dict: Dictionary
	if FileAccess.file_exists(save_dir):
		var file = FileAccess.open(save_dir, FileAccess.READ)
		save_dict = file.get_var()
		file.close()
	else:
		save_dict = {}

	return save_dict
	

func _unload() -> void:
	for line in mr_save:
		var saved = mr_save[line]
		match line:
			"grass_eaten": grass_eaten = saved
			"click_much": click_munch = saved
			"mouth_lvl": mouth_lvl = saved
			"dog_lvl": dog_lvl = saved
			"hen_lvl": hen_lvl = saved
			"cow_lvl": cow_lvl = saved


func _erase_save() -> void:
	_click_play()
	var file = FileAccess.open(save_dir, FileAccess.WRITE)
	file.store_var({})
	file.close()


func _save_quit() -> void:
	_click_play()
	_save()
	get_tree().quit()


func _eat_grass() -> void:
	grass_eaten += click_munch
	_spawn_number()
	$eat_grass/Munch.pitch_scale = randf_range(0.9, 1.5)
	$eat_grass/Munch.play()
	$eat_grass/Grass.hide()
	munching = 2


func _mouth_up() -> void:
	if grass_eaten >= mouth_cost:
		_click_play()
		grass_eaten -= mouth_cost
		mouth_lvl += 1
		mouth_cost = _cost_calc(mouth_base, mouth_lvl)
		_mouth_label_update()
		
		if mouth_lvl == 5:
			$dog/button.show()
		if mouth_lvl % 25 == 0:
			click_munch += 1


func _dog_up() -> void:
	if grass_eaten >= dog_cost:
		_click_play()
		grass_eaten -= dog_cost
		dog_lvl += 1
		dog_cost = _cost_calc(dog_base, dog_lvl)
		_dog_label_update()
		
		if dog_lvl == 5:
			$hen/button.show()


func _hen_up() -> void:
	if grass_eaten >= hen_cost:
		_click_play()
		grass_eaten -= hen_cost
		hen_lvl += 1
		hen_cost = _cost_calc(hen_base, hen_lvl)
		_hen_label_update()
		
		if hen_lvl == 5:
			$cow/button.show()


func _cow_up() -> void:
	if grass_eaten >= cow_cost:
		_click_play()
		grass_eaten -= cow_cost
		cow_lvl += 1
		cow_cost = _cost_calc(cow_base, cow_lvl)
		_cow_label_update()


func _mouth_buy_enter() -> void:
	$mouth/button/Label.show()


func _mouth_buy_exit() -> void:
	$mouth/button/Label.hide()


func _dog_buy_enter() -> void:
	$dog/button/Label.show()


func _dog_buy_exit() -> void:
	$dog/button/Label.hide()


func _hen_buy_enter() -> void:
	$hen/button/Label.show()


func _hen_buy_exit() -> void:
	$hen/button/Label.hide()


func _cow_buy_enter() -> void:
	$cow/button/Label.show()


func _cow_buy_exit() -> void:
	$cow/button/Label.hide()


func _calf_buy_enter() -> void:
	$calf/button/Label.show()


func _calf_buy_exit() -> void:
	$calf/button/Label.hide()
	

func _mouth_label_update() -> void:
	var mouth_d = "Each mouth can bite off 0.1 grass/s"
	var mouth_desc = "\n" + mouth_d + """
"They're geneticaly engineered for munchin' on grass." -Munch Man
"""

	$mouth/button.text = "   Mouth lvl" + _abr(mouth_lvl + 1)
	$mouth/button/cost.text = "cost: " + _abr(mouth_cost)
	if mouth_lvl > 0:
		$mouth/button/Label.text = str(munch * mouth_lvl) + " grass/s"
		$mouth/button/Label.text += mouth_desc
	else:
		$mouth/button/Label.text = mouth_d
	
	
func _dog_label_update() -> void:
	var dog_d = "Dog bites off 1 grass/s per lvl"
	var dog_desc = "\n" + dog_d + """
"Thier stomach problems must be imense!" -Random bystander
"""

	$dog/button.text = "   Dog lvl" + _abr(dog_lvl + 1)
	$dog/button/cost.text = "cost: " + _abr(dog_cost)
	if dog_lvl > 0:
		$dog/button/Label.text = str(dog_munch * dog_lvl) + " grass/s"
		$dog/button/Label.text += dog_desc
	else:
		$dog/button/Label.text = dog_d


func _hen_label_update() -> void:
	var hen_d = "hen pecks 10 grass/s per lvl"
	var hen_desc = "\n" + hen_d + """
"Haven't eaten in days is what I'd wager makes 'em this hungry! Or they just got stomach worms" -hen seller
"""

	$hen/button.text = "   Hen lvl" + _abr(hen_lvl + 1)
	$hen/button/cost.text = "cost: " + _abr(hen_cost)
	if hen_lvl > 0:
		$hen/button/Label.text = str(hen_munch * 10 * hen_lvl)+ " grass/s"
		$hen/button/Label.text += hen_desc
	else:
		$hen/button/Label.text = hen_d
		

func _cow_label_update() -> void:
	var cow_d = "Eats 80 grass/s"
	var cow_desc = "\n" + cow_d + """
"They be goin' moo" -Moo \\temporary pls change
"""
	
	$cow/button.text = "   Cow lvl" + _abr(cow_lvl + 1)
	$cow/button/cost.text = "cost: " + _abr(cow_cost)
	if cow_lvl > 0:
		$cow/button/Label.text = str(cow_munch / 10 * cow_lvl)+ " grass/s"
		$cow/button/Label.text += cow_desc
		$calf/button.show()
	else:
		$cow/button/Label.text = cow_d
	

func _click_play() -> void:
	$Click.pitch_scale = randf_range(0.9, 1.5)
	$Click.play()
	

func _spawn_number() -> void:
	var mp = $eat_grass.get_global_mouse_position()
	var new_label = Label.new()
	$Click_numbers.add_child(new_label, true)
	
	new_label.set_position(mp)
	new_label.text = str(click_munch)
	new_label.add_theme_font_size_override("font_size", 30)
	new_label.z_index = 3
	

func _cost_calc(base_cost, lvl) -> float:
	return base_cost * (scaling ** lvl)
