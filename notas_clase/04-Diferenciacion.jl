# # Calculando derivadas

# ## Motivación: el método de Newton
#
# Un problema usual en la física y en las matemáticas aplicadas
# es encontrar los ceros de una función. Una situación
# concreta donde esto ocurre es cuando buscamos los máximos o mínimos de una
# función $f(x)$, en cuyo caso buscamos los ceros de $f'(x)$.
# Aplicaciones de esto se encuentran en redes neuronales, en
# las que uno *entrena* la red buscando el mínimo de una función de costo.
# Otra situación de interés está relacionada con seguir los puntos de equilibrio,
# soluciones estacionarias u órbitas periódicas, al variar un parámetro.

# Un método común para obtener los ceros de una función es el
# [método de Newton](https://en.wikipedia.org/wiki/Newton%27s_method),
# que requiere evaluar sucesivamente tanto la función $f(x)$ como su derivada
# $f^\prime(x)$. Si bien uno puede en general escribir la función $f^\prime(x)$ en el
# programa, esto puede ser complicado, por ejemplo si se cambia la función $f(x)$,
# y da la posibilidad de cometer errores; esta situación se encuentra
# a menudo en redes neuronales, donde uno quiere introducir o cambiar
# ciertas funciones durante el entrenamiento de la red. Es por esto que
# uno quisiera tener formas de evaluar la derivada directamente
# a partir de la propia función $f(x)$.
#
# En este apartado estudiaremos algunos algoritmos para obtener *aproximaciones*
# de las derivadas de una función $f(x)$ numéricamente.


# ## Derivadas numéricas
#
# ### Derivada *derecha*
#
# Como bien sabemos del curso de cálculo, la derivada se define como:
#
# ```math
# \begin{equation*}
# f^\prime(x_0) = \frac{{\rm d}f}{{\rm d}x}(x_0) \equiv \lim_{h\to 0}
# \frac{f(x_0+h)-f(x_0)}{h}.
# \end{equation*}
# ```

# Numéricamente, es difícil implementar el concepto de *límite*, por
# la manera en que la computadora *simula* a los números reales.
# Olvidándo esto por el momento,
# el lado derecho de la definición es relativamente sencillo de implementar
# numéricamente. Esencialmente requerimos evaluar $f(x)$ en $x_0$ y en $x_0+h$,
# donde $h$ es un número (de punto flotante) pequeño. La sutileza está entonces
# en cómo implementar el límite $h\to 0$. Esto, por su parte, lo haremos de manera
# ingenua (numéricamente) considerando valores de $h$ cada vez más pequeños,
# por lo que esperamos obtener valores cada vez más precisos de la derivada.

"""
    derivada_derecha(f, x0, h)

Evalúa la derivada de \$f\$ en \$x0\$ usando diferencias finitas con el
incremento por la derecha.
"""
derivada_derecha(f, x0, h) = (f(x0 + h) - f(x0)) / h

# A fin de *simular* el $\lim_{h\to 0}$, consideraremos distintos valores de $h$
# cada vez más próximos a cero. Para cada valor de $h$ calcularemos el error
# absoluto del cálculo numérico, es decir, la diferencia del valor calculado
# respecto al valor *exacto* de la derivada. Concretamente, y para hacernos la
# vida fácil, usaremos $f(x) = 3x^3-2$ buscando obtener su derivada en $x_0=1$.

#La función f(x)
f(x) = 3x^3-2

#Valor exacto de la derivada
f′(x) = 9x^2


#Error absoluto de la derivada derecha
errorabs_dd(f, f′, x0, h) = abs(f′(x0) - derivada_derecha(f, x0, h))

f′(1.0)

derivada_derecha(f, 1.0, 0.1)

errorabs_dd(f, f′, 1.0, 0.1)

#Errores de la derivada derecha al similar el límite h->0
errs_dd = [ errorabs_dd(f, f′, 1.0, 1/10^i) for i=1:15 ]

findmin(errs_dd)

derivada_derecha(f, 1.0, 1.0e-8)

