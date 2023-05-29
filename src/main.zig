const std = @import("std");

pub fn Rope() type {
    return struct {
        const Self = @This();

        const NodeType = enum {
            branch,
            leaf,
        };

        const Node = union(NodeType) { branch: struct {
            weight: usize,
            left: ?*Node,
            right: ?*Node,
        }, leaf: struct {
            weight: usize,
            data: []const u8,
        } };

        gpa: std.mem.Allocator,
        root: ?*Node,

        pub fn init(gpa: std.mem.Allocator) Self {
            return Self{
                .gpa = gpa,
                .root = null,
            };
        }

        pub fn insert(self: *Self, idx: usize, data: []const u8) !void {
            var newNode = try self.gpa.create(Node);
            newNode.*.leaf = .{
                .data = data,
                .weight = data.len,
            };

            if (idx == 0) {
                var newLeaf = try self.gpa.create(Node);
                newLeaf.branch = .{
                    .weight = newNode.leaf.weight,
                    .left = newNode,
                    .right = null,
                };
                self.root = newNode;
            }
        }

        fn printSpaces(depth: usize) void {
            for (0..depth) |_| {
                std.debug.print(" ", .{});
            }
        }

        fn printNode(node: *Node, depth: usize) void {
            printSpaces(depth);

            switch (node.*) {
                .leaf => |leaf| std.debug.print("({}) {s}\n", .{ leaf.weight, leaf.data }),
                .branch => |branch| {
                    std.debug.print("({}):", .{branch.weight});
                    if (branch.left) |left| {
                        printSpaces(depth);
                        std.debug.print("L:\n", .{});
                        printNode(left, depth + 1);
                    }

                    if (branch.right) |right| {
                        printSpaces(depth);
                        std.debug.print("R:\n", .{});
                        printNode(right, depth + 1);
                    }
                },
            }
        }

        pub fn print(self: Self) void {
            if (self.root) |root| {
                printNode(root, 0);
            } else {
                std.debug.print("[EMPTY]\n", .{});
            }
        }
    };
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    var rope = Rope().init(allocator);
    try rope.insert(0, " world");
    try rope.insert(0, "Hello");

    rope.print();

}

test "rope" {
    var rope = Rope().init(std.testing.allocator);
    rope.print();
}
