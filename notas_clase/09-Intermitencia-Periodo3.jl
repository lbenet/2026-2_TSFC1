# # Intermitencia y periodo 3

# ## Intermitencia

# En el diagrama de bifurcaciones de la familia de mapeos cuadrática, y
# concentrándonos en particular en el comportamiento del exponente
# de Lyapunov, podemos observar que, después de la serie de
# bifurcaciones de doblamiento de periodo, hay un valor de $c$
# a partir del cual el exponente de Lyapunov es positivo en un
# pequeño intervalo. La dinámica en este intervalo es caótica,
# en el sentido de tener un exponente de Lyapunov positivo.
# De hecho se cumplen otras propiedades (transitividad, conjunto denso
# de órbitas periódicas y sensibilidad de condiciones iniciales) que
# justifican el hablar de una dinámica caótica.

# Para otros valores del parámetro $c$, podemos también
# observar en el diagrama de bifurcaciones que aparece un intervalo del
# parámetro $c$ que muestra una ventana de periodo 3.

# Aquí estudiaremos la dinámica cerca de la ventana de
# periodo 3. Usaremos funciones que escribimos en notebooks
# anteriores primero, para localizar la ventana de periodo 3,
# y después para hacer el análisis gráfico de la dinámica.
# Usaremos las funciones `ciclosestables` y `diag_bifurc`
# que definimos en alguna clase anterior.

Q(x, c) = x^2 - c # mapeo cuadrático

#Tercer iterado de Qc
Qc3(x,c) = Q(Q(Q(x,c),c),c)

# n-ésimo iterado del mapeo Q(x,c)
function Qn(x, c, n)
    for i = 1:n
        x = Q(x, c)
    end
    return x
end

Qprime(x, c) = 2*x # derivada

# Posición del punto fijo `x_+`
xplus(c)  = 0.5*(1+sqrt(1+4*c))

"""
    rand_dominio_Q(c)

Regresa un número aleatorio en el dominio de
`Q(x, c)`.
"""
function rand_dominio_Q(c)
    x₊ = xplus(c)
    return x₊*(2*rand()-1.0)
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
    ff = Array{Float64}(undef, nout, length(crange))

    for ic in eachindex(crange)
        c = crange[ic]
        x = rand_dominio_Q(c) # condición inicial aleatoria
        x = Qn(x, c, nit)
        @inbounds for i = 1:nout
            x = Q(x, c)
            ff[i, ic] = x
        end
    end

    return ff
end

begin
	# Rango de interés para los parámetros
	local crange = range(-0.25, stop=2, length=2^10)

	local ff = diag_bifurc(Q, crange, 10_000, 256);
	local cc = ones(size(ff, 1)) * crange';

	# Lo siguiente cambia las matrices en vectores, y se usa para la gráfica
	local ff = reshape(ff, size(ff, 1)*size(ff, 2));
	local cc = reshape(cc, size(ff));

	p1 = scatter(cc, ff, markersize=0.05, markerstrokestyle=:solid,
    	legend=false)
	xaxis!(p1, "c")
	# yaxis!(p1, "x_n")
	xlims!(p1, -0.25, 2.0)
	ylims!(p1, -2.0, 2.0)
	plot!(p1, [-0.25, 2], zero, color=:red)
	# savefig("diag_bif1-1.png");
end

# Del diagrama de bifurcaciones podemos ver que la ventana de periodo 3
# se encuentra en el intervalo $c\in [1.7, 1.8]$. Verificamos esto.

begin
	#Intervalo de interés para el diagrama de bifurcaciones
	local crange = 1.7:1/2^12:1.8
	local ff = diag_bifurc(Q, crange, 1000, 250);
	local cc = ones(size(ff, 1)) * crange';

	#Cambiamos las matrices en vectores; útil para graficar
	local ff = reshape(ff, size(ff, 1)*size(ff, 2));
	local cc = reshape(cc, size(ff));

	scatter(cc, ff, markersize=0.5, markerstrokestyle=:solid,
    legend=false, title="Ventana de periodo 3")
	xaxis!("c")
	yaxis!("x_infty")
	ylims!(-2,1.5)
end

# De la figura anterior, vemos que la ventana de periodo 3 inicia
# en $c\approxeq 1.75$. Además, la órbita de periodo 3 eventualmente tiene una
# bifurcación de doblamiento de periodo que genera una
# secuencia de doblamientos de periodo que, nuevamente, llevará al caos.

# Consideraremos entonces dos valores,
# $c_- = 1.75 - 1/2^{12}$ y $c_+ = 1.75 + 1/2^{12}$, y analizaremos el
# comportamiento de $Q_c(x)$ con la función `itera_mapeo`. Como
# condición inicial usaremos el punto
# $x_0=1.0$, aunque cualquier otro (excepto un conjunto de medida cero)
# es igual de bueno. Para esto utilizaremos la función `itera_mapeo`
# codificada anteriormente.

#Valores del parámetro cercanos a la bifurcación
c₊ = 1.75 + 1/2^12
c₋ = 1.75 - 1/2^12
c₊, c₋

