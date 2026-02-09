extends Node

var munch_pwr = 1
var grass_eaten = 0
var mouth_cost = [5, 5]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$mouth_upgrade/button/cost.text = "cost: " + str(_sum(mouth_cost))
	#$munch_pwr.text = ""

func _sum(array: Array) -> int:
	var sum = 0
	for variable in array:
		sum += variable
		
	return sum

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if grass_eaten > 100:
		$eat_grass/grass_eaten.text = str(grass_eaten)
	else:
		$eat_grass/grass_eaten.text = "grass eaten: " + str(grass_eaten)


func _eat_grass_pressed() -> void:
	grass_eaten += munch_pwr
	$eat_grass/Munch.pitch_scale = randf_range(0.9, 1.5)
	$eat_grass/Munch.play()


func _mouth_upgrade_pressed() -> void:
	if grass_eaten >=  _sum(mouth_cost):
		grass_eaten -= _sum(mouth_cost)
		mouth_cost.append(mouth_cost[-1] + mouth_cost.pop_at(0))
		$mouth_upgrade/button/cost.text = "cost: " + str(_sum(mouth_cost))
		munch_pwr += 1
		$mouth_upgrade/button.text = "   Buy lvl" + str(munch_pwr)
		#$munch_pwr.text = "Munch pwr: " + str(munch_pwr)


func _dog_upgrade_pressed() -> void:
	pass # Replace with function body.
