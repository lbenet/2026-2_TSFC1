# # Tarea 2: Diferenciación automática

# ## Ejercicio 1
#
# a. Definan una estructura en Julia `Dual` que represente a los números duales;
# los nombres de los campos internos serán `fun` y `der`.
# Por sencillez, pueden considerar que los campos de `Dual` son del tipo `Float64`,
# aunque pueden *osar* a implementar el caso paramétrico `Dual{T <: Real}`,
# donde `T` es el tipo de *ambos* campos.
#
# b. Sobrecarguen las operaciones aritméticas (en Base) de tal manera que cuando involucren `Dual`es den el resultado correcto.
#
# c. Definan un método específico para crear duales (constructor externo), a partir de
# un sólo valor (en lugar de los dos requeridos). Esto corresponderá a
# $\mathbb{D}_{x_0}c = (c, 0)$, donde $c$ es una constante (real).
#
# d. Extiendan los métodos que permitan sumar/restar y multiplicar/dividir un
# número (`::Real`) y un `::Dual`. (Recuerden que ciertas operaciones son conmutativas!).
# NOTA: Este ejercicio lo pueden hacer escribiendo todos los métodos, uno a uno. Otra
# opción es usar `promote` y `convert` para definir reglas de promoción y conversión;
# la documentación de Julia tiene más información sobre esto.
#
# e. Definan las funciones `fun` y `der` que, al ser aplicadas a un `Dual` devuelven
# la parte que corresponde a la función y la parte que corresponde a la derivada
# del `Dual`, respectivamente.
#
# f. Incluyan varios casos (propuestos por ustedes mismos) donde se *compruebe*
# que lo que
# implementaron da el resultado que debería ser. Para esto, pueden usar la librería
# estándard [`Test`](https://docs.julialang.org/en/v1/stdlib/Test/) de Julia.

import Base.+
import Base.-
import Base.*
import Base./
using Test
#Definimos el tipo dual, parametrizado por T (subtipo de Real)
struct Dual{T<:Real}
    fun::T
    der::T
end

function +(x::Dual, y::Dual)
    return Dual(x.fun+y.fun, x.der+y.der)
end

function -(x::Dual, y::Dual)
    return Dual(x.fun-y.fun, x.der-y.der)
end

function -(y::Dual)
    return Dual(-y.fun,-y.der)
end


function *(x::Dual, y::Dual)
    return Dual(x.fun*y.fun, x.der*y.fun+y.der*x.fun)
end

function /(x::Dual, y::Dual)
    return Dual(x.fun/y.fun, (x.der*y.fun-y.der*x.fun)/(y.fun^2))
end


#CONSTRUCTOR PARA CONSTANTES
function dual_const(c::T) where {T<:Real}
    return Dual(c,convert(typeof(c),0))
end

#OPERACIONES DUAL-REAL
function +(x::Real, y::Dual)
    return Dual(x+y.fun,y.der)
end

function -(x::Real, y::Dual)
    return Dual(x-y.fun,-y.der)
end


function *(x::Real, y::Dual)
    return Dual(x*y.fun, x*y.der)
end

function /(x::Real, y::Dual)
    return Dual(x/y.fun, (-y.der*x)/(y.fun^2))
end


# métodos conmutados 
function +(x::Dual, y::Real)
    return y+x
end

function -(x::Dual, y::Real)
    return Dual(x.fun-y, x.der-y)
end


function *(x::Dual, y::Real)
    return y*x
end

function /(x::Dual, y::Real)
    return Dual(x.fun/y, x.der/y)
end

# extraer parámetros (fun y der)

function fun(x::Dual)
    return x.fun
end

function der(x::Dual)
    return x.der
end


##Tests
import Base.isapprox
function isapprox(x::Tuple{T,T},y::Tuple{T,T};kargs...) where {T<:Real}
    return isapprox(x[1],y[1];kargs...) && isapprox(x[2],y[2];kargs...)
end

function isapprox(x::Tuple{T,T},y::Tuple{S,S};kargs...) where {T<:Real, S<:Real}
    return isapprox(x[1],y[1];kargs...) && isapprox(x[2],y[2];kargs...)
end

isapprox(x::Dual, y::Dual; kargs...)=isapprox((x.fun, x.der), (y.fun,y.der);kargs...) 



