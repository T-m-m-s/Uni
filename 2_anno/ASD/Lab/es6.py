def ricerca_dicotomica_ricorsiva(a, key, i, j):  # [i, j] intervallo di ricerca per la chiave
    if i > j:
        return -1
    mid = (i + j) // 2
    if a[mid] == key:
        return mid
    elif a[mid] < key:
        return ricerca_dicotomica_ricorsiva(a, key, mid + 1, j)
    else:
        return ricerca_dicotomica_ricorsiva(a, key, i, mid - 1)
    
print('Inserire un array ordinato')
line = input()
tokens = line.split(' ')
a = [int(x) for x in tokens if x != '']

print('Inserire il valore da cercare')
key = int(input())

pos = ricerca_dicotomica_ricorsiva(a, key, 0, len(a) - 1)
print(pos)