# Tarea 1 

# ## 1. Triángulo de Pascal
using Plots
#
# a. Generen el triángulo de Pascal, hasta cierto orden `ord`, usando una
# matriz de enteros, en la que cada renglón representa un orden distinto.
# Hagan que la apariencia de este vector sea lo más simétrico posible.
#

"""
    function trianguloPascal(ord::Int)

Genera una matriz del triángulo de Pascal, hasta un orden dado
"""
function trianguloPascal(ord::Int)
    triang = zeros(Int,ord,(ord*2)-1) # Creamos una matriz de ceros
    j = ord # Establecemos una variable en el "centro" de la matriz
    
    for i = 1:ord #Primero ponemos los 1s de la izquierda
        triang[i,j] = 1
        j -= 1
    end

    j = ord # Reestablecemos la variable central
    for i = 1:ord # Ahora colocamos los 1s de la derecha
        triang[i,j] = 1
        j += 1
    end

    # Establecemos variables para el funcionamiento del proximo while loop

    i = 3   # Esta indica que el loop funciona para triángulos de al menos orden 3, para menores es innecesario
    j = ord # Esta pone nuestro punto inicial en medio de la matriz, junto con la variable anterior
    n = 1   # Esta nos ayuda a regresar los espacios correctos al bajar cada fila

    while i <= ord # Loop que va decendiendo cada fila
        if triang[i,j] == 0 # Verificamos que estemos en un cero
            triang[i,j] = triang[i-1,j-1] + triang[i-1,j+1] # Sumamos los dos números que tenemos "arriba"
        end
        if triang[i,j+2] == 1 # Si el número que sigue es un uno, entonces hemos terminado esta fila
            i += 1 # Bajamos a la fila que sigue
            j = j - (2n-1) # Regresamos los espacios necesarios
            n += 1 # Y actualizamos el número de filas recorridas
        elseif triang[i,j+2] != 1 # Si el número que sigue no es un uno, entonces debemos seguir avanzando
            j += 2 # Avanzamos "un lugar" (saltándonos el cero intermedio)
        end
    end

    return triang
end


# b. Usen la matriz creada para generar *otra*, en que todo>s los números
# pares aparezcan como `false` y los impares como `true`, o alternativamente
# como 0 y 1, respectivamente. Las funciones `isodd` o `iseven` pueden
# serles útiles.
"""
    function imparYPar(mat::Matrix)
Toma una matriz y regresa otra, reemplazando los números impares con 1 y los pares con 0
"""
function imparYPar(mat::Matrix)
    for i in eachindex(mat)
        mat[i] = isodd(mat[i])
    end # Para cada entrada en la matriz reemplazamos los impares con 1 y los pares con 0
    return mat # La función regresa la matriz modificada
end

# c. Dibujen (con puntos) todos los valores impares del triángulo de Pascal
# para `ord=256`. Repitan el ejercicio para `ord=1024`.
"""
function dibujarMatriz(mat::Matrix)
    Toma una matriz de 0s y 1s, y crea una gráfica donde se muestren los 1 como puntos y los 0 
    como espacio vacio
"""
function dibujarMatriz(mat::Matrix)
    x = Vector{Int}(undef,0) #Creamos vectores vacios para nuestros x y y
    y = Vector{Int}(undef,0)
    tam = size(mat) # Establecemos un vector que tiene las dimensiones de la matriz 
    for i = 1:tam[1] # Para iterar en todas las filas
        for j = 1:tam[2] # Para iterar en todas las columnas
            if mat[i,j] == 1 # Busca que el valor en la matriz sea igual a 1
                push!(x,i)  #Si lo es, lo coloca en nuestros vectores x y y
                push!(y,j)
            end
        end
    end
    graf = scatter(x,y) #Finalmente, grafica los vectores
    return graf
end

orden256 = dibujarMatriz(imparYPar(trianguloPascal(256)))
orden1024 = dibujarMatriz(imparYPar(trianguloPascal(1024)))
# ## 2. Triángulo equilátero
#
# Sean $X_1$, $X_2$ y $X_3$ los vértices de un triángulo equilátero en el
# plano. Implementen el siguiente algoritmo.
##
# a. Elijan al azar un punto dentro del triángulo equilátero, que llamaré $Y_0$.
# Es la condición inicial.

