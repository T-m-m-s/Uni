def scanArray():
    tokens = input().split(' ')
    return [int(x) for x in tokens if x]

def majority_n2(V):
    n = len(V)
    for i in range(n):
        count = 0
        for j in range(n):
            if V[j] == V[i]:
                count += 1
        if count > n // 2:
            return V[i]
    return "No majority"

def majority_nlogn(V):
    if not V:
        return "No majority"
    
    V.sort()
    count = 1
    majority_count = len(V) // 2
    
    for i in range(1, len(V)):
        if V[i] == V[i - 1]:
            count += 1
            if count > majority_count:
                return V[i]
        else:
            count = 1
    
    return "No majority"

def majority_nk(V):
    if not V:
        return "No majority"
    
    k = max(V)  # Assuming all values are in the range [0, k]
    count = [0] * (k + 1)
    
    for num in V:
        count[num] += 1
    
    majority_count = len(V) // 2
    for i in range(len(count)):
        if count[i] > majority_count:
            return i
    
    return "No majority"

def majority_n(V):
    candidate = None
    count = 0

    for num in V:
        if count == 0:
            candidate = num
            count = 1
        elif num == candidate:
            count += 1
        else:
            count -= 1

    # Verify if the candidate is actually the majority element
    if V.count(candidate) > len(V) // 2:
        return candidate
    else:
        return "No majority"
    
V = scanArray()
res = majority_n(V)
print(res)