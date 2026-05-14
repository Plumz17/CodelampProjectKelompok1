extends Resource
class_name WaveData

@export var enemy_scenes: Array[PackedScene]   # index must match SpawnEntry.EnemyType order
@export var spawn_schedule: Array[SpawnEntry]  # typed! shows nicely in Inspector
