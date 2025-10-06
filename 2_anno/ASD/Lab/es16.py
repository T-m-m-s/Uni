class Node:
    def __init__(self, key, left=None, right=None):
        self.key = key
        self.left = left
        self.right = right

def parse_polish(tokens, pos):
    if tokens[pos] == "NULL":
        return None, pos + 1
    node = Node(int(tokens[pos]))
    node.left, next_pos = parse_polish(tokens, pos + 1)
    node.right, next_pos = parse_polish(tokens, next_pos)
    return node, next_pos

def inorder(node, result):
    if node is None:
        return
    inorder(node.left, result)
    result.append(node.key)
    inorder(node.right, result)

tokens = input().split()
root, _ = parse_polish(tokens, 0)
result = []
inorder(root, result)
print(" ".join(map(str, result)))