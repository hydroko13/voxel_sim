package main

import "core:fmt"

import rl "vendor:raylib"


main :: proc() {

	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	
	rl.InitWindow(1280, 720, "Voxel Sim")

	defer rl.CloseWindow()


	rl.MaximizeWindow()

	gameRenderTexture := rl.LoadRenderTexture(1280, 720)

	defer rl.UnloadRenderTexture(gameRenderTexture)

	camera := rl.Camera3D{position = {0, 64, 0}, target = {1, 64, 0}, up = {0, 1, 0}, fovy = 80.0, projection = .PERSPECTIVE}

	world_chunks := make([dynamic]Chunk, 0, 25 * 25)

	defer delete(world_chunks)


	for x in 0..<25 {
		for z in 0..<25 {
			chunk, ok := new_chunk(0, 0)
			if ok {
				chunk_generate(chunk)
				append(&world_chunks, chunk)
				
			}
			
		}	
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

		rl.DrawCube({8.0, 60.5, 0.0}, 2.0, 2.0, 2.0, rl.RED)
		
		rl.EndMode3D()
		
		rl.DrawFPS(20, 20)	
		
		rl.EndTextureMode()
		
		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)


		rl.DrawTexturePro(gameRenderTexture.texture, rl.Rectangle{x = 0.0, y = 720.0, width = 1280.0, height = -720.0}, rl.Rectangle{x = 0.0, y = 0.0, width = f32(rl.GetRenderWidth()), height = f32(rl.GetRenderHeight())}, rl.Vector2{0, 0}, 0.0, rl.WHITE)

		

		
		
		rl.EndDrawing()
	}
	
}