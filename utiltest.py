def bound(N):
    return N*(2**((1/N))-1)


def u(arr):
    Sum = 0
    minor = 0
    tmp = 0
    multipleList = []
    for m in arr:
        multipleList.append(False)
        if m[0] > minor:
            minor = m[0]
    
    for i, v in enumerate(arr):
        tmp = v[0]
        while tmp <= minor:
            if tmp%minor == 0:
                multipleList[i] = True
            tmp += v[0]
        if multipleList[i] == False:
            print("%.2f is not a multiple of %.2f" % (v[0], minor))
            return -1
        print (v[1]/v[0])
        Sum += v[1]/v[0] #C/T
    return Sum    
 

def uCheck(arr):
    U = u(arr)
    if U == -1:
        return -1
    B = bound(len(arr))
    if U >= B:
        print("U: %.3f >= B: %.3f | Failed "%(U, B))
    else:
        print("U: %.3f <= B: %.3f | Passed "%(U, B))


# test = [[16, 2], #[T(period), C(computation)]
#         [8, 4], 
#         [8, 1]] 


walle = [[16,  12.323700], #Measure    Pr
        [16,   0.0305180], #Controller Prior = 2
        [4,   0.4272460]]  #Move       Prior = 1   

uCheck(walle)


