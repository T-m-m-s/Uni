import random
import time
from typing import List

def counting_sort(arr: List[int]) -> List[int]:
    if not arr:
        return arr
    min_val = min(arr)
    max_val = max(arr)
    count = [0] * (max_val - min_val + 1)
    for num in arr:
        count[num - min_val] += 1
    output = []
    for i, c in enumerate(count):
        output.extend([i + min_val] * c)
    return output