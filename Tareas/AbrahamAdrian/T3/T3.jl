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

include("numDuales.jl")
using .numDuales


# (b) Escriban una función que implemente el método de Newton para funciones
# en una dimensión. La derivada que se requiere deberá ser calculada usando
# los números duales. Obtengan usando esta implementación un cero de
# \$f(x) = x^3 - 15.625\$, para verificar que su implementación funciona.

"""
Regresa todas las raíces encontradas para la función f dentro del intervalo rg (de tipo LinRange) y los puntos fijos que generan una órbita de periodo periodicity.
"""
function mN(f,n,rg::LinRange, periodicity = 1)
    rs = [] # Array de ceros encontrados
    pps = [] # Array de puntos periodicos encontrados
    g = reduce(∘, fill(f,periodicity)) # Compone la funcion f, 'periodicity' veces
    for p in rg
        # println("Currently at p = $p")
        try
            d = g(dual(p))
            x = Float64[p...]
            xi = x[1]
            while (length(x) < 2) || (x[end] ≉  x[end-1]) # Sabemos que es zero si es punto fijo aka f(x) = x
                if periodicity == 1 # El método de Newton cambia para funciones compuestas
                    xi1 = xi - (d.fun/d.der)
                else
                    xi1 = xi - ((d.fun-xi)/(d.der-1))
                end
                # println(xi1)
                ((isnan(xi1)) || (isinf(xi1))) && (error("Se obtiene valor NaN o inf.")) # Para evitar ciclos causados por NaN o inf.
                push!(x, xi1)
                d = g(dual(xi1))
                xi = xi1
                (length(x) > 100) && ((error("En x = $p, más de 100 iteraciones ocurrieron sin encontrar un cero.")) && break)
                # Para evitar ciclos infinitos causados por un mapeo que no converge.
            end
            newzero = pop!(x)
            if !any(r -> isapprox(newzero, r, atol=1e-8), rs) # Solo se añade el valor encontrado si no se ha obtenido ya uno similar
                push!(rs, newzero)
            end
        catch e # En caso de que haya alguna indefinicion, se ignorara esa iteracion especifica del ciclo
            @warn "x = $p saltado debido al error: $e" 
            continue
        end
    end
    # Checa cual grupo de valores es la serie periodica
    # De manera general, checa de los valores obtenidos, cuales generan la órbita periodo periodicity
    if periodicity > 1
        for r in rs
            # println("Comparando $r")
            temp = [r]
            for i in 1:periodicity
                t = f(temp[end])
                # println("f($r) igual a $t")
                ((any(r -> isapprox(t, r, atol=1e-8), rs)) && !(t ≈ temp[1])) && (push!(temp,t))
            end
            ((!any(temp[1] .∈ pps)) && (length(temp) == periodicity)) && (push!(pps,temp))
        end
    end
    # TODO reescribir mensajes para tener en cuenta periodicidad y demas
    # message = length(rs) == 0 ? "No se han encontrado ceros para la funcion $(@show f) ∈ [$(rg.start), $(rg.stop)]." : length(rs) == n ? "Los ceros para la funcion $(@show f) ∈ [$(rg.start), $(rg.stop)] son $(rs)." : "Se encontraron $(length(rs)) soluciones para la funcion $(@show f) ∈ [$(rg.start), $(rg.stop)]: $(rs)."
    # println(message)
    return rs, pps
end

f(x) = x^3 - 15.625
mN(f,1, LinRange(0,1,2))
# (c) Encuentren *todos* los puntos fijos del mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.

g(x) = x^2 - 1.1
mN(g,2, LinRange(-10,10,10))
# (d) Encuentren los puntos *de periodo 2* para el mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.
mN(g,2, LinRange(-1000,100,10001),2)

# (e) Usen los números duales para mostrar que los puntos de periodo 2
# para el mapeo \$F(x) = x^2 -1\$ son linealmente estables (atractivos).
e(x) = x^2 -1
e1, e2 = mN(e,2, LinRange(-1000,100,10001),2)
abs(e(dual(e2[1][1])).der*e(dual(e2[1][2])).der)
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

"""
Regresa la función compuesta resultante de componer n veces el mapeo cuadrático y establecer todos los valores de x = x₀ = 0.0.
"""
function composeQ(n, x_0 = 0.0)
    return c -> begin
            x = x_0
            for _ in 1:n
                x = Q(x, c)
            end
            x
        end
end

Q(x, c) = x^2 - c

"""
Obtiene n + 1 valores de c para mapeos cuadráticos superestables desde c₀ hasta cₙ.
"""
function obtainNCs(nTot)
    ns = [2^n for n in 1:nTot]
    cs = [0.0]
    for n in ns
        cCand = 100.0
        comp = composeQ(n)
        currC, _ = mN(comp, n, LinRange(0, 5, 100001))
        for ca in currC
            ((ca > maximum(cs)) && (abs(ca - maximum(cs)) > 1e-12)) && (cCand = min(cCand, ca))
        end
        push!(cs, cCand)
    end
    fs = [(cs[n] - cs[n+1])/(cs[n+1] - cs[n+2]) for n in 1:nTot-2]
    return cs, fs
end
cs, fs = obtainNCs(7)
cs
fAproximada = fs[end]
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

"""
Aproxima el valor de α a partir de los mapeos cuadráticos que utilizan los valores de c para ciclos superestables desde c₀ hasta cₙ.
"""
function approxA(n)
    cs, _ = obtainNCs(n)
    ds = [0.0]
    for (i, c) in enumerate(cs)
        if i != 1
            vals = abs.(accumulate((x, _) -> Q(x, c), 1:2^(i-1), init=0.0))
            push!(ds, minimum(filter(x -> !isapprox(x, 0.0, atol=1e-5), vals)))
        end
    end
    αs = [-ds[i]/ds[i+1] for i in 1:length(ds)-1]
    return ds, αs
end
ds, αs = approxA(8)
αAproximada = αs[end]