const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL3/sdl.h");
});

const MAX_FILENAME_SIZE: comptime_int = 1024;
const MAX_SOURCE_SIZE: comptime_int = 1024;

pub fn read_user_input(
    allocator: std.mem.Allocator,
    max_size: comptime_int
) ![]const u8 {
    const stdin = std.io.getStdIn().reader();
        
    const raw_input = try stdin.readUntilDelimiterAlloc(
        allocator,
        '\n',
        max_size,
    );

    return std.mem.trim(u8, raw_input, "\r");
}

fn read_source_file(
    allocator: std.mem.Allocator,
    file_path: []const u8,
    max_size: comptime_int,
) ![]const u8 {
    return std.fs.cwd().readFileAlloc(
        allocator,
        file_path,
        max_size,
    );
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    
    try std.fmt.format(
        stdout,
        "you're face-to-face with an old training dummy. please input a move!!\n",
        .{ }
    );

    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    const allocator = arena_allocator.allocator();

    var quit: bool = false;

    while(!quit) {
        defer arena_allocator.deinit();

        const user_input = read_user_input(
            allocator,
            MAX_FILENAME_SIZE
        ) catch |err| {
            try std.fmt.format(
                stdout,
                "error when getting user input: {s}\n",
                .{ @errorName(err) }
            );

            continue;
        };

        if(std.mem.eql(u8, user_input, "q")) {
            quit = true;
            continue;
        }

        const file_path = user_input;

        const source_contents = read_source_file(
            allocator,
            file_path,
            MAX_SOURCE_SIZE
        ) catch |err| {
            try std.fmt.format(
                stdout,
                "error when attempting to read file \"{s}\": {s}\n",
                .{ file_path, @errorName(err) }
            );

            continue;
        };

        try std.fmt.format(
            stdout,
            "code:\n{s}\n",
            .{ source_contents }
        );
    }
}

