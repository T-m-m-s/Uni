def printArray(a):
    print(a, end=" ")

def scanArray():
    tokens = input().split(' ')
    return [int(x) for x in tokens if x]

def soluzione_n2(V, I):
    n = len(V)
    for i in range(n):
        for j in range(i+1, n):
            if V[i] + V[j] == I:
                print(i, j)
                return
    print(-1, -1)

def soluzione_nlogn(V, I):
    n = len(V)
    for i in range(n):
        left = i + 1
        right = n - 1
        while left <= right:
            mid = (left + right) // 2
            if V[i] + V[mid] == I:
                print(i, mid)
                return
            elif V[i] + V[mid] < I:
                left = mid + 1
            else:
                right = mid - 1
    print(-1, -1)

def soluzione_n(V, I):
    left = 0
    right = len(V) - 1
    while left < right:
        s = V[left] + V[right]
        if s == I:
            print(left, right)
            return
        elif s < I:
            left += 1
        else:
            right -= 1
    print(-1, -1)

V = scanArray()
I = int(input())

# soluzione_n2(V, S)
# soluzione_nlogn(V, S)
soluzione_n(V, I)
