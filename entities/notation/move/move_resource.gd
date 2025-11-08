class_name MoveResource
extends Resource


var piece: PieceResource
var start_tile: TileResource
var end_tile: TileResource
var captured_piece: PieceResource
var castling_rook: PieceResource
var type: FrameworkSettings.MoveType = FrameworkSettings.MoveType.BASIC
var initiative: FrameworkSettings.InitiativeType = FrameworkSettings.InitiativeType.BASIC


func _init(piece_: PieceResource, start_tile_: TileResource, end_tile_: TileResource, captured_piece_: PieceResource = null, castling_rook_: PieceResource = null) -> void:
	piece = piece_
	start_tile = start_tile_
	end_tile = end_tile_
	captured_piece = captured_piece_
	castling_rook = castling_rook_
	
	check_capture()
	check_pawn_promotion()
	check_castling()
	
func check_capture() -> void:
	if captured_piece != null:
		if captured_piece.tile == end_tile:
			type = FrameworkSettings.MoveType.CAPTURE
		else:
			type = FrameworkSettings.MoveType.PASSANT
	
func check_pawn_promotion() -> void:
	if piece.template.type != FrameworkSettings.PieceType.PAWN: return
	if end_tile.coord.y == 0 and piece.template.color == FrameworkSettings.PieceColor.WHITE:
		type = FrameworkSettings.MoveType.PROMOTION
	if end_tile.coord.y == 7 and piece.template.color == FrameworkSettings.PieceColor.BLACK:
		type = FrameworkSettings.MoveType.PROMOTION
	
func pawn_promotion(new_piece_type_: FrameworkSettings.PieceType = FrameworkSettings.PieceType.QUEEN) -> void:
	var template_id = new_piece_type_ | piece.template.color
	var new_template = load("res://entities/piece/templates/" + str(template_id) + ".tres")
	piece.template = new_template
	
func check_castling() -> void:
	if piece.template.type != FrameworkSettings.PieceType.KING: return
	var x = abs(start_tile.coord.x - end_tile.coord.x)
	var y = abs(start_tile.coord.y - end_tile.coord.y)
	var l = max(x, y)#start_tile.coord.distance_squared_to(end_tile.coord)
	if l > 1:
		type = FrameworkSettings.MoveType.CASTLING
