## 地形生成器 —— 提供多种地形生成算法。
##
## 继承自 [Resource]，提供静态方法生成不同风格的地形数据。
class_name TerrainGenerator
extends Resource

## 随机方块生成概率。
const RANDOM_BLOCK_PROBABILITY = 0.015

## 生成空地形数据。
##
## 返回: [Dictionary] 空字典
static func empty() -> Dictionary[Vector3i, int]:
	return {}


## 生成随机方块地形。
##
## 返回: [Dictionary] 随机方块数据
static func random_blocks() -> Dictionary[Vector3i, int]:
	var random_data: Dictionary[Vector3i, int] = {}
	for x in Chunk.CHUNK_SIZE:
		for y in Chunk.CHUNK_SIZE:
			for z in Chunk.CHUNK_SIZE:
				var vec := Vector3i(x, y, z)
				if randf() < RANDOM_BLOCK_PROBABILITY:
					random_data[vec] = randi() % 29 + 1

	return random_data


## 生成平坦地形（草地 + 泥土 + 基岩）。
##
## 参数:
##   chunk_position: 区块位置
##
## 返回: [Dictionary] 平坦地形数据
##
## 仅在 y = -1 的区块生成地形，其他位置返回空。
static func flat(chunk_position: Vector3i) -> Dictionary[Vector3i, int]:
	var data: Dictionary[Vector3i, int] = {}

	if chunk_position.y != -1:
		return data

	for x in Chunk.CHUNK_SIZE:
		for z in Chunk.CHUNK_SIZE:
			data[Vector3i(x, 2, z)] = 3  # 草方块。
			data[Vector3i(x, 1, z)] = 2  # 泥土。
			data[Vector3i(x, 0, z)] = 2  # 泥土。
			data[Vector3i(x, -1, z)] = 9  # 基岩（由于 Y 坐标原因无法被破坏）。

	return data


## 生成原点处的草地（用于创建项目图标）。
##
## 参数:
##   chunk_position: 区块位置
##
## 返回: [Dictionary] 仅在原点有一个草方块
static func origin_grass(chunk_position: Vector3i) -> Dictionary[Vector3i, int]:
	if chunk_position == Vector3i.ZERO:
		return { Vector3i.ZERO: 3 }

	return {}
