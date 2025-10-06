def scanArray():
    tokens = input().split(' ')
    return [int(x) for x in tokens if x]

def max_diff_n2(V):
    n = len(V)
    max_diff = float('-inf')
    best_i, best_j = 0, 0
    for i in range(n):
        for j in range(i, n):
            diff = V[j] - V[i]
            if diff > max_diff:
                max_diff = diff
                best_i, best_j = i, j
    return best_i, best_j

def max_diff_n(V):
    min_val = V[0]
    min_idx = 0
    max_diff = float('-inf')
    best_i, best_j = 0, 0
    for j in range(1, len(V)):
        if V[j] - min_val > max_diff:
            max_diff = V[j] - min_val
            best_i, best_j = min_idx, j
        if V[j] < min_val:
            min_val = V[j]
            min_idx = j
    if max_diff < 0:
        max_idx = V.index(max(V))
        return max_idx, max_idx
    return best_i, best_j
 
V = scanArray()
i, j = max_diff_n(V)
print(i, j)