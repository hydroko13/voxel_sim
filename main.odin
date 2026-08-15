package main

import "core:strings"
import "core:os"
import "core:fmt"

import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"


main :: proc() {

	rl.SetConfigFlags({.WINDOW_RESIZABLE})

	rl.InitWindow(960, 540, "Voxel Sim")

	rlgl.DisableBackfaceCulling()
	
	defer rl.CloseWindow()


	rl.MaximizeWindow()

	gameRenderTexture := rl.LoadRenderTexture(1920, 1080)

	defer rl.UnloadRenderTexture(gameRenderTexture)

	camera := rl.Camera3D {
		position   = {200, 64, 0},
		target     = {0, 64, 0},
		up         = {0, 1, 0},
		fovy       = 80.0,
		projection = .PERSPECTIVE,
	}

	// Initialize texture atlas

	tex_atlas_rendertex := rl.LoadRenderTexture(16 * 3, 16)

	defer rl.UnloadRenderTexture(tex_atlas_rendertex)

	blocks_dir_path := "./blocks"

	blocks_dir_handle, open_err := os.open(blocks_dir_path)
	if open_err != os.ERROR_NONE {
		fmt.println("Cant find blocks directory for textures")
		return
	}
	
	defer os.close(blocks_dir_handle)

	file_infos, read_err := os.read_dir(blocks_dir_handle, -1, context.allocator)

	if read_err != os.ERROR_NONE {
		fmt.println("Cant read blocks files for textures")
		return
	}

	defer os.file_info_slice_delete(file_infos, context.allocator)

	block_tex_idx := 0

	for f in file_infos {
		if f.type == .Regular {
			pathstr, err := strings.clone_to_cstring(f.fullpath)
			if err != .None {
				fmt.println("clone to cstring failure")
				return
			}
			tex := rl.LoadTexture(pathstr)
			rl.BeginTextureMode(tex_atlas_rendertex)
			rl.DrawTexturePro(tex, rl.Rectangle{0.0, 0.0, f32(tex.width), f32(tex.height)}, rl.Rectangle{(16.0 * f32(block_tex_idx)), 0.0, 16.0 + (16.0 * f32(block_tex_idx)), 16.0}, {0.0, 0.0}, 0.0, rl.WHITE)
			rl.EndTextureMode()
			delete(pathstr)

			rl.UnloadTexture(tex)
			block_tex_idx += 1
			
		}
	}

	

	

	
	
	
	world_chunks := make([dynamic]Chunk, 0, 25 * 25)

	defer delete(world_chunks)


	for x in -4 ..= 4 {
		for z in -4 ..= 4 {
			chunk := new_chunk(x, z)
			chunk_generate(chunk)
			append(&world_chunks, chunk)


		}
	}

	for &chunk in world_chunks {
		chunk_update(&chunk, &tex_atlas_rendertex.texture)
	}

	defer {
		for chunk in world_chunks {
			delete_chunk(chunk)
		}
	}


	for !rl.WindowShouldClose() {

		rl.BeginTextureMode(gameRenderTexture)

		rl.ClearBackground(rl.SKYBLUE)

		rl.BeginMode3D(camera)

		for chunk in world_chunks {
			chunk_draw(chunk)
		}


		rl.EndMode3D()

		rl.DrawFPS(20, 20)

		rl.EndTextureMode()

		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)


		rl.DrawTexturePro(
			gameRenderTexture.texture,
			rl.Rectangle{x = 0.0, y = 1080.0, width = 1920.0, height = -1080.0},
			rl.Rectangle {
				x = 0.0,
				y = 0.0,
				width = f32(rl.GetRenderWidth()),
				height = f32(rl.GetRenderHeight()),
			},
			rl.Vector2{0, 0},
			0.0,
			rl.WHITE,
		)


		rl.EndDrawing()

		dt := rl.GetFrameTime()

		camera.position.x -= dt * 5

	}

}
