# # Tarea 2: Diferenciación automática

# ## Ejercicio 1
#
# a. Definan una estructura en Julia `Dual` que represente a los números duales;
# los nombres de los campos internos serán `fun` y `der`.
# Por sencillez, pueden considerar que los campos de `Dual` son del tipo `Float64`,
# aunque pueden *osar* a implementar el caso paramétrico `Dual{T <: Real}`,
# donde `T` es el tipo de *ambos* campos.
#
# b. Sobrecarguen las operaciones aritméticas (en Base) de tal manera que cuando involucren `Dual`es den el resultado correcto.
#
# c. Definan un método específico para crear duales (constructor externo), a partir de
# un sólo valor (en lugar de los dos requeridos). Esto corresponderá a
# $\mathbb{D}_{x_0}c = (c, 0)$, donde $c$ es una constante (real).
#
# d. Extiendan los métodos que permitan sumar/restar y multiplicar/dividir un
# número (`::Real`) y un `::Dual`. (Recuerden que ciertas operaciones son conmutativas!).
# NOTA: Este ejercicio lo pueden hacer escribiendo todos los métodos, uno a uno. Otra
# opción es usar `promote` y `convert` para definir reglas de promoción y conversión;
# la documentación de Julia tiene más información sobre esto.
#
# e. Definan las funciones `fun` y `der` que, al ser aplicadas a un `Dual` devuelven
# la parte que corresponde a la función y la parte que corresponde a la derivada
# del `Dual`, respectivamente.
#
# f. Incluyan varios casos (propuestos por ustedes mismos) donde se *compruebe*
# que lo que
# implementaron da el resultado que debería ser. Para esto, pueden usar la librería
# estándard [`Test`](https://docs.julialang.org/en/v1/stdlib/Test/) de Julia.

# ## Ejercicio 2
#
# Definan una nueva función `dual(x_0)` cuyo resultado sea un `Dual` que corresponde
# a la variable independiente $x$ evaluada en `x_0`. Con esta función
# obtengan $f'(2)$ para la función
# ```math
# f(x) = \frac{3x^2-8x+1}{7x^3-1}.
# ```

# ## Ejercicio 3
#
# - A partir de lo visto en clase, *extiendan* las funciones elementales usuales para que funcionen con Duales, es decir, `sin(a::Dual)`,
# `cos(a::Dual)`, `tan(a::Dual)`, `^(a::Dual, n::Int)`, `sqrt(a::Dual)`, `exp(a::Dual)`
# y `log(a::Dual)`.
#
# - Al igual que antes, construyan algún conjunto de pruebas que muestre, de manera
# sencilla, que lo que hicieron da lo que uno esperaría obtener.
