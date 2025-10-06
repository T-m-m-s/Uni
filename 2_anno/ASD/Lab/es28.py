import math

def arbitrage(n, edges):
    graph = [[] for _ in range(n)]
    for u, v, rate in edges:
        if 0 <= u < n and 0 <= v < n:
            graph[u].append((v, -math.log(rate)))

    for start in range(n):
        dist = [float('inf')] * n
        pred = [-1] * n
        dist[start] = 0

        for _ in range(n-1):
            for u in range(n):
                for v, w in graph[u]:
                    if dist[u] + w < dist[v]:
                        dist[v] = dist[u] + w
                        pred[v] = u

        for u in range(n):
            for v, w in graph[u]:
                if dist[u] + w < dist[v]:
                    cycle = []
                    x = v
                    for _ in range(n):
                        x = pred[x]
                    cycle_start = x
                    cycle = [cycle_start]
                    x = pred[cycle_start]
                    while x != cycle_start:
                        cycle.append(x)
                        x = pred[x]
                    cycle.reverse()
                    # Rimuovi eventuale duplicato finale
                    if cycle[0] == cycle[-1]:
                        cycle.pop()
                    return cycle
    return []

tokens = input().split()
n = int(tokens[0])
edges = []
i = 1
while i < len(tokens):
    u = int(tokens[i])
    v = int(tokens[i+1])
    rate = float(tokens[i+2])
    edges.append((u, v, rate))
    i += 3
cycle = arbitrage(n, edges)
if cycle:
    print(' '.join(map(str, cycle)))
else:
    print("WAIT FOR REAL TESTS!")