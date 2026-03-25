# # Bifurcaciones

# ## Un primer ejemplo

# Empezaremos recargando la función `itera_mapeo` que hicimos en una
# clase anterior, notando que hay algunos cambios pequeños (evitamos
# crear/usar el vector `its`).

"""
    itera_mapeo(f, x0, n)

Itera la función \$x \\to f(x)\$, de una dimensión, `n` veces a partir de la condición inicial `x0`.
Regresa dos vectores que se usan para dibujar los
iterados.
"""
function itera_mapeo(f, x0, n::Int)
    #Defino/creo tres vectores de salida (de `Float64`s)
    #its = [x0]
    its_x = [x0]
    its_y = [0.0]
    #Obtengo los iterados
    for i=1:n
        x1 = f(x0)
        #push!(its, x1)
        push!(its_x, x0, x1)
        push!(its_y, x1, x1)
        x0 = x1
    end
    return its_x, its_y
end

# Consideremos a la *familia* de mapeos cuadráticos definida por
# ```math
# \begin{equation*}
#     Q_c(x) = x^2 - c,
# \end{equation*}
# ```
# donde $c\in\mathbb{R}$ es un parámetro, y $x\in D_c \subset [-2,2]$
# es la variable (real) "dependiente" que estudiaremos dinámicamente;
# más adelante definiremos el dominio $D_c$.

# Estudiaremos primeramente cómo dependen los puntos fijos de $c$,
# el *parámetro*, y cómo varía su estabilidad.

# Los puntos fijos satisfacen la ecuación $Q_c(x) = x^2-c = x$, de
# donde obtenemos (analíticamente) las dos soluciones:
# ```math
# \begin{align*}
# x_+(c) & = \frac{1}{2}( 1 + \sqrt{1+4c} ),\\
# x_-(c) & = \frac{1}{2}( 1 - \sqrt{1+4c} ).\\
# \end{align*}
# ```

# Claramente vemos que, si $1+4c<0$, es decir $c<-1/4$, **no** existen
# puntos fijos (reales) del mapeo cuadrático. En este caso, es fácil ver
# que **ninguna** condición inicial quedará atrapada, y todas escaparán
# a infinito.
# Por otra parte, si se satisface que $c>-1/4$, entonces existen dos
# puntos fijos. En este caso tenemos que $x_+(c)\ge 1/2 \ge x_-(c)$;
# las igualdades sólo ocurren en $c=1/4$, que es el valor de $c$
# donde *aparecen* los puntos fijos.

# Esta *transición* o cambio en la que el mapeo pasa de no tener puntos
# fijos ($c<-1/4$) a tener dos puntos fijos ($c>-1/4$) al aumentar el
# parámetro, es un ejemplo de lo que se llama una *bifurcación*. En este
# caso concreto, es una *bifurcación de silla-nodo* (saddle-node) o
# *bifurcación tangente*.

Qc(x,c) = x^2 - c       # Mapeo cuadrático

begin
	qc1 = x -> Qc(x, -0.5)   # Mapeo cuadrático con c = -0.5
	qc2 = x -> Qc(x, -0.25)  # Mapeo cuadrático con c = -0.25
	qc3 = x -> Qc(x, 0.5)  # Mapeo cuadrático con c =  0.25

	domx = -2:1/32:2 # Dominio de interés

	p = plot(domx, qc1, xaxis=("x", ), yaxis="Q_c(x)",
	    label="c = -0.5", legend=:bottomright)
	plot!(domx, qc3, label="c = -0.25", linewidth=2)
	plot!(domx, qc2, label="c = 0.5", linewidth=2)
	plot!(domx, identity, label="Id(x)", color=:black, linestyle=:dash, linewidth=2)
	plot!(domx, x->(1+sqrt(3))/2, label="y = x₊(c)", color=:lightgrey, linestyle=:dot, linewidth=2)
	title!("Fig. 1")
end

# En la gráfica anterior vemos que si $c\in [-1/4,2]$, lo que ciertamente
# garantiza que hay al menos un punto fijo, si definimos el dominio
# $D_c=[-x_+, x_+]$, entonces los iterados de $x_0\in D_c$ bajo el
# mapeo $Q_c(x)$ se mantienen dentro de $D_c$, es decir, $Q_c(x_n)\in D_c$.
# (La cota superior para $c$ es importante, ya que para $c>2$, hay puntos
# del dominio $D_c$ cuyos iterados pueden escapar de $D_c$.) En lo que
# sigue nos concentraremos a este dominio de $c$ y a $D_c$.

