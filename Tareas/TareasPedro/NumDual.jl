module NumDual

export Dual, dual, fun, der

import Base: +, -, *, /, ^, exp, log, sin, cos, tan, sqrt, sinh, cosh, tanh

struct Dual{T<:Real}
	fun::T
	der::T
end

# Definimos: 

#Nombrando la función constante como f(x) = cons:
Dual(cons::T) where {T<:Real} = Dual{T}(cons, zero(T))

#Definiremos la función dual(x_0) como:
dual(x_0::T) where {T<:Real} = Dual{T}(x_0, one(T))

# Creamos los accesores fun y der:
fun(u::Dual) = u.fun
der(u::Dual) = u.der

# Creamos las reglas de promoción y conversión
Base.convert(::Type{Dual{T}}, c::Real) where {T<:Real} = Dual{T}(T(c), zero(T))
Base.promote_rule(::Type{Dual{T}}, ::Type{S}) where {T<:Real, S<:Real} = Dual{promote_type(T,S)}

#Suma
+(u::Real, w::Dual) = +(promote(u,w)...)
+(u::Dual, w::Real) = +(promote(u,w)...)
#Resta
-(u::Real, w::Dual) = -(promote(u,w)...)
-(u::Dual, w::Real) = -(promote(u,w)...)
#Producto
*(u::Real, w::Dual) = *(promote(u,w)...)
*(u::Dual, w::Real) = *(promote(u,w)...)
#División
/(u::Real, w::Dual) = /(promote(u,w)...)
/(u::Dual, w::Real) = /(promote(u,w)...)

# Sobrecargamos la parte aritmetica: 
#Sobrecargamos la función suma para los Duales
function +(u::Dual, w::Dual)
	return Dual(u.fun + w.fun, u.der + w.der)
end

#Sobrecargamos la función resta para los Duales
function -(u::Dual, w::Dual)
	return Dual(u.fun - w.fun, u.der - w.der)
end

#Sobrecargamos la función producto para los Duales
function *(u::Dual, w::Dual)
	return Dual(u.fun * w.fun, u.der * w.fun + u.fun * w.der)
end

#Sobrecargamos la función división para los Duales
function (u::Dual, w::Dual)
    @assert w.fun != 0 "Error! Para u/w donde u y w son duales, w.fun debe de ser distinto de cero."
	return Dual(u.fun / w.fun, (u.der - (u.fun / w.fun) * w.der) / w.fun)
end

#Sobrecargamos la función potencia para los duales
function ^(u::Dual, n::Real)
	return Dual(u.fun ^ n, n* u.der * u.fun ^(n - 1))
end

# Ahora las funciones elementales:
exp(u::Dual) = Dual(exp(u.fun), exp(u.fun)*u.der)

log(u::Dual) = Dual(log(u.fun), u.der/u.fun)

tan(u::Dual) = Dual(tan(u.fun), u.der * sec(u.fun)^2 )

sin(u::Dual) = Dual(sin(u.fun), cos(u.fun)*u.der)

cos(u::Dual) = Dual(cos(u.fun), -sin(u.fun)*u.der)

sinh(u::Dual) = Dual(sinh(u.fun), cosh(u.fun)*u.der)

cosh(u::Dual) = Dual(cosh(u.fun), sinh(u.fun)*u.der)

function tanh(u::Dual) #Lo puse así porque me pareció más cómodo que la sech
    t = tanh(u.fun)
    return Dual(t, (1 - t^2) * u.der)
end

sqrt(u::Dual) = Dual(sqrt(u.fun), u.der / (2 * sqrt(u.fun)))

end # del modulo