# # Tarea 1

# Tarea 1

using Pkg
Pkg.add("Plots") #Añadimos la paquetería Plots para poder dibujar
using Plots #cargamos la paquetería Plots

# ## 1. Triángulo de Pascal
#
# a. Generen el triángulo de Pascal, hasta cierto orden `ord`, usando una
# matriz de enteros, en la que cada renglón representa un orden distinto.
# Hagan que la apariencia de este vector sea lo más simétrico posible.


#=
Función para crear el triangulo de pascal de orden ord a partir de una matriz de 
ceros de renglones ord y columnas 2*ord - 1, en la que cada renglón representa un orden distinto. 
Al principio es una matriz de ceros, despues en la primera columna, renglon ord ponemos el primer
valor (A[1,ord] = 1), después se realiza un doble bucle for. Un for para cada renglon
evitando que nos salgamos del tamaño de la matriz con condicionales if y elseif, y en el else 
se realiza el algoritmo de suma que da los valores en el triángulo de Pascal  
=#

function triangulo_pascal(ord::Int)

    #matriz de ceros
    A = zeros(Int, ord, 2*ord - 1)
    A[1,ord] = 1
    
    for i in 1:(ord-1)
        for j in 1:(2*ord - 1)
            if j-1<=0
                A[i,j+1] == 1 ? A[i+1,j] = 1 : A[i+1,j] = 0
            elseif j+1>(2*ord-1)
                A[i,j-1] == 1 ? A[i+1,j] = 1 : A[i+1,j] = 0
            else 
                A[i+1,j] = A[i,j-1] + A[i,j+1]
            end
        end
    end
    return A
end

A = triangulo_pascal(4)
#=
Función que imprime un triangulo simétrico a partir de la matriz del triangulo de pascal
utilizando 3 matrices, la matriz de enteros A, la matriz de booleanos mask (que toma en cuenta
donde la matriz A es cero) y la matriz de strings B, todas del mismo orden, donde al final utilicé 
para imprimir los renglones de la matriz B.
=#

function imprimir_triangulo(A::Matrix{Int})

    ord = size(A,1) # nos dice el orden del triángulo

    # Impresión 
    B = Matrix{String}(undef, size(A))
    mask = A .== 0
    for j in 1:length(A)
        mask[j] ? B[j]=" " : B[j]="$(A[j])"
    end
    for i in 1:ord 
        println(join(B[i,:]))
    end
end

imprimir_triangulo(A)



# b. Usen la matriz creada para generar *otra*, en que todos los números
# pares aparezcan como `false` y los impares como `true`, o alternativamente
# como 0 y 1, respectivamente. Las funciones `isodd` o `iseven` pueden
# serles útiles.
#

#=
Función que convierte cualquier matriz de 2 dimensiones de enteros en una nueva matriz de 
booleanos, si el número es par entonces coloca 'false' y si es impar coloca 'true'.
=#


function par_impar_matriz(mat::Matrix{Int})
    #Crea una nueva matriz de booleanos del tipo BitMatrix
    A = isodd.(mat)
    return A
end

par_impar_matriz(A)



# c. Dibujen (con puntos) todos los valores impares del triángulo de Pascal
# para `ord=256`. Repitan el ejercicio para `ord=1024`.



#= Función que toma como argumento el orden del triángulo de Pascal (ord) para dibujar
con puntos los impares del triángulo, para eso primero creamos la matriz de booleanos utilizando 
las 2 funciones anteriores (mat = par_impar_matriz(triangulo_pascal(ord))) y definimos nuestros 
2 vectores de enteros: x e y que tendrán los datos de las coordenadas de los puntos.

Después con un doble bucle for que lleva a un if que verifica, con la matriz de booleanos mat, si
en esa posición i,j dentro de la matriz hay un número par, si lo hay, le asigna la posición 
en el plano cartesiano x = j e y = -i + ord + 1 (el -i + ord + 1 es para que sea un triángulo 
apuntando hacia arriba).

Después utilizando scatter de la forma 
scatter(x, y, ms = 1.0, msw = 0.1, color = :black, legend=:none) 
Le pedimos que grafique los puntos que forman los vectores x e y, con un ancho de 1.0, contorno
de 0.1, de color negro y sin leyenda.
=#

function plot_pascal_impares(ord::Int)
    begin
        mat = par_impar_matriz(triangulo_pascal(ord))
        x = Vector{Int64}()
        y = Vector{Int64}()
    end
    
    for i in 1:ord 
        for j in 1:(2*ord - 1)
            if mat[i,j]
                push!(x,j)
                push!(y,-i+ord+1)
            end
        end
    end
    scatter(x, y, ms = 1.0, msw = 0.1, color = :black, legend=:none) 
end

plot_pascal_impares(256)

plot_pascal_impares(1024)

# ## 2. Triángulo equilátero
#
# Sean $X_1$, $X_2$ y $X_3$ los vértices de un triángulo equilátero en el
# plano. Implementen el siguiente algoritmo.

