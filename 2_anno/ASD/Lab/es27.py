def justify_text(words, W):
    n = len(words)
    lengths = [[0]*n for _ in range(n)]
    for i in range(n):
        lengths[i][i] = len(words[i])
        for j in range(i+1, n):
            lengths[i][j] = lengths[i][j-1] + 1 + len(words[j])  # +1 per lo spazio

    INF = float('inf')
    cost = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(i, n):
            if lengths[i][j] > W:
                cost[i][j] = INF
            elif j == n-1:
                cost[i][j] = 0
            else:
                cost[i][j] = (W - lengths[i][j])**2

    dp = [INF]*(n+1)
    dp[0] = 0
    prev = [-1]*(n+1)
    for j in range(1, n+1):
        for i in range(j):
            if cost[i][j-1] != INF and dp[i] + cost[i][j-1] < dp[j]:
                dp[j] = dp[i] + cost[i][j-1]
                prev[j] = i

    lines = []
    idx = n
    splits = []
    while idx > 0:
        splits.append(idx)
        idx = prev[idx]
    splits.append(0)  # Assicura che la prima riga inizi da 0
    splits = splits[::-1]
    for i in range(1, len(splits)):
        line = ' '.join(words[splits[i-1]:splits[i]])
        lines.append(line)
    return lines

T = input().strip().split()
W = int(input().strip())
justified = justify_text(T, W)
for line in justified:
    print(line)