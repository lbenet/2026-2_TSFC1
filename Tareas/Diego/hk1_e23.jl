using Plots
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
#v1=vertices(pitag)
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



"""
    caminataP2(T,n,x_0)

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

equilatero=equi(3.0)

cosa=caminataP2(equilatero,10000)
p1=drawT(equilatero)
p1=scatter!(cosa, mc=:red, ms=2, title="punto medio=sierpinski")


cosa2=caminataP3(equilatero,10000)
p2=drawT(equilatero)
p2=scatter!(cosa2, mc=:red, ms=2, title="punto_tercio=caos")

#plot(p1,p2, layout=(1,2),legend=false)
