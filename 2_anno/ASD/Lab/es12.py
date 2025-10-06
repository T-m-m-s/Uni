def periodo_frazionario_n2(s):
    n = len(s)
    for p in range(1, n + 1):
        ok = True
        for i in range(n):
            if s[i] != s[i % p]:
                ok = False
                break
        if ok:
            return p

def periodo_frazionario_n(s):
    n = len(s)
    pi = [0] * n
    for i in range(1, n):
        j = pi[i - 1]
        while j > 0 and s[i] != s[j]:
            j = pi[j - 1]
        if s[i] == s[j]:
            j += 1
        pi[i] = j
    p = n - pi[-1]
    return p

# Esempio di utilizzo
s = input().strip()
print(periodo_frazionario_n(s))