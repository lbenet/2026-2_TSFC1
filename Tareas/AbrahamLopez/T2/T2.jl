# # Tarea 2: Diferenciación automática

# SECTION Ejercicio 1
#
# a. Definan una estructura en Julia `Dual` que represente a los números duales;
# los nombres de los campos internos serán `fun` y `der`.
# Por sencillez, pueden considerar que los campos de `Dual` son del tipo `Float64`,
# aunque pueden *osar* a implementar el caso paramétrico `Dual{T <: Real}`,
# donde `T` es el tipo de *ambos* campos.

"""
    Estructura que representa a los números duales. Dual es subtipo de Real y acepta como campos su parte real **fun**
    y su parte derivada **der**; ambos campos son subtipos de Real.
"""
struct Dual{T<:Real}<:Real
    fun::T
    der::T
end
# NOTE Dual es subtipo de Real porque la promoción solo es aplicada automáticamente a ops. aritméticas del subtipo Number. Como Real es subtipo de Number,
# el Dual debe ser subtipo de Real o Number para cumplir con el inciso d.

# NOTE Esta línea se encarga de que si se introducen dos tipos distintos en los campos del Dual, los promueve al mismo tipo.
Dual(f::Real, d::Real) = Dual(promote(f, d)...)

# b. Sobrecarguen las operaciones aritméticas (en Base) de tal manera que cuando involucren `Dual`es den el resultado correcto.

begin
    import Base: +, -, *, /

    +(u::Dual, w::Dual) = Dual(u.fun + w.fun, u.der + w.der)
    -(u::Dual, w::Dual) = Dual(u.fun - w.fun, u.der - w.der)
    *(u::Dual, w::Dual) = Dual(u.fun * w.fun, (u.fun * w.der) + (w.fun * u.der))
    /(u::Dual, w::Dual) = Dual(u.fun / w.fun, ((u.der*w.fun)-(u.fun*w.der)) / w.fun^2)
end

# c. Definan un método específico para crear duales (constructor externo), a partir de
# un sólo valor (en lugar de los dos requeridos). Esto corresponderá a
# $\mathbb{D}_{x_0}c = (c, 0)$, donde $c$ es una constante (real).

Dual(c::T) where {T<:Real} = Dual(c, zero(T))

# d. Extiendan los métodos que permitan sumar/restar y multiplicar/dividir un
# número (`::Real`) y un `::Dual`. (Recuerden que ciertas operaciones son conmutativas!).
# NOTA: Este ejercicio lo pueden hacer escribiendo todos los métodos, uno a uno. Otra
# opción es usar `promote` y `convert` para definir reglas de promoción y conversión;
# la documentación de Julia tiene más información sobre esto.


 #= NOTE
    El problema con este inciso es que Type{Dual} no es el tipo Singleton de las instancias de dual.
    Es decir que Dual{Int} isa Type{Dual} = false, pero Dual{Int} isa Type{Dual{Int}} = true.
    Adicionalmente, como Real es tipo abstracto, no podemos declarar directamente que 
    Base.convert(::Type{Dual{<:Real}}, x::Real)= Dual{<:Real}(x, zero(<:Real)), porque Julia no sabe que
    construir solamente con <:Real. Por eso se hace el uso de T, S y los `where`.
    =#
    Dual{Int} isa Type{Dual}
    Dual{Int} isa Type{Dual{Int}}
begin
    # NOTE Convierte una variable de tipo Real **x** a un Dual subtipo de Real de la forma x+0.
    Base.convert(::Type{Dual{T}}, x::Real) where {T<:Real}= Dual{T}(x, zero(T))
    # NOTE Convierte una estructura dual a un dual subtipo Real. El motivo es llevar tanto el dual como la variable Real al mismo nivel.
    Base.convert(::Type{Dual{T}}, x::Dual) where {T<:Real}= Dual{T}(x.fun, x.der)
    # NOTE Cuando se realiza una operación entre un Dual y un Real, el tipo del Dual resultante sera el mas general entre el Real y los campos del Dual.
    Base.promote_rule(::Type{Dual{S}},::Type{T}) where {S<:Real,T<:Real} = Dual{promote_type(S,T)}
    # NOTE Cuando se realiza una operación entre dos Duales con subtipos de Real diferentes (e.g. Int64 y Float64) promueve el tipo del Dual resultante al mas general de los campos de ambos duales. 
    Base.promote_rule(::Type{Dual{S}},::Type{Dual{T}}) where {S<:Real,T<:Real} = Dual{promote_type(S,T)}
end

# e. Definan las funciones `fun` y `der` que, al ser aplicadas a un `Dual` devuelven
# la parte que corresponde a la función y la parte que corresponde a la derivada
# del `Dual`, respectivamente.

begin
    function fun(a :: Dual)
        return a.fun
    end

    function der(a :: Dual)
        return a.der
    end
end

# f. Incluyan varios casos (propuestos por ustedes mismos) donde se *compruebe*
# que lo que
# implementaron da el resultado que debería ser. Para esto, pueden usar la librería
# estándard [`Test`](https://docs.julialang.org/en/v1/stdlib/Test/) de Julia.

#=
import Pkg;
Pkg.add("Symbolics")
using Symbolics

