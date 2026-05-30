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
        @assert abs(f′x) > 1e-15 "Derivada cercana a cero en x=$x"
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

#=
La estabilidad viene de (F^2)'(q) = F'(q₊) · F'(q₋)
(regla de la cadena, como lo muestran las notas en la ec. de Q_c²)
Con duales lo calculamos directo:
=#
der_F2_en_p2_1 = der(F(F(dual(p2_1))))
der_F2_en_p2_2 = der(F(F(dual(p2_2))))


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
