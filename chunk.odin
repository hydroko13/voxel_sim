package main

import "core:slice"
import "core:fmt"
import rl "vendor:raylib"


Chunk :: struct {
	block_data:    []u32,
	chunk_x:       int,
	chunk_y:       int,
	mesh:          rl.Mesh,
	model: rl.Model
}


new_chunk :: proc(chunk_x, chunk_y: int) -> Chunk {

	data := make([]u32, 16 * 16 * 256)

	chunk_mesh := rl.Mesh{}


	// Allocate vertex, texcoord, and normals dynamic array

	return Chunk {
		chunk_x = chunk_x,
		chunk_y = chunk_y,
		block_data = data,
		mesh = chunk_mesh,
		model = rl.Model{}
	}
}

chunk_generate :: proc(chunk: Chunk) {
	for x in 0 ..< 16 {
		for z in 0 ..< 16 {
			for y in 0 ..< 256 {
				if y < 60 {
					chunk_set_at(chunk, x, y, z, 1)
				} else {
					chunk_set_at(chunk, x, y, z, 0)
				}

			}
		}
	}

}


chunk_set_at :: proc(
	chunk: Chunk,
	within_chunk_x: int,
	within_chunk_y: int,
	within_chunk_z: int,
	block_id: u32,
) {
	idx := within_chunk_y * (16 * 16) + within_chunk_x * 16 + within_chunk_z

	chunk.block_data[idx] = block_id

}

chunk_get_at :: proc(
	chunk: Chunk,
	within_chunk_x: int,
	within_chunk_y: int,
	within_chunk_z: int,
) -> u32 {
	idx := within_chunk_y * (16 * 16) + within_chunk_x * 16 + within_chunk_z

	return chunk.block_data[idx]
}

chunk_draw :: proc(chunk: Chunk) {
	rl.DrawModel(chunk.model, rl.Vector3{f32(chunk.chunk_x) * 16.0, 0.0, f32(chunk.chunk_y) * 16.0}, 1.0, rl.WHITE)
}


chunk_update :: proc(chunk: ^Chunk) {


	vertex_data := make([dynamic]f32, 0)
	texcoord_data := make([dynamic]f32, 0)
	normal_data := make([dynamic]f32, 0)

	

	vertex_count := 0
	tri_count := 0
	
	for x in 0 ..< 16 {
		for z in 0 ..< 16 {
			for y in 0 ..< 256 {
				block_id := chunk_get_at(chunk^, x, y, z)

				if block_id != 0 {
					
					append(&vertex_data, f32(x))
					append(&vertex_data, f32(y))
					append(&vertex_data, f32(z))

					append(&texcoord_data, 0.0)
					append(&texcoord_data, 0.0)

					append(&normal_data, 0.0)
					append(&normal_data, 0.0)
					append(&normal_data, 0.0)

					append(&vertex_data, f32(x))
					append(&vertex_data, f32(y) + 1.0)
					append(&vertex_data, f32(z))

					append(&texcoord_data, 0.0)
					append(&texcoord_data, 0.0)

					append(&normal_data, 0.0)
					append(&normal_data, 0.0)
					append(&normal_data, 0.0)


					append(&vertex_data, f32(x) + 1.0)
					append(&vertex_data, f32(y))
					append(&vertex_data, f32(z))

					append(&texcoord_data, 0.0)
					append(&texcoord_data, 0.0)

					append(&normal_data, 0.0)
					append(&normal_data, 0.0)
					append(&normal_data, 0.0)

					tri_count += 1
					vertex_count += 3	
				}
			}
		}
	}

	chunk.mesh.vertexCount = i32(vertex_count)
	chunk.mesh.triangleCount = i32(tri_count)


	vertex_data_allocated := (^f32)(rl.MemAlloc(u32(len(vertex_data) * 4)))
	texcoord_data_allocated := (^f32)(rl.MemAlloc(u32(len(texcoord_data) * 4)))
	normal_data_allocated := (^f32)(rl.MemAlloc(u32(len(normal_data) * 4)))


	vertex_data_slice := slice.from_ptr(vertex_data_allocated, len(vertex_data))
	texcoord_data_slice := slice.from_ptr(texcoord_data_allocated, len(texcoord_data))
	normal_data_slice := slice.from_ptr(normal_data_allocated, len(normal_data))

	for vert, idx in vertex_data {
		vertex_data_slice[idx] = vert
	}
	for norm, idx in normal_data {
		normal_data_slice[idx] = norm
	}
	for coord, idx in texcoord_data {
		texcoord_data_slice[idx] = coord
	}
	

	chunk.mesh.vertices = vertex_data_allocated
	chunk.mesh.texcoords = texcoord_data_allocated
	chunk.mesh.normals = normal_data_allocated


	rl.UploadMesh(&chunk.mesh, false)

	chunk.model = rl.LoadModelFromMesh(chunk.mesh)

	
	
}

delete_chunk :: proc(chunk: Chunk) {
	rl.UnloadModel(chunk.model)

	delete(chunk.block_data)
	
}