# Como hemos visto anteriormente, la derivada del mapeo evaluada en los
# puntos fijos da información sobre la estabilidad lineal del punto fijo,
# es decir, el caracter atractivo (si el valor absoluto de la derivada en
# el punto fijo es menor que 1), o repulsivo (si el valor absoluto de la
# derivada en el punto fijo es mayor que 1), del mapeo cerca del punto fijo.

# En el caso concreto del mapeo cuadrático tenemos que $Q_c'(x) = 2x$, de
# donde se desprenden dos propiedades importantes.
# En primer lugar, en el punto de bifurcación $c=-1/4$, tenemos
# $x_+(-1/4) = x_-(-1/4) = 1/2$ y $Q_{-1/4}'(1/2) = 1$. Esto es, en el
# punto de bifurcación la derivada es -1, por lo que el punto de
# equilibrio es "degenerado".
# Además, para $c>-1/4$, el punto fijo $x_+(c)$ es repulsivo, o
# linealmente inestable, ya que $x_+(c)>1/2$; por su parte, $x_-(c)$
# es atractivo si se cumple $|Q_c'(x_-(c))| = 2 |x_-(c)|<1$. De la última
# expresión es fácil obtener que, para que $x_-(c)$ sea linealmente
# estable, se debe además cumplir la desigualdad
# ```math
# \begin{equation*}
# -1 < 1 - \sqrt{1+4c} < 1,
# \end{equation*}
# ```
# que equivale a $2 > \sqrt{1+4c} > 0$. Esto, a su vez, nos conduce
# a la condición $3/4 > c > -1/4$ para que $x_-(c)$ sea un punto atractivo.

# Las observaciones anteriores se pueden resumir con el diagrama de
# bifurcación que ilustramos en la figura 2.

xplus(c)  = 0.5*(1+sqrt(1+4*c))
xminus(c) = 0.5*(1-sqrt(1+4*c))

begin
	domc = -1/4:1/128:2

	plot(domc, xplus, xaxis=("c", (-1/2,2)), yaxis=("x_±(c)"),
	    label="x₊(c)", color=:red, linewidth=2)
	plot!(-1/4:1/64:3/4, xminus, label="x₋(c) estable", color=:blue, linewidth=2)
	plot!(3/4:1/64:2, xminus, label="x₋(c) inestble", color=:red, line=(:dash),     linewidth=2)
	title!("Fig. 2")
end

# El diagrama de bifurcación anterior fue obtenido a partir de la
# dependencia de los puntos fijos del parámetro $c$, que obtuvimos
# de manera analítica. El diagrama de bifurcaciones también se puede
# obtener de manera numérica. Por ejemplo, resolviendo la ecuación de
# punto fijo numéricamente con el método de Newton, para lo que
# necesitamos un "buen" punto inicial para iniciar la recurrencia.

# Otra opción para obtener *la parte estable* de este diagrama de
# bifurcación de manera numérica, es iterando el mapeo varias veces a
# partir de una condición inicial $x_0$ que esté en la cuenca de atracción
# de $x_-(c)$, es decir, suficientemente cerca de $x_-(c)$.

# Formalmente, la bifurcación de silla-nodo para una familia monoparamétrica
# $F_\lambda$ ocurre en el parámetro $\lambda_0$, cuando existe un intervalo
# *abierto* $I$ y un $\epsilon>0$ tal que:

# - Para $\lambda_0-\epsilon<\lambda<\lambda_0$ no hay puntos fijos de $F_\lambda$ en $I$.
# - Para $\lambda=\lambda_0$ existe un sólo punto fijo de $F_\lambda$ (de
# multiplicidad 2) en $I$ y éste es neutral (o degenerado), es decir, su derivada es 1.
# - Para $\lambda_0<\lambda<\lambda_0+\epsilon$ tenemos dos puntos fijos de $F_\lambda$, uno es repulsivo y el otro es atractivo.

