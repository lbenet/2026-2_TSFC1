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

function Cn(n)
    """
    Compone n veces x^2 y en cada composición le añade una - x. (x juega el rol de c)
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
v =Cn(1)
CerosFun(v,-10,10)

#El resultado nos dice que para c1 = 0, en la orbita de Q1(x) = x^2, cero es punto fijo. Veamos si esto es cierto. 

Q1(x) = x^2   
F1(x) = Q1(x) - x
CerosFun(F1,-10,10)

#Tenemos como puntos fijos para Q1, a cero y a 1, que era lo que buscabamos. 

#Ahora voy a rectificar el resultado que ya se encontró anteriormente para n=2
v =Cn(2)
CerosFun(v,-10,10)

#Ahora obtenemos que C2=1 y C2=0, lo cual ya habíamos obtenido anteriormente de manera analítica. Y como se realizó en el ejercicio anterior
# para C2 = 1 se tiene a cero como punto fijo. 

#Rectificaré, por último, para n=5
v =Cn(5)
CerosFun(v,-10,10)

# Tomaré C5 = 1.8607825222048548

Q5(x) = x^2 - 1.8607825222048548    
Fcinco = Comp(Q5,5)
CerosFun(x -> Fcinco(x) - x ,-10,10)


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



