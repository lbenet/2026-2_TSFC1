# # Julia (1)

# ## Comentarios

# Iniciamos con lo más trivial: cómo incluir comentarios. En julia, uno puede agregar
# comentarios usando `#`, significando que todo lo que viene después será ignorado
# por el *interpretador* de julia.

#`#` sirve para escribir comentarios en una línea, o el resto de una línea

# El `#`, entonces, sólo se puede usar en una línea.

# Si se quiere agregar comentarios más amplios éstos deben encerrarse entre `#=`,
# que marca el inicio del comentario (de múltiples líneas), y `=#` que marca el
# final del comentario.

#=
Un *bloque* de varias líneas de comentarios se inicia con `#=`
y se termina con `=#`; puede tener las líneas que sea y
el formato que se quiera... pero **sin faltas de ortografía**!

=#

# ## Julia como calculadora

# Julia puede ser utilizada, primero que nada, como una calculadora. Las operaciones
# aritméticas elementales funcionan con `+` la suma, `-` la resta, `*` la
# multiplicación, con `/` la división, y las potencias con `^`.

1 + 1

2 * 3 # los espacios aquí no son esenciales, pero pueden serlo !

# La asignación de variables se hace como siempre, "de derecha a izquierda:
# ```julia
# <variable> = <valor>
# ```
# donde `<var>` es el *símbolo* que se usará para guardar el valor.
# No está de más **enfatizar** que `=` **no** representa la
# igualdad entre
# las cantidades, sólo la asignación.

a = 1.0

# !!! note "Nota para usuarios de Python"
# 	En Python se utiliza `**` para las potencias; en Julia `^`.


b = 2^17 - 1 # es número primo!

# Usar `;` al final de una *instrucción* suprime el despliegue del resultado, y
# también permite concatenar instrucciones.

2^17 - 1;

pi_primaria = 3.1416; b + 1

# Aunque no se despliegue el resultado, las asignación se hizo. Esto se puede
# notar mostrando el valor de la variable.

pi_primaria

# Y, evidentemente, se pueden hacer cálculos más elaborados usando otras funciones:

# división Euclideana
b ÷ 3 # equivalente a `div(b, 3)`; ÷ se obtiene `\div<TAB>`

b % 3  # mod(b, 3); residuo de la div Euclideana

sin(pi_primaria/16)^2

# Julia permite hacer cálculos, además de con enteros o números de punto flotante
# (por default de 64 bits, Float64), con racionales, números imaginarios, y otro
# tipo de "formatos" extendidos.

7 // 128 + 1//128 # racionales

#`im^2 == -1`
#Para π teclear \pi<TAB>
sqrt(exp(-im*π/2))

#Un número *irracional* !
π

#Precisión extendida; default 256 bits, pero se puede cambiar
sqrt(big(2))

# Uno puede hacer comparaciones en Julia. El resultado es una variable booleana,
# es decir, true que equivale a 1, o false, que equivale a 0.

3 >= 5 # 3 ≥ 5, con `≥` tecleando `\ge<TAB>`

#Varias comparaciones a la vez
a < 3 < b

#Igualdad
a == -im^2

#Identidad
a === -im^2 # Falso, porque 1.0 no es idéntico a 1

# ## Funciones

# En Julia, las funciones son **muy importantes**. Por un lado, existen varias funciones definidas en el lenguaje mismo, como `sin`, `div`, `mod` o `sqrt`, que hemos usamos antes. Además, Julia permite y **fomenta** definir funciones propias.

# !!! tip
# 	Julia es *rápido* ya que primero compila (internamente) la función que ha sido corrida, y después usa la función compilada. Es por eso que para escribir código rápido uno debe escribir funciones.

# Esencialmente hay tres maneras de definir funciones, independientemente del número de *argumentos* de los que depende la función. Éstas son: la forma *corta*, la forma *anónima* y la formal *larga*.

# !!! note "Convención"
# 	Por convención, los nombres de las funciones en Julia incluyen *sólo* minúsculas
# (y números u otros caracteres).

#Forma corta
f1(x) = x^3

# En la forma corta, las funciones en general deben escribirse en una sóla
# línea de código, aunque también se pueden escribir dentro de bloques
# `begin ... end`, lo que permite incluir cosas más complejas:
# ```julia
# f2(x) = begin
# 	x^3
# end
# ```
# El resultado de la última instrucción es la que se devuelve al ejecutar la función.
# Esta forma, como veremos después, esencialmente corresponde a la forma larga.

