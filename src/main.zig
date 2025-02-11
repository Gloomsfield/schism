const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL3/sdl.h");
});

var window: *sdl.SDL_Window = undefined;

pub fn main() !void {
    window = sdl.SDL_CreateWindow(
        "meow!",
        640,
        480,
        sdl.SDL_WINDOW_OPENGL
    ) orelse @panic("failed to create SDL window...");

    var quit: bool = false;
    var event: sdl.SDL_Event = undefined;

    while(!quit) {
        while(sdl.SDL_PollEvent(&event) != false) {
            if(event.type == sdl.SDL_EVENT_QUIT) {
                quit = true;
            }
        }
    }

    sdl.SDL_DestroyWindow(window);
    sdl.SDL_Quit();
}

