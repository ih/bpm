from builtin_element import Tile

road_t_empty = {
	'tid': 1,
	'edge': {'L': 0, 'R': 0, 'U': 0, 'D': 0 }
}

road_t_vert = {
	'tid': 2,
	'edge': {'L': 0, 'R': 0, 'U': 1, 'D': 1 }
}
road_t_hor = {
	'tid': 3,
	'edge': {'L': 1, 'R': 1, 'U': 0, 'D': 0 }
}

road_t_cross = {
	'tid': 4,
	'edge': {'L': 1, 'R': 1, 'U': 1, 'D': 1 }
}

road_tilemap = {
		'1' : Tile(road_t_empty),
		'2' : Tile(road_t_vert),
		'3' : Tile(road_t_hor),
		'4' : Tile(road_t_cross),
}

