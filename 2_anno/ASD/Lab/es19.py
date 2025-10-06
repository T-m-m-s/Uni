class Node:
    def __init__(self, key, left=None, right=None):
        self.key = key
        self.left = left
        self.right = right

def parse(tokens):
    val = next(tokens)
    if val == "NULL":
        return None
    node = Node(int(val))
    node.left = parse(tokens)
    node.right = parse(tokens)
    return node

def check_bst_avl(node):
    # Returns: (is_bst, is_avl, min_key, max_key, height)
    if node is None:
        return (True, True, float('inf'), float('-inf'), 0)
    l_bst, l_avl, l_min, l_max, l_h = check_bst_avl(node.left)
    r_bst, r_avl, r_min, r_max, r_h = check_bst_avl(node.right)
    is_bst = l_bst and r_bst and (l_max < node.key < r_min)
    is_avl = l_avl and r_avl and abs(l_h - r_h) <= 1
    min_key = min(l_min, node.key)
    max_key = max(r_max, node.key)
    height = 1 + max(l_h, r_h)
    return (is_bst, is_avl, min_key, max_key, height)

seq = input().strip().split()
root = parse(iter(seq))
is_bst, is_avl, _, _, _ = check_bst_avl(root)
if not is_bst:
    print(0)
elif is_avl:
    print(2)
else:
    print(1)
