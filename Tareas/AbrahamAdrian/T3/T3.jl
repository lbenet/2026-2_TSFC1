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
Regresa todas las raíces encontradas para la función f dentro del intervalo rg (de tipo LinRange). Para obtener puntos fijos de una función f, es necesario introducir una función anónima en el argumento de la forma "x -> f(x) - x". Regresa un array con los ceros/pts. fijos encontrados en el rango establecido.
"""
function metNewt(f,rg::LinRange)
    rs = [] # Array de ceros encontrados
    for p in rg
        # println("Currently at p = $p")
        try
            d = f(dual(p))
            x = Float64[p...]
            xi = x[1]
            while (length(x) < 2) || (x[end] ≉  x[end-1]) # Sabemos que es zero si es punto fijo aka f(x) = x
                xi1 = xi - (d.fun/d.der)
                # println(xi1)
                ((isnan(xi1)) || (isinf(xi1))) && (error("Se obtiene valor NaN o inf.")) # Para evitar ciclos causados por NaN o inf.
                push!(x, xi1)
                d = f(dual(xi1))
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
    return rs
end

b(x) = x^3 - 15.625
metNewt(b, LinRange(0, 5, 100))
# (c) Encuentren *todos* los puntos fijos del mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.

c(x) = x^2 - 1.1
metNewt(x -> c(x)-x, LinRange(-5,5,200))
# (d) Encuentren los puntos *de periodo 2* para el mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.
metNewt(x -> c(c(x))-x, LinRange(-10,10,101))

# (e) Usen los números duales para mostrar que los puntos de periodo 2
# para el mapeo \$F(x) = x^2 -1\$ son linealmente estables (atractivos).
e(x) = x^2 -1
e1 = metNewt(x -> e(e(x))-x, LinRange(-10,10,1001))
multiplicador = abs(e(dual(e1[1])).der*e(dual(e1[2])).der)
# El multiplicador del ciclo es |F'(x₁)·F'(x₂)|. Como multiplicador < 1,
# el ciclo de periodo 2 es linealmente estable (atractor).
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
Obtiene n + 1 valores de c para mapeos cuadráticos superestables desde c₀ hasta cₙ. Devuelve dos vectores: cs que contiene las n + 1 iteraciones superstables del mapeo cuadrático, y fs que contiene los n - 2 valores de f donde f = fₙ = (cₙ-c_{n+1})/(c_{n+1}-c_{n+2}).
"""
function obtainNCs(nTot)
    ns = [2^n for n in 1:nTot]
    cs = [0.0]
    for n in ns
        cCand = 100.0
        comp = composeQ(n)
        currC = metNewt(comp, LinRange(0, 5, 100001))
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
Aproxima el valor de α a partir de los mapeos cuadráticos que utilizan
los valores de c para ciclos superestables desde c₀ hasta cₙ.

Devuelve dos vectores:
- `ds`: distancias dₙ con signo al origen del punto del ciclo superestable
  de periodo 2ⁿ más cercano a 0 (distintos de 0). Los valores alternan de
  signo por la estructura del árbol de Feigenbaum.
- `αs`: cocientes αₙ = -dₙ/dₙ₊₁, cuyo límite aproxima la constante de
  Feigenbaum α ≈ 2.5029.
"""
function approxA(n)
    cs, _ = obtainNCs(n)
    ds = [0.0]
    for (i, c) in enumerate(cs)
        if i != 1
            vals = accumulate((x, _) -> Q(x, c), 1:2^(i-1), init=0.0)
            non_zero = filter(x -> !isapprox(x, 0.0, atol=1e-5), vals)
            # Tomamos el elemento con menor valor absoluto, conservando su signo.
            # Los dₙ alternan de signo, por lo que -dₙ/dₙ₊₁ > 0 y converge a α.
            push!(ds, non_zero[argmin(abs.(non_zero))])
        end
    end
    αs = [-ds[i]/ds[i+1] for i in 1:length(ds)-1]
    return ds, αs
end
ds, αs = approxA(8)
αAproximada = αs[end]