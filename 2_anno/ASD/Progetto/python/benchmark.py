import random
import time
from python.quickSort import quick_sort
from python.countingSort import counting_sort
from python.quickSort3w import quick_sort_3way
from python.mergeSort import merge_sort

from matplotlib import pyplot as plt

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
def measure(n, min_time, algorithm):
    count = 0
    start_time = time.perf_counter()
    while True:
        vector = init_array(n)
        index = init_index(n)
        algorithm(vector) # !!! index è già -1, facendo index-1 ottengo -2 
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

benchmark(quick_sort,"Quick Sort")
benchmark(counting_sort,"Counting Sort")
benchmark(quick_sort_3way,"Quick Sort 3 way")
benchmark(merge_sort,"Merge Sort")
