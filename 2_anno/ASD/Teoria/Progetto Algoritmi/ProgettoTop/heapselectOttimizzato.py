#HEAPSELECT
#Questo algoritmo di selezione utilizza due min-heap, denominate H1 e H2.
#La prima heap H1 é costruita a partire dal vettore fornito in input in tempo lineare
#e non viene modificata. La seconda heap H2 contiene inizialmente un solo nodo, corrispondente
#alla radice di H1. All'𝑖-esima iterazione, per 𝑖 che va da 1 a 𝑘−1, l'algoritmo estrae la radice di H2,
#che corrisponde a un nodo 𝑥𝑖 in H1, e reinserisce in H2 i nodi successori (figli sinistro e destro) di 𝑥𝑖
#nella heap H1. Dopo 𝑘−1 iterazioni, la radice di H2 corrisponderà al 𝑘-esimo elemento più piccolo del vettore
#fornito in input.
#L'algoritmo descritto ha complessità temporale 𝑂(𝑛+𝑘𝑙𝑜𝑔𝑘) sia nel caso pessimo che in quello medio.
#Per 𝑘 sufficientemente piccolo, quindi, l'algoritmo "heap select" sarà preferibile, almeno nel caso pessimo,
#all'algoritmo "quick select". È possibile implementare una variante che utilizzi opportunamente min-heap
#o max-heap, a seconda del valore di 𝑘.

#------------------------------------------------------------------------------------

#Classe MinHeap: crea una struttura dati minheap partendo da un array.
#Forma quindi un albero con nella radice l'elemento più piccolo.
#Operazioni:
# - length: dimensione della heap
# - getRoot: restituisce il minimo
# - print: stampa gli elementi presenti nella heap
# - extract: estrae la radice dall albero e la restituisce
# - heapify: sistema l'errore che è presente in posizione i spostando l'elemento che sta in i nella posizione adeguata
# - insert: inserisce un nodo
# - buildHeap: partendo da un array a costruisce una min heap che contenga gli elementi dell'array
# - moveUp: scambia una nodo con il padre tante volte quante serve per portarlo nella posizione corretta
# - parent,left,right: restituiscono padre, figlio sx e figlio dx

class MinHeap:
    heap = []

    def length(self):
        return len(self.heap)

    def getRoot(self):
        assert len(self.heap) > 0  # presupponiamo che la heap non sia vuota
        return self.heap[0]  # ritorna elemento minore della heap

    def print(self):
        for i in range(0, self.length()):
            print(self.heap[i], end=" ")

    def extract(self):
        element = self.heap[0]
        self.heap[0] = self.heap[-1]
        self.heap.pop()
        # uguale a : self.heap[0] = self.heap.pop()
        self.heapify(0)
        return element

    def heapify(self, i):
        l = 2 * i + 1
        r = 2 * i + 2
        # prendo il minimo tra heap[i],heap[l] e heap[r]
        argmin = i
        if l < len(self.heap) and self.heap[l] < self.heap[argmin]:
            argmin = l

        if r < len(self.heap) and self.heap[r] < self.heap[argmin]:
            argmin = r

        if i != argmin:
            self.heap[i], self.heap[argmin] = self.heap[argmin], self.heap[i]  # scambio
            self.heapify(argmin)  # ricorsione per ripulire le figlie di argmin

    def insert(self, x):
        self.heap.append(x)
        self.moveUp(len(self.heap) - 1)

    def buildHeap(self, a):
        self.heap = a.copy()
        for i in range(len(self.heap) - 1, -1, -1):  # compreso elemento alla posizione 0, procediamo a ritroso
            self.heapify(i)

        self.heap = [(value, index) for index, value in enumerate(self.heap)]

    def moveUp(self, i):
        if i == 0:
            return
        p = (i + 1) // 2 - 1
        if self.heap[i][0] < self.heap[p][0]:
            self.heap[i], self.heap[p] = self.heap[p], self.heap[i]
            self.moveUp(p)

    def parent(self, i):
        return i // 2

    def left(self, i):
        return 2 * i + 1

    def right(self, i):
        return 2 * i + 2

#------------------------------------------------------------------------------------

