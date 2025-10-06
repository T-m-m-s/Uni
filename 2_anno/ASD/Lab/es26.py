def max_expression(V):
    n = len(V)
    max1 = V[0]
    max2 = float('-inf')
    max3 = float('-inf')
    max4 = float('-inf')

    for i in range(1, n):
        if i >= 3:
            max4 = max(max4, max3 - V[i])
        if i >= 2:
            max3 = max(max3, max2 + V[i])
        if i >= 1:
            max2 = max(max2, max1 - V[i])
        max1 = max(max1, V[i])
    return max4


V = list(map(int, input().split()))
print(max_expression(V))