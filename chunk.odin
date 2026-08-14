package main

import "core:fmt"
import rl "vendor:raylib"



Chunk :: struct {
	block_data: []u32,
	chunk_x: int,
	chunk_y: int,
	mesh: rl.Mesh,
	vertex_data_element_count: int,
	texcoord_data_element_count: int,
	normals_data_element_count: int,

	
	
}


new_chunk :: proc(chunk_x, chunk_y: int) -> (chunk: Chunk, ok: bool) {
	
	data, err := make([]u32, 16 * 16 * 256)

	if err != .None {
		return Chunk{}, false
	}

	// Allocate vertex, texcoord, and normals dynamic array
	
	return Chunk{chunk_x = chunk_x, chunk_y = chunk_y, block_data = data}, true
}

chunk_generate :: proc(chunk: Chunk) {
	for x in 0..<16 {
		for z in 0..<16 {
			for y in 0..<256 {
				if y < 60 {
					chunk_set_at(chunk, x, y, z, 1)
				} else {
					chunk_set_at(chunk, x, y, z, 0)
				}
				
			}	
		}	
	}

}



chunk_set_at :: proc(chunk: Chunk, within_chunk_x: int, within_chunk_y: int, within_chunk_z: int, block_id: u32) {
	idx := within_chunk_y * (16 * 16) + within_chunk_x * 16 + within_chunk_z

	chunk.block_data[idx] = block_id 
	
}

chunk_get_at :: proc(chunk: Chunk, within_chunk_x: int, within_chunk_y: int, within_chunk_z: int) -> u32 {
	idx := within_chunk_y * (16 * 16) + within_chunk_x * 16 + within_chunk_z

	return chunk.block_data[idx]
}

chunk_draw :: proc(chunk: Chunk) {
	
}


delete_chunk :: proc(chunk: Chunk) {
	delete(chunk.block_data)
}

