const std = @import("std");

// Very simple build system, get a C file out of a zig file, then `make` the rest
//  This is partly because Zig 

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(
        .{
            .cpu_arch = .mips,
            .os_tag = .freestanding,
            .abi = .gnu,
            .cpu_model = .{
                .explicit = &std.Target.mips.cpu.mips2
            },
            .ofmt = .c,
        }
    );

    const obj = b.addObject(.{
        .name = "game",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
        }),
    });

    obj.addIncludePath(b.path("include"));
    obj.addIncludePath(b.path("src"));

    obj.addSystemIncludePath(.{
        .cwd_relative = "/usr/mips64-elf/include",
    });

    obj.linkLibC();

    const install_c = b.addInstallFile(
        obj.getEmittedBin(),
        "main.c",
    );

    b.getInstallStep().dependOn(&install_c.step);
}