#=
Ocuparemos X_1 = [0,0], X_2 = [1,0] y X_3 = [0.5,sqrt(3/4)], que son las coordenadas de un triángulo
equilátero de lado 1. 
=#
begin
    X_1 = [0.0, 0.0]
    X_2 = [1.0, 0.0]
    X_3 = [0.5, sqrt(3/4)]
end


# a. Elijan al azar un punto dentro del triángulo equilátero, que llamaré $Y_0$.
# Es la condición inicial.


#=
Escogemos 2 flotantes entre 0 y 1, uno para la coordenada x y uno para la coordenada y, si
el de la coordenada y se sale del triángulo lo redefinimos hasta que cumpla la condicion
y1 < tan(π/3)*x1 (tan(π/3)=sqrt(3)), para que este dentro del tríangulo equilátero.
=#

begin
    x1 = rand()
    y1 = rand()
    while y1 >= sqrt(3)*x1
        y1 = rand()
    end
end
Y_0 = [x1, y1]

# b. Elijan al azar uno de los vértices $X_1$, $X_2$ y $X_3$, que llamaré
# $A_0$.
#
A_0 = rand([X_1, X_2, X_3 ])
# c. Obtengan el punto medio de $Y_0$ y $A_0$; el
# resultado lo etiquetaremos $Y_1$. Guarden el valor de $Y_1$.

Y_1 = (Y_0 + A_0)/2

#
# d. Repitan el algoritmo (pasos b y c), paso b para obtener $A_r$, y c para
# obtener $Y_{r+1}$ usando como el punto medio de $A_r$ y
# $Y_{r}$ (obtenido antes), guardando los iterados.
#
#=
Vamos a guardar todos los iterados A_r en un vector de vectores A y todas las Y_r en un vector de
vectores Y:

Primero guardamos lo que ya tenemos:
=#
begin
    A = [A_0]
    Y = [Y_0, Y_1]
    Yx = [Y_0[1], Y_1[1]]
    Yy = [Y_0[2], Y_1[2]]
end


for i in 2:100000
    push!(A, rand([X_1, X_2, X_3 ])) # Paso b, Guardamos A_{i-1}
    push!(Y, (Y[i] + A[i])/2) # Paso c. Guardamos Y_i
    push!(Yx, Y[i+1][1]) # Guardamos la coordenada x de Y_i
    push!(Yy, Y[i+1][2]) # Guardamos la coordenada y de Y_i
end

# e. Grafiquen todos los iterados $Y_n$ que guardaron, considerando
# muuuuchos puntos.

scatter(Yx,Yy, 
    ms = 1.0, msw = 0.1, 
    xlabel = "x", ylabel = "y",
    color = :purple, legend=:none)


# ## 3. Proporción distinta
#
# Repitan el ejercicio anterior usando ahora, no el punto medio, sino 1/3
# de la distancia entre el vértice elegido al azar y el iterado $Y_n$.
#

#=
Ocuparemos X_1 = [0,0], X_2 = [1,0] y X_3 = [0.5,sqrt(3/4)], que son las coordenadas de un triángulo
equilátero de lado 1. 
=#
begin
    X_1 = [0.0, 0.0]
    X_2 = [1.0, 0.0]
    X_3 = [0.5, sqrt(3/4)]
end

#=
Para hacer el inciso a de nuevo:
Escogemos 2 flotantes entre 0 y 1, uno para la coordenada x y uno para la coordenada y, si
el de la coordenada y se sale del triángulo lo redefinimos hasta que cumpla la condicion
y1 < tan(π/3)*x1 (tan(π/3)=sqrt(3)), para que este dentro del tríangulo equilátero.
=#

begin
    x1 = rand()
    y1 = rand()
    while y1 >= sqrt(3)*x1
        y1 = rand()
    end
end
Y_0 = [x1, y1]

#Eligo al azar uno de los vertices y le llamo A_0, para hacer el inciso b.
A_0 = rand([X_1, X_2, X_3 ])
#Ahora, en vez de encontrar el punto medio, tomaremos el punto tercio.
Y_1 = (Y_0 + A_0)/2

#=
Ahora, vamos a guardar todos los iterados A_r en un vector de vectores A y todas las Y_r en un vector de
vectores Y:

Primero guardamos lo que ya tenemos:
=#
begin
    A = [A_0]
    Y = [Y_0, Y_1]
    Yx = [Y_0[1], Y_1[1]]
    Yy = [Y_0[2], Y_1[2]]
end


for i in 2:100000
    push!(A, rand([X_1, X_2, X_3 ])) # Paso b, Guardamos A_{i-1}
    push!(Y, (Y[i] + A[i])/3) # Encontramos punto tercio. Guardamos Y_i
    push!(Yx, Y[i+1][1]) # Guardamos la coordenada x de Y_i
    push!(Yy, Y[i+1][2]) # Guardamos la coordenada y de Y_i
end

# e. Grafiquen todos los iterados $Y_n$ que guardaron, considerando
# muuuuchos puntos.

using Pkg
using Plots #cargamos la paquetería Plots

scatter(Yx,Yy, ms = 1.0, msw = 0.1, color = :blue, legend=:none)

