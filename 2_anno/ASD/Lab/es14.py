class MinHeap:
    def __init__(self):
        self.heap = []

    def build(self, elements):
        self.heap = elements[:]
        for i in range(len(self.heap) // 2, -1, -1):
            self._heapify_down(i)

    def length(self):
        return len(self.heap)

    def getmin(self):
        if not self.heap:
            return None
        return self.heap[0]

    def extract(self):
        if not self.heap:
            return None
        root_value = self.heap[0]
        last_value = self.heap.pop()
        if self.heap:
            self.heap[0] = last_value
            self._heapify_down(0)
        return root_value

    def insert(self, value):
        self.heap.append(value)
        self._heapify_up(len(self.heap) - 1)

    def change(self, index, value):
        if index < 0 or index >= len(self.heap):
            raise IndexError("Index out of bounds")
        old_value = self.heap[index]
        self.heap[index] = value
        if value < old_value:
            self._heapify_up(index)
        else:
            self._heapify_down(index)

    def _heapify_up(self, index):
        while index > 0:
            parent_index = (index - 1) // 2
            if self.heap[index] < self.heap[parent_index]:
                self.heap[index], self.heap[parent_index] = self.heap[parent_index], self.heap[index]
                index = parent_index
            else:
                break

    def _heapify_down(self, index):
        length = len(self.heap)
        while True:
            left_child_index = 2 * index + 1
            right_child_index = 2 * index + 2
            smallest = index

            if left_child_index < length and self.heap[left_child_index] < self.heap[smallest]:
                smallest = left_child_index
            if right_child_index < length and self.heap[right_child_index] < self.heap[smallest]:
                smallest = right_child_index

            if smallest == index:
                break

            self.heap[index], self.heap[smallest] = self.heap[smallest], self.heap[index]
            index = smallest


heap = MinHeap()
while True:
    command = input().strip()
    if not command:
        continue
    parts = command.split()
    op = parts[0]

    if op == 'build':
        elements = list(map(int, parts[1:]))
        heap.build(elements)
        print(' '.join(map(str, heap.heap)))
    elif op == 'length':
        print(heap.length())
        print(' '.join(map(str, heap.heap)))
    elif op == 'getmin':
        print(heap.getmin())
        print(' '.join(map(str, heap.heap)))
    elif op == 'extract':
        heap.extract()
        print(' '.join(map(str, heap.heap)))
    elif op == 'insert':
        if len(parts) < 2:
            print("Missing value for insert")
            continue
        value = int(parts[1])
        heap.insert(value)
        print(' '.join(map(str, heap.heap)))
    elif op == 'change':
        if len(parts) < 3:
            print("Missing index or value for change")
            continue
        index = int(parts[1])
        value = int(parts[2])
        heap.change(index, value)
        print(' '.join(map(str, heap.heap)))
    else:
        break