# # Diferenciación automática

# La pregunta es si podemos obtener el valor exacto,
# en un sentido numérico, usando números de punto flotante,
# y en la medida de lo posible hacer esto de forma independiente de $h$.
# Esto es, obtener como resultado el valor que más se acerca al valor
# que se obtendría usando números reales, excepto quizás por cuestiones
# inevitables de redondeo. Las técnicas que introduciremos se conocen como
# *diferenciación automática* o *algorítmica*.


# ## Preludio: álgebra de los números complejos

# Antes de ilustrar cómo funcionan los *números duales*, que introduciremos
# más adelante, empezaremos recordando el álgebra de los números complejos:
# $z = a + \mathrm{i} b$, donde $a$
# representa la parte real de $z$, $b$ es su parte imaginaria, y donde
# $\mathrm{i}^2=-1$.

# Uno puede definir todas las operaciones aritméticas de *manera
# natural* (a partir de los números reales), manteniendo las expresiones
# con $\mathrm{i}$ factorizada. En el caso de la multiplicación (y la
# división) debemos explotar el hecho que $\mathrm{i}^2=-1$, que es
# la propiedad que *define* al número imaginario $\mathrm{i}$;
# este punto será clave más adelante cuando extendamos este
# tipo de análisis a los números duales.

# De esta manera, para $z = a + \mathrm{i} b$ y $w = c + \mathrm{i} d$,
# tenemos que,
# ```math
# \begin{align*}
# z \pm w & = (a + \mathrm{i} b) \pm (c + \mathrm{i} d) = (a \pm c) + \mathrm{i}(b \pm d),\\
# z \cdot w & = (a + \mathrm{i} b)\cdot (c + \mathrm{i} d)
#   = ac + \mathrm{i} (ad+bc) + \mathrm{i}^2 b d\\
#  & = (ac - b d) + \mathrm{i} (ad+bc).\\
# \end{align*}
# ```
# Por último, vale la pena recordar que $\mathbb{C}$ es
# *isomorfo* a $\mathbb{R}^2$, esto es, uno puede asociar un punto
# en $\mathbb{C}$ con uno en $\mathbb{R}^2$ de manera unívoca, y
# visceversa.


# ## Números duales

# De manera análoga a los números complejos, introduciremos un par
# ordenado que definirá a los *números duales*, donde la primer componente
# es el valor de una función $f(x)$ evaluada en un punto $x_0$ dado, y
# la segunda es el valor de su derivada evaluada en el mismo punto.
# Esto es, definimos a los *duales* como:
# ```math
# \begin{equation*}
# \mathbb{D}_{x_0}f = \big( f(x_0), f'(x_0) \big) = \big( f_0, f'_0 \big) =
# f_0 + \epsilon\, f'_0.
# \end{equation*}
# ```
# Aquí $f_0 = f(x_0)$ y $f'_0=\frac{d f}{d x}(x_0)$ y, en la última
# igualdad, $\epsilon$ sirve para indicar la segunda componente del
# par ordenado. En un sentido que se precisará más adelante, $\epsilon$
# se comporta de manera parecida a $\mathrm{i}$ para los números
# complejos: mientras $\mathrm{i}$ distingue la parte real y la parte
# imaginaria de un número complejo, $\epsilon$ distinguirá la parte
# función de la parte derivada en los números duales.

# En particular, para la función constante $f(x)=c$, cuya valor
# es independiente de la variable (independiente) $x$, se debe cumplir
# que el dual asociado sea
# ```math
# \begin{equation*}
# \mathbb{D}_{x_0}c = (c, 0) = c,
# \end{equation*}
# ```
# y para la función identidad $f(x)=x$ tendremos
# ```math
# \begin{equation*}
# \mathbb{D}_{x_0} x =(x_0,1) = x_0 + \epsilon.
# \end{equation*}
# ```

# Vale la pena notar que la variable independiente respecto a la que estamos
# derivando es la que define a la función identidad, y que su derivada es 1.

# ## Aritmética de números duales

# Para $\mathbb{D}_{x_0} u = (u_0, u^\prime_0)$ y
# $\mathbb{D}_{x_0} w = (w_0, w^\prime_0)$, y *definiendo* $\epsilon^2=0$,
# usando simple álgebra, tenemos que las operaciones aritméticas para los
# números duales vienen dadas por:
# ```math
# \begin{align*}
#    \pm \mathbb{D}_{x_0} u & = \big(\pm u_0, \pm u'_0 \big), \\
# \mathbb{D}_{x_0} (u\pm w) & = \mathbb{D}_{x_0} u \pm \mathbb{D}_{x_0} w =
#     \big( u_0 \pm w_0, \, u'_0\pm w'_0 \big),\\
# \mathbb{D}_{x_0} (u \cdot w) & = \mathbb{D}_{x_0} u \cdot \mathbb{D}_{x_0} w =
#     \big( u_0 w_0,\, u_0 w'_0 +  w_0 u'_0 \big),\\
# \mathbb{D}_{x_0} \frac{u}{w} & = \frac{\mathbb{D}_{x_0} u}{\mathbb{D}_{x_0} w} =
#     \big( \frac{u_0}{w_0},\, \frac{ u'_0 - (u_0/w_0)w'_0}{w_0}\big),\\
# {\mathbb{D}_{x_0} u}^n & = \mathbb{D}_{x_0}u \cdot {\mathbb{D}_{x_0} u}^n = \big( u_0^n,\, n u_0^{n-1} u'_0 \big).\\
# \end{align*}
# ```
# Claramente, en las expresiones anteriores la segunda componente corresponde
# a la derivada de la operación aritmética involucrada.
# Finalmente, vale la pena también notar que, en las operaciones
# aritméticas *ambos* los duales están definidos en el mismo punto $x_0$.


