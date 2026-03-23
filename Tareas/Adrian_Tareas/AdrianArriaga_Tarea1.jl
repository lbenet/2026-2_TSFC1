# TSFC1 - Tarea 1. 

using Plots, LaTeXStrings   # Se importan las paqueterías 


## 1. Triángulo de Pascal


function pascal_triangle(order) 
    # Esta función genera un triángulo de Pascal a un orden deseado. Primero se obtiene la dimensión de filas
    # y columnas para inicializar una matriz de enteros con esas dimensiones.
    # A partir de dos ciclos "for" anidados se accede primero a la primera fila para colocar el primer uno en su 
    # posición y a partir de esa fila se generan las demas filas sumando los elementos de las diagonales 
    # superiores del ij-elemento de la matriz, es decir M[i, j] = M[i - 1, j - 1] + M[i - 1, j + 1].

    ord = order; 
    M_row=ord + 1;  
    M_col = 2*ord + 1; 
    M = zeros(Int, M_row, M_col) 

    for j in 1:M_col
        if j == M_row
             M[1,j]=1
        else
             M[1,j]=0 
        end
    end

    for i in 2:M_row
        M[i,1]=0;
        M[i,M_col]=0
        for j in 2:(M_col-1)
            M[i,j]=M[i-1, j-1] + M[i-1, j+1]
        end       
    end

    # En el ciclo for anidado para i>1, se coloca cero por default en la columna inicial y final, las siguientes dos
    # corrigen lo anterior para el caso de la ultima fila.

    M[M_row, 1]=1;
    M[M_row, M_col]=1;
    return M
end

function dot_drawing(order)
    # Esta función genera un triángulo de Pascal llamando a la función "pascal_triangle(order)". Después, se usa
    # broadcasting (isodd.) para convertir todos los números impares en 1 y los pares en 0 de forma simultánea.

    P = pascal_triangle(order)
    P = isodd.(P) # Evaluamos si cada elemento de P es impar y lo convertimos a entero (1 o 0)
    M_row = size(P, 1)
    M_col = size(P, 2)
    x_dot = Vector{Int64}()
    y_dot = Vector{Int64}()
    
    # Con un ciclo for anidado, distinguimos los valores triángulo de Pascal binario, guardamos las coordenadas en caso de 
    # que el valor sea 1. 
    p = scatter()
    for i in 1:M_row
        for j in 1:M_col
            if P[i,j] == 1
                push!(x_dot, j) 
                push!(y_dot, (M_row - i)) 
            end
        end
    end
    
    # Usamos la función "scatter()" para graficar el vector de puntos guardado.
    p = scatter!(x_dot, y_dot, 
                markersize = 1.0,           
                markerstrokewidth = 0,      
                color = :blue) 

    display(p)
   
end

TrianguloPascal = pascal_triangle(8)
# Se usa broadcasting (isodd.) para convertir todos los números impares en 1 y los pares en 0 de forma simultánea
TriangPascalBinario = isodd.(TrianguloPascal)
PuntosOrden256 = dot_drawing(256)
PuntosOrden10 = dot_drawing(1024)



## 2. Triángulo equilátero 

begin 
    # En este bloque inicializamos los vértices de nuestro triángulo equilátero en el plano.
    # Elegimos coordenadas que forman una base de longitud 1 sobre el eje x y la altura correspondiente.
    # Usamos la función scatter para colocar los tres puntos iniciales y scatter! (con signo de exclamación) 
    # para añadir los siguientes puntos a la misma gráfica sin borrar la anterior.
    x1 = [0.0, 0.0];
    x2 = [1.0, 0.0];
    x3 = [0.5, (sqrt(3))/2];
end


