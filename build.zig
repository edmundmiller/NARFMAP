const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const make_target = b.option([]const u8, "make_target", "Makefile Target") orelse "all";
    const make_cmd = b.addSystemCommand(&.{"make"});
    make_cmd.addArgs(&.{make_target});
    make_cmd.setName(b.fmt("make {s}", .{make_target}));

    b.getInstallStep().dependOn(&b.addInstallFileWithDir(output, .prefix, "word.txt").step);
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const all_step = createMakeStep(b, "all", "Build all targets");
    b.default_step.dependOn(&all_step.step);

    const exe = b.addExecutable(.{
        .name = "NARFMAP",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}

fn createMakeStep(b: *std.Build, target: []const u8, description: []const u8) *std.Build.Step.Run {
    const make_cmd = b.addSystemCommand(&.{"make"});
    make_cmd.addArgs(&.{target});
    make_cmd.setName(b.fmt("make {s}", .{target}));
    make_cmd.step.description = description;
    return make_cmd;
}
