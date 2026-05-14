extends Resource
class_name SpawnEntry

enum EnemyType { NORMAL, VLOGGER, DUKUN }

@export var time_seconds: float = 0.0
@export var enemy_type: EnemyType = EnemyType.NORMAL
@export var count: int = 0