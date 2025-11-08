extends Node


func rank_index(tile_id_: int) -> int:
	return tile_id_ >> 3
	
func file_index(tile_id_: int) -> int:
	return tile_id_ & 0b000111
	
func index_from_coord(coord_: Vector2i) -> int:
	return coord_.y * FrameworkSettings.BOARD_SIZE.x + coord_.x
	
func coord_from_index(tile_id_: int) -> Vector2i:
	var x = tile_id_ % FrameworkSettings.BOARD_SIZE.x
	var y = tile_id_ / FrameworkSettings.BOARD_SIZE.x
	return Vector2i(x, y)
	
func is_valid_coord(coord_: Vector2i) -> bool:
	return coord_.x >= 0 && coord_.x < FrameworkSettings.BOARD_SIZE.x && coord_.y >= 0 && coord_.y < FrameworkSettings.BOARD_SIZE.y
