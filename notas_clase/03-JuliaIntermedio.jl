# # Julia (2)

# ## Broadcasting (*transmisión*)

# Hemos ya hablado de funciones y de arreglos. Julia incluye varias operaciones
# entre arreglos, ya sean vectores, matrices, generalizaciones o mezclas, como extensión
# de las operaciones asociadas en matemáticas.

#Definimos dos vectores de dos componentes
begin
	v1 = [1, 0.0]
	v2 = [0.0, 1.0]
	v1, v2
end

# La suma, resta y la multiplicación/división por un escalar están bien definidas.

v1 - 2*v2

# Esto equivale al producto punto

v1' * v2

# Esto equivale al producto de vector columna por vector renglón
# cuyo resultado es una matriz
v1 * v2'

# Definimos una matriz de 2x2
# La suma, resta o multiplicación/división por un escalar están bien definidas.

mat = [ 1 1 ; -1 1]/sqrt(2)

# El producto matrix * vector está bien definido
mat * v1

v1' * mat

# El producto de matrices es el usual(!)
mat * mat

# Otras funciones usuales sobre matrices están incluidas
# `transpose` es la transpuesta, `conjugate` el conjugado transpuesto
# (equivalente a usar ')
transpose( [0 im; -im 0.0] ) == [0 -im; im 0.0]'

# En ciertos casos, las funciones no tienen un sentido matemático, o éste
# requiere de sutilezas, y entonces se emiten errores. Por ejemplo, el producto
# de dos vectores emite un error, dado que no está definido en un sentido "usual" matemático.

#Esto da un error
v1 * v2

# !!! note "LinearAlgebra.jl"
# 	Existen paqueterías que extienden la funcionalidad que tiene Julia,
#     en particular menciono `LinearAlgebra.jl`, que es una paquetería "estándar",
#     es decir, está incluída en Julia aunque no se carga por default; esta
#     paquetería permite por ejemplo obtener eigenvalores y eigenvectores,
#     u operar con matrices "especiales".

# En ocasiones, uno quiere que, por ejemplo, el producto de matrices sea
# "elemento a elemento", y no el producto usual entre matrices, o que la aplicación
# de cierta función, como `exp` o `sin`, cuyo resultado tiene sentido matemáticamente
# para matrices, se lleve a cabo elemento a elemento. En este caso en Julia se explota
# la "transmisión" de una función a fin de ser aplicada elemento a elemento; a esto se
# le conoce como *broadcasting*.

# La transmisión se basa en la función `broadcast` usando la sintaxis.
# ```julia
# broadcast(f, obj1, obj2)
# ```
# donde `f` es la función que será aplicada elemento a elemento sobre `obj1` y `obj2`,
# donde éstos son dos objetos iterables. Obviamente, cierta compatibilidad de las dimensiones
# se exige.

# Una forma alternativa más concisa usa el llamado "operador punto". Para las
# operaciones aritméticas, o comparaciones que usan operadores aritméticos, el punto se
# escribe antes del operador: `.+`, `.-`, `.*`, `./`, `.^`, `.=`, `.==`, etc; en el caso
# de otras funciones, como `exp`, `sin`, etc, el punto se escribe después de la función y
# antes del o los argumentos de la función.

#Recoredemos quien es `mat`
mat

#El producto usual de dos matrices
transpose(mat) * mat

#Producto elemento a elemento de dos matrices, usando `broadcast`
broadcast(*, transpose(mat), mat)

#Producto elemento a elemento de dos matrices
transpose(mat) .* mat

#Comparación elemento a elemento; 1 == true
transpose( [0 im; -im 0.0] ) .== [0 -im; im 0.0]'

#`exp` sobre una matrix tiene sentido en matemáticas
exp(mat)

#Se obtiene la `exp` de cada elemento
exp.(mat)

#Matriz de racionales positivos ("irreducibles"), con cierto orden
#El numerador es el renglón, y el denominador la columna
ones(Int, 5, 5) .* (1:5)' .// (1:5)

ones(Int, 5, 5)

(1:5)'

(1:5)

# Broadcasting se puede aplicar a otras situaciones "menos obvias". Por ejemplo,
# podemos sumar el vector `v1` definido arriba, elemento a elemento, con `mat`, lo
# que significa operar las columnas, o si en cambio sumamos el traspuesto, la suma
# es elemento a elemento sobre los renglones.

v1, mat

mat .+ v1

mat .+ v1'

