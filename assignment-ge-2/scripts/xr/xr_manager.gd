extends Node

@onready var nav_region = $NavigationRegion3D

func _ready() -> void:
	nav_region.bake_navigation_mesh()
	await nav_region.bake_finished
	print("Navmesh baked!")
