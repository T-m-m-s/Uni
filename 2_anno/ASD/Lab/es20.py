class Node:
    def __init__(self, key, value):
        self.key = key
        self.value = value
        self.left = None
        self.right = None

class BST:
    def __init__(self):
        self.root = None

    def insert(self, key, value):
        def _insert(node, key, value):
            if node is None:
                return Node(key, value)
            if key < node.key:
                node.left = _insert(node.left, key, value)
            elif key > node.key:
                node.right = _insert(node.right, key, value)
            return node
        self.root = _insert(self.root, key, value)

    def find(self, key):
        def _find(node, key):
            if node is None:
                return None
            if key == node.key:
                return node.value
            elif key < node.key:
                return _find(node.left, key)
            else:
                return _find(node.right, key)
        return _find(self.root, key)

    def remove(self, key):
        def _remove(node, key):
            if node is None:
                return None
            if key < node.key:
                node.left = _remove(node.left, key)
            elif key > node.key:
                node.right = _remove(node.right, key)
            else:
                # Nodo trovato
                if node.left is None:
                    return node.right
                if node.right is None:
                    return node.left
                # Nodo con due figli: trova il minimo nel sottoalbero destro
                min_larger_node = node.right
                while min_larger_node.left:
                    min_larger_node = min_larger_node.left
                node.key, node.value = min_larger_node.key, min_larger_node.value
                node.right = _remove(node.right, min_larger_node.key)
            return node
        self.root = _remove(self.root, key)

    def clear(self):
        self.root = None

    def show(self):
        def _show(node):
            if node is None:
                return "NULL"
            left = _show(node.left)
            right = _show(node.right)
            return f"{node.key}:{node.value} {left} {right}"
        return _show(self.root)

bst = BST()
while True:
    try:
        line = input()
    except EOFError:
        break
    if not line.strip():
        continue
    parts = line.strip().split()
    if not parts:
        continue
    cmd = parts[0]
    if cmd == "insert" and len(parts) >= 3:
        k = int(parts[1])
        v = " ".join(parts[2:])
        bst.insert(k, v)
    elif cmd == "remove" and len(parts) == 2:
        k = int(parts[1])
        bst.remove(k)
    elif cmd == "find" and len(parts) == 2:
        k = int(parts[1])
        res = bst.find(k)
        if res is not None:
            print(res)
    elif cmd == "clear":
        bst.clear()
    elif cmd == "show":
        print(bst.show())
    else:
        break