f1(3)

# Forma "anónima"
x -> sin(x)

(x -> sin(x))(π/4)

# Forma larga: la indentación es opcional pero recomendada
function f2(x, α=3) # α=3 es el parámetro default (\alpha<TAB>)
	β = 1/α         # se pueden incluir varios cálculos!
	return x^β      # "return" es opcional, pero recomendado
end

f2(27) # α=3 es el parámetro default

f2(16, 2) # En este caso se usa α=2

# Vale la pena hacer notar que tenemos *dos* métodos definidos para la función
# `f2`, uno que involucra un argumento (y el segundo tiene la asignación de default),
# y otro que involcura dos argumentos.
# En ambos casos, la función se llama `f2`, y cada uno de los métodos se distingue
# por los argumentos (o sus tipos): a esto se le conoce como *multiple dispatch*.

methods(f2)

# Julia permite además definir funciones que incluyen argumentos que deben ser
# "nombrados" (en inglés, *keyword arguments*). Para usarlas, estos argumentos
# deben hacerse explícitos para usarse precisamente
# con el mismo nombre que se les asignó.

f4(x; α, β) = f2(x - β, α)  # (x-β)^(1/α)

f4(126, β=1, α=3)

# En las funciones que hemos definido arriba no hemos impuesto nada específico
# sobre el tipo de argumentos que se espera. Esta manera de programar es
# *genérica*, lo que significa que la función se puede usar en otros contextos,
# siempre y cuando tenga sentido las operaciones.