# El resultado anterior muestra que el mínimo del error absoluto lo encontramos
# usando `h=1.0e-8` (con el muestreo que usamos), y el error absoluto es del orden de
# `3.4e-8`. Esto indica, en algún sentido, que la noción de límite no la logramos
# *simular* correctamente. Más adelante analizaremos este resultado.

# ### Derivada *simétrica*
#
# Una definición alternativa a la dada anteriormente para la derivada, consiste
# en *simetrizar* la ocurrencia de $h$ en la definición. Podemos entonces definir
# a la derivada usando la definición
# ```math
# \begin{equation}
# f^\prime(x_0) \equiv \lim_{h\to 0} \frac{f(x_0+h)-f(x_0-h)}{2h}.
# \end{equation}
# ```
#
# Repetiremos el ejercicio anterior, usando ahora la aproximación de la derivada simétrica
# ```math
# \begin{equation}
# f^\prime(x_0) \approx \frac{\Delta f_\textrm{sym}}{\Delta x} \equiv \frac{f(x_0+h)-f(x_0-h)}{2h}.
# \end{equation}
# ```

"""
    derivada_simétrica(f, x0,h)

Evalúa la derivada de \$f\$ en \$x0\$ usando diferencias finitas con el
incremento simétrico.
"""
derivada_simétrica(f, x0, h) = (f(x0 + h) - f(x0 - h)) / (2h)

#Error absoluto de la derivada simétrica
errorabs_ds(f, f′, x0, h) = abs(f′(x0) - derivada_simétrica(f, x0, h))

#Errores de la derivada simétrica simulando h->0
errs_ds = [errorabs_ds(f, f′, 1.0, 1/10^i) for i=1:15]

findmin(errs_ds)

derivada_simétrica(f, 1.0, 1.0e-6)

# Al igual que en el caso de la derivada derecha, la derivada simétrica no simula
# correctamente el límite, como podríamos haberlo inicialmente pensado, sin embargo,
# la aproximación es mejor, en el sentido de que el error absoluto es menor
# (en 3 órdenes de magnitud) que el de la derivada derecha.

# Los resultados anteriores sobre la convergencia se pueden entender analíticamente
# de la siguiente manera: si usamos el desarrollo en series de Taylor de
# $f(x_0+h)$ y $f(x_0-h)$ tenemos:
#
# ```math
# \begin{align*}
# f(x_0+h) & = f(x_0) + h f^\prime(x_0) + \frac{h^2}{2}f^{\prime\prime}(x_0) + \mathcal{O}(h^3),\\
# f(x_0-h) & = f(x_0) - h f^\prime(x_0) + \frac{h^2}{2}f^{\prime\prime}(x_0) + \mathcal{O}(h^3),\\
# \end{align*}
# ```
# de donde obtenemos, para cada aproximación de la derivada ($h = \Delta x$),
# ```math
# \begin{align*}
# \frac{\Delta f_+}{h} & = f^\prime(x_0) + \mathcal{O}(h),\\
# \frac{\Delta f_\textrm{sym}}{2h} & = f^\prime(x_0) + \mathcal{O}(h^2).\\
# \end{align*}
# ```

# Estos desarrollos muestran que la aproximación de la derivada derecha
# tiene un error de orden $h$ para la derivada, mientras que la aproximación
# de la derivada simétrica tiene un error que es proporcional a $h^2$. Esto
# explica que, en general, la aproximación de la derivada simétrica será mejor.
# De hecho, este truco (de simetrizar expresiones) se usa a menudo para ganar precisión.

# El hecho de que el *límite* no pueda ser simulado como uno quisiera no está relacionado
# con las propiedades de convergencia (en términos de $h$) del cálculo,
# sino está relacionado con el hecho de que
# el cálculo involucra números de punto flotante (y no números en $\mathbb{R}$) y que las
# diferencias de números muy cercanos (como las que definen el numerador), o
# las divisiones con números muy pequeños, conllevan una pérdida de precisión.
# Esto se conoce como
# [cancelación catastrófica](https://en.wikipedia.org/wiki/Catastrophic_cancellation).

