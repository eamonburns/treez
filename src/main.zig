const std = @import("std");
const Io = std.Io;

const Tree = @import("Tree");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    var tree: Tree = .init;
    defer tree.deinit(gpa);
    const ctx: Tree.CreateContext = try .init(&tree, gpa);
    var leaf: Tree.Node.Index = .none;
    try ctx.setRoot(.{
        .data = 45,
        .left = try ctx.newNode(.{
            .data = -10,
            .left = try ctx.newNode(.{ .data = 2, .idx = &leaf }),
        }),
        .right = try ctx.newNode(.{
            .data = 89_000,
        }),
    });

    std.debug.print("{f}", .{tree});

    std.debug.print("leaf: {d}\n", .{@intFromEnum(leaf)});
}
