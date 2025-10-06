def printArray(a):
    print(a, end=" ")

def scanArray():
    tokens = input().split(' ')
    return [int(x) for x in tokens if x]

def preprocessing_per_somma(a):
    c = [0 for i in range(0, len(a) + 1)]
    c[0] = 0
    for k in range(1, len(a) + 1):
        c[k] = c[k - 1] + a[k - 1]
    return c

def calcola_somma_furba(c, i, j):
    return c[j + 1] - c[i]
# -------------------------------------------------------------------------------
class SegmentTree:
    def __init__(self, data):
        self.n = len(data)
        self.size = 1
        while self.size < self.n:
            self.size *= 2
        self.tree = [float('-inf')] * (2 * self.size)
        
        for i in range(self.n):
            self.tree[self.size + i] = data[i]
        for i in range(self.size - 1, 0, -1):
            self.tree[i] = max(self.tree[2 * i], self.tree[2 * i + 1])
    
    def range_max(self, left, right):
        left += self.size
        right += self.size
        max_value = float('-inf')
        while left <= right:
            if left % 2 == 1:
                max_value = max(max_value, self.tree[left])
                left += 1
            if right % 2 == 0:
                max_value = max(max_value, self.tree[right])
                right -= 1
            left //= 2
            right //= 2
        return max_value
# -------------------------------------------------------------------------------
def preprocessing_per_prodotto(a):
    n = len(a)
    prod_prefix = [1] * (n + 1)
    zero_prefix = [0] * (n + 1)
    for k in range(1, n + 1):
        if a[k - 1] == 0:
            prod_prefix[k] = prod_prefix[k - 1]
            zero_prefix[k] = zero_prefix[k - 1] + 1
        else:
            prod_prefix[k] = prod_prefix[k - 1] * a[k - 1]
            zero_prefix[k] = zero_prefix[k - 1]
    return prod_prefix, zero_prefix

def prodotto_intervallo(prod_prefix, zero_prefix, i, j):
    if zero_prefix[j + 1] - zero_prefix[i] > 0:
        return 0
    return prod_prefix[j + 1] // prod_prefix[i]

# -------------------------------------------------------------------------------
a = scanArray()
b = scanArray()
c = preprocessing_per_somma(a)
st = SegmentTree(a)
prod_prefix, zero_prefix = preprocessing_per_prodotto(a)


for k in range(0, len(b), 2):
    i = b[k]
    j = b[k + 1]
    print(calcola_somma_furba(c, i, j), end = " ")

print("\n")

for k in range(0, len(b), 2):
    i = b[k]
    j = b[k + 1]
    print(st.range_max(i, j), end=" ")
    
print("\n")

for k in range(0, len(b), 2):
    i = b[k]
    j = b[k + 1]
    print(prodotto_intervallo(prod_prefix, zero_prefix, i, j), end=" ")