"""
    itera_mapeo(f, x0, n)

Itera la función ``x->f(x)``, de una dimensión, `n` veces a partir de la
condición inicial `x0`. Regresa dos vectores que se pueden usar para el
análisis gráfico.
"""
function itera_mapeo(f, x0, n::Int)
    #Defino/creo tres vectores de salida (de `Float64`s)
    its_x = [x0]
    its_y = [0.0]
    #Obtengo los iterados
    for i=1:n
        x1 = f(x0)
        push!(its_x, x0, x1)
        push!(its_y, x1, x1)
        x0 = x1
    end
    return its_x, its_y
end;

#Generamos los iterados del mapeo
begin
	x1, _ = itera_mapeo(x->Q(x,c₊), 1.0, 400);
	x2, _ = itera_mapeo(x->Q(x,c₋), 1.0, 400);

	plot(x1[1:2:end], marker=(:dot,2,:blue), markerstrokecolor=:blue, label="c₊")
	scatter!(x2[1:2:end], marker=(:dot,2,:red), markerstrokecolor=:red, label="c₋")
	xlabel!("n")
	ylabel!("x_n")
	title!("Iteraciones sucesivas")
	ylims!(-2, 2.2)
end

# De la figura anterior podemos ver que, después de un comportamiento
# inicial transitorio, para $c_+ > c_3 \aproxeq 1.75$ el periodo 3 emerge
# claramente, lo que sugiere que la órbita de periodo 3 es estable
# después de la bifurcación.
# Por otra parte, antes de la aparición de la ventana de periodo 3, para
# $c_3 > c_-$, se observa un comportamiento transitorio inicial,
# que depende de la condición inicial $x_0$, seguido de varios
# iterados del mapeo que parecen estár cerca de órbita de periodo 3,
# para eventualmente alejarse de ella.

# Esto se repite varias veces, como se aprecia en la figura, involucrando
# distinto número de iteraciones, que hacen la dinámica no periódica.
# A este fenómeno lo llamaremos *intermitencia*.

# El comportamiento *intermitente* se puede entender directamente
# de la gráfica del tercer iterado del mapeo, $y = Q_c^3(x)$, como se muestra abajo.
# Para $c>c_3$, *después* de la aparición de la órbita de periodo 3,
# la identidad intersecta a la gráfica de $Q_c^3(x)$ en dos puntos
# del dominio ilustrado, uno corresponde a la órbita estable de
# periodo 3 y el otro a la inestable, lo que sugiere que la bifurcación
# creó esos dos puntos fijos.
# Por otro lado, para $c<c_3$, no hay intersección con la identidad
# en el dominio mostrado correspondiente al periodo 3.
# (De hecho, si se considera todo el
# dominio del mapeo, hay dos intersecciones que corresponden a
# las órbitas de periodo 1, ambas inestables.)
# La curva punteada corresponde a $c=c_3=1.75$, y claramente
# muestra una intersección tangente.
# Esta última observación sugiere que, localmente, la bifurcación es
# similar a la bifurcación de centro-silla.

begin
	local rng = -0.075:1/2^10:-0.035
	plot( rng, x->Qc3(x, c₊), linewidth=2, legend=:topleft,
		  label="c=c₊")
	plot!(rng, x->Qc3(x, c₋), linewidth=2, color=:green, label="c=c₋")
	plot!(rng, x->Qc3(x, 1.75), color=:black, linestyle=:dash,
		  label="c=c_3")
	plot!(rng, x->x, linewidth=2, color=:red, label="Identidad",
		 linestyle=:dash)
	xlabel!("x")
	ylabel!("y = Q_c^3(x)")
end

# Por lo tanto, si consideramos iterados sucesivos *antes* de la bifurcación,
# para $c < c_3$, y en particular con condiciones iniciales cargadas
# a la derecha ($x_0 \gtrsim -0.055$), los iterados muestran un
# atrapamiento transitorio en esta región, para eventualmente escapar
# de esta región por el lado izquierdo.
# Esto aclara el comportamiento intermitente mostrado arriba para
# los iterados de $Q_c(x)$ que se acercan a los distintos puntos
# que eventualmente serán de periodo tres, para escapar de su cercanía
# después de cierto tiempo.
# Dependiendo de la condición inicial, el comportamiento intermitente
# puede durar más o menos, al igual que el tiempo transiente para
# volver a la cercanía de estas regiones de intermitencia.
# En estas condiciones, uno esperaría que la órbita tenga un
# exponente de Lyapunov positivo.

# ## Periodo 3 implica caos

# Un resultado importante (y famoso) para mapeos de una dimensión
# fue establecido por Li y Yorke en
# [Period three implies chaos](https://www.its.caltech.edu/~matilde/LiYorke.pdf).
# El teorema de Li y Yorke establece que, bajos ciertas condiciones
# (que en particular se satisfacen cuando existen órbitas de periodo 3):

# (i) existen órbitas periódicas con cualquier valor del periodo, y

# (ii) existe un conjunto no numerable de puntos que no es
# asintóticamente periódico.

