package main

import "core:fmt"
import "core:math/noise"
import "core:slice"
import rl "vendor:raylib"


Chunk :: struct {
	block_data: []u32,
	chunk_x:    int,
	chunk_y:    int,
	mesh:       rl.Mesh,
	model:      rl.Model,
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
		model = rl.Model{},
	}
}

chunk_generate :: proc(chunk: Chunk) {
	for x in 0 ..< 16 {
		for z in 0 ..< 16 {
			height := int(
				64 +
				noise.noise_2d(
					100,
					{
						(f64(chunk.chunk_x) * 16.0 + f64(x)) / 24,
						(f64(chunk.chunk_y) * 16.0 + f64(z)) / 24,
					},
				) *
					5.2,
			)

			for y in 0 ..< 256 {
				if y == height {
					chunk_set_at(chunk, x, y, z, 2)
				} else if y < (height - 4) {
					chunk_set_at(chunk, x, y, z, 3)
				}
				else if (y < height) && (y >= height - 4) {
					chunk_set_at(chunk, x, y, z, 1)
				}
				else if (y > height) {
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
	rl.DrawModel(
		chunk.model,
		rl.Vector3{f32(chunk.chunk_x) * 16.0, 0.0, f32(chunk.chunk_y) * 16.0},
		1.0,
		rl.WHITE,
	)
}


@(private = "file")
gen_triangle :: proc(
	vertex_data, normal_data: ^[dynamic]f32,
	offset_x, offset_y, offset_z: int,
	vert_idx1, vert_idx2, vert_idx3: int,
) {


	vert_offset_x: f32 = 0.0
	vert_offset_y: f32 = 0.0
	vert_offset_z: f32 = 0.0

	switch vert_idx1 {
	case 1:
		vert_offset_x = 1.0
	case 2:
		vert_offset_x = 1.0
		vert_offset_z = 1.0
	case 3:
		vert_offset_z = 1.0
	case 4:
		vert_offset_y = 1.0
	case 5:
		vert_offset_x = 1.0
		vert_offset_y = 1.0
	case 6:
		vert_offset_x = 1.0
		vert_offset_z = 1.0
		vert_offset_y = 1.0
	case 7:
		vert_offset_z = 1.0
		vert_offset_y = 1.0

	}


	append(vertex_data, f32(offset_x) + vert_offset_x)
	append(vertex_data, f32(offset_y) + vert_offset_y)
	append(vertex_data, f32(offset_z) + vert_offset_z)


	append(normal_data, 0.0)
	append(normal_data, 0.0)
	append(normal_data, 0.0)


	vert_offset_x = 0.0
	vert_offset_y = 0.0
	vert_offset_z = 0.0

	switch vert_idx2 {
	case 1:
		vert_offset_x = 1.0
	case 2:
		vert_offset_x = 1.0
		vert_offset_z = 1.0
	case 3:
		vert_offset_z = 1.0
	case 4:
		vert_offset_y = 1.0
	case 5:
		vert_offset_x = 1.0
		vert_offset_y = 1.0
	case 6:
		vert_offset_x = 1.0
		vert_offset_z = 1.0
		vert_offset_y = 1.0
	case 7:
		vert_offset_z = 1.0
		vert_offset_y = 1.0

	}

	append(vertex_data, f32(offset_x) + vert_offset_x)
	append(vertex_data, f32(offset_y) + vert_offset_y)
	append(vertex_data, f32(offset_z) + vert_offset_z)


	append(normal_data, 0.0)
	append(normal_data, 0.0)
	append(normal_data, 0.0)

	vert_offset_x = 0.0
	vert_offset_y = 0.0
	vert_offset_z = 0.0

	switch vert_idx3 {
	case 1:
		vert_offset_x = 1.0
	case 2:
		vert_offset_x = 1.0
		vert_offset_z = 1.0
	case 3:
		vert_offset_z = 1.0
	case 4:
		vert_offset_y = 1.0
	case 5:
		vert_offset_x = 1.0
		vert_offset_y = 1.0
	case 6:
		vert_offset_x = 1.0
		vert_offset_z = 1.0
		vert_offset_y = 1.0
	case 7:
		vert_offset_z = 1.0
		vert_offset_y = 1.0

	}

	append(vertex_data, f32(offset_x) + vert_offset_x)
	append(vertex_data, f32(offset_y) + vert_offset_y)
	append(vertex_data, f32(offset_z) + vert_offset_z)


	append(normal_data, 0.0)
	append(normal_data, 0.0)
	append(normal_data, 0.0)


}


chunk_update :: proc(chunk: ^Chunk, atlas_texture: ^rl.Texture2D) {


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

					blocks_num: f32 = 3.0


					gen_triangle(&vertex_data, &normal_data, x, y, z, 0, 1, 2)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 0.0)

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 1.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 0, 3, 2)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))


					append(&texcoord_data, 0.0)


					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 0.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)

					gen_triangle(&vertex_data, &normal_data, x, y, z, 0, 1, 5)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 0.0)

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 1.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 0, 4, 5)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))


					append(&texcoord_data, 0.0)


					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 0.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 1, 2, 6)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 0.0)

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 1.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 1, 5, 6)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))


					append(&texcoord_data, 0.0)


					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 0.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 3, 0, 4)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 0.0)

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 1.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 3, 7, 4)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))


					append(&texcoord_data, 0.0)


					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 0.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 6, 7, 4)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 0.0)

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 1.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 6, 5, 4)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))


					append(&texcoord_data, 0.0)


					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 0.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 3, 2, 6)
					tri_count += 1
					vertex_count += 3

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 0.0)

					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))
					append(&texcoord_data, 1.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)


					gen_triangle(&vertex_data, &normal_data, x, y, z, 3, 7, 6)
					tri_count += 1
					vertex_count += 3


					append(&texcoord_data, (1.0 / blocks_num) * (f32(block_id) - 1.0))


					append(&texcoord_data, 0.0)


					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 0.0)

					append(
						&texcoord_data,
						(1.0 / blocks_num) * (f32(block_id) - 1.0) + (1.0 / blocks_num),
					)
					append(&texcoord_data, 1.0)

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

	chunk.model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = atlas_texture^


}

delete_chunk :: proc(chunk: Chunk) {
	rl.UnloadModel(chunk.model)

	delete(chunk.block_data)

}
