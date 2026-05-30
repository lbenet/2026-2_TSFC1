using Plots, LaTeXStrings, LinearAlgebra

# ============================================================
# Mapeo estándar
#   pₙ₊₁ = pₙ + ε sin(θₙ)   (mod 2π, centrado en [-π, π))
#   θₙ₊₁ = θₙ + pₙ₊₁        (mod 2π)
#
# (θ, p) ∈ T² = [0, 2π) × [-π, π)
# ============================================================

"""
    standard_map(p, θ, ε) -> (p_new, θ_new)

Aplica una iteración del mapeo estándar de Chirikov al punto `(p, θ)`
con parámetro `ε`. Devuelve el nuevo `(p, θ)` reducido al toro T².
"""
function standard_map(p, θ, ε)
    p_new = mod(p + ε * sin(θ) + π, 2π) - π   # p ∈ [-π, π)
    θ_new = mod(θ + p_new, 2π)                  # θ ∈ [0, 2π)
    return p_new, θ_new
end

# ============================================================
# Retrato de fase
# ============================================================

"""
    plot_phase_space(ε; n_orbits=60, n_iter=500) -> Plot

Genera el retrato de fase del mapeo estándar para el parámetro `ε`,
iterando `n_orbits` condiciones iniciales aleatorias `n_iter` veces cada una.
"""
function plot_phase_space(ε; n_orbits=60, n_iter=500)
    plt = plot(size=(500, 500), xlims=(0, 2π), ylims=(-π, π),
               title="Mapeo estándar, ε = $ε",
               xlabel=L"\theta", ylabel=L"p",
               legend=false, dpi=150)
    for _ in 1:n_orbits
        θ_n = 2π * rand()
        p_n = 2π * rand() - π
        θs, ps = Float64[], Float64[]
        for _ in 1:n_iter
            p_n, θ_n = standard_map(p_n, θ_n, ε)
            push!(θs, θ_n)
            push!(ps, p_n)
        end
        scatter!(plt, θs, ps, markersize=0.4, markerstrokewidth=0,
                 color=:blue, alpha=0.4, label=false)
    end
    return plt
end

# Generamos y guardamos los retratos de fase para cada ε de la presentación
for ε in [0.0, 0.01, 0.5, 0.95, 1.2, 5.0]
    plt = plot_phase_space(ε; n_orbits=60, n_iter=500)
    fname = "fase_eps_$(replace(string(ε), "." => "p")).png"
    savefig(plt, fname)
    println("Guardado: $fname")
end

# ============================================================
# Diferenciación automática 2D (Jacobiano)
#
# Para aplicar Newton 2D necesitamos calcular simultáneamente
# F^q(x) y su Jacobiano DF^q(x). Lo hacemos propagando una
# matriz 2×2 junto con el valor del mapeo.
# ============================================================

"""
    Dual2D

Par (valor, Jacobiano) para diferenciación automática del mapeo estándar.
- `f`: vector 2D con el valor actual `(p, θ)`.
- `J`: matriz 2×2 con el Jacobiano acumulado hasta ese punto.
"""
struct Dual2D
    f::Vector{Float64}
    J::Matrix{Float64}
end

"""
    dual2d(p, θ) -> Dual2D

Semilla de diferenciación: punto `(p, θ)` con Jacobiano = I (identidad).
"""
dual2d(p, θ) = Dual2D([p, θ], Matrix{Float64}(I, 2, 2))

"""
    standard_map_dual(d::Dual2D, ε) -> Dual2D

Una iteración del mapeo estándar sobre un `Dual2D`, propagando el Jacobiano
mediante la regla de la cadena. El Jacobiano de un paso es:

    DF(θ) = [1       ε cos θ ]
            [1   1 + ε cos θ ]
"""
function standard_map_dual(d::Dual2D, ε)
    p, θ = d.f
    p_new = mod(p + ε * sin(θ) + π, 2π) - π
    θ_new = mod(θ + p_new, 2π)
    DF = [1.0        ε * cos(θ);
          1.0  1.0 + ε * cos(θ)]
    return Dual2D([p_new, θ_new], DF * d.J)
end

"""
    iterate_map_dual(p₀, θ₀, ε, q) -> Dual2D

Itera el mapeo estándar `q` veces desde `(p₀, θ₀)`, devolviendo
`F^q(p₀, θ₀)` y el Jacobiano `DF^q(p₀, θ₀)` por diferenciación automática.
"""
function iterate_map_dual(p0, θ0, ε, q)
    d = dual2d(p0, θ0)
    for _ in 1:q
        d = standard_map_dual(d, ε)
    end
    return d
end

# ============================================================
# Método de Newton 2D para órbitas periódicas
#
# Una órbita de periodo q satisface F^q(x) = x, es decir,
# es cero de G(x) = F^q(x) - x = 0.
#
# Newton:  xₙ₊₁ = xₙ - [DG(xₙ)]⁻¹ G(xₙ),   DG = DF^q - I
# ============================================================

