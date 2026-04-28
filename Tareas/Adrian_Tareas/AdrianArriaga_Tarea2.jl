#TSFC1 - Tarea 2                       Adrián Arriaga

#Pkg
using LaTeXStrings 
using Test

# a. Se define la estructura de los numeros duales, con los campos 'fun' y 'der', los cuales  
# son subtipos del campo 'Real'. 

struct DualNumb{T<:Real}
    fun::T
    der::T
end

#b. Se sobrecargan las operaciones aritméticas y funciones elementales para los Duales.
import Base: +, -, *, /, ^, sin, cos, tan, exp, log, sqrt, sinh, cosh

# Se sobrecargan las operaciones aritméticas.
function +(a::DualNumb, b::DualNumb)
    c = DualNumb(a.fun + b.fun, a.der + b.der)
    return c
end

function -(a::DualNumb, b::DualNumb)
    c = DualNumb(a.fun - b.fun, a.der - b.der)
    return c
end

function *(a::DualNumb, b::DualNumb)
    c = DualNumb((a.fun)*(b.fun), (a.fun)*(b.der) + (a.der)*(b.fun))
    return c
end


function /(a::DualNumb, b::DualNumb)
    local x = a.fun
    local y = a.der
    local u = b.fun
    local w = b.der
    c = DualNumb((x)*(u^(-1)), ((y)*(u) - (x)*(w))*(u^(-2)))
    return c
end

function ^(a::DualNumb, n::Int64)
    c = DualNumb((a.fun)^n, n*(a.fun^(n-1))*(a.der))
    return c
end


#c. Se define un método específico para crear duales (constructor externo), a partir de
# un sólo valor (en lugar de los dos requeridos). Esto corresponde a
# $\mathbb{D}_{x_0}c = (c, 0)$, donde $c$ es una constante (real).

function DualNumb(u::Real)
    c = DualNumb(u, zero(u))
    return c
end

dd = DualNumb(5)


# d. Se extienden los métodos que permitan sumar/restar y multiplicar/dividir un
# número (`::Real`) y un `::Dual`. 

function +(a::Real, b::DualNumb)
    c = DualNumb(a) + b
    return c
end

function +(a::DualNumb, b::Real)
    c = a + DualNumb(b)
    return c
end


function -(a::Real, b::DualNumb)
    c = DualNumb(a) - b
    return c
end

function -(a::DualNumb, b::Real)
    c = a - DualNumb(b)
    return c
end

function *(a::Real, b::DualNumb)
    c = DualNumb(a)*b
    return c
end

function *(a::DualNumb, b::Real)
    c = a*DualNumb(b)
    return c
end

function /(a::Real, b::DualNumb)
    c = DualNumb(a)/b
    return c
end

function /(a::DualNumb, b::Real)
    c = a/DualNumb(b)
    return c
end

# e. Se definen las funciones `fun` y `der` que, al ser aplicadas a un `Dual` devuelven
# la parte que corresponde a la función y la parte que corresponde a la derivada
# del `Dual`, respectivamente.
function fun(u::DualNumb)
    c = u.fun;
    return c
end

function der(u::DualNumb)
    c = u.der;
    return c
end




# f. Se incluyen varios casos (propuestos por ustedes mismos) donde se *comprueba*
# que lo que implementaron da el resultado que debería ser.
# Para esto, pueden usar la librería estándard [`Test`](https://docs.julialang.org/en/v1/stdlib/Test/) de Julia.

@testset "Test dual arithmetic" begin
    
    A = DualNumb(1.0, 3.0)
    B = DualNumb(2.0, 1.0)

    # Pruebas de aritmética básica: 
    @test A + B == DualNumb(3.0, 4.0)
    @test A - B == DualNumb(-1.0, 2.0)
    @test A * B == DualNumb(2.0, 7.0)
    @test A / B == DualNumb(0.5, 1.25)

    # Probando operaciones mixtas: 
    @test A^2 == DualNumb(1.0, 6.0) 
    @test A * 2.0 == DualNumb(2.0, 6.0) 
    
    # Probando el generador de Duales: 
    @test DualNumb(2.0) == DualNumb(2.0, 0.0)

    #Probando las funciones fun() y der():
    @test fun(A) == 1.0
    @test der(A) == 3.0


end


# ## Ejercicio 2
#
# Se define una nueva función `dual(x_0)` cuyo resultado sea un `Dual` que corresponde
# a la variable independiente $x$ evaluada en `x_0`. Con esta función
# obtengan $f'(2)$ para la función
# ```math
# f(x) = \frac{3x^2-8x+1}{7x^3-1}.
# ```


function dual(x_0)
    a, b = promote(x_0, one(x_0))
    c = DualNumb(a, b)
    return c
end

f(x) = (3x^2-8x+1)/(7x^3-1)
f(dual(2.0))
f(dual(2//1))

# ## Ejercicio 3
#
# A partir de lo visto en clase, *extiendan* las funciones elementales usuales para que funcionen con Duales, es decir, `sin(a::Dual)`, `cos(a::Dual)`, `tan(a::Dual)`, `^(a::Dual, n::Int)`, `sqrt(a::Dual)`, `exp(a::Dual)` y `log(a::Dual)`.
#
# - Al igual que antes, construyan algún conjunto de pruebas que muestre, de manera
# sencilla, que lo que hicieron da lo que uno esperaría obtener.

#Se sobrecargan las funciones elementales:
function sin(a::DualNumb)
    c = DualNumb(sin(fun(a)), cos(fun(a))*der(a))
    return c
end

function cos(a::DualNumb)
    c = DualNumb(cos(fun(a)), -sin(fun(a))*der(a))
    return c
end

function tan(a::DualNumb)
    c = DualNumb(tan(fun(a)), (sec(fun(a))^2)*der(a))
    return c
end

function log(a::DualNumb)
    c = DualNumb(log(fun(a)), der(a)/fun(a))
    return c
end

function exp(a::DualNumb)
    c = DualNumb(exp(fun(a)), exp(fun(a))*der(a))
    return c
end

function sqrt(a::DualNumb)
    c = DualNumb(sqrt(fun(a)), (0.5)*(fun(a)^(-0.5))*der(a))
    return c
end


function sinh(a::DualNumb)
    c = DualNumb(sinh(fun(a)), cosh(fun(a))*der(a))
    return c
end

function cosh(a::DualNumb)
    c = DualNumb(cosh(fun(a)), sinh(fun(a))*der(a))
    return c
end

@testset "Testing elemental functions over dual numbers" begin
    
    #Se crea un dual evaluado en x_0 = π:

    @test dual(pi) == DualNumb(Float64(pi), 1.0)

    x_pi = dual(π) # Equivale a evaluar en x = pi
    x_zero = dual(0.0)
    x_one = dual(1.0) # Equivale a evaluar en x = 0
    
    # Derivada de sen(x) es cos(x). En x=pi, cos(pi) = -1. 
    # Usamos ≈ porque pi tiene infinitos decimales.
    @test der(exp(x_zero)) ≈ 1.0 
    @test der(sin(x_pi)) ≈ -1.0 
    @test der(cos(dual(0.5*π))) ≈ -1.0 
    @test der(tan(x_zero)) ≈ 1.0 
    @test der(tan(x_one)) ≈ 3.425518820814759
    @test der(sqrt(dual(4.0))) ≈ 0.25

    @test der(cosh(x_zero)) ≈ 0.0
    @test der(sinh(x_zero)) ≈ 1.0

end
