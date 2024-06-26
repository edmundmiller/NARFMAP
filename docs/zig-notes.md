https://github.com/blark/mmdvmhost-zig/blob/main/build.zig
https://zig.news/kristoff/compile-a-c-c-project-with-zig-368j

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create steps for various make targets
    const all_step = createMakeStep(b, "all", "Build all targets");
    b.default_step.dependOn(&all_step.step);

    const clean_step = b.step("clean", "Clean the project");
    clean_step.dependOn(&createMakeStep(b, "clean", "Cleaning project").step);

    const help_step = b.step("help", "Show Makefile help");
    help_step.dependOn(&createMakeStep(b, "help", "Showing Makefile help").step);

    const install_step = b.step("install", "Install the project");
    install_step.dependOn(&createMakeStep(b, "install", "Installing project").step);

    // Add any other Makefile targets you want to expose
}

fn createMakeStep(b: *std.Build, target: []const u8, description: []const u8) *std.Build.Step.Run {
    const make_cmd = b.addSystemCommand(&.{"make"});
    make_cmd.addArgs(&.{target});
    make_cmd.setName(b.fmt("make {s}", .{target}));
    make_cmd.step.description = description;
    return make_cmd;
}
```

## external programs

https://ziglang.org/learn/build-system/

```zig
pub fn build(b: *std.Build) void {
    const lang = b.option([]const u8, "language", "language of the greeting") orelse "en";
    const tool_run = b.addSystemCommand(&.{"jq"});
    tool_run.addArgs(&.{
        b.fmt(
            \\.["{s}"]
        , .{lang}),
        "-r", // raw output to omit quotes around the selected string
    });
    tool_run.addFileArg(b.path("words.json"));

    const output = tool_run.captureStdOut();

    b.getInstallStep().dependOn(&b.addInstallFileWithDir(output, .prefix, "word.txt").step);

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const install_artifact = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .prefix },
    });
    b.getInstallStep().dependOn(&install_artifact.step);
}
```

## Examples

https://github.com/blark/mmdvmhost-zig/blob/main/build.zig

# Linking

Time to figure out if I can teach the monkey to juggle...

https://stackoverflow.com/questions/76499404/how-to-link-against-a-static-library
https://zig.news/xq/zig-build-explained-part-3-1ima

## Needs a C wrapper

https://github.com/gardc/zig-cpp-interop/blob/main/cpp-src/wrapper.h
https://stackoverflow.com/questions/73467232/how-to-incorporate-the-c-standard-library-into-a-zig-program

# Back to the drawing board

Looked and building the hashmap is actually just a C library already.

I think I can do the alignment writing if that's all and the conversion. I can use HTSlib like [this package](https://github.com/brentp/hts-zig/blob/main/build.zig) for all of the lowerlevel stuff.