# NOTE Esta parte de codigo solo es simbolico para no realizar la simplificacion a mano
@variables x
a = simplify(expand((3(2+x)^2 - 8(2+x) + 5) + (7(2+x)^3 - 1)))
b = simplify(expand((3(2+x)^2 - 8(2+x) + 5) - (7(2+x)^3 - 1)))
c = simplify(expand((7(2+x)^3 - 1) - (3(2+x)^2 - 8(2+x) + 5)))
d = simplify(expand((3(2+x)^2 - 8(2+x) + 5) * (7(2+x)^3 - 1)))
e = simplify(expand((3(2+x)^2 - 8(2+x) + 5) / (7(2+x)^3 - 1)))
g = simplify(expand((7(2+x)^3 - 1) / (3(2+x)^2 - 8(2+x) + 5)))
D = Differential(x)

u+w == Dual(substitute(a, Dict(x => 2)),substitute(expand_derivatives(D(a)), Dict(x => 2)))
u-w == Dual(substitute(b, Dict(x => 2)),substitute(expand_derivatives(D(a)), Dict(x => 2)))
w-u == Dual(substitute(c, Dict(x => 2)),substitute(expand_derivatives(D(a)), Dict(x => 2)))
u*w == Dual(substitute(d, Dict(x => 2)),substitute(expand_derivatives(D(a)), Dict(x => 2)))
u/w == Dual(substitute(e, Dict(x => 2)),substitute(expand_derivatives(D(a)), Dict(x => 2)))
w/u == Dual(substitute(f, Dict(x => 2)),substitute(expand_derivatives(D(a)), Dict(x => 2)))
=#

U(x) = 3(x)^2 - 8(x) + 5
W(x) = 7(x)^3 - 1 
xdual = Dual(2.0, 1.0)
u = U(xdual)
w = W(xdual)
u == Dual(U(2.0), 6*2-8)
w == Dual(W(2.0), 21*2^2)

using Test
@testset "aritmetica dual" begin
    @test u+w ≈ Dual(56,88)
    @test u-w ≈ Dual(-54,-80)
    @test w-u ≈ Dual(54,80)
    @test u*w ≈ Dual(55,304)
    @test u/w ≈ Dual(1/55, 136/3025)
    @test w/u ≈ Dual(55,-136)
end

@testset "aritmetica dual real" begin
    @test 5+u ≈ Dual(6,4)
    @test 5-u ≈ Dual(4,-4)
    @test u-5 ≈ Dual(-4,4)
    @test 5*u ≈ Dual(5,20)
    @test 5/u ≈ Dual(5,-20)
    @test u/5 ≈ Dual(0.2,0.8)
end

# !SECTION
# SECTION Ejercicio 2
#
# Definan una nueva función `dual(x_0)` cuyo resultado sea un `Dual` que corresponde
# a la variable independiente $x$ evaluada en `x_0`. Con esta función
# obtengan $f'(2)$ para la función
# ```math
# f(x) = \frac{3x^2-8x+1}{7x^3-1}.
# ```

function dual(x_0)
    return Dual(x_0, one(x_0))
end

begin
    f(x) = (3x^2-8x+1)/(7x^3-1)
    f(dual(2))
end

#!SECTION
# SECTION Ejercicio 3
#
# - A partir de lo visto en clase, *extiendan* las funciones elementales usuales para que funcionen con Duales, es decir, `sin(a::Dual)`, `cos(a::Dual)`, `tan(a::Dual)`, `^(a::Dual, n::Int)`, `sqrt(a::Dual)`, `exp(a::Dual)` y `log(a::Dual)`.

begin
    import Base: sin, cos, tan, ^, sqrt, exp, log, ≈, ==

    sin(u::Dual) = Dual(sin(u.fun), u.der*cos(u.fun))
    cos(u::Dual) = Dual(cos(u.fun), -u.der*sin(u.fun))
    tan(u::Dual) = Dual(tan(u.fun), u.der*(sec(u.fun))^2)
    # ^(u::Dual, n::Int) = Dual(u.fun ^ n, n*u.fun^(n-1)*u.der) Implementacion no necesaria debido al uso de literalpow
    sqrt(u::Dual) = Dual(sqrt(u.fun), u.der/(2*sqrt(u.fun)))
    exp(u::Dual) = Dual(exp(u.fun), u.der*exp(u.fun))
    log(u::Dual) = Dual(log(u.fun), u.der/u.fun)
    ≈(u::Dual, v::Dual) = u.fun ≈ v.fun && u.der ≈ v.der
    ==(u::Dual, v::Dual) = u.fun == v.fun && u.der == v.der
end

# - Al igual que antes, construyan algún conjunto de pruebas que muestre, de manera
# sencilla, que lo que hicieron da lo que uno esperaría obtener.

θ = dual(pi/4)
@testset "trigos y mas dual" begin
    @test sin(θ) ≈ Dual(1/sqrt(2),1/sqrt(2)) 
    @test cos(θ) ≈ Dual(1/sqrt(2),-1/sqrt(2)) 
    @test tan(θ) ≈ Dual(1,2) 
    @test u^3 ≈ Dual(1,12)
    @test sqrt(u) ≈ Dual(1, 2)
    @test exp(u) ≈ Dual(exp(1),4*exp(1))
    @test log(u) ≈ Dual(0.0,4.0)
end

#!SECTION