#Classe MaxHeap: crea una struttura dati mmaxheap partendo da un array.
#Forma quindi un albero con nella radice l'elemento più grande.
#Operazioni:
# - length: dimensione della heap
# - getRoot: restituisce il minimo
# - print: stampa gli elementi presenti nella heap
# - extract: estrae la radice dall albero e la restituisce
# - heapify: sistema l'errore che è presente in posizione i spostando l'elemento che sta in i nella posizione adeguata
# - insert: inserisce un nodo
# - buildHeap: partendo da un array a costruisce una min heap che contenga gli elementi dell'array
# - moveUp: scambia una nodo con il padre tante volte quante serve per portarlo nella posizione corretta
# - parent,left,right: restituiscono padre, figlio sx e figlio dx


class MaxHeap:
    heap = []

    def length(self):
        return len(self.heap)

    def getRoot(self):
        assert len(self.heap) > 0  # presupponiamo che la heap non sia vuota
        return self.heap[0]  # ritorna elemento minore della heap

    def print(self):
        for i in range(0, self.length()):
            print(self.heap[i], end=" ")

    def extract(self):
        element = self.heap[0]
        self.heap[0] = self.heap[-1]
        self.heap.pop()
        # uguale a : self.heap[0] = self.heap.pop()
        self.heapify(0)
        return element

    def heapify(self, i):
        l = 2 * i + 1
        r = 2 * i + 2
        # prendo il minimo tra heap[i],heap[l] e heap[r]
        argmax = i
        if l < len(self.heap) and self.heap[l] > self.heap[argmax]:
            argmax = l

        if r < len(self.heap) and self.heap[r] > self.heap[argmax]:
            argmax = r

        if i != argmax:
            self.heap[i], self.heap[argmax] = self.heap[argmax], self.heap[i]  # scambio
            self.heapify(argmax)  # ricorsione per ripulire i figli di argmax

    def insert(self, x):
        self.heap.append(x)
        self.moveUp(len(self.heap) - 1)

    def buildHeap(self, a):
        self.heap = a.copy()
        for i in range(len(self.heap) - 1, -1, -1):  # compreso elemento alla posizione 0, procediamo a ritroso
            self.heapify(i)

        self.heap = [(value, index) for index, value in enumerate(self.heap)]

    def moveUp(self, i):
        if i == 0:
            return
        p = (i + 1) // 2 - 1
        if self.heap[i][0] > self.heap[p][0]:
            self.heap[i], self.heap[p] = self.heap[p], self.heap[i]
            self.moveUp(p)

    def parent(self, i):
        return i // 2

    def left(self, i):
        return 2 * i + 1

    def right(self, i):
        return 2 * i + 2

#------------------------------------------------------------------------------------

#HeapSelect:
# @param a: array di partenza
# @param p: indice di inizio dell'array
# @param q: indice di fine dell'array
# @param h: rappresenta l'indice per il quale sono interessato a capire quale elemento finirebbe in tale indice se
#           l'array fosse ordinato
# L'idea è di tenere due min heap, partire dalla prima in cui è presente tutto a, e andare a estrarre h volte il minimo dalla
# prima MinHeap sostituendolo con i figli all'interno della seconda MinHeap. Alla fine l'h-esimo minimo sarà la radice
# della seconda MinHeap.
# L'idea per ottimizzarlo è quella di:
# aggiungere MaxHeap e usare max o min heap in base al valore di h.
# Se h sta nella metà superiore dell'array uso maxheap perché farò meno estrazioni (siccome estraggo i massimi fino al k-esimo più piccolo) in quanto 
# l'h-esimo elemento è più vicino alla fine dell'array (al massimo) che all'inizio (al minimo).
# Sennò uso MinHeap in quanto farò meno estrazioni perché l'h-esimo più piccolo è "più vicino" al minimo dell'array (all'inizio) che al massimo (la fine).

def heap_select(a,p,q,h):
    if h>(len(a)//2): 
        H1 = MaxHeap()
        H2 = MaxHeap()
        low = h
        high = len(a)-1
    else:
        H1 = MinHeap()
        H2 = MinHeap()
        low = 0
        high = h

    H1.buildHeap(a)
    H2.insert(H1.getRoot())

    for i in range(low,high):
        # H2.print()
        extracted = H2.extract()
        left = H2.left(extracted[1])
        right = H2.right(extracted[1])

        if left < H1.length():
            H2.insert(H1.heap[left])
        if right < H1.length():
            H2.insert(H1.heap[right])

    return H2.getRoot()[0]

def input_array():
    return [int(x) for x in input().split(" ") if x]

a = input_array()
h = int(input())
print(heap_select(a,0,len(a),h-1))


