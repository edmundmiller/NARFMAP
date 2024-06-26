const std = @import("std");

const c = @cImport({
    @cDefine("__cplusplus", "201703L");
    @cDefine("BOOST_ALL_NO_LIB", {});
    @cInclude("GenHashTableWorkflow.hpp");
});

pub fn main() void {
    // Example usage of functions from the C++ header
    const fullPath = c.dragenos.workflow.GetFullPath("some/path");
    std.debug.print("Full path: {s}\n", .{fullPath});

    // Example of using the HashTableType enum
    c.dragenos.workflow.HT_TYPE_NORMAL;

    // You would need to create DragenOsOptions and hashTableConfig_t structs
    // to use functions like SetBuildHashTableOptions
    // var opts: c.options.DragenOsOptions = undefined;
    // var config: c.hashTableConfig_t = undefined;
    // c.dragenos.workflow.SetBuildHashTableOptions(&opts, &config, hashType);

    // Call other functions as needed
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