#Dos resultados
f1(3//2), f1(1.5)

# A veces es conveniente restringir (respecto al tipo) los argumentos de una
# función; esto veremos cómo se hace un poco más adelante. Lo importante es que
# en Julia, esa especificación no hace al código más rápido ni más lento, sólo
# específico.

# ## Cadenas (*strings*)

# Una cadena se define usando comillas `\"...\"`; si ocupa varias líneas, se usan comillas triples \"\"\"...\"\"\"

cadena = "Esto es una cadena (o string)"

cadena_larga = """
Esta es otra cadena larga.
Si se es suficientemente buen observador, resulta ser una cadena que incluye "caracteres especiales" (`\"`, `\n`).
"""

# En lo que se imprimió para `cadena_larga`, noten que las "nuevas líneas" aparecen
# con `\n`, lo que marca una nueva línea, y las comillas con `\"`; estos son
# ejemplos de "secuencias de escape", que empiezan con `\`. Otras secuencias de escape
# incluyen
# - `\t`, tabulador horizontal,
# - `\'`, comilla sencilla,
# - `\\`, la diagonal inversa (backslash),
# - `\$`, el signo `$`,
# entre otras.

# Para concatenar o yuxtaponer cadenas, es decir, hacer una cadena a partir de dos distintas, se utiliza `*`.

cadena * " yuxtapuesta"

# Dado que las potencias enteras se definen como una abreviación de la
# multiplicación `*`, es posible entonces elevar una cadena a *potencia entera*.
# Arriba, `f1(x)` correspondía a "elevar al cubo", y como no se impuso nada
# en el tipo del argumento (función genérica), esa función se puede usar
# con cadenas también.

f1("oh")

# Es posible *insertar* dentro de una cadena el valor que una variable toma,
# usando `$`; a esto se le conoce como *interpolar*.

#Para generar el símbolo π se usa "\pi<tab>"
"El valor de π que se enseña en primaria es $pi_primaria"

# Las comillas sencillas `'`, a diferencia de las dobles `"`, sirven para definir
# *caracteres*, que son las unidades básicas a partir de las que se forman las cadenas.

'c'

"c"

'β'

"β"

# La diferencia que hay entre caracteres y las cadenas de un elemento es muy sutil.
"β" == 'β'

# Para las cadenas se define un *orden lexicográfico". Considerando los caracteres
# típicos (ASCII), primero van los números, luego las minúsculas y luego las mayúsculas.

c0 = "1"; c1 = "Yo"; c2 = "yo"; c3 = "zyo"; alpha = "α";

#Primero van los números, luego las mayúsculas, después las minúsculas
c0 < c1 < c2 < c3 < alpha

# Como dijimos, las cadenas se componen de caracteres. Uno puede acceder a cada uno
# de manera individual a través de su posición, que se numera a partir de 1; el
# resultado es un caracter. El concepto de longitud de una cadena está, entonces,
# bien definido, y se puede accesar con `length`.

#Un caracter
c1[1]

#Un caracter Unicode
alpha[1]

#Una subcadena
cadena_larga[6:12]

#Longitud de cadenas
length(c1), length(alpha)

# !!! danger "Indices de cadenas con caracteres unicode"
# 	Los índices de cadenas con caracteres unicode son un poco enredados.
# En el ejemplo con `alpha` `alpha[2]` arroja un error, mientras que `alpha[3]`
# corresponde a '2', pese a que la longitud de la cadena es 2 (¡ya que sólo
# hay dos caracteres!).

alpha2 = "α2"

alpha2[1]

alpha2[2] # Comentado porque arroja un error

alpha2[3]



# ## Estructuras básicas de datos

# A menudo, uno debe poner en una misma variable (o en una asignación) varios objetos;
# las "estructuras de datos" (aka *data structures*) más básicos son las tuplas,
# los diccionarios y los arreglos.

# ### Tuplas

# Un tupla es una estructura ordenada (*inmutable*!) de objetos. Para definirla,
# la colección de objetos se escribe el contenido entre paréntesis:

# ```julia
# ( obj1, obj2, obj3, ...)
# ```

idiomas = ("español", "catalán", "inglés", "francés", "alemán")

# Para obtener el valor de un elemento de una tupla, usamos su índice, que se
# cuenta a partir de 1, y los paréntesis cuadrados `[ ]` (igual que para las cadenas).
# Para saber qué tan larga es la tupla se usa `length` también.

idiomas[2], length(idiomas)

#Esta instrucción da un error !
idiomas[0]

# !!! attention "Atención"
#     En Julia, igual que en Fortran, el default al enumerar es empezar en 1; esto es
#     contrario a Python o c, que empiezan en 0.

# Las tuplas son estructuras *inmutables*, lo que significa que **no** podemos cambiar
# el valor interno de cada elemento. Tampoco se puede borrar o adicionar un nuevo
# elemento a la tupla. Para hacer cambios hay que reemplazar la tupla entera.

isimmutable(idiomas)

ismutable(idiomas)

#Esto da un error; no se puede cambiar el contenido de algo inmutable
idiomas[3] = "gallego"

#Esto da otro error, `push!` agrega un elemento al final
push!(idiomas, "chino")

#y otro error más; `pop!` borra el último elemento
pop!(idiomas, "chino")


# La ventaja que tienen las tuplas, precisamente por ser inmutables, es que
# permiten un mejor manejo de su almacenamiento en memoria, incluso, cuando los
# elementos tienen tipos distintos.

# Existe una variación sobre las tuplas, en que cada elemento de la tupla tiene
# un nombre asignado. En este caso, para hacer referencia a un elemento podemos
# seguir usando la posición, o también el nombre/etiqueta usando el *símbolo*
# asociado al nombre/etiqueta, o como el "campo" asociado a la etiqueta.

tupla_nombres = (animal="gato", racional=1//1, otracosa=(1,2))

tupla_nombres[1], tupla_nombres[:racional], tupla_nombres.otracosa

# ### Diccionarios

# Un diccionario es una estructura *no ordenada* que liga dos conjuntos de datos. Usando
# ```julia
# Dict()
# ```
# se crea a un diccionario vacío (que debe asignarse a una variable) y que eventualmente
# se puede llenar (usando `push!`). Esto quiere decir que los diccionarios son
# *mutables*. Otra manera de crear un diccionario es con la sintaxis:
# ```
# Dict(key1 => value1, key2 => value2, ...)
# ```

# El hecho de que un diccionario sea *no ordenado* simplemente significa que no hay
# un equivalente a la posición dentro del diccionario; en esto, y en la mutabilidad,
# se distingue de las tuplas con nombre.

calificaciones = Dict( "Fulanito" => 8,  "Mafalda" => 10, "Anónimo" => 2)

calificaciones["Fulanito"]

ismutable(calificaciones)

#Esto cambia la asignación de una entrada
calificaciones["Anónimo"] = 0

calificaciones

# La mutabilidad implica que se pueden agregar, quitar elementos del diccionario,
# o cambiar los *valores* asignados a las distintas *llaves*.

#Agregamos una nueva entrada
push!(calificaciones, "Yo" => 6)

# Vale la pena notar que el diccionario es *tipo* `Dict{String, Int64}`; esto
# **impone** que nuevas entradas tienen que tener llaves que son cadenas, cuyos
# valores asociados tienen que ser enteros. Es por eso que la siguiente instrucción
# generaría un error.

#Esto genera un error
push!(calificaciones, "Perenganito" => "NP")

calificaciones

#Quitamos la *primer* entrada
pop!(calificaciones)

calificaciones

#Borramos una entrada
delete!(calificaciones, "Yo")

# Para conocer todas las llaves que se han asignado a un diccionario, se utiliza
# el comando `keys`, y para saber los valores `values`.

keys(calificaciones)

values(calificaciones)


# ### Arreglos: vectores, matrices y más

# Los arreglos, a diferencia de las tuplas, son *mutables*. Para construir un arreglo,
# usamos la sintaxis:
# ```
# [obj1, obj2, obj3, ...]
# ```
# Si bien los elementos de un vector pueden ser de distinto tipo, por ejemplo
# mezclando números y cadenas, *si es posible* Julia *homogeiniza* todos los
# elementos a un mismo tipo. Esto último se hace para *optimizar* como se almacena
# el arreglo en memoria.

#Vector con Int64, Int64, Float64, Float64, Rational{Int64}
#Las entradas se *promueven* a un vector de `Float64`, ya que esto es posible
coefs_exp = [1, 1, 0.5, 1/6, 1//factorial(4)]

#Las entradas sólo tienen `Any` en común
vector_mezclado = [cos, "cos", :cos, (cos, sin)]

# El hecho de que el tipo de los elementos de `vector_mezclado` sea `Any` implica
# que no hay una manera óptima de almacenar los elementos en memoria, ya que pueden
# ser cualquier cosa, y entonces trabajar con este vector será menos eficiente.

# Igual que para las tuplas, los elementos del vector se acceden a partir de su
# posición y con `[ ]`. Uno, de hecho, puede definir vectores cuyos índices empiezan
# en otro valor distinto que 1. Por esto, Julia usa `begin` y `end` para referirse
# al primero o último elemento del vector de manera más general.

vector_mezclado[3]

coefs_exp[begin], vector_mezclado[end][end]

# Dado que los vectores son mutables, uno puede borrar un elemento, cambiarlo,
# o agregar nuevos elementos. Las instrucciones importantes para quitar o poner
# elementos son `popfirst!`, `popat!`, `pop!`, `deleteat!`, para extraer y/o
# borrar, y `push!`, `pushfirt!`, `insert!` para insertar.

#Agrega un elemento al final del vector
push!(coefs_exp, 1/factorial(5))

# Borra el último elemento del vector
pop!(vector_mezclado)

vector_mezclado

#Cambiamos el último elemento
vector_mezclado[end] = [tan,]

vector_mezclado

# Para crear un arreglo de dimensión 2 podemos hacer un "vector de vectores", lo que
# es útil en ocasiones, pero también incómodo (y male on términos de la memoria).
# Esto, sin embargo, no es internamente una matriz, que existen como tales en Julia.

#Vector de vectores; útil en ocasiones
vec_vec = [[1, 2], [3, 4]]

# Hay distintas maneras de crear una matriz.

#Una matriz construida por renglones! Los espacios en blanco y el `;` son importantes!
mat = [ 1 2; 3 4]

#Mismo resultado, construido por columnas!
[[1,3] [2, 4]]

#Y otra manera más, usando "concatenación" (;)
#El doble ;; cambia a la segunda dimensión
[ 1; 3;; 2;4]

# Los elementos se acceden usando la notación apropiada.

vec_vec[1], vec_vec[1][2]

mat[1], mat[1, 2]

# Las matrices (¡y no los vectores de vectores!), internamente se almacenan recorriendo
# el primer índice, el de la columna, llamado el índice rápido. Esto quiere decir que uno
# puede usar un índice para acceder a los elementos de la matriz, en lugar de dos,
# aunque usar dos es posible. Además, esto *dicta* la manera eficiente en que se
# deben escribir los ciclos (*loops*) anidados que involucran a cada índice:
# el loop más interno debe ser el del índice rápido (primer índice)! Esta convención se
# llama *column major*, y es la misma que se usa también en Fortran... y en las matemáticas.

# !!! note "Nota para usuarios de Python"
# 	La convención que se usa en Python es *row major*, donde el índice rápido recorre los renglones.

#Las matrices se pueden acceder con un sólo índice
mat[1], mat[2], mat[3], mat[4]

(mat[1:4]...,)

#El índice "rápido" es el primero!
mat[1,1], mat[2,1], mat[1,2], mat[2,2]

# Para crear un vector o una matriz de números aleatorios podemos usar `rand`,
# donde un argumento es la longitud del vector; si se usan dos o más índices
# se obtiene una matriz o un arreglo con más dimensiones, con los argumentos
# indicando columnas y renglones. (`rand()` da un número de punto flotante "al azar"
# entre 0 y 1.) Otras funciones más o menos análogas son `zeros` y `ones`, que
# generan arreglos con ceros o unos de las dimensiones especificadas,
# respectivamente.

rand(3)

rand(4,2)

# Arreglos de dimensión 3, y más, se pueden obtener de manera similar.

#Esto genera un arreglo de 3 dimensiones, con enteros entre 1 y 10 al azar
rand(1:10, 2,3,2)

#Esta es una manera que recorre las columnas, en el orden de la memoria
arreglo3d = [ 3;4 ;; 4;5 ;; 4;9 ;;; 8;6 ;; 6; 10;; 4;2]

# Aquí, `undef` significa que el valor es indefinido (pero del tipo `T`),
# aunque en ciertos casos puede mostrar algún valor concreto, y los `nX`
# indican el tamaño de la dimensión correspondiente, con la dimensión total siendo `N`.

#Matriz "indefinida" de 2x3
aa = Array{Float64}(undef, 2, 3)

#Da información sobre las dimensiones de `aa`
size(aa)

# !!! warn "Los asignaciones de arreglos pueden **no** crear copias"
# 	Cuando uno trabaja con vectores, hay que ser cuidadoso cuando uno usa *asignaciones*
#     entre vectores, lo que **no** necesariamente crea copias *independientes*. Esto es,
#     si se crea un arreglo a partir de otro y si se cambia un elemento de uno de los
#     arreglos, **también** se le cambia al otro.

#`bb` NO es copia independiente de `aa`
bb = aa

bb[begin] = pi_primaria

#`aa[1]` TAMBIÉN cambió!
aa[1], bb[1]

#De hecho, se mapean a la misma memoria
aa === bb

# Claramente, los cambios en `aa` o en `bb` afectarán al otro objeto, que de hecho
# es el mismo en memoria, sólo tiene asignado otro símbolo. Esto se hace para optimizar
# el uso de la memoria: no se crean copias a menos que eso es *explíciamente* lo que
# se quiere hacer.

# Para lograr una copia independiente, hay que usar `copy`, o `deepcopy`, si los
# vectores involucran objetos mucho más complicados.

#Hacemos una copia de aa
cc = copy(aa)

aa[1] = 8

#`aa` y `bb` cambian, pero `cc` NO
aa[1], bb[1], cc[1]

# En ocasiones, uno quiere explícitamente evitar que se formen copias. Esto, por ejemplo,
# ocurre cuando uno sólo trabaja con *parte* del arreglo, y no todo, lo que se conoce como
# *slices* (rebanadas), y que crean copias.

# En el siguiente ejemplo, `1:2:3` es un *rango* que empieza en 1, termina en 3, y da
# saltos de 2 en 2. En este ejemplo el resultado equivale a 1 y 3.

#Creamos una rebanada en el segundo índice
dd = aa[:, 1:2:3]

dd[1] = 0.0

# `aa[1]` NO cambió, lo que significa que `dd` es OTRO arreglo (una copia)
aa[1], dd[1]

# Para evitar hacer copias, uno crea una vista (view).

#Creamos un `view` de aa
ee = view(aa, :, 1:2:3)

ee[1] = 5.0

#`ee` es una copia de `aa` (y `bb`)
aa[1], bb[1], ee[1]

# Concluimos este apartado mostrando una manera de verificar si dos arreglos son o
# no son copia el uno del otro, pese a que sus elementos son los mismos (si no fueran
# los mismo, obviamente se trata de dos objetos independientes). La sutileza importante
# no es si sus elementos son iguales (todos, comparados de uno en uno), para lo que
# usamos `==`, sino si los objetos son *independientes* en la memoria; para esto último
# usamos el operador `===`, que precisamente verifica si dos objetos son *idénticos*,
# incluyendo su dirección en la memoria.

# Entre los arreglos que creamos, `aa` y `bb` no crearon una copia. Por lo tanto,
# `==` y `===` resultan en `true`.

#`aa` y `bb` son idénticos, no una copia independiente
aa == bb, aa === bb

#Hacemos iguales el único elemento cambiado
cc[1] = aa[1]

#`aa` y `cc` son copias independientes, pese a tener los mismo elementos
aa == cc, aa === cc


# ## Control de flujo

# ### Ciclos (*loops*)

# En Julia hay dos maneras de implementar los ciclos, que esencialmente son equivalentes.

# - Ciclos `while`

# ```julia
# while _condicion_
# 	_código_
# end
# ```

# - Ciclos `for`

# ```julia
# for _iterador_
# 	_código_
# end
# ```

#Inicializamos n evitando un error (`n` no existe!)
n = -2

while n < 5
	# `println` imprime y cambia a la siguiente línea
	# `print` imprime y continua en la línea
	print(n, "_")
	n += 1
	# `m` es una variable local interna
	m = n
	print(m, "_")
end; n

#Esto da un error, ya que `m` sólo existe dentro del contexto del `while`
m

# OJO: este es distinto en python!
for i = 0:5
    print(i, "_")
end

i

# Noten que `i` sólo existe *dentro* del bloque `for`, al igual que `m` sólo
# existe en el ciclo `while`. La propiedad que describe esto, que una variable sólo
# existe en cierta parte del código, se llama "alcance" (*scope*). Las variables
# usadas dentro de un ciclo `for` o `while`, si no existen antes, sólo existen dentro
# del ciclo. Se dice en este caso que su alcance es *local*.

# En el ciclo `for`, la notación `0:5` define un rango unitario, que empieza en `0`, que
# termina en `5` y se incrementa en una unidad, incluyendo ambos límites. Los rangos
# son maneras eficientes (respecto al uso de memoria) de almacenar un rango.

# Los rangos, al igual que las tuplas, diccionarios, vectores y arreglos, son
# objetos *iterables*, lo que significa que tienen un índice lineal. Entonces, es
# posible acceder directamente a los elementos.

arreglo3d

for c in arreglo3d
    println(c)
end

# Una manera de recorrer todos los índices de un iterador de manera eficiente y que
# además puede evitar errores, es usando `eachindex`.

#"∈" se obtiene \in<tab>
for i ∈ eachindex(aa)
    println(i, "  ", aa[i])
end

# Como se dijo antes, el índice rápido es el primer índice. Entonces, para "recorrer"
# rápidamente un arreglo con muchas dimensiones en todos sus índices, el primer índice
# del arreglo debe corresponder al del ciclo más interno.

size(arreglo3d)

for k in 1:size(arreglo3d, 3)
	for j in 1:size(arreglo3d, 2)
	    for i in 1:size(arreglo3d, 1)
    	    println(i, " ", j, " ", k, " ", arreglo3d[i,j,k])
		end
    end
end


# ### Condicionales

# Para verificar algún tipo de condición, uno utiliza el bloque
# ```julia
# if <condición>
#     ...
# elseif <otra_condición>
#     ...
# else
#     ...
# end
# ```

# Las condiciones deben resultar en `true` (equivalentemente 1), en cuyo caso se ejecuta el bloque, o `false` (equivalentemente 0), en cuyo caso se pasa a la siguiente condición dada por el `elseif`, o el `else`. El orden en que las condiciones aparecen es importante, en particular si no son mutuamente exclusivas (es una u otra, pero no ambas).

# Para definir condiciones, uno puede usar cualquier comparación `==, >, >=, <, ≤, ...`, o funciones, siempre y cuando el resultado sea una variable booleana (`true` o `false`).

#guau!
0 == false

#`!` es la negación booleana
0 != !true

# Cuando uno trabaja con variables booleanas, es útil usar las funciones "or" (`|`), "and" (`&`), y "not" (`!`), que permiten combinar y evaluar dos o más condiciones booleanas. En estos casos, el uso de paréntesis, que impone el orden en que se evalúan los distintos operadores, es importante.

# !!! note "Negación"
#     La negación booleana se lleva a cabo con `!`. En Julia existe también `~` que
#     es la negación de cada bit, lo que es útil al operar con enteros al nivel de bits.

# Por ejemplo, la condición `(false == 0) | (true == 0)` **no** es equivalente a
# `false == 0 | true == 0`, que es la versión sin paréntesis; el último condicional
# equivale a `false == ( 0 | true) == 0`, lo que da simplemente otro resultado.

(false == 0) | (true == 0), false == 0 | true == 0, false == ( 0 | true) == 0

# Los operadores `|` o `&` evalúan ambos lados de operador lógico. A veces uno la doble
# ejecución no es necesaria, y es por eso que existen los operadores de "corto circuito",
# `||` y `&&`.

# A diferencia de los operadores `|` y `&`, los operadores de corto circuito *pueden*
# sólo evaluar un lado (el izquierdo primero), dando la posibilidad de evitar la segunda
# evaluación cuando la primera determina la respuesta. Por ejemplo, con un operador `||`,
# si la primera condición es `true`, el resultado será `true`, y de manera análoga, con `&&`,
# si la primera condición es `false`, el resultado será `false`.

#`@show` es un "macro" que imprime y evalúa la expresión
for b1 in (false, true)
    for b2 in (false, true)
		# @show(b1 || b2)
		@show(b1) || @show(b2)
		# @show(b1 && b2)
		@show(b1) && @show(b2)
        println()
    end
end

# Los operadores de corto circuito, a diferencia de los operadores lógicos, permiten
# construir condicionales tipo `if ... then ...`, incluyendo la ejecución de funciones.
# Esta forma de usar los condicionales es común, por ejemplo, cuando se quiere continuar
# (`continue`) o interrumpir (`break`) un ciclo.

# Como ejemplo interesante, que combina usar arreglos, ciclos y condicionales, escribiremos
# el código que implementa la [criba de Eratostenes](https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes),
# un buscador de números primos.

# El algoritmo es sencillo: para cada entero hay que verificar si es divisible por
# cualquiera de los números primos precedentes. Si `N` es el número entero máximo que
# queremos probar, debemos recorrer la lista de todos los enteros (de hecho, después
# de 2, sólo los impares), y ver si el residuo respecto a *todos* los primos anteriores
# se anula. Si eso pasa, el número es divisible por el número primo, y si no, entonces
# es número primo.

"""
	cribaEratostenes(N::Int)

Implementamos la criba de Eratóstenes de manera ingenua.

NOTA: Esta cadena *antes* de la función es lo que se llama *doctrings*
y es lo que permite saber qué hace la función
"""
function cribaEratostenes(N::Int)
	#Empezamos poniendo en la lista al 2 y 3, que son primos
	#Noten cómo creamos el vector de enteros `Int` que serán el resultado
	numeros_primos = Int[2, 3]

	#Verificamos que `N` sea mayor a 2
	@assert N > 2 "N debe ser mayor a 2"

	#Recorremos los enteros impares (a partir del 5)
	for n in 5:2:N
		println(n)
		p_last = numeros_primos[end]
		for p in numeros_primos
			print(p, "_")
			res = mod(n, p)
			print(res, "   ")
			#`n` es múltiplo de `p`, y entonces se sale del ciclo para `p`
			res == 0 && break
			#regresa al ciclo de `p`, iterándolo
			p < p_last && continue
			#Si se llega aquí, `n` es primo y se agrega a `vector_primos`
			push!(numeros_primos, n)
		end
	end

	return numeros_primos
end

cribaEratostenes(20)

# Por último, Julia admite la forma ternaria de un condicional:
# ```julia
# condición ? codigo_caso_verdadero : codigo_caso_falso
# ```
# que da una manera concisa de escribir un condicional, y que es más o menos equivalente a:
# ```julia
# ifelse(condición, codigo_caso_verdadero, codigo_caso_falso)
# ```
# Una ventaja del condicional ternario (o de usar `ifelse`), es que permite hacer asignaciones de manera clara y concisa.

redondeo_pi = pi_primaria > pi ? "Redondeo para arriba" : "Redondeo para abajo"

