# # Tarea 3: Exponentes de Feigenbaum
# Por Meneses Orozco Pedro Damian

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
include("NumDual.jl")
using .NumDual
# (b) Escriban una función que implemente el método de Newton para funciones
# en una dimensión. La derivada que se requiere deberá ser calculada usando
# los números duales. Obtengan usando esta implementación un cero de
# \$f(x) = x^3 - 15.625\$, para verificar que su implementación funciona.

"""
El método de Newton usa la iteración x_{n+1} = x_n - f(x_n)/f'(x_n).
Con duales obtenemos f y f' simultáneamente: f(dual(x)) nos da
fun = f(x) y der = f'(x) en una sola evaluación. Usaremos una tolerancia base de 10^-12 y una 
máxima iteracion de 100 como base. 
"""

function newton(f, x0::Float64; tol=1e-12, max_iter=100) 
    x = x0
    for i in 1:max_iter
        d = f(dual(x))
        fx  = fun(d)
        f′x = der(d)
        @assert abs(f′x) > 1e-16 "Derivada cercana a cero en x=$x"
        x_new = x - (fx / f′x)
        abs(x_new - x) < tol && return x_new
        x = x_new
    end
    @warn "Newton no convergió en $max_iter iteraciones"
    return x
end
#Buscando un cero de f(x) = x^3 - 15.625:
f_p(x) = x^3 - 15.625
#Graficando la función, solo tiene una raiz que es 2.5, utilizando el método para x_0=1.0, 2.0, 0.0 nos da:
newton(f_p, 1.0)
newton(f_p, 2.0)
newton(f_p, 0.0) # El punto es justo su derivada en 0.0

# (c) Encuentren *todos* los puntos fijos del mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.

#=Para hacer eso debemos de considerar los puntos donde F(x) = x, entonces queremos saber cuando
F(x) - x = 0
=#
F(x) = x^2 - 1.1 # Definimos F(x)

#Puntos fijos — raíces de x -> F(x) - x (La definimos implicitamente)
#Al ser una función cuadratica centrada en el cero, tomamos como puntos cercanos x_0 = 2 y x_0 = -2 para encontrar las raices.
pf1 = newton(x -> F(x) - x,  2.0)
pf2 = newton(x -> F(x) - x, -2.0)
println("Puntos fijos: ", pf1, "  ", pf2)

# (d) Encuentren los puntos *de periodo 2* para el mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.
#
#=
Son los puntos tales que: F(F(x)) = x pero F(x) ≠ x.
Es decir raíces de F(F(x)) - x = 0 que no son puntos fijos.
=#
FF(x) = F(F(x))
#escogí 0.0 y -1.0 porque no me dieron los puntos fijos
p2_1 = newton(x -> FF(x) - x,  0.0)
p2_2 = newton(x -> FF(x) - x, -1.0)
println("Puntos de periodo 2: ", p2_1, "  ", p2_2)
# (e) Usen los números duales para mostrar que los puntos de periodo 2
# para el mapeo \$F(x) = x^2 -1\$ son linealmente estables (atractivos).

#Definimos F1(x) = x^2 - 1 y FF1(x) = F1(F1(x)) 
F1(x) = x^2 - 1
FF1(x) = F1(F1(x))
#Veamos cuales son los puntos fijos de F1:
p1f1 = newton(x -> F1(x) - x,  2.0)
p1f2 = newton(x -> F1(x) - x, 0.0)
println("Puntos fijos: ", p1f1, "  ", p1f2)

#Ahora los de periodo 2:

p2_1 = newton(x -> FF1(x) - x,  1.0)
p2_2 = newton(x -> FF1(x) - x, 0.0)

#=
La estabilidad viene de (F^2)'(q) justo cuando |(F^2)'(q)| es menor que 1. Para esto usaremos regla 
de la cadena.
Con duales lo calculamos directo:
=#
der_F2_en_p2_1 = der(F(F(dual(p2_1))))
der_F2_en_p2_2 = der(F(F(dual(p2_2))))
#Notamos que -1 es estable y 0.0 es superestable


# ## Ejercicio 2
#
# Llamaremos \$c_n\$ al valor del parámetro $c$ para el mapeo cuadrático
# \$Q_c(x) = x^2-c\$, donde ocurre el ciclo superestable de periodo \$2^n\$,
# esto es, el valor de \$c\$ tal que \$x_0=0\$ pertenece a la órbita
# periódica de periodo \$2^n\$.
#
# Calculen los valores de \$c_r\$, al menos hasta \$c_7\$. Con estos
# valores, definimos la secuencia \$\{f_0, f_1, f_2, \dots\}$, donde
# ```math
# \begin{equation*}
# f_n = \frac{c_n-c_{n+1}}{c_{n+1}-c_{n+2}} .
# \end{equation*}
# ```
# Aproximen el valor al que converge esta secuencia,
# es decir, den una estimación de \$\delta = f_\infty\$.
#

