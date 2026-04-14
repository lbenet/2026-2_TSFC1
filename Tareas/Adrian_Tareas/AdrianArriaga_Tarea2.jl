#TSFC1 - Tarea 2                       Adrián Arriaga

#Pkg
using LaTeXStrings 

# a. Se define la estructura de los numeros duales, con los campos 'fun' y 'der'. 
# Estos campos son subtipos del campo 'Real'. 

struct DualNumb{T<:Real}
    fun::T
    der::T
end


import Base: +, -, *, /

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
    c = DualNumb((a.fun)/(b.fun), (a.fun)*(b.der) + (a.der)*(b.fun))
    return c
end

Adual = DualNumb(1, 3);
Bdual = DualNumb(2, 1);

Adual + Bdual

Adual * Bdual