# La aplicación de broadcasting es genérica y no es de uso exclusiva de aplicaciones
# que involucren números.

#Vandermonde matrix
#En este caso se multiplica un vector columna por uno renglón!
string.("x_", (0:5)) .* string.("^", (0:2)')

#Algo de francés
begin
	pron_fr = ["J'", "Tu ", "Il/elle/on ", "Nous ", "Vous ", "Ils/Elles "]
	conj_avoir = ["ai", "as", "a", "avons", "avez", "ont"]
	pron_fr .* conj_avoir
end

# Otra función interesante, en el contexto de aplicar una función a todos los elementos
# de un arreglo, es `map`:
# ```julia
# map(f, c...)
# ```
# Literalmente, `map` transforma la colección `c` aplicando a cada uno de sus elementos
# la función `f`.

map(*, pron_fr, conj_avoir)

# Entre otras aplicaciones, `map` sirve para crear máscaras y filtrar elementos de
# arreglos complicados.

#Definimos un tensor con dimensiones 2x3x2
tens = reshape(1:12, 2, 3, 2)

#Definimos una máscara
mask = map(ispow2, tens)

#Imprimimos los valores que verifican la condición definida en la máscara
tens[mask]

# En este mismo contexto, `filter(f, a)` es otra función que *filtra* los
# elementos de `a` si la aplicación de `f` es verdadera.

#Otra manera de hacert lo mismo, sin usar máscaras
filter(ispow2, tens)

# ## Tipos y estructuras

### Todo en Julia tiene un tipo asignado

# !!! tip "tldr;"
# 	**Todo** en Julia está asociado a algún tipo.

# En Julia **todo** está asociado con algún tipo, lo que incluye a los valores
# *literales*, *símbolos*, funciones, incluídas las que uno define, y los tipos
# mismos, todo está asociados a tipos.

#Varios tipos asociados a valores
typeof(1), typeof(1f0), typeof(1.0), typeof(big(1)), typeof(big(1.0))

#Tipo asociado a la función `cos`
typeof(cos)

#Tipo asociado a una función anónima
typeof(x->3*x^2)

#Tipo de un vector de enteros
typeof([1, 2, 3])

#Tipo de un tipo!
typeof(Int32), typeof(typeof(big(1.0)))

typeof(true)

#El tipo asociado al valor de la variable `pi_primaria` (3.1416)
pi_primaria = 3.1416

typeof(pi_primaria)

#Tipo asociado a un *símbolo*
typeof(:pi_primaria)

#Tipo asociado a una expresión
typeof( :(cos(pi_primaria)) )

# Además, Julia establece una jerarquía de tipos, lo que permite mucha flexibilidad
# a la hora de escribir código y aplicarlo. Esta jerarquía es un árbol (completamente
# conectado), donde la "raíz" es `Any`, cualquier cosa es tipo `Any`, y las "hojas" del
# árbol son en general los tipos concretos; al resto de los tipos que no son concretos
# se les llama *abstractos*. El tipo asociado a `Any` es `DataType`.

# Construímos el árbol de tipos desde `Float64`
begin
	T = Float64
	@show T
	while T != Any
		T = supertype(T)
		@show T
	end
	println()
	@show(T, typeof(T))
end

# De igual manera en que uno puede "ir hacia la raíz", uno puede inspeccionar los
# subtipos que existen asociados a algo.

subtypes(Number)

subtypes(Real)

subtypes(Integer)

subtypes(Signed)

# Una manera de saber si un tipo es subtipo de otro, es usar el operador `<:`.
# Este operador se usará para definir funciones que se aplican a varios *(sub)tipos*.
# El análogo para una *instancia* de un tipo es `isa`.

#Verifica si `Float64` es subtipo de `Number`
Float64 <: Number

#Verifica que 1.0 es un `Number`
1.0 isa Number

#Se puede usar en tipos abstractos
Integer <: AbstractFloat

#Verifica que 1 es un `Integer`
1 isa Integer

Vector <: AbstractArray

String <: AbstractArray

# Verifica que [1] es un `AbstractArray`
[1] isa AbstractArray

[1] isa AbstractArray{Int,1}


### Definiendo tipos propios

# Julia permite al usuario definir sus propios tipos, a los que uno se refiere
# como *tipos compuestos* o también  *estructuras*, lo que le da gran versatilidad
# y funcionalidad a Julia. Esto es, uno puede definir su propia estructura de datos
# que incluso puede ser *paramétrica*, e insertarla en el árbol de tipos con libertad,
# si es conveniente, a fin de usar dicha estructura de manera general. (Si uno no la
# inserta en un lugar específico, esto implica que el tipo creado es un subtipo de
# `Any` directamente.)

# Hay dos tipos de estructuras compuestas, las estructuras inmutables, como las tuplas,
# que se definen usando un bloque `struct ... end`, o las estructuras mutables, como los
# arreglos, que se definen usando un bloque `mutable struct ... end`. (Todos los bloques
# en Julia siempre terminan en `end`.) A pesar de que un objeto es inmutable, alguno de
# sus campos pueden ser mutable, como arreglos; el hecho de tener campos mutables significa
# que el campo puede cambiar, pero no el objeto en memoria al que apunta.

# La sintaxis para definir un tipo compuesto es:

# ```julia
# struct MiTipo
# 	foo
# 	bar :: Int
# 	baz :: Float64
# end
# ```

# Aquí, los *campos internos* de la estructura `MiTipo` son `foo`, `bar` y `baz`,
# y en este ejemplo se ha *impuesto* que `bar` sea un `Int` (que en general implica
# ser `Int64`), `baz` sea un `Float64`, y `foo` no tenga ninguna especificación, por
# lo que puede ser cualquier cosa; esta falta de especificidad, de hecho, no es óptima
# en Julia aunque a veces es necesaria.

# !!! important "Convención"
# 	Por convención, los nombres de los tipos en Julia incluyen se escriben en
# *camel case*, que combina el uso de mayúsculas al principio de las palabras, y
# minúsculas para el resto de las palabras.

struct MiTipo
	foo
	bar :: Int
	baz :: Float64
end

#Esto crea un objeto del tipo MiTipo
mt = MiTipo("nombre", 1, 2.5)

typeof(mt)

#MiTipo es inmutable
isimmutable(mt)

#Lo siguiente genera un error, ya que `bar` debe ser `Int` (y es `Float64`)
MiTipo((), 1.3, 2)

# La función `fieldnames` da información sobre los campos definidos para un tipo
# específico. Para acceder al valor en cada campo se utiliza `mt.foo`, por ejemplo,
# que es equivalente a `getfield(mt, :foo)`.

fieldnames(MiTipo)

#`:foo` es el símbolo asociado al campo `foo`
getfield(mt, :foo), mt.foo

# En Julia algunos tipos pueden depender de otros tipos *de forma paramétrica*,
# por ejemplo, según el tipo que adquieren uno o varios campos internos. Como
# ejemplo de un tipo paramétrico menciono los arreglos; como vimos arriba, el tipo
# asociado al vector `[1,2,3]` es
# ```julia
# Vector{Int64}
# ```
# que es un *alias* de `Array{Int64,1}`. En este caso, el arreglo tiene elementos
# que son `Int`, y es de dimensión `1` (es un vector). Otros ejemplos de tipos
# paramétricos son los número racionales y los números complejos.

# Para definir tipos paramétricos, sean o no inmutables, se usa la sintaxis
# ```julia
# struct Punto2d{T}
# 	x::T
# 	y::T
# end
# ```
# En este ejemplo, `T` es el tipo de *ambos* campos internos (`x` y `y`); vale la
# pena enfatizar que `T` no ha sido restringido de ninguna manera. Entonces,
# mientras que el tipo de `x` y `y` sean lo mismo, uno puede crear una *instancia*
# de `Punto2d`.

# Este ejemplo puede ser refinado, en el sentido de que uno puede *acotar* `T` para
# sólo considerar subtipos de `Real`, por ejemplo. Esto permitirá, entonces, poder
# crear `Punto2d{Float64}`, o `Punto2d{Rational{Int64}}`, e impedirá crear un
# `Punto2d{String}`. Esto se logra usando, en el ejemplo anterior, `T<:Real`.

#Estructura paramétrica restringida a tener campos con subtipo `Real`
struct Punto2d{T<:Real}
	x::T
	y::T
end

p = Punto2d(1.0, 2.5)

typeof(p)

p isa Punto2d, p isa Punto2d{Float64}

Punto2d(1//2, 3//1)

#Esto dará un error, ya que las cadenas no son subtipo de `Real`
Punto2d("a", "b")

#Esto dará un error, ya que los tipos de los campos no coinciden
Punto2d(1, 2.5)

#El ejemplo anterior se logra hacer funcionar explicitando `T`
Punto2d{Float64}(1, 2.5)

# `Punto2d` es un tipo válido por sí mismo, que en algún sentido engloba a los
# distintos `Punto2d{T}`. Sin embargo, dos tipos `Punto2d{T1}` y `Punto2d{T2}`
# no son subtipos de ellos entre sí (a menos que `T1` y `T2` sean idénticos).

Punto2d{Float64} <: Punto2d

Punto2d{Float64} <: Punto2d{Int}, Punto2d{Int} <: Punto2d{Float64}

Punto2d{Float64} <: Punto2d{Real}

# El último resultado, a pesar que es verdadero `Float64 <: Real`, implica que el
# sistema de tipos en Julia es *invariante* (y no covariante o contravariante).
# Sin embargo, cierta noción de invariancia existe en Julia usando `<: Real`, y
# de contravariancia usando `>: Int`, por ejemplo.

#covariancia
Punto2d{Float64} <: Punto2d{<:Real}

#contravariancia
Punto2d{Real} <: Punto2d{>:Int}

# Por completez, mencionamos cómo insertar en algún punto específico del árbol de
# tipos a algún tipo compuesto. En el siguiente ejemplo, `Intervalo` es una
# estructura paramétrica que es subtipo de `Real`. El interés de esto es que `Intervalo`
# *puede* heredar propiedades de `Real` de manera más o menos automática.

struct Intervalo{T} <: Real
	inf :: T
	sup :: T

	# Constructor interno!!
	function Intervalo(a::T1, b::T2) where {T1<:Real, T2<:Real}
		@assert a <= b "Error!! `inf` debe ser menor o igual que `sup`"
		R = promote_type(T1,T2)
		return new{R}(a, b)
	end
end

# La definición de `Intervalo` es interesante por varias cuestiones:

# 1. La definición de `Intervalo` incluye una función dentro de la estructura.
# Esa función, llamada *constructor interno*, verifica que el primer argumento `a`
# (que corresponde a `inf`) sea menor o igual al segundo `b` (que corresponde a `sup`);
# si eso no es verdadero, un error de asersión ocurre.

# 1. Vale la pena notar la forma en que el constructor interno impone que los argumentos
# `a` y `b` son del tipo `T1` y `T2`, respectivamente, ambos subtipos de `Real`; en
# particular, noten el `where`.

# 1. La verificación de que se cumpla `a <= b` se hace usando `@assert`, que es un macro
# que verifica que la expresión que sigue sea verdadera, y lanza un error si la expresión
# no lo es; de manera opcional, aparece el mensaje dado por la cadena que sigue.

# 1. El constructor interno devuelve el resultado de la función `new`. El único uso que
# tiene `new` es precisamente crear una instancia del tipo que se está definiendo, en este
# caso `Intervalo`.

# 1. El constructor interno, además, *promueve* los tipos asociados a `a::T1` y `b::T2`,
# almacenándolo en `R`, que es el tipo que aparece como parámetro en `new{R}`. Se requiere
# que `new` sea paramétrico, ya que el intervalo lo es. Lo que esto quiere decir es que,
# internamente los tipos de `a` y `b`, si son diferentes son promovidos *a un
# tipo común* debajo de la jerarquía de `Real`.

#Ejemplo Interval{Float64}
Intervalo(1.0, 2.5)

#Esto da un error
Intervalo(1.5, 1.2)

#Ejemplo de Intervalo con tipos no idénticos
dom = Intervalo(1.2, big(1.5))

typeof(dom)

# ### Algunas estructuras particulares

# Una excepción a lo descrito sobre los tipos, en particular en cuanto a los campos
# internos, son las tuplas: las tuplas, como estructuras, no tienen campos internos
# y los datos que se almacenan sólo pueden accesarse a través de la posición, como ya
# vimos. Además, las tuplas son covariantes. Este compartamiento especial de las tuplas
# se da porque las tuplas, en algún sentido, son el argumento de las funciones, en
# donde el orden importa. Comentarios semejantes se aplican a los `NamedTuples` en
# relación a sus campos internos y a las funciones que requieren especificar parámetros
# a través de nombre ("keyword args").

#Covariancia de tuplas!
Tuple{Int, String} <: Tuple{Real, Any} <: Tuple

typeof( (a=3, st="algo más", tpl=(1,2,)) )

# Las funciones, como ejemplificamos arriba, tienen asociadas tipos propios, y todas
# son subtipo del tipo abstracto `Function`. Esto es importante, por ejemplo, cuando
# un argumento (o varios) de una función son precisamente funciones. Ejemplos de
# funciones que requieren como argumentos funciones son `broadcast` o `map`, como se
# mostró arriba.

#Todas las funciones son subtipo de `Function`
typeof(cos) <: Function

# Hay otros tipos que son especiales en distintos sentidos. Por ahora, sólo mencionaré
# los llamados "singletons" y los "value types".

# Los tipos *singletones* son tipos inmutables compuestos que no tienen campos internos.
# Por ejemplo:
# ```julia
# struct MiSingleton
# end
# ```
# Estos tipos satisfacen que, si `a isa MiSingleton && b isa MiSingleton`, entonces
# `a === b`. En otras palabras, sólo existe una instancia de realizar `MiSingleton`.

#Definimos un singletón
struct MiSingleton
end

#Creamos un objeto tipo MiSingleton
a = MiSingleton()

#Verifica que el tipo `MiSingleton` es un singletón
Base.issingletontype(MiSingleton)

# Un ejemplo concreto de singletones son los tipos asociados a funciones.

Base.issingletontype(typeof(cos))

# Otro tipo especial en Julia son los "tipos de valores", o *value types*, que son
# singletones paramétricos, `Val{x}`. En este caso, se trata de un tipo que se asocia
# a un valor `x`, como por ejemplo `true` o `false`, que son instancias del tipo `Bool`.

#Esto crea una instancia de Val{true}
Val(true), typeof(Val(true))

Base.issingletontype(typeof(Val(true)))

# Los tipos mencionados anteriormente tienen papeles especiales. Por ahora
# menciono como ejemplo que los tipos de valores pueden ayudar a elegir qué
# método concreto se aplica dependiendo de un valor, de la función, o del tipo.
# Julia decide qué método usa, es decir qué implementación concreta de una
# función (de un mismo nombre), usando los *tipos* de los argumentos (¡no de
# sus valores!). En los casos en que ciertos *valores* determinan el método,
# por ejemplo distinguiendo el caso por `true` o `false`, uno entonces define
# métodos para `Val{true}` y `Val{false}`, que son tipos, cuyas *instancias*
# son `Val(true)` y `Val(false)`, respectivamente.

# ## Funciones y estabilidad de tipo

# Ya vimos cómo se definen las funciones más sencillas. Uno puede definir funciones
# que actúan diferente según el tipo, por ejemplo, para que la función se comporte
# de manera diferente según el tipo. Esto se logra *especificando* el tipo del argumento, usando la notación
# ```julia
# function mifuncion(a::Int, b)
# 	...
# end
# ```
# Aquí, la notación `a::Tipo` indica que `a` es una instancia de `Int`,
# mientras que `b` no ha sido restringido, y por lo mismo, puede ser
# cualquier cosa.

# Lo importante es que uno puede definir *métodos* distintos asociados a una misma
# función. En el siguiente ejemplo definimos el producto de dos `Intervalo`s; el
# ejemplo además ilustra cómo se sobrecarga un método ya existente (en este caso
# proporcionado por el *módulo* `Base`), y también si dicho método está asociado a
# un operador, en este caso `*`.

#Sobrecargamos la función producto para Intervalos
function Base.:*(a::Intervalo, b::Intervalo)
	rmin, rmax = extrema((a.inf * a.inf, a.inf * b.sup,
						a.sup * b.inf, a.sup * b.sup))
	return Intervalo(rmin, rmax)
end

begin
	aI = Intervalo(0.0, 1.0)
	bI = Intervalo(-1.0, 1.0)
	aI*bI, bI*bI
end

# Un punto **muy** importante para que Julia sea rápido es que el resultado de las
# funciones dependa **sólo** del tipo de los argumentos de entrada, y no de sus
# valores. Este concepto se llama *estabilidad de tipo*.

# La siguiente función es un ejemplo de una función que NO es estable
# según el tipo.

pos(x) = x < 0 ? 0 : x

pos(3.5), pos(-3.5)

# El problema en la función está que si `x` es negativo el resultado es `0::Int`,
# mientras que si `x` es positivo el resultado es `x` que puede ser de tipo distinto
# a `Int`.

# Una manera sencilla de corregir el problema es usando la siguiente función:

#El uso de `zero(x)` hace la función estable según el tipo.
pos1(x) = x < 0 ? zero(x) : x

pos1(3.5), pos1(-3.5)

# Un problema cercano a la estabilidad de tipo se da cuando las variables en
# un ambiente cambian (por ejemplo, las funciones).

function miinverso()
    x = 1
    for i = 1:10
        x = 1/rand()
    end
    return x
end

# En este caso inicializar `x` a 0.0 resuelve el problema.

# Un macro muy útil para detectar la falta de estabilidad de tipo es
# `@code_warntype`.

@code_warntype pos(-3.5)


# ## Manejador de paqueterías

# Julia tiene una gran variedad de paqueterías públicas, que uno puede manejar de
# distintas maneras, instalar, crear, y en algunos casos, modificar (incluso
# para proponer mejoras).

# En primer lugar, existen las paqueterías que pertenecen a las librerías estándar
# (*standard library*) de Julia. Éstas, en algún sentido, son parte de Julia pero
# no se cargan por default, sino que hay que cargarlas de manera explícita, para
# que no sea demasiado pesado el uso de Julia.

# Algunos ejemplos de paquetes que están en la librería estándar son:
# [Dates.jl](https://docs.julialang.org/en/v1/stdlib/Dates/), para trabajar con
# fechas, [DelimitedFiles.jl](https://docs.julialang.org/en/v1/stdlib/DelimitedFiles/)
# para poder leer y escribir archivos (a disco) que incluyen datos, por ejemplo,
# en formato `csv`,
# [`LinearAlgebra.jl`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/)
# para hacer cosas relacionadas con álgebra lineal,
# [Pkg.jl](https://docs.julialang.org/en/v1/stdlib/Pkg/) para trabajar
# con paqueterías, entre otras.

#Cargamos la paquetería Pkg
using Pkg

# La siguiente instrucción activa un directorio temporal para las paqueterías.
# Esto es útil, por ejemplo, en casos en que estamos probando las cosas.
#
# ```julia
# Pkg.activate(temp=true)
# ```

# Uno puede especificar (usando cadenas dentro del paréntesis) cualquier
# otro directorio específico; esto depende del sistema operativo en que se
# trabaje.

#Esto activa el directorio en el que nos encontramos
Pkg.activate(".")

# La activación de un paquete lee, y si no existe, crea, (en el mismo
# directorio, el archivo `Project.toml`
# que incluye toda la información necesaria para "recrear" el ambiente específico
# y reproducir los resultados. La reproducibilidad completa se logra, además
# del archivo `Project.toml`, con el archivo `Manifest.toml`, que incluye
# muchísima información extra para lograr la reproducibilidad.

Pkg.status()

# Para cargar una paquetería, uno debe tenerla instalada, y después se carga. Las
# librerías estándar no se necesitan instalar, pero es útil "anunciarlas" para
# que aparezcan en los archivos "Project.toml" y "Manifest.toml".

#Esto instala paqueterías, y para las estándar, las incluye en "Project.toml"
Pkg.add("LinearAlgebra")

#Esto activa la paquetería
using LinearAlgebra

#Calcula eigenvalores
eigvals(mat)

#Calcula el producto punto
dot(v1, v1)

# Una paquetería particularmente útil es "Plots.jl", que sirve para hacer gráficas.
# Hay otras también útiles, pero por ahora usaremos esta. `Plots.jl` es una
# librería amplia que permite hacer muchos tipos de gráficas con una interfaz
# similar, utilizando distintos programas para finalmente hacer las gráficas.
# No es la única librería, pero sí una suficientemente sencilla de usar.

#Instalamos la paquetería
Pkg.add("Plots")

#Cargamos la paquetería
using Plots


begin
    # "Crea" la gráfica y pinta x vs sin(x)
	plot(0.0:0.125:2π, x->sin(x), label="sin(x)", lw=2)
    # "Modifica" la gráfica anterior, pintando x vs cos(x)
  	plot!(0.0:0.125:2π, cos, label="cos(x)", lw=4)
	xlabel!("x")
	ylabel!("y=f(x)")
end

# Ahora graficamos algunos datos al azar

#Gráfica algo burda
scatter(x, y, xaxis=("x"), yaxis=("y"),
    color=decide_color.(x, y), 	aspect_ratio=:equal, legend=:none)

#Ajusatmos más detalles
scatter(x, y, color=decide_color.(x, y),
    markerstrokecolor=decide_color.(x, y),
    legend=:none, aspect_ratio=:equal,
    ms=1.0)