const std = @import("std");
const html_dir = @import("config").html_dir;

test "validate HTML" {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const allocator = debug_allocator.allocator();

    try std.testing.expect(html_dir.len > 0);

    var child = std.process.Child.init(&.{
        "vnu",
        "--Werror",
        "--filterpattern",
        ".*Trailing slash.*",
        "--skip-non-html",
        html_dir,
    }, allocator);

    try std.testing.expectEqual(std.process.Child.Term{ .Exited = 0 }, try child.spawnAndWait());
}

test "validate CSS" {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const allocator = debug_allocator.allocator();

    try std.testing.expect(html_dir.len > 0);

    var child = std.process.Child.init(&.{
        "vnu",
        "--Werror",
        "--skip-non-css",
        html_dir,
    }, allocator);

    try std.testing.expectEqual(std.process.Child.Term{ .Exited = 0 }, try child.spawnAndWait());
}

test "check links" {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    var arena = std.heap.ArenaAllocator.init(debug_allocator.allocator());
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    try std.testing.expect(html_dir.len > 0);
    var dir = try std.fs.cwd().openDir(html_dir, .{ .iterate = true });
    defer dir.close();
    var walker = try dir.walk(arena_allocator);

    var client = std.http.Client{ .allocator = arena_allocator };
    defer client.deinit();

    // Go through html_dir one HTML file at a time.
    while (try walker.next()) |entry| switch (entry.kind) {
        .file => {
            if (!std.mem.endsWith(u8, entry.basename, ".html")) continue;

            const file = try dir.openFile(entry.path, .{});
            defer file.close();
            const stat = try file.stat();
            var content = try file.readToEndAlloc(arena_allocator, stat.size);

            // Go through HTML file one link at a time.
            const link_prefix = "href=\""; // from href="
            const link_suffix = "\""; // to "
            while (std.mem.indexOf(u8, content, link_prefix)) |prefix_start| {
                const start = prefix_start + link_prefix.len;
                const end = std.mem.indexOfPos(u8, content, start, link_suffix).?;
                const link = content[start..end];

                std.debug.assert(link.len > 0);

                if (!std.mem.startsWith(u8, link, "mailto:")) {
                    // If it starts with HTTP, we'll see if we get a 200 back. Otherwise, we assume
                    // it's a relative path so we check the file exists.
                    if (std.mem.startsWith(u8, link, "http")) {
                        const uri = try std.Uri.parse(link);
                        var request = try client.request(.GET, uri, .{});
                        defer request.deinit();
                        try request.sendBodiless();
                        const response = try request.receiveHead(&.{});
                        const status = response.head.status;
                        if (status != std.http.Status.ok) {
                            std.debug.print("GET to '{s}' returned {d}\n", .{ link, status });
                            return error.LinkNotOk;
                        }
                    } else {
                        entry.dir.access(link, .{}) catch |e| switch (e) {
                            error.FileNotFound => {
                                std.debug.print("Relative link '{s}' not in prefix\n", .{link});
                                return e;
                            },
                            else => return e,
                        };
                    }
                }

                // Shrink the slice as we go to exclude the previous links.
                content = content[end + link_suffix.len .. content.len];
            }
        },
        .directory => {},
        else => unreachable,
    };
}
