class Node:
    def __init__(self, key, value, color="red"):
        self.key = key
        self.value = value
        self.color = color  # "red" or "black"
        self.left = None
        self.right = None
        self.parent = None

class RedBlackTree:
    def __init__(self):
        self.NIL = Node(None, None, color="black")  # Sentinel NIL node
        self.root = self.NIL

    def insert(self, key, value):
        new_node = Node(key, value, color="red")
        new_node.left = self.NIL
        new_node.right = self.NIL
        parent = None
        current = self.root

        while current != self.NIL:
            parent = current
            if key < current.key:
                current = current.left
            elif key > current.key:
                current = current.right
            else:
                current.value = value
                return

        new_node.parent = parent
        if parent is None:
            self.root = new_node
        elif key < parent.key:
            parent.left = new_node
        else:
            parent.right = new_node

        self._fix_insert(new_node)

    def _fix_insert(self, z):
        while z.parent and z.parent.color == "red":
            if z.parent == z.parent.parent.left:
                y = z.parent.parent.right
                if y and y.color == "red":
                    z.parent.color = "black"
                    y.color = "black"
                    z.parent.parent.color = "red"
                    z = z.parent.parent
                else:
                    if z == z.parent.right:
                        z = z.parent
                        self._rotate_left(z)
                    z.parent.color = "black"
                    z.parent.parent.color = "red"
                    self._rotate_right(z.parent.parent)
            else:
                y = z.parent.parent.left
                if y and y.color == "red":
                    z.parent.color = "black"
                    y.color = "black"
                    z.parent.parent.color = "red"
                    z = z.parent.parent
                else:
                    if z == z.parent.left:
                        z = z.parent
                        self._rotate_right(z)
                    z.parent.color = "black"
                    z.parent.parent.color = "red"
                    self._rotate_left(z.parent.parent)
        self.root.color = "black"

    def _rotate_left(self, x):
        y = x.right
        x.right = y.left
        if y.left != self.NIL:
            y.left.parent = x
        y.parent = x.parent
        if x.parent is None:
            self.root = y
        elif x == x.parent.left:
            x.parent.left = y
        else:
            x.parent.right = y
        y.left = x
        x.parent = y

    def _rotate_right(self, x):
        y = x.left
        x.left = y.right
        if y.right != self.NIL:
            y.right.parent = x
        y.parent = x.parent
        if x.parent is None:
            self.root = y
        elif x == x.parent.right:
            x.parent.right = y
        else:
            x.parent.left = y
        y.right = x
        x.parent = y

    def find(self, key):
        node = self.root
        while node != self.NIL:
            if key < node.key:
                node = node.left
            elif key > node.key:
                node = node.right
            else:
                return node.value
        return None

    def clear(self):
        self.root = self.NIL

    def show(self):
        def _show(node):
            if node == self.NIL:
                return "NULL"
            s = f"{node.key}:{node.value}:{node.color}"
            left = _show(node.left)
            right = _show(node.right)
            return f"{s} {left} {right}"
        print(_show(self.root))

rbt = RedBlackTree()
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
        rbt.insert(k, v)
    elif parts[0] == "find" and len(parts) == 2:
        k = int(parts[1])
        res = rbt.find(k)
        if res is not None:
            print(res)
    elif parts[0] == "clear":
        rbt.clear()
    elif parts[0] == "show":
        rbt.show()
    else:
        break