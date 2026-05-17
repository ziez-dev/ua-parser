const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // --- PCRE2 C library (vendored) ---
    const pcre2_source_root = b.path("include");
    const pcre2_generated_headers = b.addWriteFiles();
    const pcre2_include = pcre2_generated_headers.getDirectory();
    _ = pcre2_generated_headers.addCopyFile(pcre2_source_root.path(b, "pcre2.h.generic"), "pcre2.h");
    _ = pcre2_generated_headers.addCopyFile(pcre2_source_root.path(b, "config.h.generic"), "config.h");
    const pcre2_chartables = pcre2_generated_headers.addCopyFile(pcre2_source_root.path(b, "pcre2_chartables.c.dist"), "pcre2_chartables.c");

    const pcre2_lib = blk: {
        const pcre2_root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .sanitize_c = .off,
        });
        const lib = b.addLibrary(.{
            .name = "pcre2_8",
            .root_module = pcre2_root_module,
        });
        lib.root_module.addIncludePath(pcre2_include);
        lib.root_module.addIncludePath(pcre2_source_root);
        lib.root_module.addCMacro("HAVE_CONFIG_H", "1");
        lib.root_module.addCMacro("PCRE2_CODE_UNIT_WIDTH", "8");
        lib.root_module.addCMacro("PCRE2_STATIC", "1");
        lib.root_module.addCMacro("SUPPORT_UNICODE", "1");
        lib.root_module.addCMacro("SUPPORT_PCRE2_8", "1");
        lib.root_module.addCSourceFiles(.{
            .root = pcre2_source_root,
            .files = &.{
                "pcre2_auto_possess.c",
                "pcre2_chkdint.c",
                "pcre2_compile.c",
                "pcre2_compile_class.c",
                "pcre2_config.c",
                "pcre2_context.c",
                "pcre2_convert.c",
                "pcre2_dfa_match.c",
                "pcre2_error.c",
                "pcre2_extuni.c",
                "pcre2_find_bracket.c",
                "pcre2_maketables.c",
                "pcre2_match.c",
                "pcre2_match_data.c",
                "pcre2_newline.c",
                "pcre2_ord2utf.c",
                "pcre2_pattern_info.c",
                "pcre2_script_run.c",
                "pcre2_serialize.c",
                "pcre2_string_utils.c",
                "pcre2_study.c",
                "pcre2_substitute.c",
                "pcre2_substring.c",
                "pcre2_tables.c",
                "pcre2_ucd.c",
                "pcre2_valid_utf.c",
                "pcre2_xclass.c",
            },
        });
        lib.root_module.addCSourceFile(.{ .file = pcre2_chartables });
        b.installArtifact(lib);
        break :blk lib;
    };

    // --- PCRE2 Zig module (via translate-c) ---
    const pcre2_mod = blk: {
        const pcre2_translate = b.addTranslateC(.{
            .root_source_file = pcre2_include.path(b, "pcre2.h"),
            .target = target,
            .optimize = optimize,
        });
        pcre2_translate.addIncludePath(pcre2_include);
        pcre2_translate.addIncludePath(pcre2_source_root);
        pcre2_translate.defineCMacro("HAVE_CONFIG_H", "1");
        pcre2_translate.defineCMacro("PCRE2_CODE_UNIT_WIDTH", "8");
        pcre2_translate.defineCMacro("PCRE2_STATIC", "1");
        break :blk pcre2_translate.createModule();
    };

    // --- UA parser module ---
    const plugin_mod = b.addModule("ziez-ua-parser", .{
        .root_source_file = b.path("src/root.zig"),
    });
    plugin_mod.addImport("pcre2", pcre2_mod);
    plugin_mod.linkLibrary(pcre2_lib);

    // ── Tests (auto-discover tests/*.test.zig) ──────────────────────────────
    const test_step = b.step("test", "Run tests");
    const io = b.graph.io;

    var test_dir = b.build_root.handle.openDir(io, "tests", .{ .iterate = true }) catch return;
    defer test_dir.close(io);

    var walker = test_dir.walk(b.allocator) catch return;
    defer walker.deinit();

    while (walker.next(io) catch null) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.basename, ".test.zig")) continue;

        const test_path = std.fmt.allocPrint(b.allocator, "tests/{s}", .{entry.path}) catch continue;

        const test_mod = b.createModule(.{
            .root_source_file = b.path(test_path),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "ziez_ua_parser", .module = b.addModule("ziez_ua_parser_test", .{
                    .root_source_file = b.path("src/root.zig"),
                    .imports = &.{.{ .name = "pcre2", .module = pcre2_mod }},
                }) },
            },
        });
        test_mod.linkLibrary(pcre2_lib);

        const unit_test = b.addTest(.{
            .root_module = test_mod,
        });

        const run_unit_test = b.addRunArtifact(unit_test);
        test_step.dependOn(&run_unit_test.step);
    }
}
