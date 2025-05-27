const std = @import("std");

const assert = std.debug.assert;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();

    const journal_dir_path = try std.fs.path.join(allocator, &[_][]const u8{
        std.posix.getenv("HOME").?,
        "notes",
        "journal",
    });

    std.debug.print("Journal directory: {s}\n", .{journal_dir_path});

    // Get current date as "YYYY-MM-DD".
    const date_string = try run_cmd(allocator, &[_][]const u8{ "date", "+%Y-%m-%d" });

    std.debug.print("Using date: {s}\n", .{date_string});

    const filename = try std.fmt.allocPrint(allocator, "{s}.md", .{date_string});
    const fullpath = try std.fs.path.join(allocator, &[_][]const u8{ journal_dir_path, filename });

    std.debug.print("Full path: {s}\n", .{fullpath});

    var cwd = std.fs.cwd();

    if (cwd.openDir(journal_dir_path, .{}) catch |err| err == error.FileNotFound) {
        std.debug.print("Journal directory ({s}) does not exist\n", .{journal_dir_path});
        return error.JournalDirNotFound;
    }

    var file_exists = true;
    _ = cwd.openFile(fullpath, .{}) catch |err| {
        if (err == error.FileNotFound) {
            file_exists = false;
        } else {
            return err;
        }
    };

    if (!file_exists) {
        const header = try run_cmd(allocator, &[_][]const u8{
            "date",
            "-d",
            date_string,
            "+# %A, %-d %B %Y",
        });

        std.debug.print("Writing new header to file: {s}\n", .{header});

        const file = try cwd.createFile(fullpath, .{});
        defer file.close();

        try file.writer().print("{s}\n", .{header});
        std.debug.print("Created new file: {s}\n", .{fullpath});
    } else {
        std.debug.print("File already exists, not modifying it\n", .{});
    }

    std.debug.print("Launching nvim...\n", .{});
    var nvim = std.process.Child.init(&[_][]const u8{ "nvim", fullpath }, allocator);
    _ = try nvim.spawnAndWait();
}

/// Run a command in a child subprocess, returning stdout. Fails if processs does not terminate with
/// 0 or if any text is present in stderr.
///
/// The caller is responsible for freeing the returned slice.
fn run_cmd(allocator: std.mem.Allocator, argv: []const []const u8) ![]const u8 {
    var child = std.process.Child.init(argv, allocator);

    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    var stdout: std.ArrayListUnmanaged(u8) = .empty;
    defer stdout.deinit(allocator);
    var stderr: std.ArrayListUnmanaged(u8) = .empty;
    defer stderr.deinit(allocator);

    try child.spawn();
    try child.collectOutput(allocator, &stdout, &stderr, 1024);
    const term = try child.wait();

    // Ensure the process exited normally with code 0
    if (term != .Exited or term.Exited != 0) {
        const command_str = try join_args(allocator, argv);
        defer allocator.free(command_str);
        std.debug.print("Failed to run command: {s}\n", .{command_str});
        return error.ProcessFailed;
    }

    return try allocator.dupe(u8, std.mem.trim(u8, stdout.items, " \n\r\t"));
}

/// Join argv into a single space-separated string, e.g. ["git", "status"] → "git status"
///
/// The caller is responsible for freeing the returned slice.
fn join_args(allocator: std.mem.Allocator, argv: []const []const u8) ![]const u8 {
    assert(argv.len > 0);

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    try list.appendSlice(argv[0]);

    for (argv[1..]) |arg| {
        try list.append(' ');
        try list.appendSlice(arg);
    }

    return list.toOwnedSlice();
}