# ### Ejemplo de cálculo con duales

# A fin de desarrollar un ejemplo que utiliza las operaciones que hemos
# definido entre duales, evaluaremos la función
# $f(x) = (3x^2-8x+5)/(7x^3-1)$ y su derivada en $x=2$. Para esto usaremos
# el dual $u = 2 + \epsilon$; vale la pena enfatizar
# que este dual corresponde a la variable *independiente* $x$ evaluada en 2,
# es decir, la función identidad evaluada en 2, $u = {\mathbb{D}_{2} x}$,
# que corresponde en efecto a la variable independiente
# ya que su derivada (en cualquier punto) es 1.

# (Si todo lo que hemos hecho es consistente, la primer componente
# del resultado deberá corresponder a evaluar
# [$f(2)=1/55$](https://www.wolframalpha.com/input?i=evaluate+%283x%5E2-8x%2B5%29%2F%287x%5E3-1%29+at+x+%3D+2),
# y la segunda componente corresponderá a la derivada
# [$f^\prime(2)=136/3025$](https://www.wolframalpha.com/input?i=derivative%28%283x%5E2-8x%2B5%29%2F%287x%5E3-1%29%2C+x%2C+2%29).
# )
# ```math
# \begin{align*}
# f(2+\epsilon) = & \frac{3u^2-8u+5}{7u^3-1} =
#             \frac{3(2+\epsilon)^2-8(2+\epsilon)+5}{7(2+\epsilon)^3-1} \\
#         = & \frac{3*2^2-8*2^1+5 +\epsilon(2*3*2^1-8) + 3\epsilon^2}{7*2^3-1 + \epsilon(3*7*2^2) + 7*2*3\epsilon^2 + 7\epsilon^3} \\
#         = & \frac{1+4\epsilon}{55+84\epsilon} =
#             \frac{1}{55} + \epsilon \frac{4-\frac{1}{55}(84)}{55}
#             = \frac{1}{55} + \epsilon \frac{4*55-84}{3025}
#             = \frac{1}{55} + \epsilon \frac{136}{3025}.\\
# \end{align*}
# ```
# Los resultados claramente corresponden con la interpretación que queremos.
# Es importante recalcar que si el dual es de la forma
# $u = {\mathbb{D}_{x_0} x}$, es decir, corresponde a la
# variable independiente evaluada en $x_0$, la segunda componente
# de $f(u)$ corresponde a la derivada $f^\prime(x_0)$.

# ## Funciones definidas sobre los duales

# La regla de la cadena es fundamental para el cálculo de las derivadas,
# y por lo mismo, se aplicará para definir funciones sobre duales.
# Definiremos la aplicación de funciones en duales, buscando que la
# interpretación del dual sea preservada: la primer componente del par
# ordenado debe corresponder a la composición de las funciones, y la
# segunda a su derivada.
#
# Entonces, usando la regla de la cadena
# ```math
# \begin{equation}
# \frac{\textrm{d}g(f(x))}{\textrm{d}x}(x_0) = g'(f(x_0)) f^\prime(x_0),
# \end{equation}
# ```
# y escribiendo ${\mathbb{D}_{x_0} f}=f_0+\epsilon f_0^\prime$, con $f_0 = f(x_0)$ y $f'_0 = f'(x_0)$, entonces podemos escribir
# ```math
# \begin{equation*}
# g({\mathbb{D}_{x_0} f}) = g(f(x_0+\epsilon)) = g(f_0+\epsilon f_0^\prime)
#     = g(f_0)+ \epsilon g'(f_0) f_0^\prime,
# \end{equation*}
# ```
# donde el último factor incluye la regla de la cadena.

# De manera similar podemos obtener
# ```math
# \begin{align*}
# \exp({\mathbb{D}_{x_0} u}) & = \exp(u_0) + \epsilon \exp(u_0) u_0^\prime,\\
# \log({\mathbb{D}_{x_0} u}) & = \log(u_0) + \epsilon \frac{u_0^\prime}{u_0},\\
# \sin({\mathbb{D}_{x_0} u}) & = \sin(u_0) + \epsilon \cos(u_0) u_0^\prime,\\
# \cos({\mathbb{D}_{x_0} u}) & = \cos(u_0) - \epsilon \sin(u_0) u_0^\prime,\\
# \tan({\mathbb{D}_{x_0} u}) & = \tan(u_0) + \epsilon \sec^2(u_0) u_0^\prime,\\
# \sinh({\mathbb{D}_{x_0} u}) & = \sinh(u_0) + \epsilon \cosh(u_0) u_0^\prime,\\
# \dots
# \end{align*}
# ```

# Al igual que antes, lo importante de estas expresiones es que si
# $u = {\mathbb{D}_{x_0} x}$ es la variable independiente evaluada
# en $x_0$ (la derivada de $u$ es 1), entonces
# la segunda componente de $f(u)$ corresponderá a $f^\prime(x_0)$.
# Claramente, las reglas anteriores garantizan que la composición de funciones se
# puede usar con duales.

# ## Epílogo

# Citando a [wikipedia](https://en.wikipedia.org/wiki/Automatic_differentiation):
#
# > Automatic differentiation (AD), also called algorithmic differentiation or computational differentiation [...], is a set of techniques to numerically evaluate the derivative of a function specified by a computer program.
#
# Diferenciación automática **no es** diferenciación numérica. Está
# basada en cálculos numéricos (evaluación de funciones en la computadora
# con números de precisión finita), pero **no** usa ninguna de las
# definiciones basadas en diferencias finitas. Tampoco es diferenciación
# simbólica. La implementación que hemos descrito se basa en definir
# los números duales, que son estructuras adecuadas que permiten obtener
# los resultados que buscamos.
