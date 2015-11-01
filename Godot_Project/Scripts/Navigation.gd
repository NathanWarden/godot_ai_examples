extends Navigation


var navMeshInstance
var navMesh
var navMeshId

func _ready():
	navMeshInstance = get_parent().get_node("Field").get_node("NavMesh")
	navMesh = navMeshInstance.get_navigation_mesh()
	navMeshId = navmesh_create(navMesh, navMeshInstance.get_transform())
