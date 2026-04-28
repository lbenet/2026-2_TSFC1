# # Tarea 1

# Tarea 1
using Plots
using SimplePolynomials #para evitar errores tipo OverFlow
# ## 1. Triángulo de Pascal
#
# a. Generen el triángulo de Pascal, hasta cierto orden `ord`, usando una
# matriz de enteros, en la que cada renglón representa un orden distinto.
# Hagan que la apariencia de este vector sea lo más simétrico posible.
#
# b. Usen la matriz creada para generar *otra*, en que todos los números
# pares aparezcan como `false` y los impares como `true`, o alternativamente
# como 0 y 1, respectivamente. Las funciones `isodd` o `iseven` pueden
# serles útiles.
#
# c. Dibujen (con puntos) todos los valores impares del triángulo de Pascal
# para `ord=256`. Repitan el ejercicio para `ord=1024`.
"""
Genera un polinomio (objeto tipo SymplePolynomial) de grado n
con raiz -1. El coeficiente de x^k en este polinomio será:
binomial(n,k)
"""
function pol(n::Int64)
    x=getx()
    return (x+1)^n
end

"""
Devuelve un vector de tamaño n+1, cuya entrada k-ésima es el coeficiente
del término x^k en el polinomio p=(x+1)^n.

Análogamente, su entrada k-ésima es igual a binomial(n,k), mas este método no causa
un error tipo OverflowError.
"""
function cpol(n::Int64)
    c=coeffs(pol(n))
    return c
end

"""
Devuelve un vector de tamaño n, donde todas sus entradas tienen 
tipo BigInt y valor 0.
"""
function zerosB(n::Int64)
    cosa::Array{BigInt,1}=zeros(n)
    return cosa
end


"""
Dado un vector tamaño l con entradas BigInt, lo extiende hasta un tamaño 
deseado size (donde size >= l), rellenando los espacios faltantes con 0's.
"""
function pad(v::Array{BigInt,1},size::Int64) #size >=length(v)
    f=size-length(v)
    faltantes=zerosB(f)
    append!(v,faltantes)
    return v
end

"""
Dado un vector tamaño l con entradas BigInt, lo extiende hasta un tamaño 
deseado size (donde size >= l), rellenando hacia la izquierda y hacia la derecha
con 0's.
"""
function pad_symm(v::Array{BigInt,1},size::Int64) #size > =length(v)
    f=size-length(v)
    recept::Array{BigInt,1}=[]
    if mod(f,2)==0
        faltantes=zerosB(div(f,2))
        append!(recept,faltantes)
        append!(recept,v)
        append!(recept,faltantes)
    else    #f mod 2 = 1
        append!(recept,zerosB(div(f,2)))
        append!(recept,v)
        append!(recept,zerosB(div(f,2)+1))
    end
    return recept
end

"""
Dado un vector con entradas BigInt, intercala 0's en sus entradas
y lo devuelve.
"""
function insert_zeros(v::Array{BigInt,1})
    if length(v) <= 1
        return v 
    else
        recept::Array{BigInt,1}=zeros(2*length(v)-1)
        for i in 1:length(v)
            recept[2*i-1]=v[i]
        end
        return recept
    end
end

#Primer intento del tríangulo de pascal con resultado no simétrico
"""
Devuelve una matriz tamaño (ord+1,ord+1) cuyas entradas corresponden al
triángulo de Pascal. Tiene apariencia asimétrica.

En desuso.
"""
function pascal_old(ord::Int64)
    M::Array{BigInt,2}=zeros(ord+1,ord+1) 
    for i in 1:ord+1
        M[i,:]=pad_symm(cpol(i-1),ord+1)
    end
    return M
end

"""
Devuelve una matriz tamaño (ord+1,2ord+1), donde cada renglón 
corresponde a un orden distinto en el tríangulo de Pascal.

Contiene 0's intercalados en cada renglón para tener apariencia simétrica.
"""
function pascal(ord::Int64)
    ancho=2*ord+1
    M::Array{BigInt,2}=zeros(ord+1,ancho) 
    for i in 1:ord+1
        M[i,:]=pad_symm(insert_zeros(cpol(i-1)),ancho)
    end
    return M
end

"""
Devuelve una matriz tamaño (ord+1,2ord+1), donde cada renglón 
corresponde a las entradas impares del triángulo de Pascal.
"""
function pascal_odd(ord::Int64)
    M=pascal(ord)
    return isodd.(M)
end

"""
Dibuja con puntos las entradas impares del triángulo
de Pascal.
"""
function pascal_draw(ord::Int64)
    M=pascal_odd(ord)
    a,b=size(M)
    p=scatter(legend=:false) #inicializa la gráfica
    for i in 1:a
        for j in 1:b
            if M[i,j]==true
                scatter!((j,a+1-i),mc=:black,ms=2) ##(i,j)->(j,a+1-i) rota e invierte respecto a y=a+1
            end
        end
    end
    return p
end

# ## 2. Triángulo equilátero
#
# Sean $X_1$, $X_2$ y $X_3$ los vértices de un triángulo equilátero en el
# plano. Implementen el siguiente algoritmo.
#
# a. Elijan al azar un punto dentro del triángulo equilátero, que llamaré $Y_0$.
# Es la condición inicial.
#
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
"""
Define un tríangulo por sus vértices 

Los vértices se dan de forma ordenada, así que el tríangulo
definido por (v1,v2,v3) es distinto a (v2,v3,v1)
"""
struct Triangle
    a::NTuple{2,Float64}
    b::NTuple{2,Float64}
    c::NTuple{2,Float64}
end