#Empezaremos definiendo Q_c como:
Qc(x,c) = x^2 - c

#c_n es tal que Q_{cn}^{2^n}(0) = 0

#Función que evalua Q_c^{m}(x_0)
function itera_Qc(x_0, c, m::Int)
    x = x_0
    for i=1:m
        x = Qc(x,c)
    end
    return x
end

#=
Ahora para calcular c_r es necesario que creemos una función que  saber cuando 
g(c) = itera_Qc(0, c, 2^n) es cero. Para lo cual es necesario aplicar el método de newton a
g(c) para algún punto c_0. 
=#
function encontrar_cn(n::Int, c0::Float64;  max_ite=100)
    periodo = 2^n
    g(c) = itera_Qc(0, c, periodo)
    return newton(g, c0, max_iter = max_ite)
end

#Definimos un vector donde vamos a colocar las c_r de 0 a 15:
cr = Vector{Float64}(undef, 16)
# Notemos que el de periodo uno es 0^2 + c_0 = 0, entonces c_0 = 0

#tanteandole para encontrar unos cr que hagan que f_r parezca que converga
cr[1] = 0.0
cr[2] = encontrar_cn(1, 0.8)
#A partir de aquí utilicé como semilla el anterior e hice una pequeña variación a cada paso
for i in 3:16
    #c_i > c_{i-1}, usamos c_{i-1} + fracción de la diferencia anterior
    paso = cr[i-1] - cr[i-2]
    if i <= 8
        cr[i] = encontrar_cn(i-1, cr[i-1] + paso/(i-1), max_ite = 100)
    else 
        cr[i] = encontrar_cn(i-1, cr[i-1] + paso/7, max_ite = 100) #Me di cuenta que cuando i pasaba de 8 el metodo de newton dejaba de converger
    end
end

for n in 1:(length(cr))
    cr_n = cr[n]
    println("c_$(n-1) = $cr_n")
end

f_n = Float64[]
println("Secuencia f_n:")
for n in 1:(length(cr)-2)
    fn = (cr[n] - cr[n+1]) / (cr[n+1] - cr[n+2])
    push!(f_n, fn)
    println("f_$(n-1) = $fn")
end

δ = f_n[end]
println("Parece que cuando r tiende a infinito tiende a $δ")
# ## Ejercicio 3
#
# (Este ejercicio requiere el cálculo de las $c_n$ del ejercicio anterior.)
# De los \$2^p\$ puntos del ciclo de periodo \$2^p\$ superestable, es decir,
# \$\{0, x_1, \dots x_{2^{n-1}}\,\}\$ hay uno (*distinto del 0*) cuya distancia
# a 0 es la menor; a esa distancia la identificaremos como \$d_n\$.
# (Ver las notas de clase)
#
# Estimen numéricamente a qué converge la secuencia
# ```math
# \begin{equation*}
# \alpha = - d_n/d_{n+1},
# \end{equation*}
# ```
# en el límite de \$n\$ muy grande.
#
#=
Para el ciclo superestable de periodo 2^n con parámetro c_n,
los puntos del ciclo son: 0, Q_cn(0), Q_cn²(0), ..., Q_cn^{2^n - 1}(0)
Queremos el punto distinto de 0 con menor |x|, esa distancia es d_n.
=#

function calcular_dn(cr::Vector{Float64},n::Int)
    #Iteramos 2^(n-1) pasos desde x=0 (mitad del periodo)
    cn = cr[n+1]
    x = 0.0
    for i in 1:2^(n-1)
        x = Qc(x, cn)
    end
    return abs(x)
end

# Calculamos d_n para n = 1 a 15 (necesitamos c_1 a c_15, o sea cr[2:16])
ds = [calcular_dn(cr, n) for n in 1:15]

println("Distancias d_n:")
for (n, d) in enumerate(ds)
    println("d_$n = $d")
end

# Estimamos α = -d_n / d_{n+1}
println("\nSecuencia α_n = -d_n / d_{n+1}:")
for n in 1:(length(ds)-1)
    αn = -ds[n] / ds[n+1]
    println("α_$n = $αn")
end

α_estimado = -ds[end-1] / ds[end]
#El que mejor se aproxima a la convergencia es  α_6 ≈ α_∞ ≈ -2.5029