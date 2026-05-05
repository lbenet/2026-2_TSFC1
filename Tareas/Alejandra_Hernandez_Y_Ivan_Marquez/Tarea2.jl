# # Tarea 2: Diferenciación automática

# ## Ejercicio 1
#
# a. Definan una estructura en Julia `Dual` que represente a los números duales;
# los nombres de los campos internos serán `fun` y `der`.
# Por sencillez, pueden considerar que los campos de `Dual` son del tipo `Float64`,
# aunque pueden *osar* a implementar el caso paramétrico `Dual{T <: Real}`,
# donde `T` es el tipo de *ambos* campos.
#
struct Dual
    fun::Float64
    der::Float64
end

# b. Sobrecarguen las operaciones aritméticas (en Base) de tal manera que cuando involucren `Dual`es den el resultado correcto.

#La suma
function Base.:+(a::Dual, b::Dual)
	c = Dual(a.fun + b.fun, a.der + b.der)
    return c
end

# La resta
function Base.:-(a::Dual, b::Dual)
	c = Dual(a.fun - b.fun, a.der-b.der)
    return c
end

# La multiplicación
function Base.:*(a::Dual, b::Dual)
    c = Dual(a.fun * b.fun, (a.fun * b.der) + (a.der * b.fun))
    return c
end

# La división
function Base.:/(a::Dual, b::Dual)
    @assert b.fun != 0 "La división no está definida para un denominador sin parte real" 
    c = Dual(a.fun / b.fun, ((a.der * b.fun) - (a.fun * b.der))/((b.fun)^2))
end

# c. Definan un método específico para crear duales (constructor externo), a partir de
# un sólo valor (en lugar de los dos requeridos). Esto corresponderá a
# $\mathbb{D}_{x_0}c = (c, 0)$, donde $c$ es una constante (real).

function D(a::Real)
    c = Dual(a,0.0)
    return c
end

# d. Extiendan los métodos que permitan sumar/restar y multiplicar/dividir un
# número (`::Real`) y un `::Dual`. (Recuerden que ciertas operaciones son conmutativas!).
# NOTA: Este ejercicio lo pueden hacer escribiendo todos los métodos, uno a uno. Otra
# opción es usar `promote` y `convert` para definir reglas de promoción y conversión;
# la documentación de Julia tiene más información sobre esto.

import Base: convert
convert(::Type{Dual}, x::T) where {T<:Real} = Dual(x,x)

import Base: +
+(a::Dual, b::Real) = +(a, convert(Dual, b))
+(a::Real, b::Dual) = +(convert(Dual, a), b)
import Base: -
-(a::Dual, b::Real) = -(a, convert(Dual, b))
-(a::Real, b::Dual) = -(convert(Dual, a), b)
import Base: *
*(a::Dual, b::Real) = *(a, convert(Dual, b))
*(a::Real, b::Dual) = *(convert(Dual, a), b)
import Base: /
/(a::Dual, b::Real) = /(a, convert(Dual, b))
/(a::Real, b::Dual) = /(convert(Dual, a), b)


# e. Definan las funciones `fun` y `der` que, al ser aplicadas a un `Dual` devuelven
# la parte que corresponde a la función y la parte que corresponde a la derivada
# del `Dual`, respectivamente.

# Función fun, es la parte real

function fun(a::Dual)
    return a.fun
end

# Función der, corresponde a la parte epsilon

function der(a::Dual)
    return a.der
end

# f. Incluyan varios casos (propuestos por ustedes mismos) donde se *compruebe*
# que lo que
# implementaron da el resultado que debería ser. Para esto, pueden usar la librería
# estándard [`Test`](https://docs.julialang.org/en/v1/stdlib/Test/) de Julia.

#Para comparar, comenzaré definiendo == para duales

Base.:(==)(a::Dual, b::Dual) = a.fun == b.fun && a.der == b.der

using Test

@testset "Pruebas Ejercicio 1" begin 
    x = Dual(2,5)  
    y = Dual(3,6)
    
#Operaciones aritmeticas 
    @test x+y == Dual(2+3,5+6)
    @test x-y == Dual(2-3,5-6)
    @test x*y == Dual(2*3,(2*6)+(5*3))
    @test x/y == Dual(2/3 , ((5*3)-(2*6))/3^2)