# Hay dos puntos importantes que vale la pena enfatizar.
# Primero, la bifurcación de silla-nodo ocurre cuando $F_{\lambda_0}(x)$
# tiene una tangencia *cuadrática* con la diagonal, es decir,
# $F'_{\lambda_0}(x_0)=1$ y $F''_{\lambda_0}(x_0)\ne 0$. Esto es, localmente
# $F_{\lambda_0}$ es cóncava o convexa.
# El segundo punto es que la teoría de bifurcaciones es una teoría local,
# válida en la cercanía del parámetro $\lambda_0$. Es por eso que la
# definición incluye $\epsilon>0$. La teoría no dice nada de qué pasa
# lejos de $\lambda_0$.

# Siguiendo con el ejemplo de la familia cuadrática $Q_c(x)$, en $c=3/4$
# *otra* bifurcación ocurre, y ésta está relacionada con el cambio de
# estabilidad de $x_-(3/4)=-0.5$. En este caso, a diferencia del caso
# anterior, tenemos $Q_{3/4}'(x_-(3/4)) = -1$.

# Como veremos, al volverse inestable $x_-(c)$ para $c > 3/4$, *aparece* un
# ciclo de periodo 2 que, de hecho, es linealmente estable; ver la figura 3.

# ## Otra bifurcación

# Siguiendo con el ejemplo de la familia cuadrática $Q_c(x)$, en $c=3/4$
# *otra* bifurcación ocurre, y ésta está relacionada con el cambio de
# estabilidad de $x_-(3/4)=-0.5$. En este caso, a diferencia del caso
# anterior, tenemos $Q_{3/4}'(x_-(3/4)) = -1$.

# Como se muestra en la Figura 3 (por inspección), al volverse inestable
# $x_-(c)$ para $c > 3/4$, *aparece* un ciclo de periodo 2 que, de hecho,
# es linealmente estable; ver la figura 3.

begin
	local param1 = 0.5
	local param2 = 0.9
	local qc1 = x -> Qc(x, param1)  # Mapeo cuadrático con c = 0.5
	local qc2 = x -> Qc(x, param2)  # Mapeo cuadrático con c = param2

	plot(domx, qc1, xaxis=("x", ), yaxis="Q_c(x)",
	    label="Q_{$param1}(x)", legend=:bottomright)
	plot!(domx, qc2, xaxis=("x", ), yaxis="Q_c(x)", label="Q_{$param2}(x)",
		  linewidth=2)
	plot!(domx, identity, xaxis=("x"), label="Id(x)", color=:black,
	    linestyle=:dash, linewidth=2)
	plot!(domx, x -> xplus(param1), label="x_+(c)", color=:lightgrey, linestyle=:dot)
	plot!(domx, x -> xplus(param2), label="", color=:lightgrey, linestyle=:dot)

	local vx, vqc1 = itera_mapeo(qc1, 1/256, 256)
	plot!(vx, vqc1, marker=(:circle, 3, 0.4), label="", color=:green,
	    linewidth=2)

	local vx, vqc2 = itera_mapeo(qc2, 1/256, 256)
	plot!(vx, vqc2, marker=(:circle, 3, 0.1), label="", color=:green, alpha=0.4,
		  linewidth=2)

	ylims!(-1, 2)
	title!("Fig. 3")
	#savefig("Fig31-3.png")
end

# Para entender este comportamiento, obviamente tenemos que analizar el
# mapeo $Q^2_c(x)$, que explícitamente está dado por
# ```math
# \begin{equation*}
# Q^2_c(x) = (x^2-c)^2-c = x^4 - 2cx^2 + c^2-c.
# \end{equation*}
# ```
# Los puntos fijos de $Q_c^2(x)$ satisfacen:
# ```math
# \begin{equation*}
# Q^2_c(x) -x = (x^2-c)^2-c-x = x^4 - 2cx^2 - x + c^2-c = 0.
# \end{equation*}
# ```

