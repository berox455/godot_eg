extends Node

var time: float  # in seconds
var grass_eaten = 0
const scaling = 1.4
#pwr
var munch = 1
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
	
	$mouth_upgrade/button.text = "   Buy lvl" + _abr(mouth_lvl + 1)
	$mouth_upgrade/button/cost.text = "cost: " + _abr(mouth_cost)
	$dog/button.text = "   Buy #" + _abr(dog_lvl + 1)
	$dog/button/cost.text = "cost: " + _abr(dog_cost)
	$dog_upgrade/Button/cost.text = "cost: " + _abr(dog_upgrade_cost)
	$chicken/button.text = "   Buy #" + _abr(chicken_lvl + 1)
	$chicken/button/cost.text = "cost: " + _abr(chicken_cost)
	
	if mouth_lvl > 4 or dog_lvl > 0:
		$dog_upgrade/label.text = "Dog munch: " + _abr(dog_munch * dog_lvl)
	else:
		$dog_upgrade/label.hide()
		$dog_upgrade/Button.hide()
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
	if time == floor(time) and dog_lvl > 0:
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
		var temp = mr_save[line]
		match line:
			"grass_eaten":
				grass_eaten = temp
			"mouth_lvl":
				mouth_lvl = temp
			"munch":
				munch = temp
			"dog_lvl":
				dog_lvl = temp
			"dog_upgrade_lvl":
				dog_upgrade_lvl = temp
			"dog_munch":
				dog_munch = temp
			"chicken_lvl":
				chicken_lvl = temp
			"chicken_munch":
				chicken_munch = temp


func _eat_grass_pressed() -> void:
	grass_eaten += munch
	$eat_grass/Munch.pitch_scale = randf_range(0.9, 1.5)
	$eat_grass/Munch.play()


func _mouth_upgrade_pressed() -> void:
	if grass_eaten >= mouth_cost:
		grass_eaten -= mouth_cost
		mouth_lvl += 1
		munch += 1
		mouth_cost = mouth_base * (scaling ** mouth_lvl)
		$mouth_upgrade/button/cost.text = "cost: " + _abr(mouth_cost)
		$mouth_upgrade/button.text = "   Buy lvl" + _abr(mouth_lvl + 1)
		
		if mouth_lvl == 5:
			$dog/TextBlock.show()
			$dog/button.show()


func _dog_buy_pressed() -> void:
	if grass_eaten >= dog_cost:
		grass_eaten -= dog_cost
		dog_lvl += 1
		dog_cost = dog_base * (scaling ** dog_lvl)
		$dog/button.text = "   Buy #" + _abr(dog_lvl + 1)
		$dog/button/cost.text = "cost: " + _abr(dog_cost)
		$dog_upgrade/label.text = "Dog munch: " + _abr(dog_munch * dog_lvl)
		if dog_lvl == 1:
			$dog_upgrade/Button.show()
			$dog_upgrade/label.show()


func _dog_upgrade_pressed() -> void:
	if grass_eaten >= dog_upgrade_cost:
		grass_eaten -= dog_upgrade_cost
		dog_upgrade_lvl += 1
		dog_munch += 1
		dog_upgrade_cost = dog_upgrade_base * (scaling ** dog_upgrade_lvl)
		$dog_upgrade/label.text = "Dog munch: " + _abr(dog_munch * dog_lvl)
		$dog_upgrade/Button/cost.text = "cost: " + _abr(dog_upgrade_cost)
		if dog_lvl == 5:
			$chicken/TextBlock.show()
			$chicken/button.show()


func _chicken_buy_pressed() -> void:
	if grass_eaten >= chicken_cost:
		grass_eaten -= chicken_cost
		chicken_lvl += 1
		chicken_cost = chicken_base * (scaling ** chicken_lvl)
		$chicken/button.text = "   Buy #" + _abr(chicken_lvl + 1)
		$chicken/button/cost.text = "cost: " + _abr(chicken_cost)