# En este apartado mostraremos la idea de la demostración de la
# primer parte del teorema de Li y Yorke.

# **Teorema** (Li-Yorke): Sea $J$ un intervalo y $F:J\to J$ continua.
# Supongamos que $a\in J$ es un punto tal que $b=F(a)$, $c=F^2(a)$
# y $d=F^3(a)$, tal que se satisface:
# ```math
# \begin{equation*}
# d \le a < b < c \quad \textrm{(o } d \ge a > b > c\textrm{)}.
# \end{equation*}

# Entonces,

# T1: para toda $k=1, 2, 3, \dots$ extiste un punto periódico de periodo $k$ en $J$;

# T2: existe un conjunto no numerable $S\subset J$, que no contiene puntos periódicos, que satisface las siguientes condiciones:

# A. Para todo $p,q\in S$, $p\neq q$,
# ```math
# \begin{equation}
# \lim_{n\to\infty} \sup |F^n(p)-F^n(q)| > 0,
# \end{equation}
# ```
# y,
# ```math
# \begin{equation}
# \lim_{n\to\infty} \inf |F^n(p)-F^n(q)| = 0.
# \end{equation}
# ```

# B. Para todo $p\in S$, y un punto periódico $q\in J$,
# ```math
# \begin{equation}
# \lim_{n\to\infty} \sup |F^n(p)-F^n(q)| > 0.
# \end{equation}
# ```

# El comentario importante a recalcar es que si hay un punto periódico
# con periodo 3 ($a = d$), las hipótesis del teorema se satisfacen.
# Entonces, T2-B significa que, genéricamente, $p$ es un
# punto que nunca termina en una secuencia periódica,
# es decir, no es asintóticamente periódico.

# La demostración del teorema es una hermosa aplicación del teorema
# del punto intermedio. En particular, usando el teorema del
# punto intermedio uno puede demostrar que, si $f(x)$ es una
# función continua en el intervalo $[a,b]$ y si el rango de $f(x)$
# contiene a $[a,b]$, entonces existe un punto $x_0\in[a,b]$
# tal que $f(x_0)=x_0$, es decir, un punto fijo.
# La aplicación de este resultado, pensando que $f$ es un mapeo, es
# muy clara, ya que si se cumplen las condiciones, entonces existe
# un punto fijo $x_0$ de $f$ en $[a,b]$.

# Entonces, para demostrar T1 uno simplemente utiliza el teorema
# del valor intermedio notando que uno puede construir una secuencia
# de intervalos cerrados $I_k$, tal que $I_{k+1}\subseteq f(I_k)$,
# con $k=0,1,\dots,n-1$, y además $I_n \subseteq I_0$.
# Esto es, el conjunto generado al aplicar $f$ a cada $I_k$ está
# contenido en $I_{k+1}$, y todos los intervalos generados al
# aplicar $f$ están contenidos en $I_0$.
# Entonces existe un punto $x_0$ tal que $f^n(x_0)=x_0$, es decir,
# es un punto periódico con periodo $n$.

# En el caso del periodo 3, usando la notación del teorema ($a<b<c$,
# con $f(a)=c$, $f(b)=a$, $f(c)=b$), uno define los intervalos
# $I_0^* = [a,b]$, $I_1^*=[b,c]$, y por el teorema del valor
# intermedio tenemos que $I_0^*,I_1^*\subseteq [a,c] \subseteq f(I_0^*)$,
# ya $I_0^* = [a,b] \subset f(I_1^*)$.
# Definiendo $I_0^*=I_0=\dots=I_{n-2}$ y $I_{n-1}=I_1^*$, y con
# el resultado anterior para el periodo $n$, tenemos que
# para toda $n$ existe un punto $x_{n}^*$ tal que $f^n(x_{n}^*)=x_{n}^*$.

# La primera parte del teorema es una caso particular del
# [teorema de Sharkovsky](http://www.scholarpedia.org/article/Sharkovsky_ordering),
# que establece un ordenamiento (de los números naturales) en el
# que la aparición de cierto periodo implica la existencia de
# otros periodos.
# El ordenamiento es:
# ```math
# \begin{equation}
# 1 \prec 2 \prec 2^2 \prec 2^3 \prec \dots \prec 7\cdot 2^n \prec  5\cdot 2^n \prec 3\cdot 2^n ... \prec 7 \prec  5 \prec 3.
# \end{equation}
# ```

# Así, el periodo 1 *precede* al 2, que es precedido por 4, etc.
# Periodo 3, entonces, es precedido por todos los periodos.
# El ordenamiento es total.

# ## Referencias

# - Tien-Yien Li and James A. Yorke, American Mathematical Monthly Vol. 82, No. 10 (1975), pp. 985-992. [Link](https://www.its.caltech.edu/~matilde/LiYorke.pdf)

# - Aleksandr Nikolayevich Sharkovsky (2008) Sharkovsky ordering. Scholarpedia, 3(5):1680. [Link](http://www.scholarpedia.org/article/Sharkovsky_ordering)

