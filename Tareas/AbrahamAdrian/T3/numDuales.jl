# # Tarea 3: Exponentes de Feigenbaum

# ## Ejercicio 1
#
# (a) Usando lo que desarrollaron para los números `Dual`es en la Tarea2,
# creen un *módulo* que llamaremos `NumDual`.
# El módulo debe *exportar* el tipo `Dual`, y la función
# `dual(x)` que crea al `Dual(x, 1.0)` que corresponde a la variable
# independiente.
# El archivo con el módulo lo deben incluir en un archivo ".jl" en su
# propio directorio de tareas, en particular donde hagan los ejercicios
# de esta tarea. El módulo deberá ser cargado usando
# ```
# include("nombre_archivo.jl")
# using .NumDual
# ```

module numDuales
    export Dual, dual, fun, der
    """
        Estructura que representa a los números duales. Dual es subtipo de Real y acepta como campos su parte real **fun**
        y su parte derivada **der**; ambos campos son subtipos de Real.
    """
    # NOTE Dual es subtipo de Real porque la promoción solo es aplicada automáticamente a ops. aritméticas del subtipo Number. Como Real es subtipo de Number,
    # el Dual debe ser subtipo de Real o Number para cumplir con el inciso d.
    struct Dual{T<:Real}<:Real
        fun::T
        der::T
    end

    # NOTE Esta línea se encarga de que si se introducen dos tipos distintos en los campos del Dual, los promueve al mismo tipo.
    Dual(f::Real, d::Real) = Dual(promote(f, d)...)

    import Base: +, -, *, /, sin, cos, tan, ^, sqrt, exp, log, ≈, ==

    +(u::Dual, w::Dual) = Dual(u.fun + w.fun, u.der + w.der)
    -(u::Dual, w::Dual) = Dual(u.fun - w.fun, u.der - w.der)
    *(u::Dual, w::Dual) = Dual(u.fun * w.fun, (u.fun * w.der) + (w.fun * u.der))
    /(u::Dual, w::Dual) = Dual(u.fun / w.fun, ((u.der*w.fun)-(u.fun*w.der)) / w.fun^2)
    sin(u::Dual) = Dual(sin(u.fun), u.der*cos(u.fun))
    cos(u::Dual) = Dual(cos(u.fun), -u.der*sin(u.fun))
    tan(u::Dual) = Dual(tan(u.fun), u.der*(sec(u.fun))^2)
    ^(u::Dual, n::Int) = Dual(u.fun ^ n, n*u.fun^(n-1)*u.der)
    sqrt(u::Dual) = Dual(sqrt(u.fun), u.der/(2*sqrt(u.fun)))
    exp(u::Dual) = Dual(exp(u.fun), u.der*exp(u.fun))
    log(u::Dual) = Dual(log(u.fun), u.der/u.fun)
    ≈(u::Dual, v::Dual) = u.fun ≈ v.fun && u.der ≈ v.der
    ==(u::Dual, v::Dual) = u.fun == v.fun && u.der == v.der
    -(x::Dual{T}) where T = Dual(-x.fun, -x.der)
    
    Dual(c::T) where {T<:Real} = Dual(c, zero(T))

    # NOTE Convierte una variabled de tipo Real **x** a un Dual subtipo de Real de la forma x+0.
    Base.convert(::Type{Dual{T}}, x::Real) where {T<:Real}= Dual{T}(x, zero(T))
    # NOTE Convierte una estructura dual a un dual subtipo Real. El motivo es llevar tanto el dual como la variable Real al mismo nivel.
    Base.convert(::Type{Dual{T}}, x::Dual) where {T<:Real}= Dual{T}(x.fun, x.der)
    # NOTE Cuando se realiza una operación entre un Dual y un Real, el tipo del Dual resultante sera el mas general entre el Real y los campos del Dual.
    Base.promote_rule(::Type{Dual{S}},::Type{T}) where {S<:Real,T<:Real} = Dual{promote_type(S,T)}
    # NOTE Cuando se realiza una operación entre dos Duales con subtipos de Real diferentes (e.g. Int64 y Float64) promueve el tipo del Dual resultante al mas general de los campos de ambos duales. 
    Base.promote_rule(::Type{Dual{S}},::Type{Dual{T}}) where {S<:Real,T<:Real} = Dual{promote_type(S,T)}

    function fun(a :: Dual)
        return a.fun
    end

    function der(a :: Dual)
        return a.der
    end

    function dual(x_0)
        return Dual(x_0, one(x_0))
    end
end