function random_point_in_triangle(v1, v2, v3)
    # Esta función genera un punto aleatorio uniformemente distribuido dentro del triángulo
    # formado por los vértices v1, v2 y v3. Primero genera un punto en el paralelogramo definido por 
    # los vectores (v2-v1) y (v3-v1). Si el punto cae en la mitad exterior (la suma de r1 y r2 > 1), 
    # se refleja hacia la mitad interior restando sus componentes a 1.
    
    r1 = rand()
    r2 = rand()
    
    if r1 + r2 > 1.0
        r1 = 1.0 - r1
        r2 = 1.0 - r2
    end
    
    # Se calcula la posición final usando una combinación lineal vectorial tomando v1 como origen.
    Y0 = v1 .+ r1 .* (v2 .- v1) .+ r2 .* (v3 .- v1)
    
    return Y0
end


# Agrupamos los vértices en un solo arreglo para poder utilizar la función rand() 
# más adelante y elegir uno de ellos con la misma probabilidad.
vertices = [x1, x2, x3]

# Definimos el número total de iteraciones.
N = 50_000 

# Creamos dos arreglos llenos de ceros del tamaño N donde guardaremos la historia de las coordenadas.
puntos_x = zeros(N)
puntos_y = zeros(N)

# Generamos nuestra condición inicial (el punto Y0) llamando a la función que definimos arriba.
Y_actual = random_point_in_triangle(x1, x2, x3) 


# En este ciclo for se ejecuta el algoritmo iterativo.
# En cada vuelta (pasos b y c), se elige un vértice al azar, se calcula el punto medio entre 
# nuestra posición actual y dicho vértice, y este nuevo punto medio se convierte en el iterado actual.
for r in 1:N
    A_r = rand(vertices)
    
    Y_actual = (Y_actual + A_r) / 2.0
    
    # Extraemos y guardamos las coordenadas x e y por separado en sus respectivos arreglos 
    # para facilitar la graficación al final del ciclo.
    puntos_x[r] = Y_actual[1]
    puntos_y[r] = Y_actual[2]
end


# Finalmente, utilizamos la función scatter para graficar la nube de puntos resultante.
# Se ajustan los parámetros visuales (tamaño de punto pequeño, sin bordes de marcador, y 
# sin ejes de marco) para que la estructura fractal fina se aprecie con claridad y no como una mancha sólida.
p = scatter(puntos_x, puntos_y, 
            markersize = 0.5,           
            markerstrokewidth = 0,      
            color = :blue,              
            legend = false,             
            aspect_ratio = :equal,      
            title = "Triángulo de Sierpinski",
            framestyle = :none)



## 3. Triángulo equilátero con diferente proporción


# Usamos los mismos datos que el ejercicio anterior, unicamente cambio el nombre de las 
# variables que se usaran ene este ejercicio.

# Creamos dos arreglos llenos de ceros del tamaño N donde guardaremos la historia de las coordenadas.
puntos_x2 = zeros(N)
puntos_y2 = zeros(N)

# Generamos nuestra nueva condición inicial (el punto Y0) para este nuevo ejercicio.
Y_actual2 = random_point_in_triangle(x1, x2, x3) 


# En este ciclo for se ejecuta el algoritmo iterativo.
# En cada vuelta (pasos b y c), se elige un vértice al azar, pero ahora se calcula 1/3 de la distancia entre 
# nuestra posición actual y dicho vértice, y este nuevo punto se convierte en el iterado actual.
for r in 1:N
    A_r2 = rand(vertices)
    
    Y_actual2 = (Y_actual2 + A_r2) / 3.0
    
    # Extraemos y guardamos las coordenadas x e y por separado en sus respectivos arreglos 
    # para facilitar la graficación al final del ciclo.
    puntos_x2[r] = Y_actual2[1]
    puntos_y2[r] = Y_actual2[2]
end


# Finalmente, utilizamos la función scatter para graficar la nube de puntos resultante.
# Se ajustan los parámetros visuales (tamaño de punto pequeño, sin bordes de marcador, y 
# sin ejes de marco) para que la estructura fractal fina se aprecie con claridad y no como una mancha sólida.
p2 = scatter(puntos_x2, puntos_y2, 
            markersize = 0.5,           
            markerstrokewidth = 0,      
            color = :red,              
            legend = false,             
            aspect_ratio = :equal,      
            title = "Triángulo de Sierpinski, 1/3",
            framestyle = :none)