# Sabemos que dos soluciones de esta ecuación son los puntos fijos
# $x_+(c)$ y $x_-(c)$, ya que al ser puntos fijos (de periodo 1) de $Q_c(x)$,
# también son puntos fijos de periodo 2.
# Por lo tanto, $x-x_+(c)$ y $x-x_-(c)$ factorizan a $Q^2_c(x) -x$.
# Entonces, usando esto, podemos escribir
# ```math
# \begin{equation*}
# Q^2_c(x) -x = (x-x_+(c))(x-x_-(c))(x^2+x-c+1) = 0,
# \end{equation*}
# ```
# de donde obtenemos las soluciones
# ```math
# \begin{align*}
# q_+(c) & = & \frac{1}{2}( -1 + \sqrt{-3+4c} ),\\
# q_-(c) & = & \frac{1}{2}( -1 - \sqrt{-3+4c} ).\\
# \end{align*}
# ```

# Claramente, $q_\pm(c)$ son reales si $-3+4c\ge 0$, es decir, si $c > 3/4$.
# Cuando $c= 3/4$ tenemos que $q_\pm(3/4) = x_-(3/4)$, es decir, los nuevos
# puntos fijos de $Q^2_c(x)$ se originan en $x_-(3/4)$.

# En cuanto a la estabilidad, como vimos antes, para puntos periódicos,
# ésta viene dada por la derivada del mapeo $Q_c^2$,
# ```math
# \begin{align*}
# {Q_c^2}'(q_+(c)) &= {Q_c^2}'(q_-(c)) = Q_c'(q_+(c)) Q_c'(q_-(c))\\
# &= 4 q_+(c) q_-(c) = 4-4c.
# \end{align*}
# ```

# Entonces, en el momento en que aparece la órbita de periodo 2, ésta es
# neutral (en términos de estabilidad) dado que ${Q_c^2}'(q_\pm(-3/4)) = 1$.
# Además, podemos ver que para $5/4>c>3/4$, el ciclo de periodo 2 es
# atractivo, ya que $|{Q_c^2}'(q_\pm(c))|<1$, mientras que para $c>5/4$,
# dicho ciclo es repulsivo. Esto se resume en la Figura 4.

begin
	qplus(c) = 0.5*(-1+sqrt(-3+4*c))
	qminus(c) = 0.5*(-1-sqrt(-3+4*c))

	local domc = -1/4:1/64:2

	plot(domc, xplus, xaxis=("c", (-1/2,2)), yaxis=("x_pm(c), q_pm(c)"), color=:red)
	plot!(-1/4:1/64:3/4, xminus, color=:blue, legend=:false, linewidth=2)
	plot!( 3/4:1/64:2, xminus, color=:red, line=(:dash), linewidth=2)

	plot!(3/4:1/64:5/4, qplus, color=:blue, linewidth=2)
	plot!(3/4:1/64:5/4, qminus, color=:blue, linewidth=2)
	plot!(5/4:1/64:2, qplus, color=:red, line=(:dash), linewidth=2)
	plot!(5/4:1/64:2, qminus, color=:red, line=(:dash), linewidth=2)

	title!("Fig. 4")
	#savefig("Fig31-4.png")
end

# La bifurcación que acabamos de describir se llama, como es de esperarse,
# *bifurcación de doblamiento de periodo*.

# De manera más formal, una bifurcación de doblamiento de periodo para una
# familia monoparamétrica de mapeos $F_\lambda$ ocurre en $\lambda_0$
# si existe un intervalo *abierto* $I$ y un $\epsilon>0$ tal que:
#
# - Para toda $\lambda$ en el intervalo
# $[\lambda_0-\epsilon, \lambda_0+\epsilon]$ existe (localmente) un único
# punto fijo $p_\lambda$ en $I$.
# - Para $\lambda_0-\epsilon<\lambda<\lambda_0$, el mapeo $F_\lambda$ no
# tiene ciclos de periodo 2, y $p_\lambda$ es un atractor
# (respectivamente repulsor).
# - Para $\lambda_0<\lambda<\lambda_0+\epsilon$, existe un ciclo de periodo 2
# en $I$ para el mapeo el mapeo $F_\lambda$, que denotamos por $q_\lambda^1$ y
# $q_\lambda^2$, que es atractivo (resp. repulsivo), y el punto fijo
# $p_\lambda$ es repulsor (resp. atractor).
# - En el límite $\lambda\to\lambda_0^+$, tenemos que
# $q_\lambda^i\to p_\lambda$.

