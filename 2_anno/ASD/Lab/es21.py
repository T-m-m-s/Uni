class Node:
    def __init__(self, key, value):
        self.key = key
        self.value = value
        self.left = None
        self.right = None
        self.height = 1  # altezza del sottoalbero radicato qui

class BST:
    def __init__(self):
        self.root = None
        self._height = 0  # altezza dell'albero, aggiornata ad ogni modifica

    def insert(self, key, value):
        def _insert(node, key, value):
            if not node:
                return Node(key, value), True
            if key < node.key:
                node.left, changed = _insert(node.left, key, value)
            elif key > node.key:
                node.right, changed = _insert(node.right, key, value)
            else:
                node.value = value
                changed = False
            node.height = 1 + max(self._get_height(node.left), self._get_height(node.right))
            return node, changed

        self.root, changed = _insert(self.root, key, value)
        self._height = self._get_height(self.root)

    def remove(self, key):
        def _min_value_node(node):
            current = node
            while current.left:
                current = current.left
            return current

        def _remove(node, key):
            if not node:
                return node, False
            if key < node.key:
                node.left, changed = _remove(node.left, key)
            elif key > node.key:
                node.right, changed = _remove(node.right, key)
            else:
                if not node.left:
                    return node.right, True
                elif not node.right:
                    return node.left, True
                temp = _min_value_node(node.right)
                node.key, node.value = temp.key, temp.value
                node.right, _ = _remove(node.right, temp.key)
                changed = True
            if node:
                node.height = 1 + max(self._get_height(node.left), self._get_height(node.right))
            return node, changed

        self.root, changed = _remove(self.root, key)
        self._height = self._get_height(self.root)

    def find(self, key):
        node = self.root
        while node:
            if key < node.key:
                node = node.left
            elif key > node.key:
                node = node.right
            else:
                return node.value
        return None

    def clear(self):
        self.root = None
        self._height = 0

    def height(self):
        return self._height

    def show(self):
        def _show(node):
            if not node:
                return "NULL"
            s = f"{node.key}:{node.value}:{node.height}"
            left = _show(node.left)
            right = _show(node.right)
            return f"{s} {left} {right}"
        print(_show(self.root))

    def _get_height(self, node):
        return node.height if node else 0

bst = BST()
while True:
    try:
        cmd = input().strip()
    except EOFError:
        break
    if not cmd:
        continue
    parts = cmd.split()
    if parts[0] == "insert" and len(parts) >= 3:
        k = int(parts[1])
        v = " ".join(parts[2:])
        bst.insert(k, v)
    elif parts[0] == "remove" and len(parts) == 2:
        k = int(parts[1])
        bst.remove(k)
    elif parts[0] == "find" and len(parts) == 2:
        k = int(parts[1])
        res = bst.find(k)
        if res is not None:
            print(res)
    elif parts[0] == "clear":
        bst.clear()
    elif parts[0] == "show":
        bst.show()
    elif parts[0] == "height":
        print(bst.height())
    else:
        break
