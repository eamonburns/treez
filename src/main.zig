const std = @import("std");
const Io = std.Io;

const Tree = @import("Tree");

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;

    var tree: Tree = .init;
    defer tree.deinit(gpa);

    _ = try tree.createNode(gpa, 45);

    const a = try tree.createNode(gpa, -10);
    const b = try tree.createNode(gpa, 89_000);
    const c = try tree.createNode(gpa, 2);

    tree.rootPtr().left = a;
    tree.rootPtr().right = b;
    tree.nodePtr(a).left = c;

    std.debug.print("{f}", .{tree});
}
