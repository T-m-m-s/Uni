class Node:
    def __init__(self, key):
        self.key = key
        self.left = None
        self.right = None

def parse_tree(tokens):
    val = next(tokens)
    if val == "NULL":
        return None
    node = Node(int(val))
    node.left = parse_tree(tokens)
    node.right = parse_tree(tokens)
    return node

def is_bst(node, min_key=float('-inf'), max_key=float('inf'), seen=None):
    if seen is None:
        seen = set()
    if node is None:
        return True
    if not (min_key < node.key < max_key):
        return False
    if node.key in seen:
        return False
    seen.add(node.key)
    return (is_bst(node.left, min_key, node.key, seen) and
            is_bst(node.right, node.key, max_key, seen))


seq = input().strip().split()
tokens = iter(seq)
root = parse_tree(tokens)
print(1 if is_bst(root) else 0)