# Esto es, al cambiar el parámetro, un punto fijo cambia de estabilidad
# (de atractivo pasa a ser repulsivo, o viceversa), y también aparece de una
# órbita de periodo dos que tiene la estabilidad que tenía el punto fijo antes
# de la bifurcación.
# De manera más general, una órbita de periodo $n$ estable, se tornará
# inestable, y dará origen a una nueva órbita estable de periodo $2n$.
# (La dirección de las desigualdades, o la forma en que cambiamos el
# parámetro, es irrelevante.)

# La bifurcación de doblamiento de periodo ocurre entonces cuando
# $F_\lambda(x)$ es perpendicular a la diagonal, es decir,
# $F_{\lambda_0}'(p_{\lambda_0})=-1$. Usando la regla de la cadena tenemos
# que ${F^2_{\lambda_0}}'(p_{\lambda_0})=1$.

## Más allá del atractor de periodo 2

# Hemos visto que en la familia de mapeos cuadrática $Q_c(x) = x^2-c$
# hay *al menos* dos bifurcaciones que ocurren.
# - Para $c<-1/4$, no hay puntos fijos en el mapeo, y para $c>-1/4$ hay dos puntos fijos que, para valores de $c$ suficientemente cercanos a $c=-1/4$ corresponden a un atractor y a un repulsor.  La bifurcación en $c=-1/4$ es de silla-nodo.
# - Para $c> 3/4$ vimos que el punto fijo atractor se torna repulsor y
# *aparecen* dos puntos de periodo 2 que son atractores. La bifurcación que ocurre en $c=3/4$ corresponde a la bifurcación de  doblamiento de periodo.
# - Para $c>5/4$ los dos puntos del ciclo de periodo dos se tornan repulsores.

# En este apartado estudiaremos qué pasa para $c>5/4$. Antes de esto,
# enfatizamos que para $c\in [-1/4,2]$, toda $x\in D_c = [-x_+,x_+]$ se mapea
# en $D_c$ bajo el mapeo $Q_c(x)$; fuera de este intervalo para $c$ existe
# puntos en $D_c$ que se mapean afuera de $D_c$, lo que de facto implica que
# sus iterados escapan a infinito.

# Construiremos ahora el diagrama de bifurcaciones numéricamente, con cierta
# ingenuidad, considerando la condición inicial $x_0=0$, para hacernos la vida
# más fácil. Es importante notar que este punto tiene una peculiaridad
# importante: $Q_c'(0)=0$ y $Q_c''(0) \neq 0$. Esto es, si $x_0=0$ pertenece a
# una órbita periódica para algún valor de $c$, entonces la órbita será
# *superestable*, aunque esto no es evidente del análisis lineal de la
# estabilidad. Más adelante aclararemos la superestabilidad a la que nos
# referimos.

"""
    ciclosestables!(x, f, c, nit, nout)

Esta función itera el mapeo \$f(x,c)\$ (de una variable) `nit+nout`
veces, usando como condición inicial `x0=0`; los últimos `nout` iterados
actualizan al vector `x` que tiene longitud `nout`. `c` es el valor
del parámetro del mapeo `f`. El mapeo `f` debe ser definido de
tal manera que `f(x0, c)` tenga sentido. La idea es que los últimos
`nout` iterados reflejen los ciclos estables del mapeo `f`.
"""
function ciclosestables!(x, f, c, nit, nout)
    @assert (nit > 0) && (nout > 0)

    #Primeros nit iterados
    x0 = 0.0
    for it = 1:nit
        x0 = f(x0, c)
    end

    #Se guardan los siguientes nout iterados
    for it = 1:nout
        x0 = f(x0, c)
        @inbounds x[it] = x0
    end

    return nothing
end

"""
    diag_bifurc(f, crange, nit, nout)

Itera el mapeo `f` `nit+nout` veces y regresa una matriz
cuya columna `i` tiene los últimos `nout` iterados del mapeo
para el valor del parámetro del mapeo `crange[i]`.

La función `f` debe ser definida de tal manera que `f(x0, c)`
tenga sentido.
"""
function diag_bifurc(f, crange, nit, nout)
    res = Array{Float64}(undef, (nout, length(crange)))

    for ic in eachindex(crange)
        c = crange[ic]
        ciclosestables!(view(res, :, ic), f, c, nit, nout)
    end

    return res
end