"""
    newton_orbita(p₀, θ₀, ε, q; tol=1e-12, maxiter=50) -> (Vector, Bool)

Método de Newton 2D para encontrar una órbita periódica de periodo `q`
del mapeo estándar con parámetro `ε`, partiendo de la semilla `(p₀, θ₀)`.

Devuelve el punto `[p, θ]` encontrado y un booleano indicando convergencia.
"""
function newton_orbita(p0, θ0, ε, q; tol=1e-12, maxiter=50)
    x = [p0, θ0]
    for _ in 1:maxiter
        d  = iterate_map_dual(x[1], x[2], ε, q)
        G  = d.f - x        # F^q(x) - x
        DG = d.J - I        # DF^q - I
        norm(G) < tol && return x, true
        x  = x - DG \ G    # paso de Newton
        # Reducir al toro
        x[2] = mod(x[2], 2π)
        x[1] = mod(x[1] + π, 2π) - π
    end
    d = iterate_map_dual(x[1], x[2], ε, q)
    return x, norm(d.f - x) < tol
end

"""
    buscar_orbitas(ε, q; n_seeds=60, tol=1e-10) -> Vector{Vector{Float64}}

Busca órbitas periódicas de periodo `q` del mapeo estándar con parámetro `ε`
lanzando Newton desde `n_seeds` semillas aleatorias en el toro.

Devuelve una lista de puntos `[p, θ]` únicos (sin repeticiones).
"""
function buscar_orbitas(ε, q; n_seeds=60, tol=1e-10)
    orbitas = Vector{Float64}[]
    for _ in 1:n_seeds
        θ0 = 2π * rand()
        p0 = 2π * rand() - π
        x, conv = newton_orbita(p0, θ0, ε, q; tol=1e-12)
        if conv
            es_nuevo = all(norm(x - o) > tol for o in orbitas)
            es_nuevo && push!(orbitas, copy(x))
        end
    end
    return orbitas
end

# ============================================================
# Figura para la diapositiva 13: retrato de fase + órbitas periódicas
# ============================================================

"""
    plot_orbitas_periodicas(ε, periodos; n_orbits=80, n_iter=500) -> Plot

Retrato de fase del mapeo estándar con las órbitas periódicas encontradas
por Newton marcadas con colores distintos según su periodo.
"""
function plot_orbitas_periodicas(ε, periodos=[1, 2, 3]; n_orbits=80, n_iter=500)
    plt = plot(size=(600, 600), xlims=(0, 2π), ylims=(-π, π),
               title="Mapeo estándar ε = $ε — órbitas periódicas",
               xlabel=L"\theta", ylabel=L"p",
               legend=:topright, dpi=150)

    # Retrato de fase en gris
    for _ in 1:n_orbits
        θ_n = 2π * rand()
        p_n = 2π * rand() - π
        θs, ps = Float64[], Float64[]
        for _ in 1:n_iter
            p_n, θ_n = standard_map(p_n, θ_n, ε)
            push!(θs, θ_n); push!(ps, p_n)
        end
        scatter!(plt, θs, ps, markersize=0.4, markerstrokewidth=0,
                 color=:gray, alpha=0.3, label=false)
    end

    # Órbitas periódicas marcadas por periodo
    colores = [:red, :blue, :green, :orange, :purple]
    ya_etiquetados = Set{Int}()
    for (i, q) in enumerate(periodos)
        pts = buscar_orbitas(ε, q; n_seeds=80)
        for pt in pts
            # Propagar el ciclo completo para ver todos sus puntos
            p_n, θ_n = pt[1], pt[2]
            θs_orb, ps_orb = Float64[], Float64[]
            for _ in 1:q
                push!(θs_orb, θ_n); push!(ps_orb, p_n)
                p_n, θ_n = standard_map(p_n, θ_n, ε)
            end
            lbl = q ∈ ya_etiquetados ? false : "periodo $q"
            scatter!(plt, θs_orb, ps_orb,
                     markersize=7, color=colores[i],
                     markerstrokewidth=1, markerstrokecolor=:black,
                     label=lbl)
            push!(ya_etiquetados, q)
        end
    end
    return plt
end

# Generamos la figura para la diapositiva 13
ε_demo = 0.5   # ε = 0.5 tiene estructura clara de islas y puntos periódicos visibles

println("\n=== Órbitas periódicas (ε = $ε_demo) ===")
for q in [1, 2, 3, 4]
    pts = buscar_orbitas(ε_demo, q; n_seeds=100)
    println("  Periodo $q: $(length(pts)) punto(s) encontrado(s)")
    for pt in pts
        p_r, θ_r = round(pt[1], digits=6), round(pt[2], digits=6)
        # Calcular traza del Jacobiano para clasificar el punto
        d = iterate_map_dual(pt[1], pt[2], ε_demo, q)
        τ = tr(d.J)
        tipo = abs(τ) < 2 ? "elíptico" : "hiperbólico"
        println("    (p, θ) = ($p_r, $θ_r)  |  Tr(DF^$q) = $(round(τ, digits=4))  → $tipo")
    end
end

plt_orbitas = plot_orbitas_periodicas(ε_demo, [1, 2, 3, 4])
savefig(plt_orbitas, "orbitas_periodicas_eps_$(replace(string(ε_demo), "." => "p")).png")
println("\nGuardado: orbitas_periodicas_eps_$(replace(string(ε_demo), "." => "p")).png")
