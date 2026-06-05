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
#

include("ModuloDual.jl")
using .NumDual

# (b) Escriban una función que implemente el método de Newton para funciones
# en una dimensión. La derivada que se requiere deberá ser calculada usando
# los números duales. Obtengan usando esta implementación un cero de
# \$f(x) = x^3 - 15.625\$, para verificar que su implementación funciona.
#

function cerosNewton(f,a) 
    """
    Obtiene un solo cero de la función dada, estableciendo una variable inicial (a), para buscar nuestro cero.
    Se detiene el procedimiento cuando el error relativo es menor a 1e-6
    """
    error=1e-6
    dif = 1
    while dif>error  
        b = a
        a = a - (fun(f(dual(a))))/(der(f(dual(a))))
        dif = abs(b-a)
    end
    return a
end

f(x) = x^3-15.625
cerosNewton(f,2)

# (c) Encuentren *todos* los puntos fijos del mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.
#

F(x) = x^2 - 1.1 
G(x) = x^2 - x - 1.1 # Debemos encontrar los ceros cuando F(x) = x => G(x) = F(x)-x

#  Como la función es cuadrática, solo hay 2 posibles ceros, los buscamos iniciando en 1 y -1 respectivamente
cerosNewton(G,1)
cerosNewton(G,-1)

# (d) Encuentren los puntos *de periodo 2* para el mapeo \$F(x) = x^2 - 1.1\$
# usando la función que implementaron para el método de Newton.

H(x) = x^4 - 2.2x^2 -x + 0.11

function CerosFun(f,a,b) 
    """
    Obtiene todos los ceros de una función implementando un barrido en el dominio [a,b].
    Primero obtiene f(x) en todo el dominio, luego se obtienen aquellos puntos en los que hay un cambio de signo. 
    Se aplica Newton sobre la semisuma de los puntos en los que se encuentra el cambio de signo. 
    """
    x0Aprox = []
    x0 = []
    x = range(a,b,length=1000)
    y = f.(x)
    for i in 1:length(y)-1
        if y[i]*y[i+1]<0
            push!(x0Aprox,[x[i],x[i+1]])
        end
    end
    for i in 1:length(x0Aprox)
        push!(x0,cerosNewton(f,(x0Aprox[i][1]+x0Aprox[i][2])*0.5))
    end
    return x0
end

CerosFun(H,-3,3)

# (e) Usen los números duales para mostrar que los puntos de periodo 2
# para el mapeo \$F(x) = x^2 -1\$ son linealmente estables (atractivos).
F(x) = x^2 -1

Q(x)= F(F(x))-x

#Obteniendo los ceros de este polinomio 
C = CerosFun(Q, -10,10)

derivs = []
#Obteniendo la derivada en cada punto 
for i in 1:length(C)
    y = dual(C[i])
    push!(derivs, der(F(y)))    
end

derQ = derivs[1]*derivs[2]*derivs[3]*derivs[4] 
#como derQ está entre -1 y 1, concluímos que todos los puntos fijos de Q son atractores.


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

# Para n=1 H1(0) = F(0) = -c1 = 0, entonces c1 = 0  
# Para n=2 H2(0) = F(F(0)) = c2(c2-1) = 0, entonces c1 = 1 y c1 = 0. En el ejercicio anterior ya se demostró que para c2 = 1, se tiene a cero 
# como punto fijo y estable. 
# Para n=3, al hacer las cuentas, se puede ver que H3(0) = F(F(F(0))) = g(c3(c3-1))-c3 con g(x) = x^2.
# De lo anterior, lo que hice fue conjeturar que puedo tomar a la cuadratica, y las F(x) compuestas para encontrar las ecuaciones
# que le daré al algoritmo de Newton para encontrar las orbitas superestables. 

# Para n=1 H1(0) = F(0) = -c1 = 0, entonces c1 = 0  
# Para n=2 H2(0) = F(F(0)) = c2(c2-1) = 0, entonces c2 = 1 y c2 = 0. Podemos notar a continuación que es con 1 que se tiene una
# órbita de periodo 2.  

Fc2(x) = x^2 -1
Fc2(0)
Fc2(-1)

#Por lo tanto c2=1
# Para n=3, al hacer las cuentas, se puede ver que H3(0) = F(F(F(0))) = g(c3(c3-1))-c3 con g(x) = x^2.
# De lo anterior, lo que hice fue conjeturar que puedo tomar a la cuadratica, y las H_n(x) compuestas para encontrar las ecuaciones
# que le daré al algoritmo de Newton para encontrar las orbitas superestables. 

function Comp(f,n)
    """
    Esta función compone n veces la función f. Para n=0, devuelve la identidad. Para n=1 devuelve f.
    """
    g = identity

    for i in 1:n
        g1 = g
        g = x -> f(g1(x))
    end

    return g
end

function PolinC(n)
    """
    Compone n veces x^2 y en cada composición le añade una - x. (x juega el rol de c).
    Esta función crea los poliniomios con los cuales vamos a obtener las C, usando el CerosFun. 
    """
    if n == 1
        Cn = identity
    elseif n>=2
        Cn = identity
        f(x) = x^2
        for i in 1:(n-1)
            g1 = Cn
            Cn = x -> f(g1(x)) - x
        end
    end
    return Cn
end  

# Para probar la función, usaré n=1
PoliC1 = PolinC(1)
print(CerosFun(PoliC1,-10,10))

#Esto nos dice lo que ya sabíamos sobre C1

#Ahora voy a rectificar el resultado que ya se encontró anteriormente para n=1
Polic2 =PolinC(2)
print(CerosFun(Polic2,-10,10))

#Ahora obtenemos que C2=1 y C2=0, lo cual ya habíamos obtenido anteriormente de manera analítica. Y como se realizó en el ejercicio anterior
# para C2 = 1 se tiene la orbita de periodo 2.

#Rectificaré, por último, para n=2, es decir, para Q^4
Polic4 =PolinC(4)
ceros = CerosFun(Polic4,-10,10)

#Ahora veamos para qué C se tiene una órbita de periodo 4 en x0 = 0.
Q4(x) = x^2 - 1.3107026413398222  #descarto C2 = 0 ya que esa es una orbita de periodo 1; y descarto C2=1 porque esa es de periodo 2.
print(Comp(Q4,4)(0))

#Notemos que el resultado es prácticamente cero. Y se cumple que para C2 = 1.3107026413398222 se tiene una órbita de periodo 4 en x0 = 0

function Cns(n)
    """
    Esta función obtiene ceros de los polinomios P(c), que genera la función Cn(n). 
    Regresa el vector cs, donde cs[1] contiene c1 = 0 y c1=0, cs[2] contiene a c2 = 0.0, 1.0, 1.3107026413398222, 1.9407998065294847
    """
    cs = CerosFun(PolinC(2^n),0,2)
    return cs
end

#FUNCIONA, PERO FALTA OPTIMIZARLO PORQUE NO PASA DE N=4 ...

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



