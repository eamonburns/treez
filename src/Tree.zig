const std = @import("std");
const Allocator = std.mem.Allocator;

const Tree = @This();

nodes: std.ArrayList(Node),

pub const init: Tree = .{ .nodes = .empty };

pub fn deinit(tree: *Tree, gpa: Allocator) void {
    tree.nodes.deinit(gpa);
}

pub const Node = struct {
    data: i32,
    left: Index = .none,
    right: Index = .none,

    pub const Index = enum(u32) {
        none = 0,
        _,
    };
};

pub fn createNode(tree: *Tree, gpa: Allocator, value: i32) Allocator.Error!Node.Index {
    const idx: Node.Index = @enumFromInt(@as(u32, @intCast(tree.nodes.items.len)));
    try tree.nodes.append(gpa, .{ .data = value });
    return idx;
}

pub fn root(tree: *const Tree) Node {
    return node(tree, @enumFromInt(0));
}

pub fn rootPtr(tree: *Tree) *Node {
    return nodePtr(tree, @enumFromInt(0));
}

pub fn node(tree: *const Tree, idx: Node.Index) Node {
    return tree.nodes.items[@intFromEnum(idx)];
}

pub fn nodePtr(tree: *Tree, idx: Node.Index) *Node {
    return &tree.nodes.items[@intFromEnum(idx)];
}

pub fn format(
    tree: *const Tree,
    writer: *std.Io.Writer,
) std.Io.Writer.Error!void {
    std.debug.assert(tree.nodes.items.len > 0);

    try tree.printNode(@enumFromInt(0), writer, 0);
}

pub fn printNode(tree: *const Tree, idx: Node.Index, writer: *std.Io.Writer, depth: usize) std.Io.Writer.Error!void {
    const n = tree.node(idx);
    try writer.splatBytesAll("  ", depth);
    try writer.print("[{d}] {d}\n", .{ @intFromEnum(idx), n.data });

    if (n.left != .none) try tree.printNode(n.left, writer, depth + 1);
    if (n.right != .none) try tree.printNode(n.right, writer, depth + 1);
}
