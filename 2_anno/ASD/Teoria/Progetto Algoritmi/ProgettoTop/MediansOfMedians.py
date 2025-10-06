
#MEDIANS OF MEDIANS SELECT
# L'algoritmo è basato sulla suddivisione del vettore fornito in input in blocchi di dimensione limitata e sul calcolo della mediana delle mediane. Più precisamente, l'algoritmo esegue le seguenti operazioni:
#   - divisione dell'array in blocchi di 5 elementi, escluso eventualmente l'ultimo blocco che potrà contenere meno di 5 elementi,
#   - ordinamento e calcolo della mediana di ciascun blocco,
#   - calcolo della mediana 𝑀 delle mediane dei blocchi, attraverso chiamata ricorsiva allo stesso algoritmo
#   - partizionamento dell'intero array attorno alla mediana 𝑀, attraverso una variante della procedura "partition" dell'algoritmo "quick sort"
#   - chiamata ricorsiva nella parte di array che sta a sinistra o a destra della mediana 𝑀, in funzione del valore 𝑘 fornito in input.
# Il modo più semplice per implementare quest'algoritmo consiste nell'allocare, ad ogni chiamata ricorsiva, un nuovo vettore per memorizzare le mediane dei blocchi. Esiste tuttavia un approccio più efficiente e "quasi in place" che riutilizza lo spazio allocato per il vettore originariamente fornito in input (l'unico spazio aggiuntivo utilizzato è dato dalla pila dedicata alla gestione delle chiamate ricorsive). La valutazione del progetto terrà conto della variante implementata (quella "quasi in place", essendo più complicata ma anche più efficiente, sarà valutata con un punteggio più alto).
# Indipendentemente dalla variante implementata, nel caso pessimo l'algoritmo dovrà avere complessità, sia temporale che spaziale, pari a O(𝑛)

#------------------------------------------------------------------------------------------------

# ordina l'array[low:high] passato in input --> N.B: l'array[low:high] può anche essere un sottoarray di un altro array
# @param arr: array su cui si sta lavorando, non necessariamente quello da ordinare
# @param low: estremo inferiore del sottoarray di arr che si vuole ordinare
# @param high: estremo superiore del sottoarray di arr che si vuole ordinare
def insertionSort(arr,low,high): 
    for i in range(low+1, high+1):  
        key = arr[i]  
        j = i-1
        while j >= low and key < arr[j]:
            arr[j+1] = arr[j] 
            j -= 1
        arr[j+1] = key 

# calcola effettivamente l'indice della posizione del mediano dei mediani la sua esecuzione si basa su:
# - divide l'array in gruppi da 5
# - ordina ogni gruppo da 5 
# - trova il mediano del gruppo
# - lo mette all'inizio dell'array -> in questo modo l'algoritmo rimane in place
# @param arr: array su cui si sta lavorando
# @param low: indice di inizio del gruppo di 5 (o meno) elementi dell'array su cui sto lavorando 
# @param high: indice di fine del gruppo di 5 (o meno) elementi dell'array su cui sto lavorando
# @param k: indica l'indice della posizione per la quale voglio sapere quale elemento finirebbe in tale posizione se
#           l'array fosse ordinato.  
def momCalcolo(arr,low,high,k):
    j = low
    #contatore = 0   
    for i in range(low,high+1,5): 
# non più if ma un min in questo modo "simulo" l'if prendendo sempre il valore minore
        local_min = min((i+4),high) #su i+4 e high siccome ho cambiato insertion sort in modo che conti anche l'ultimo elemento 
        insertionSort(arr,i,local_min)
        arr[j], arr[(i+local_min)//2] = arr[(i+local_min)//2],arr[j]
        #contatore += 1
        j += 1

    return medianOfmedians(arr,low,j-1,(low + j-1)//2)

# funzione principale che ha lo scopo di tornare la posizione del mediano dei mediani nell'array, per farlo
# richiama momCalcolo in modo da ottenere la posizione del mediano all'interno dell'array quindi sposta il mediano in
# ultima posizione e richiama partition con perno il mediano dei mediani (in ultima posizione).
# Ricorsivamente ricalcola il tutto in base al valore di k in modo da restituire l'indice dell'elemento dell'array che 
# finirebbe in posizione k-esima se l'array fosse ordinato. 
# @param arr: array su cui si sta lavorando
# @param low: indice di inizio del gruppo di 5 (o meno) elementi dell'array su cui sto lavorando 
# @param high: indice di fine del gruppo di 5 (o meno) elementi dell'array su cui sto lavorando
# @param k: indica l'indice della posizione per la quale voglio sapere quale elemento finirebbe in tale posizione se
#           l'array fosse ordinato. 
def medianOfmedians(arr,low,high,k): 
    if high == k and k ==low: 
        return k
    m = momCalcolo(arr,low,high,k)
    arr[high], arr[m] = arr[m], arr[high]
    #e richiamo partition sull'array
    pi = Partition(arr,low,high)

    if  k == pi:
        return pi
    elif k < pi: 
        return medianOfmedians(arr,low,pi-1,k)
    else: 
        return medianOfmedians(arr,pi+1,high,k) 

# partiziona l'array intorno all'ultimo elemento, mette all'inizio dell'array tutti i valori minori del pivot (ultimo elemento)
# e tutti gli elementi più grandi alla fine quindi scambia il pivot (ultimo elemento) mettendolo nella sua posizione adeguata 
# restituisce tale posizione.
# @param a: array su cui sto lavorando
# @param low: indice di inizio dell'array o del sottoarray su cui voglio lavorare
# @param high: indice di fine dell'array o del sottoarray su cui voglio lavorare e contemporaneamente rappresenta il pivot della funzione
#              nel nostro caso è il mediano dei mediani
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


arr = input_array()
k = int(input())

mom = medianOfmedians(arr,0,len(arr)-1,k-1)
print(arr[mom])