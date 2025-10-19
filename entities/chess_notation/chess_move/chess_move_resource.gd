class_name ChessMoveResource
extends Resource


var chess_piece: ChessPieceResource
var start_chess_tile: ChessTileResource
var end_chess_tile: ChessTileResource
var type: FrameworkSettings.MoveType = FrameworkSettings.MoveType.FREE


func _init(chess_piece_: ChessPieceResource, start_chess_tile_: ChessTileResource, end_chess_tile_: ChessTileResource) -> void:
	chess_piece = chess_piece_
	start_chess_tile = start_chess_tile_
	end_chess_tile = end_chess_tile_