#De Reales a duales
    @test D(3) == Dual(3,0)

#Extensión de operaciones aritmeticas, de rea-dual y dual-real
    @test 3+x == Dual(3+2,3+5)
    @test x+3 == Dual(3+2,3+5)
    @test 3+x == x+3
    
    @test 3-x == Dual(3-2,3-5)
    @test x-3 == Dual(2-3,5-3)
    
    @test x*3 == x*Dual(3,3)
    @test 3*x == Dual(3,3)*x
    @test x*3 == 3*x

    @test x/3 == x/Dual(3,3)
    @test 3/x == Dual(3,3)/x 

#Funciones fun y der
    @test fun(x) == 2
    @test der(x) == 5
    
end

# ## Ejercicio 2
#
# Definan una nueva función `dual(x_0)` cuyo resultado sea un `Dual` que corresponde
# a la variable independiente $x$ evaluada en `x_0`. Con esta función
# obtengan $f'(2)$ para la función
# ```math
# f(x) = \frac{3x^2-8x+1}{7x^3-1}.
# ```

#CREANDO EL DUAL x+1

function dual(x)
    """
    Se define el dual de la identidad; se usa la estructura Dual, y en la segunda entrada, se coloca la derivada de la identidad. 
    """
    return Dual(x,1)
end

# OBTENIENDO LA DERIVADA DE LA FUNCIÓN 

function Df(x)
    """
    Esta función es f(x) pero tomando a dual(x) como argumento 
    """
    return ((3*dual(x)*dual(x))-(8*dual(x))+1)/((7*dual(x)*dual(x)*dual(x))-1)
end

#DERIVADA ANALÍTICA 

function DfA(x)
    """
    Esta función es la derivada analítica de la función dada f()
    """
    return (((6*x)-8)/((7*x^3)-1)) - ((((3*x^2)-(8*x)+1)*(21*x^2))/((7*x^3)-1)^2)
end

D_dual = Df(2)    #Derivada hecha usando como argumento a los duales, i.e f(dual(x))
D_analitica = DfA(2)            #Derivada analítica f'(x)

der(D_dual)-D_analitica


# ## Ejercicio 3
#
# - A partir de lo visto en clase, *extiendan* las funciones elementales usuales para que funcionen con Duales, es decir, `sin(a::Dual)`, `cos(a::Dual)`, `tan(a::Dual)`, `^(a::Dual, n::Int)`, `sqrt(a::Dual)`, `exp(a::Dual)` y `log(a::Dual)`.

function Base.:sin(a::Dual)
    return Dual(sin(a.fun),cos(a.fun)*a.der)
end

function Base.:cos(a::Dual)
    return Dual(cos(a.fun),-sin(a.fun)*a.der)
end

function Base.:log(a::Dual)
    return Dual(log(a.fun),a.der/a.fun)
end

function Base.:exp(a::Dual)
    return Dual(exp(a.fun),exp(a.fun)*a.der)
end

function Base.:tan(a::Dual)
    return Dual(tan(a.fun),(sec(a.fun))^2*a.der)
end

function Base.:^(a::Dual,b::Real)
    return Dual(a.fun^b,b*((a.fun)^(b-1))*(a.der))
end

function Base.:sqrt(a::Dual)
    return Dual(sqrt(a.fun),(1/2)*(1/sqrt(a.fun))*a.der)
end

#
# - Al igual que antes, construyan algún conjunto de pruebas que muestre, de manera
# sencilla, que lo que hicieron da lo que uno esperaría obtener.

using Test 

Base.:(≈)(a::Dual, b::Dual) = a.fun ≈ b.fun && a.der ≈ b.der


@testset "Pruebas ejercicio 3" begin 
    x = Dual(4,12)
    
    @test sin(x) ≈ Dual(sin(4), cos(4)*12 )
    @test cos(x) ≈ Dual(cos(4),-sin(4)*12)
    @test log(x) ≈ Dual(log(4), 12/4)
    @test exp(x) ≈ Dual(exp(4),exp(4)*12)
    @test tan(x) ≈ Dual(tan(4),(sec(4)^2)*12)
    @test x^2 == x*x
    @test x^3 == x*x*x
    @test sqrt(x) == Dual(sqrt(4),(1/2)*(1/sqrt(4)*12))
end
