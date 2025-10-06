import time
import random
import matplotlib.pyplot as plt

#------------------------------------------------------------------------------------------------------------------------------------------------
#QUICKSELECT

def Partition(a, low, high):
    p = a[high]
    i = low
    for j in range(low, high):
        if a[j] <= p:
            a[i], a[j] = a[j], a[i]
            i += 1
    a[i], a[high] = a[high], a[i]
    return i

def QuickSelect(A,p,q,i): 
        if i<p or i>q: 
            return None
        if p==q == i: 
            return A[p]
        else: 
            r = Partition(A,p,q)
            if i==r: 
                return A[r]
            elif i<r:
                return QuickSelect(A,p,r-1,i) 
            else: 
                return QuickSelect(A,r+1,q,i)

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class MinHeap:
    heap = []

    def length(self):
        return len(self.heap)

    def getRoot(self):
        assert len(self.heap) > 0 
        return self.heap[0]  
    def print(self):
        for i in range(0, self.length()):
            print(self.heap[i], end=" ")

    def extract(self):
        element = self.heap[0]
        self.heap[0] = self.heap[-1]
        self.heap.pop()
        self.heapify(0)
        return element

    def heapify(self, i):
        l = 2 * i + 1
        r = 2 * i + 2
        argmin = i
        if l < len(self.heap) and self.heap[l] < self.heap[argmin]:
            argmin = l

        if r < len(self.heap) and self.heap[r] < self.heap[argmin]:
            argmin = r

        if i != argmin:
            self.heap[i], self.heap[argmin] = self.heap[argmin], self.heap[i]  
            self.heapify(argmin)  

    def insert(self, x):
        self.heap.append(x)
        self.moveUp(len(self.heap) - 1)

    def buildHeap(self, a):
        self.heap = a.copy()
        for i in range(len(self.heap) - 1, -1, -1): 
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

#----------------------------------------------------------------------------------------------------------
# HEAP SELECT 

class MaxHeap:
    heap = []

    def length(self):
        return len(self.heap)

    def getRoot(self):
        assert len(self.heap) > 0 
        return self.heap[0]  

    def print(self):
        for i in range(0, self.length()):
            print(self.heap[i], end=" ")

    def extract(self):
        element = self.heap[0]
        self.heap[0] = self.heap[-1]
        self.heap.pop()
        self.heapify(0)
        return element

    def heapify(self, i):
        l = 2 * i + 1
        r = 2 * i + 2
        argmax = i
        if l < len(self.heap) and self.heap[l] > self.heap[argmax]:
            argmax = l

        if r < len(self.heap) and self.heap[r] > self.heap[argmax]:
            argmax = r

        if i != argmax:
            self.heap[i], self.heap[argmax] = self.heap[argmax], self.heap[i]
            self.heapify(argmax)

    def insert(self, x):
        self.heap.append(x)
        self.moveUp(len(self.heap) - 1)

    def buildHeap(self, a):
        self.heap = a.copy()
        for i in range(len(self.heap) - 1, -1, -1): 
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


#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# MEDIANS OF MEDIANS SELECT

def insertionSort(arr,low,high): 
    for i in range(low+1, high+1):  
        key = arr[i]  
        j = i-1
        while j >= low and key < arr[j]:
            arr[j+1] = arr[j] 
            j -= 1
        arr[j+1] = key 

def momCalcolo(arr,low,high,k):
    j = low  
    for i in range(low,high+1,5): 
        local_min = min((i+4),high) 
        insertionSort(arr,i,local_min)
        arr[j], arr[(i+local_min)//2] = arr[(i+local_min)//2],arr[j]
        j += 1

    return medianOfmedians(arr,low,j-1,(low + j-1)//2)

def medianOfmedians(arr,low,high,k): 
    if high == k and k ==low: 
        return k
    m = momCalcolo(arr,low,high,k)
    arr[high], arr[m] = arr[m], arr[high]
    pi = Partition(arr,low,high)

    if  k == pi:
        return pi
    elif k < pi: 
        return medianOfmedians(arr,low,pi-1,k)
    else: 
        return medianOfmedians(arr,pi+1,high,k) 

def Partition(a, low, high):
    p = a[high]
    i = low
    for j in range(low, high):
        if a[j] <= p:
            a[i], a[j] = a[j], a[i]
            i += 1
    a[i], a[high] = a[high], a[i]
    return i

def input_array():
    return [int(x) for x in input().split(" ") if x]

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#BENCHMARK

A = 100
B = 1000 ** (1 / 99.0)

range_test = [int(A * (B ** i)) for i in range(100)]  #lunghezze dei vettori di test


def init_array(n):
    #genera un array di numeri interi casuali di dimensione n in un intervallo 1 - 100
    return [random.randint(1, 1000000) for i in range(n)]


def init_index(n):
    #genera un indice k casuale tra 0 e n-1
    return random.randint(0, n - 1)


#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
def resolution():
    start = time.perf_counter()
    while time.perf_counter() == start:
        pass
    stop = time.perf_counter()
    return stop - start

# time.perf_counter() e non time.time() perché -> https://stackoverflow.com/questions/61713551/how-to-properly-use-time-time
def measure(n, min_time, select_algorithm):
    count = 0;
    start_time = time.perf_counter()
    while True:
        vector = init_array(n)
        index = init_index(n)
        select_algorithm(vector, 0, n-1, index) # !!! index è già -1, facendo index-1 ottengo -2 
        count += 1
        end_time = time.perf_counter()
        if end_time - start_time >= min_time:
            break
    average_time = (end_time - start_time) / count
    return average_time


R = resolution()
E = 0.001
T_min = R * ((1 / E) + 1)

def benchmark(algoritmo,name):
    mean_times = []
    for n in range_test:
        time_vector = [] #vettore dove salvo i tempi di 100 iterazioni di un algoritmo su un vettore lungo n
        for x in range(100):
            t = measure(n, T_min, algoritmo) #eseguo una misurazione
            time_vector.append(t)              #inserisco il risultato della misurazione nel vettore dei tempi

        tempo_medio = sum(time_vector) / len(time_vector) #calcolo il tempo medio
        mean_times.append(tempo_medio)

        print("Tempo medio di esecuzione per n =", n, "=>", tempo_medio, "secondi")
    plt.plot(range_test,mean_times,"o",label = name)

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Esecuzione del benchmark

benchmark(QuickSelect,"Quick select")
benchmark(medianOfmedians,"Medians of medians select")
benchmark(heap_select,"Heap select")

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Gestione della generazione dei grafici 

font = {
    'size':20
}

plt.yscale("log")
plt.xscale("log")
plt.title("Tempo medio d'esecuzione per dimensione dell'array(scala logaritmica)",fontdict=font)
plt.ylabel("tempo medio d'esecuzione (logaritmico)")
plt.xlabel("dimensione dell'array (logaritmica)")
plt.legend(loc="upper left")
plt.show()

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