# ### Derivada de *paso complejo*
#
# Ahora, por divertimento, consideraremos la siguiente definición de la derivada,
# que podemos llamar  *derivada de paso complejo*
# ```math
# \begin{equation*}
# f^\prime(x_0) \equiv \lim_{h\to 0} \textrm{Im}\left(\frac{f(x_0+i h)}{h}\right),
# \end{equation*}
# ```
# donde $i^2 = -1$, e $\textrm{Im}(x)$ es la parte imaginaria de $x$. Reharemos los
# ejercicios que hemos hecho hasta ahora.

"""
    derivada_pasocomplejo(f, x0,h)

Evalúa la derivada de \$f\$ en \$x0\$ usando la definición basada en una evaluación
compleja.
"""
derivada_pasocomplejo(f, x0, h) = imag( f( complex(x0, h) )/h )

errorabs_dc(f, f′, x0, h) = abs(f′(x0) - derivada_pasocomplejo(f, x0, h))

errs_dc = [errorabs_dc(f, f′, 1.0, 1/10^i) for i=1:15]

findmin(errs_dc)

derivada_pasocomplejo(f, 1.0, 1.0e-9)

# En este caso, observamos que obtenemos el resultado *numéricamente* exacto, incluso
# para un valor de $h$ finito.

# Repitiendo el análisis que hicimos antes, en este caso tenemos
# ```math
# \begin{equation*}
# f(x_0+i h) = f(x_0) + i h f^\prime(x_0) - \frac{h^2}{2}f^{\prime\prime}(x_0) + \mathcal{O}(h^3),
# \end{equation*}
# ```
# de donde tenemos
# ```math
# \begin{equation*}
# \textrm{Im}\left(\frac{f(x_0+i h)}{h}\right) = f^\prime(x_0) + \mathcal{O}(h^2).
# \end{equation*}
# ```
# Claramente, vemos que la aproximación tiene un error proporcional a $h^2$. Sin embargo, y
# a diferencia de la derivada simétrica, la implementación de la derivada compleja no
# incluye cancelaciones catastróficas (en la diferencia), por lo que para valores de $h$
# suficientemente pequeños, el error de la aproximación queda escondida en el error
# de redondeo.

# Para más información sobre estos detalles ver
# [esta liga](https://nhigham.com/2020/10/06/what-is-the-complex-step-approximation/)
# y/o [este artículo](https://epubs.siam.org/doi/epdf/10.1137/S003614459631241X).

# ### Resumen
#
# Resumiendo:
#
# - El error absoluto de la "derivada derecha" es lineal respecto a $h$. Sin embargo, al implementarlo en la computadora, para valores suficientemente pequeños de $h$, el valor obtenido de la derivada deja de tener sentido ya que se pierde la exactitud.
#
# - El error absoluto de la "derivada simétrica" es cuadrático respecto a $h$. Al igual que la derivada derecha, para $h$ suficientemente pequeña, la implementación es dominada por [*errores de cancelación*](https://en.wikipedia.org/wiki/Loss_of_significance) debidos a las diferencias que hay en el numerador y a la división de números muy pequeños.
#
# - Finalmente, vimos que el error absoluto de la "derivada de paso complejo" también es cuadrático en $h$. A diferencia de las dos definiciones anteriores, la derivada de paso complejo no exhibe problemas al considerar valores de $h$ muy pequeños. Esto se debe a que no involucra restas de números muy cercanos, y que dan lugar a errores de cancelación.
#
# Los puntos anteriores muestran que al implementar un algoritmo
# numéricamente (usando números de punto flotante u otros con
# *precisión finita*) es importante la manera en que se hace,
# y cuestiones de convergencia y manejo de errores
# numéricos se vuelven importantes.
# En este sentido, la "derivada compleja" da el resultado
# que (numéricamente) más se acerca al exacto, incluso para valores
# muy pequeños de $h$.