begin
	local crange = -0.25:1/2^10:2.0

	local ff = diag_bifurc(Qc, crange, 2000, 256);
	local cc = ones(size(ff, 1)) * crange';

	#Lo siguiente cambia las matrices en vectores;
	#ayuda un poco para los dibujos
	ff = reshape(ff, size(ff, 1)*size(ff, 2));
	cc = reshape(cc, size(ff));

	scatter(cc, ff, markersize=0.05, markerstrokesize=0,
	    legend=false, title="Fig. 5")
	plot!([1.2,1.5,1.5,1.2,1.2], [-1.5,-1.5,-0.9,-0.9,-1.5], color=:black)
	plot!([-0.5,2], zero, color=:red)
	xaxis!("c")
	yaxis!("x_infty")
	# savefig("diag_bif1.png");
end

# Es muy claro a partir del diagrama de bifurcaciones de la Figura 5, que la
# dinámica se vuelve rica e interesante a medida que uno aumenta el parámetro
# $c$ más allá de 5/4.
# En la Figura 6 mostramos un aumento de la región indicada en la Figura 5;
# vale la pena notar que usamos los mismos puntos calculados que aparecen en
# la Figura 5.

begin
	scatter(cc, ff, markersize=0.5, markerstrokestyle=:solid,
	    legend=false, title="Fig. 6")
	xaxis!("c")
	yaxis!("x_infty")
	xlims!(1.2,1.5)
	ylims!(-1.5,-0.9)
	plot!([1.35,1.425,1.425,1.35,1.35], [-1.425,-1.425,-1.33,-1.33,-1.425],
		  color=:black)
	# savefig("diag_bif2.png");
end

# La Figura 6 muestra el aumento indicado en la Figura 5, usando los mismos
# puntos calculados que se usaron en la Figura 5; la curva suave de la derecha
# en la Figura 6 corresponde a una de las ramas de periodo 2.
# Es claro que después del reescalamiento se obtiene esencialmente la
# misma estructura que la gráfica completa (Figura 5), lo que sugiere una
# *estructura fractal*.

# Podemos ver que en $c=5/4$ hay *otra* bifurcación de doblamiento de periodo.
# A partir de ese valor, la órbita de periodo 2 se torna en un repulsor (y por
# eso no se observa en el diagrama de bifurcaciones) y aparece una órbita de
# periodo 4 atractiva.
# Este escenario se preserva hasta cierto valor de $c$ donde la órbita de
# periodo 4 se vuelve inestable (repulsiva), y aparece ahora un ciclo de
# periodo 8, nuevamente por doblamiento de periodo. De hecho, la Figura 6
# muestra que *antes* de $c\simeq 1.4$, aparece un ciclo estable de periodo 16.

# Claramente estamos observando *una cascada de bifurcaciones* de doblamiento
# de periodo. Esto es, al aumentar $c$ los puntos periódicos aparecen en el
# orden: $1, 2, 4, 8, \dots, 2^n, \dots$. Además, el intervalo en $c$ donde el
# periodo $2^n$ se observa (por ser estable), es mayor que donde se observa el
# periodo $2^{n+1}$.
# Aumentos sucesivos de la escala muestran la veracidad de estas observaciones,
# aunque para tener suficientes puntos hay que hacer nuevos cálculos. En la
# Figura 7, que corresponde al recuadro indicado en la Figura 6, la curva de la
# derecha corresponde a una de las ramas del ciclo de periodo 4; en este caso
# iteramos inicialmente 4000 veces, y guardamos para la gráfica los
# siguientes 512 iterados.

# En estas figuras uno puede además observar ciertas regiones del parámetro $c$
# donde *aparecen* ventanas de baja periodicidad, pero cuyo periodo **no** es
# de la forma $2^n$, y también se aprecia que éstas van seguidas de otras
# casadas de bifurcaciones de doblamiento de periodo. Un ejemplo notable es la
# ventana de *periodo 3* que se muestra en la Figura 5. Como veremos más
# adelante, la existencia del periodo 3 implica caos.

# La observación de que los intervalos en $c$ donde se observa cierta
# periodicidad *disminuyen* al aumentar la periodicidad (respetando el
# doblamiento de periodo), lleva a la pregunta si hay una $c$ donde se observe
# un periodo *infinito*.
