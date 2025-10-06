import heapq

def quickselect(arr, k):
    def partition(left, right):
        pivot = arr[right]
        i = left
        for j in range(left, right):
            if arr[j] < pivot:
                arr[i], arr[j] = arr[j], arr[i]
                i += 1
        arr[i], arr[right] = arr[right], arr[i]
        return i

    def select(left, right, k_smallest):
        if left == right:
            return arr[left]
        pivot_index = partition(left, right)
        if k_smallest == pivot_index:
            return arr[k_smallest]
        elif k_smallest < pivot_index:
            return select(left, pivot_index - 1, k_smallest)
        else:
            return select(pivot_index + 1, right, k_smallest)

    return select(0, len(arr) - 1, k - 1)

def kth_smallest_heap(arr, k):
    n = len(arr)
    if k < 1 or k > n:
        raise ValueError("k fuori range")
    # H1: min-heap degli elementi (valore, indice)
    H1 = [(val, idx) for idx, val in enumerate(arr)]
    heapq.heapify(H1)
    # H2: heap ausiliaria con indici, confronta tramite valore in H1
    H2 = []
    heapq.heappush(H2, (arr[0], 0))  # inizia dal minimo (radice)
    visited = set([0])
    result = None
    for _ in range(k):
        result, idx = heapq.heappop(H2)
        left = 2 * idx + 1
        right = 2 * idx + 2
        if left < n and left not in visited:
            heapq.heappush(H2, (arr[left], left))
            visited.add(left)
        if right < n and right not in visited:
            heapq.heappush(H2, (arr[right], right))
            visited.add(right)
    return result

def median_of_medians(arr, k):
    def select(lst, k):
        if len(lst) <= 5:
            return sorted(lst)[k-1]
        # Dividi in blocchi di 5
        chunks = [lst[i:i+5] for i in range(0, len(lst), 5)]
        medians = [sorted(chunk)[len(chunk)//2] for chunk in chunks]
        median = select(medians, (len(medians)+1)//2)
        # Partition attorno alla mediana
        lows = [el for el in lst if el < median]
        highs = [el for el in lst if el > median]
        pivots = [el for el in lst if el == median]
        if k <= len(lows):
            return select(lows, k)
        elif k <= len(lows) + len(pivots):
            return median
        else:
            return select(highs, k - len(lows) - len(pivots))
    return select(arr, k)

if __name__ == "__main__":
    arr = list(map(int, input().split()))
    k = int(input())
    #print(quickselect(arr, k))
    #print(kth_smallest_heap(arr, k))
    print(median_of_medians(arr, k))