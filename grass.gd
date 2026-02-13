extends Node

var time: float  # in seconds
var grass_eaten = 0
const scaling = 1.2
#pwr
var click_munch = 1
var munch = 0
var dog_munch = 1
var chicken_munch = 1
#lvl
var mouth_lvl = 0
var dog_lvl = 0
var dog_upgrade_lvl = 0
var chicken_lvl = 0
#base cost
const mouth_base = 15
const dog_base = 100
const dog_upgrade_base = 140
const chicken_base = 1100
#cost
var mouth_cost: float
var dog_cost: float
var dog_upgrade_cost: float
var chicken_cost: float
#LoadSave
const save_dir: String = "user://save.json"

var mr_save: Dictionary
var saving = 0
#other
var munching: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("User dir:", OS.get_data_dir())
	mr_save = _load()
	if len(mr_save) > 1:
		_unload()
	mouth_cost = mouth_base * (scaling ** mouth_lvl)
	dog_cost = dog_base * (scaling ** dog_lvl)
	dog_upgrade_cost = dog_upgrade_base * (scaling ** dog_upgrade_lvl)
	chicken_cost = chicken_base * (scaling ** chicken_lvl)
	
	_mouth_label_update()
	_dog_label_update()
	_chicken_label_update()
	
	if !(mouth_lvl > 4):
		$dog/TextBlock.hide()
		$dog/button.hide()
		
	if !(dog_lvl > 4 or chicken_lvl > 0):
		$chicken/TextBlock.hide()
		$chicken/button.hide()
	$save/saving.visible_characters = saving


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if grass_eaten > 100:
		$eat_grass/grass_eaten.text = _abr(grass_eaten)
	else:
		$eat_grass/grass_eaten.text = "grass eaten: " + _abr(grass_eaten)


func _get_time() -> void:
	time += 0.1
	time = snapped(time, 0.1)
	
	#munching
	if time == floor(time):
		grass_eaten += munch
		if dog_lvl > 0:
			grass_eaten += dog_munch * dog_lvl
	
	if chicken_lvl > 0:
		grass_eaten += chicken_munch * chicken_lvl
	
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
	mr_save = {
	"grass_eaten": grass_eaten,
	"click_much": click_munch,
	"mouth_lvl": mouth_lvl,
	"munch": munch,
	"dog_lvl": dog_lvl,
	"dog_upgrade_lvl": dog_upgrade_lvl,
	"dog_munch": dog_munch,
	"chicken_lvl": chicken_lvl,
	"chicken_munch": chicken_munch
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
			"munch": munch = saved
			"dog_lvl": dog_lvl = saved
			"dog_upgrade_lvl": dog_upgrade_lvl = saved
			"dog_munch": dog_munch = saved
			"chicken_lvl": chicken_lvl = saved
			"chicken_munch": chicken_munch = saved


func _eat_grass_pressed() -> void:
	grass_eaten += click_munch
	$eat_grass/Munch.pitch_scale = randf_range(0.9, 1.5)
	$eat_grass/Munch.play()
	$eat_grass/Grass.hide()
	munching = 2


func _mouth_pressed() -> void:
	if grass_eaten >= mouth_cost:
		grass_eaten -= mouth_cost
		mouth_lvl += 1
		munch += 0.1
		mouth_cost = mouth_base * (scaling ** mouth_lvl)
		_mouth_label_update()
		
		if mouth_lvl == 5:
			$dog/TextBlock.show()
			$dog/button.show()
		if mouth_lvl % 25 == 0:
			click_munch += 1


func _dog_buy_pressed() -> void:
	if grass_eaten >= dog_cost:
		grass_eaten -= dog_cost
		dog_lvl += 1
		dog_cost = dog_base * (scaling ** dog_lvl)
		_dog_label_update()
		
		if dog_lvl == 5:
			$chicken/TextBlock.show()
			$chicken/button.show()


func _chicken_buy_pressed() -> void:
	if grass_eaten >= chicken_cost:
		grass_eaten -= chicken_cost
		chicken_lvl += 1
		chicken_cost = chicken_base * (scaling ** chicken_lvl)
		_chicken_label_update()


func _erase_save() -> void:
	var file = FileAccess.open(save_dir, FileAccess.WRITE)
	file.store_var({})
	file.close()


func _save_quit() -> void:
	_save()
	get_tree().quit()


func _mouth_buy_enter() -> void:
	$mouth/button/Label.show()


func _mouth_buy_exit() -> void:
	$mouth/button/Label.hide()


func _dog_buy_enter() -> void:
	$dog/button/Label.show()


func _dog_buy_exit() -> void:
	$dog/button/Label.hide()


func _chicken_buy_enter() -> void:
	$chicken/button/Label.show()


func _chicken_buy_exit() -> void:
	$chicken/button/Label.hide()
	

func _mouth_label_update() -> void:
	$mouth/button.text = "   Buy lvl" + _abr(mouth_lvl + 1)
	$mouth/button/cost.text = "cost: " + _abr(mouth_cost)
	$mouth/button/Label.text = "Munch/s: " + str(munch)
	$mouth/button/Label.text += """
Each mouth can bite off 0.1 grass/s
They're geneticaly engineered for munchin' on grass. -Munch Man
"""
	
	
func _dog_label_update() -> void:
	$dog/button.text = "   Buy lvl" + _abr(dog_lvl + 1)
	$dog/button/cost.text = "cost: " + _abr(dog_cost)
	$dog/button/Label.text = "Munch/s: " + str(dog_munch * dog_lvl) + "\n"
	$dog/button/Label.text += ""
	

func _chicken_label_update() -> void:
	$chicken/button.text = "   Buy lvl" + _abr(chicken_lvl + 1)
	$chicken/button/cost.text = "cost: " + _abr(chicken_cost)
	$chicken/button/Label.text = "Munch/s: " + str(chicken_munch * 10 * chicken_lvl) + "\n"
	$dog/button/Label.text += ""
	
	
