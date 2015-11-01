
extends BTDistance

export var color = Color(1,1,1,1)

func _success():
	var material = get_agent().get_node("TestCube").get_material_override()
	material.set_parameter(FixedMaterial.PARAM_DIFFUSE, color)
