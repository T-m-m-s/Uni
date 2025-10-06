#Implementazione dell'algoritmo di QuickSelect
#Complessità nel caso medio theta(n), complessità nel caso peggiore theta(n^2)

#Procedura di Partition che prende come perno l'ultimo elemento e riarrangia l'array in modo che 
#tutti gli elementi prima del perno siano minore e quelli dopo siano maggiori del perno.
# @param A: array su cui lavorare
# @param p: indice della prima posizione dell'array
# @param q: indice dell'ultima posizione dell'array

def Partition(A,p,q): 
	x = A[q]
	i = p-1
	j=p
	for j in range (p,q): 
		if A[j] <= x: 
			i += 1 
			A[i],A[j] = A[j],A[i]
	A[i+1],A[q] = A[q],A[i+1]
	return i+1

#Procedura che preso in input un array restituisce L'i-esimo elemento più piccolo dell'array
# @param A: array su cui lavorare
# @param p: indice del primo elemento dell'array
# @param q: indice del ultimo elemento dell'array
# @param i: indice della posizione a cui si è interessati, alla fine restituirà l'elemento 
#			che si troverebbe in questa posizione se l'array fosse ordinato 

def QuickSelect(A,p,q,i): 
		if i<p or i>q: 
			return None
		if p==q==i: 
			return A[p]
		else: 
			r = Partition(A,p,q)
			if i==r: 
				return A[r]
			elif i<r:
				return QuickSelect(A,p,r-1,i) 
			else: 
				return QuickSelect(A,r+1,q,i)

#input e output

array = [int(x) for x in input().split(" ") if x]
index = int(input())
A = QuickSelect(array,0,len(array)-1,index-1)
print(A)
