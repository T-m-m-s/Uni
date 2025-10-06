class Node:
    def __init__(self, key, value):
        self.key = key
        self.value = value
        self.left = None
        self.right = None
        self.height = 1

class AVL:
    def __init__(self):
        self.root = None

    def insert(self, key, value):
        def _insert(node, key, value):
            if not node:
                return Node(key, value)
            if key < node.key:
                node.left = _insert(node.left, key, value)
            elif key > node.key:
                node.right = _insert(node.right, key, value)
            else:
                node.value = value
                return node
            node.height = 1 + max(self._get_height(node.left), self._get_height(node.right))
            return self._rebalance(node)
        self.root = _insert(self.root, key, value)

    def remove(self, key):
        def _min_value_node(node):
            current = node
            while current.left:
                current = current.left
            return current

        def _remove(node, key):
            if not node:
                return None
            if key < node.key:
                node.left = _remove(node.left, key)
            elif key > node.key:
                node.right = _remove(node.right, key)
            else:
                if not node.left:
                    return node.right
                elif not node.right:
                    return node.left
                temp = _min_value_node(node.right)
                node.key, node.value = temp.key, temp.value
                node.right = _remove(node.right, temp.key)
            node.height = 1 + max(self._get_height(node.left), self._get_height(node.right))
            return self._rebalance(node)
        self.root = _remove(self.root, key)

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

    def _get_balance(self, node):
        return self._get_height(node.left) - self._get_height(node.right) if node else 0

    def _rebalance(self, node):
        balance = self._get_balance(node)
        # Left heavy
        if balance > 1:
            if self._get_balance(node.left) < 0:
                node.left = self._rotate_left(node.left)
            return self._rotate_right(node)
        # Right heavy
        if balance < -1:
            if self._get_balance(node.right) > 0:
                node.right = self._rotate_right(node.right)
            return self._rotate_left(node)
        return node

    def _rotate_left(self, z):
        y = z.right
        T2 = y.left
        y.left = z
        z.right = T2
        z.height = 1 + max(self._get_height(z.left), self._get_height(z.right))
        y.height = 1 + max(self._get_height(y.left), self._get_height(y.right))
        return y

    def _rotate_right(self, z):
        y = z.left
        T3 = y.right
        y.right = z
        z.left = T3
        z.height = 1 + max(self._get_height(z.left), self._get_height(z.right))
        y.height = 1 + max(self._get_height(y.left), self._get_height(y.right))
        return y

avl = AVL()
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
        avl.insert(k, v)
    elif parts[0] == "remove" and len(parts) == 2:
        k = int(parts[1])
        avl.remove(k)
    elif parts[0] == "find" and len(parts) == 2:
        k = int(parts[1])
        res = avl.find(k)
        if res is not None:
            print(res)
    elif parts[0] == "clear":
        avl.clear()
    elif parts[0] == "show":
        avl.show()
    else:
        break