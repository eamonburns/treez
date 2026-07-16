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

pub const CreateContext = struct {
    tree: *Tree,
    gpa: Allocator,

    // Creates a new tree creation context, clearing the tree's nodes (if it
    // had any), and creating the root node (with undefined data)
    pub fn init(tree: *Tree, gpa: Allocator) Allocator.Error!CreateContext {
        tree.nodes.clearRetainingCapacity();
        // Create root
        _ = try tree.createNode(gpa, undefined); // TODO: Don't use undefined?
        return .{ .tree = tree, .gpa = gpa };
    }

    pub const NewNodeOptions = struct {
        data: i32,
        left: Node.Index = .none,
        right: Node.Index = .none,
        /// A pointer to store the newly created node's index
        idx: ?*Node.Index = null,
    };

    pub fn setRoot(ctx: CreateContext, opts: NewNodeOptions) Allocator.Error!void {
        const r = ctx.tree.rootPtr();
        r.data = opts.data;
        r.left = opts.left;
        r.right = opts.right;
        if (opts.idx) |ptr| ptr.* = @enumFromInt(0);
    }

    pub fn newNode(ctx: CreateContext, opts: NewNodeOptions) Allocator.Error!Node.Index {
        const idx = try ctx.tree.createNode(ctx.gpa, opts.data);
        const n = ctx.tree.nodePtr(idx);
        n.left = opts.left;
        n.right = opts.right;
        if (opts.idx) |ptr| ptr.* = idx;
        return idx;
    }
};
