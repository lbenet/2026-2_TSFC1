# Tarea 1

begin
    using Plots
    """
    Genera un triángulo de Pascal de orden _ord - 1_, donde los espacios vacios son ceros.
    No hace uso del binomio de Newton.
    """
    function trianguloPascal(ord)
        tP = zeros(Int, (ord, ord))
        for j = 1:ord # Iteracion filas
            tP[j,ord-j+1] = 1 # Diagonal de 1s
            for i = 1:ord # Iteracion columnas
                if (j > 2) && (iseven(i-ord+j-1)) && (i-ord+j-1 > 0) # No ocurre en las primeras dos filas. Suma en columnas pares después del 1
                    if iseven(j) # Filas pares
                        tP[j,i] = tP[j-1, i-1] + tP[j-1, i+1]
                    else # Filas nones
                        # Revisa que no sea el ultimo
                        ((i != ord)) && (tP[j,i] = tP[j-1, i-1] + tP[j-1, i+1]) 
                        tP[j, ord] = 2*tP[j-1, ord-1] #
                    end
                end
            end
        end
        # Concatenamos la mitad de matriz con su equivalente revertido sin el eje.
        return res = [tP reverse(tP[:,1:ord-1], dims=2)]
    end

    """
    Copia una matriz de orden _ord_ de un triángulo de Pascal, y para cada elemento de la matriz revisa si el número es par o non. 
    Si es par, el número se reemplaza por un _0_, si es non por un _1_.
    En caso de ser un espacio vacio, llena con el número arbitrario 5, que después es sustituido por una cadena vacía al transformar
    la matriz de enteros en una matriz de cadenas para mejor legibilidad.
    """
    function parNon(ord)
        m = trianguloPascal(ord)
        m2 = copy(m)
        return isodd.(m2)
    end

    """
    Toma una matriz a partir de la función _parNon(ord)_ y genera una nueva matriz a partir de esta.
    Para cada número none o _1_, reemplaza el elemento por un punto. El resto de la matriz se llena de 
    cadenas vacía. Finalmente imprime la matriz en la terminal.
    """
    function dots(ord)
        m = parNon(ord)
        x = Float64[]
        y = Float64[]
        n = size(m)
        for a in 1:n[1]
            for b in 1:n[2]
                m[a,b] == 1 && (push!(x, b - 1);push!(y,n[1] - a))
            end
        end
        p = scatter(x, y,
            # La formula usada en markersize una funcion logartimica con
            # asintota en 4.5 que toca los puntos (1,6) y (1024, 0.01).
            # Esto para que los puntos mas o menos se adapten segun el 
            # orden del triangulo de Pascal.
            markersize = -1.056*log(ord-4.5)+7.323,
            markercolor = :blue,
            fillalpha = 0.2,
            legend = false
        )
    end
    dots(1024)
end

begin
    using Plots
    """
    Genera un vector aleatorio con elementos x∈[0,2], y∈[0,√3]. La función checa que el vector generado
    se encuentre dentro de un tríangulo equilatero de L = 2 con un vértice en (0,0) en el cuadrante I.
    Si esa condición no se cumple, genera un nuevo vector hasta generar uno que si lo haga.
    """
    function genVec()
        p = [0,0]
        # Checar que el vector este dentro de los limites
        while ((p[2] >= sqrt(3)*p[1]) || (p[2] >= -sqrt(3)*(p[1]-2)) || (p[1] == 0) | (p[2] == 0)) 
            p = [2*rand(), sqrt(3)*rand()]
        end
        return p
    end

    """
    Genera un número aleatorio entero entre el 1 y el 3. Para cada número, elige uno de los vértices
    del triángulo equilatero de L = 2 en el cuadrante I. Los vértices son: 1 -> (0,0), 2 -> (2,0) y 
    3 -> (1, √3).
    """
    function getAxis()
        A = rand(1:3)
        return A == 1.0 ? [0,0] : A == 2 ? [2,0] : [1, sqrt(3)]
    end

    """
    Obtiene las coordenas del punto medio entre dos puntos.
    """
    function midpoint(p,A)
        return (p .+ A) ./ 2
    end

    """
    Genera un numero _n_ de datos de la siguiente manera: genera un vector aleatorio con genVec() y obtiene
    un vértice aleatorio del triángulo con getAxis(). Luego obtiene el punto medio entre estos dos puntos e
    introduce las coordenadas (x,y) en dos matrices, xData y yData respectivamente. Finalmente regresa estos
    dos vectores de longitud _n_.
    """
    function getData(n)
        xData = Float64[]
        yData = Float64[]
        p = genVec()
        A = getAxis()
        mp = Array{Float64}(undef, 2)
        for i in 1:n
            mp .= midpoint(p,A)
            push!(xData, mp[1])
            push!(yData, mp[2])
            p = [xData[i], yData[i]]
            A = getAxis()
        end
        
        # @show xData
        # @show yData
        return xData, yData

    end 

    """
    Utilizando la paquetería Plots.jl, dibuja el triángulo equilatero de L = 2 con vértices
    en (0,0), (2,0), y (1, √3). Después dibuja todos los puntos en los vectores _x_ y _y_.
    """
    function drawData(x,y)
        xAxes = [0, 2, 1, 0]
        yAxes = [0, 0, sqrt(3), 0]

        p = plot(xAxes, yAxes,
            seriestype = :shape,   
            aspect_ratio = :equal, 
            linecolor = :black,
            fillalpha = 0.2,
            legend = false)

        scatter!(x,y, 
            markersize = 0.5,
            markercolor = :blue)
    end

    """
    Genera con getData(n) un número _n_ de datos y los dibuja con drawData(x,y).
    """
    function genAndSee(n)
        x,y = getData(n)
        drawData(x,y)
    end

    genAndSee(50000)
end

begin
    """
    Encuentra un punto 1/3 entre dos puntos. Para type = 1, se elige el punto 1/3 hacia el vértice, para 2 el punto 1/3 hacia el punto arbitrario, y 
    para 3 se elige una opción aleatoria entre estas dos para cada iteración.
    """
    function oneThirdPoint(p,A,type)
        if type == 1
            return A .+ (p .- A) ./ 3
        elseif type == 2
            return p .+ (A .- p) ./ 3
        elseif type == 3
            randNum = rand(1:2)
            return A .+ (randNum/3) .* (p .- A)
        end
    end

    """
    Genera un numero _n_ de datos de la siguiente manera: genera un vector aleatorio con genVec() y obtiene
    un vértice aleatorio del triángulo con getAxis(). Luego obtiene el punto 1/3 y/o 2/3 (dependiendo del _type_) entre estos dos puntos e
    introduce las coordenadas (x,y) en dos matrices, xData y yData respectivamente. Finalmente regresa estos
    dos vectores de longitud _n_. 
    """
    function getDataT(n,type)
        xData = []
        yData = []
        p = genVec()
        A = getAxis()
        mp = Array{Float64}(undef,2)
        for i in 1:n
            mp .= oneThirdPoint(p,A,type)
            push!(xData, mp[1])
            push!(yData, mp[2])
            p = [xData[i], yData[i]]
            A = getAxis()
        end
        
        # @show xData
        # @show yData
        return xData, yData

    end 

    """
    Genera con getDataT(n, type) un número _n_ de datos y los dibuja con drawData(x,y).
    """
    function genAndSeeT(n,type)
        x,y = getDataT(n,type)
        drawData(x,y)
    end

    genAndSeeT(10000,1)
end

# begin
#     using Pkg
#     Pkg.activate(".")
#     Pkg.add("CairoMakie")
# end

# begin
#     using CairoMakie
# end