"""
Devuelve un vector con los vértices del tríangulo en
el orden del constructor.
"""
function vertices(T::Triangle)
    return [T.a,T.b,T.c]
end



"""
Devuelve la distancia euclidea entre dos 'puntos'(2-tupla)
"""
function distP2P(a::NTuple{2,Float64}, b::NTuple{2,Float64})
    r_cuadrado=(a[1]-b[1])*(a[1]-b[1])+(a[2]-b[2])*(a[2]-b[2])
    return sqrt(r_cuadrado)
end



#Requiere modificación ya que el orden no es obvio,
# es mejor devolver un diccionario
"""
Devuelve un una 3-tupla con la longitud de los lados del tríangulo
"""
function LsidesT(t::Triangle)
    s1=distP2P(t.a,t.b)
    s2=distP2P(t.a,t.c)
    s3=distP2P(t.b,t.c)
    return s1,s2,s3
end

#Objetos Triangle de ejemplo y para uso posterior
t1=Triangle((1.2,5),(-2.6,0.9),(0.0,7.0))

pitag=Triangle((0,0),(0,4),(3,0))


"""
Devuelve un triangulo equilátero, cuyos lados miden L.

Este tríangulo tendrá un vértice en el origen y estará complétamente contenido en el primer cuadrante (x,y>=0) del plano
"""
function equi(L::Float64)
    v1=(0,0)
    v2=(L,0)
    h=sqrt(3)*L/2
    v3=(L/2,h)
    return Triangle(v1,v2,v3)
end

"""
Método para Triangle. Lo dibuja en un objeto 'Plot',
lo despliega y devuelve para manipulación extra.
"""
function drawT(tri::Triangle)
    p=scatter(tri.a, mc=:black,ms=1)
    scatter!(tri.b, mc=:black,ms=1)
    scatter!(tri.c, mc=:black,ms=1)
    x=range(0,1,length=100)
    l1(t)=@. tri.a+(tri.b-tri.a)*t
    l2(t)=@. tri.a+(tri.c-tri.a)*t
    l3(t)=@. tri.b+(tri.c-tri.b)*t
    y1=l1.(x)
    y2=l2.(x)
    y3=l3.(x)
    plot!(y1,lw=3,lc=:black)
    plot!(y2,lw=3,lc=:black)
    plot!(y3,lw=3,lc=:black)
    display(p)
    return p
end

"""
    punto_medio(p1,p2)

Devuelve el punto (2-tupla) medio entre los puntos
p1 y p2.

Por su construcción, funciona con cualquier NTuple{n,Number}
o con vectores (Array{Number,1})
"""
function punto_medio(p1,p2)
    p3=@. (p1+p2)/2
    return p3
end


"""
    punto_frac(p1,p2,q)

Devuelve el punto (2-tupla) p entre p1 y p2 tal que:
    distP2P(p1,p)=q*distP2P(p1,p2)

Valor por default de q=1/2 (cuando este se omite).
Por su construcción, funciona con cualquier NTuple{n,Number}
o con vectores (Array{Number,1})
"""
function punto_frac(p1,p2,q=1/2)
    p3=@. p1+(p2-p1)*q
    return p3
end

#Inicia la caminata aleatoria del problema 2

"""
    step(T,x)

Devuelve el punto medio entre un vértice aleatorio del 
tríangulo T y el punto x.

Por default, x toma el valor (1,1).
"""
function step(T::Triangle, x=(1,1))
    v=vertices(T)
    #drawT(T)
    #scatter!(x_0, mc=:red, ms=5)
    return punto_frac(x, rand(v))
end

#Nota: usar push!() para añadir un elemento, append!() para varios.

"""
    caminataP2(T,n,x_0)

Devuelve un vector de longitud n+1 con la siguiente
caminata aleatoria de n pasos en el plano:

Comienza en x_0 un punto dentro de t (a priori random), 
x_{n} será el punto medio entre x_{n-1} y un vértice
aleatorio de T.
"""
function caminataP2(T::Triangle, n, x_0=(1.0,1.0))
    X::Array{NTuple{2,Float64},1}=[x_0]
    for i in 1:n 
        x_temp=step(T,X[i])
        push!(X,x_temp)
    end
    return X
end

equilatero=equi(3)

cosa=caminataP2(equilatero,10000)
p1=drawT(equilatero)
p1=scatter!(cosa, mc=:red, ms=2, title="punto medio")

# ## 3. Proporción distinta
#
# Repitan el ejercicio anterior usando ahora, no el punto medio, sino 1/3
# de la distancia entre el vértice elegido al azar y el iterado $Y_n$.
#

"""
    step3(T,x)

Devuelve punto_frac(q=1/3) entre un vértice aleatorio del 
tríangulo T y el punto x.

Por default, x toma el valor (1,1).
"""
function step3(T::Triangle, x=(1,1))
    v=vertices(T)
    #drawT(T)
    #scatter!(x_0, mc=:red, ms=5)
    return punto_frac(x, rand(v),2/3)
end


"""
    caminataP3(T,n,x_0)

Devuelve un vector de longitud n+1 con la siguiente
caminata aleatoria de n pasos en el plano:

Comienza en x_0 un punto dentro de t (a priori random), 
x_{n} será el punto_frac(q=1/3) entre x_{n-1} y un vértice
aleatorio de T.
"""
function caminataP3(T::Triangle, n, x_0=(1.0,1.0))
    X::Array{NTuple{2,Float64},1}=[x_0]
    for i in 1:n 
        x_temp=step3(T,X[i])
        push!(X,x_temp)
    end
    return X
end

cosa2=caminataP3(equilatero,10000)
p2=drawT(equilatero)
p2=scatter!(cosa2, mc=:red, ms=2, title="punto_tercio")
