import random
import time
from typing import List

def quick_sort_3way(arr: List[int]) -> List[int]:
    def sort(a, lo, hi):
        if hi <= lo:
            return
        lt, gt = lo, hi
        pivot = a[lo]
        i = lo + 1
        while i <= gt:
            if a[i] < pivot:
                a[lt], a[i] = a[i], a[lt]
                lt += 1
                i += 1
            elif a[i] > pivot:
                a[i], a[gt] = a[gt], a[i]
                gt -= 1
            else:
                i += 1
        sort(a, lo, lt - 1)
        sort(a, gt + 1, hi)
    a = arr.copy()
    sort(a, 0, len(a) - 1)
    return a