d0=dual_const(0.0)
d1=Dual(7,-1)
d2=Dual(4,3)
d3=Dual(11.0,2.0)
dr=Dual(7//2,1//3)
dR=Dual(5//1,-2//7)

@testset "dual-dual sums" begin 
    @test d1+d2==Dual(11,2)
    @test d1+d2 !=d3
    @test d1+d0 !=d1
    @test d3+d0==d3
    @test d1+dr==Dual(21//2,-2//3)
    @test d3+dr==Dual(14.5,convert(Float64,2.0+1//3))
    @test d1-d1==dual_const(0)
    @test dr-dR==Dual(-3//2,13//21)
end


@testset "dual-dual products" begin
    @test d0*d1==d0
    @test d1*dr==Dual(49//2, -7//6)
    @test d2*d2==Dual(16,24)
    @test d3*(d1+d2)==d3*d3
    @test dr*(d1+d2)==dr*d1+dr*d2
    @test d0/d1==d0
    @test d1/d2==Dual(7/4,-25/16)
    @test dR/dR==Dual(1//1,0//1)
end

a=-1
b=5.0
c=8.17
r=3//2
@testset "real-dual products" begin
    @test -d1==a*d1
    @test d3*5==b*d3
    @test r*dr==3*dr/2 != (3/2)*dr
    #@test c*d1+c*d2==c*d3 #falla por poco 
    @test isapprox(c*d1+c*d2,c*d3) #aunque el default es atol=0, el test pasa
end


# ## Ejercicio 2
#
# Definan una nueva función `dual(x_0)` cuyo resultado sea un `Dual` que corresponde
# a la variable independiente $x$ evaluada en `x_0`. Con esta función
# obtengan $f'(2)$ para la función
# ```math
# f(x) = \frac{3x^2-8x+1}{7x^3-1}.
# ```

using SimplePolynomials

function dual(x_0)
    return Dual(x_0,1)
end

f(x)=(3x*x-8x+1)/(7x*x*x-1)

f(dual(2))
x=getx()
p=(3x*x-8x+1)/(7x*x*x-1)

#El primero de estos tests pasa al ser aproximado, los siguientes fallan por motivos aún desconocidos
@testset "Rational function" begin
    @test f(dual(2)) ≈ Dual(convert(Float64,p(2)),convert(Float64,p'(2))) atol=0.001
    @test p(dual(2))==Dual(p(2),p'(2)) #debería pasar pero no lo hace
    p0=p(0)
    @test dual_const(p0)==dual_const(p0) 
end


# ## Ejercicio 3
#
# - A partir de lo visto en clase, *extiendan* las funciones elementales usuales para que funcionen con Duales, es decir, `sin(a::Dual)`, `cos(a::Dual)`, `tan(a::Dual)`, `^(a::Dual, n::Int)`, `sqrt(a::Dual)`, `exp(a::Dual)` y `log(a::Dual)`.
#
# - Al igual que antes, construyan algún conjunto de pruebas que muestre, de manera
# sencilla, que lo que hicieron da lo que uno esperaría obtener.
import Base.^
import Base.sin
import Base.cos
import Base.tan
import Base.sqrt
import Base.exp
import Base.log 

function ^(x::Dual, n::Integer)
    return Dual(x.fun^n, n*x.der*x.fun^(n-1))
end

function sin(x::Dual)
    return Dual(sin(x.fun), x.der*cos(x.fun))
end

function cos(x::Dual)
    return Dual(cos(x.fun),-x.der*sin(x.fun))
end

function tan(x::Dual)
    return Dual(tan(x.fun), x.der*sec(x.fun)*sec(x.fun))
end

function sqrt(x::Dual)
    return Dual(sqrt(x.fun),x.der/(2*sqrt(x.fun)))
end

function exp(x::Dual)
    return Dual(exp(x.fun),x.der*exp(x.fun))
end

function log(x::Dual)
    return Dual(log(x.fun),x.der/x.fun)
end 


@testset "trigonometrics" begin
    @test tan(d1) ≈ sin(d1)/cos(d1) atol=0.000001
    @test cos(d0) ≈ Dual(1.0,0.0) atol=0.000001
    @test sin(d0) ≈ Dual(0.0,0.0) atol=0.000001
    @test tan(d0) ≈ Dual(0.0,0.0) atol=0.000001
    @test cos(d3)^2+sin(d3)^2 ≈ Dual(1.0,0.0) atol=0.000001
    @test sin(d1+d2) ≈ sin(d1)cos(d2)+sin(d2)cos(d1) atol=0.000001
    @test cos(d1+d2) ≈ cos(d1)cos(d2)-sin(d2)sin(d1) atol=0.000001
    @test tan(d1+d2) ≈ (tan(d1)+tan(d2))/(1-tan(d1)tan(d2)) atol=0.000001
    @test cos(2*d2) ≈ cos(d2)^2-sin(d2)^2 atol=0.000001
    @test sin(2*d1) ≈ 2*sin(d1)*cos(d1) atol=0.000001
    @test cos(dr)^2 ≈ (1+cos(2*dr))/(2) atol=0.000001 
    @test sin(dr)^2 ≈ (1-cos(2*dr))/(2) atol=0.000001 #identidades de cuadrados pasan
    @test cos(dr) ≈ sqrt((1+cos(2*dr))/(2)) atol=0.000001  
    @test sin(dr) ≈ sqrt((1-cos(2*dr))/(2)) atol=0.000001  #pero al tomar raíz fallan 
    @test cos(dr) ≈ -sqrt((1+cos(2*dr))/(2)) atol=0.000001  
    @test sin(dr) ≈ -sqrt((1-cos(2*dr))/(2)) atol=0.000001  #(por un signo menos)
end

@testset "other functions" begin
    @test sqrt(d1^2) ≈ sqrt(d1)^2 atol=0.000001
    @test exp(d0) ≈ Dual(1.0,0.0) atol=0.000001
    @test exp(log(d3)) ≈ d3 atol=0.000001
    @test log(exp(d3)) ≈ d3 atol=0.000001
    @test exp(log(d1)) ≈ d1 atol=0.000001
    @test sqrt(d0) != Dual(0.0, NaN)
    @test sqrt(dual(0)) == Dual(0.0, Inf)
end