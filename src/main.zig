const std = @import("std");

const dragen = @cImport({
    @cInclude("gen_hash_table.c");
    @cInclude("hash_table_compress.c");
});

pub fn main() void {
    const result = dragen.ComputeEndPadding(32, 6400);
    std.debug.print("Result: {}\n", .{result});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
