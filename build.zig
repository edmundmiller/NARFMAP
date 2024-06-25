const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Step 1: Build C++ project using Makefile
    const make_step = b.addSystemCommand(&.{"make"});
    make_step.setName("build-cpp");
    // make_step.step.description = "Building C++ project using Makefile";

    // Step 2: Create Zig executable for the CLI
    const exe = b.addExecutable(.{
        .name = "NARFMAP",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Step 3: Link C++ libraries with Zig executable
    // Assuming the Makefile produces a static library named libdragen.a
    exe.addObjectFile(.{ .path = "build/release/libdragmap-workflow.a" });
    exe.linkLibCpp(); // Link with C++ standard library

    // Add any necessary include directories
    exe.addIncludePath(.{ .path = "src/include/workflow/" });

    // Make sure the C++ build is complete before linking
    exe.step.dependOn(&make_step.step);

    // Install the final executable
    b.installArtifact(exe);

    // Create a run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the NARFMAP CLI");
    run_step.dependOn(&run_cmd.step);

    // TODO
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