# b. Elijan al azar uno de los vértices $X_1$, $X_2$ y $X_3$, que llamaré
# $A_0$.
#
# c. Obtengan el punto medio de $Y_0$ y $A_0$; el
# resultado lo etiquetaremos $Y_1$. Guarden el valor de $Y_1$.
#
# d. Repitan el algoritmo (pasos b y c), paso b para obtener $A_r$, y c para
# obtener $Y_{r+1}$ usando como el punto medio de $A_r$ y
# $Y_{r}$ (obtenido antes), guardando los iterados.
#
# e. Grafiquen todos los iterados $Y_n$ que guardaron, considerando
# muuuuchos puntos.



#Para simplificar las cosas, fijaré dos de los puntos al eje X con v[1]<u[1]
function dis(p,q)        #Función distancia entre puntos 
    return sqrt((p[1]-q[1])^2 + (p[2]-q[2])^2)
end 

function G(x,y,z)       #Función baricentro del triángulo
    return [(x[1]+y[1]+z[1])/3,(x[2]+y[2]+z[2])/3]
end

function L(p,x,y,z)     #Función del Teo de Leibniz
    g = G(x,y,z)
    return dis(p,x)^2 + dis(p,y)^2 + dis(p,z)^2 - 3*(dis(p,g))^2
end

function random(x,y)     #Función para encontrar la componente en x del punto dentro del triángulo
    return x[1] + rand()*(y[1] - x[1])
end

function S(x,y,z,n)   # x,y,z son los puntos en el plano que forman el triángulo, n es el 
                      #numero de iteraciones que se quieren
    Y = []
    Y1 = [random(x,y),rand()*z[2]]
    while L(Y1,x,y,z) != dis(x,y)^2 
        Y1 = [random(x,y),rand()*z[2]]    
    end
    m=1
    while m < n+1
        A = rand([x,y,z]) 
        Y1 = [(A[1]+Y1[1])/2,(A[2]+Y1[2])/2]
        push!(Y,Y1)
        m = m+1
    end
    return Y
end 

v = [0,0]
u = [2,0]
w = [1,sqrt(3)]
n = 100000

Y = S(v,u,w,n)
x = [k[1] for k in Y]
y = [k[2] for k in Y]
scatter(x, y, markersize=1, color = :blue)



# ## 3. Proporción distinta
#
# Repitan el ejercicio anterior usando ahora, no el punto medio, sino 1/3
# de la distancia entre el vértice elegido al azar y el iterado $Y_n$.
#
using Plots 


#Para simplificar las cosas, fijaré dos de los puntos al eje X con v[1]<u[1]
function dis(p,q)        #Función distancia entre puntos 
    return sqrt((p[1]-q[1])^2 + (p[2]-q[2])^2)
end 

function G(x,y,z)       #Función baricentro del triángulo
    return [(x[1]+y[1]+z[1])/3,(x[2]+y[2]+z[2])/3]
end

function L(p,x,y,z)     #Función del Teo de Leibniz
    g = G(x,y,z)
    return dis(p,x)^2 + dis(p,y)^2 + dis(p,z)^2 - 3*(dis(p,g))^2
end

function random(x,y)     #Función para encontrar la componente en x del punto dentro del triángulo
    return x[1] + rand()*(y[1] - x[1])
end

function S(x,y,z,n)   # x,y,z son los puntos en el plano que forman el triángulo, n es el 
                      #numero de iteraciones que se quieren
    Y = []
    Y1 = [random(x,y),rand()*z[2]]
    while L(Y1,x,y,z) != dis(x,y)^2 
        Y1 = [random(x,y),rand()*z[2]]    
    end
    m=1
    while m < n+1
        A = rand([x,y,z]) 
        Y1 = [(2*A[1]+Y1[1])/3,(2*A[2]+Y1[2])/3]  #La única modificación respecto al otro código está aquí
        push!(Y,Y1)
        m = m+1
    end
    return Y
end 

v = [0,0]
u = [2,0]
w = [1,sqrt(3)]
n = 100000

Y = S(v,u,w,n)
x = [k[1] for k in Y]
y = [k[2] for k in Y]
scatter(x, y, markersize=1, color = :blue)