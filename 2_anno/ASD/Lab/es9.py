def scanArray():
    tokens = input().split(' ')
    return [int(x) for x in tokens if x]

def soluzione_n3(V, S):
    n = len(V)
    for i in range(n):
        for j in range(i, n):
            somma = 0
            for k in range(i, j+1):
                somma += V[k]
            if somma == S:
                print(i, j)
                return
    print(-1, -1)

def soluzione_n(V, S):
    n = len(V)
    left = 0
    somma = 0
    for right in range(n):
        somma += V[right]
        while somma > S and left <= right:
            somma -= V[left]
            left += 1
        if somma == S:
            print(left, right)
            return
    print(-1, -1)

V = scanArray()
S = int(input())

# soluzione_n3(V, S)
soluzione_n(V, S)