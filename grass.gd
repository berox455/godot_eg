extends Node

var time: float  # in seconds
var grass_eaten = 0
#pwr
var munch = 1
var dog_munch = 2
#passive
var dogs = 0
#cost
var mouth_cost = [5, 5]
var dog_cost = [10, 10]
var dog_upgrade_cost = [50, 50]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$mouth_upgrade/button/cost.text = "cost: " + _abr(_sum(mouth_cost))
	$dog/button/cost.text = "cost: " + _abr(_product(dog_cost))
	$dog_upgrade/Button/cost.text = "cost: " + _abr(_sum(dog_upgrade_cost))
	$dog_upgrade/Button.hide()


func _sum(array: Array) -> int:
	var sum = 0
	for variable in array:
		sum += variable
		
	return sum
	

func _product(array: Array) -> int:
	var product = 1
	for variable in array:
		product *= variable
		
	return product

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if grass_eaten > 100:
		$eat_grass/grass_eaten.text = _abr(grass_eaten)
	else:
		$eat_grass/grass_eaten.text = "grass eaten: " + str(grass_eaten)
	


func _eat_grass_pressed() -> void:
	grass_eaten += munch
	$eat_grass/Munch.pitch_scale = randf_range(0.9, 1.5)
	$eat_grass/Munch.play()


func _mouth_upgrade_pressed() -> void:
	if grass_eaten >=  _sum(mouth_cost):
		grass_eaten -= _sum(mouth_cost)
		mouth_cost.append(mouth_cost[-1] + mouth_cost.pop_at(0))
		$mouth_upgrade/button/cost.text = "cost: " + _abr(_sum(mouth_cost))
		munch += 1
		$mouth_upgrade/button.text = "   Buy lvl" + _abr(munch)
		#$munch.text = "Munch pwr: " + str(munch)


func _dog_buy_pressed() -> void:
	if grass_eaten >= _product(dog_cost):
		grass_eaten -= _product(dog_cost)
		dog_cost.append(dog_cost[-1] * dog_cost.pop_at(0))
		$dog/button/cost.text = "cost: " + _abr(_product(dog_cost))
		dogs += 1
		$dog/button.text = "   Buy #" + _abr(dogs + 1)
		$dog_upgrade/label.text = "Dog munch: " + _abr(dog_munch * dogs)
		if dogs == 1:
			$dog_upgrade/Button.show()
			


func _dog_upgrade_pressed() -> void:
	if grass_eaten >= _sum(dog_upgrade_cost):
		grass_eaten -= _sum(dog_upgrade_cost)
		dog_upgrade_cost.append(dog_upgrade_cost[-1] + dog_upgrade_cost.pop_at(0))
		$dog_upgrade/Button/cost.text = "cost: " + _abr(_sum(dog_upgrade_cost))
		dog_munch += 2
		$dog_upgrade/label.text = "Dog munch: " + _abr(dog_munch * dogs)


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


func _get_time() -> void:
	time += 0.1
	time = snapped(time, 0.1)
	
	if time == floor(time) and dogs > 0:
		grass_eaten += dog_munch * dogs
