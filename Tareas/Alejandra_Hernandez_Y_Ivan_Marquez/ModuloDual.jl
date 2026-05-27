module NumDual
    export Dual,dual, fun, der
    
    # Copio todo lo relacionado a Duales y operaciones con estos desde la Tarea 2
    struct Dual
        fun::Float64
        der::Float64
    end

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

    function Dual(a::Real)
        c = Dual(a,0.0)
        return c
    end


    import Base: +
    +(a::Dual, b::Real) = +(a, Dual(b))
    +(a::Real, b::Dual) = +(Dual(a), b)
    import Base: -
    -(a::Dual, b::Real) = -(a, Dual(b))
    -(a::Real, b::Dual) = -(Dual(a), b)
    import Base: *
    *(a::Dual, b::Real) = *(a, Dual(b))
    *(a::Real, b::Dual) = *(Dual(a), b)
    import Base: /
    /(a::Dual, b::Real) = /(a, Dual(b))
    /(a::Real, b::Dual) = /(Dual(a), b)

    # Función fun, es la parte real

    function fun(a::Dual)
        return a.fun
    end

    # Función der, corresponde a la parte epsilon

    function der(a::Dual)
        return a.der
    end


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


    # Copio una versión modificada de la función dual de la tarea 2
    function dual(a::Real)
        c = Dual(a,1.0)
        return c
    end
    
end