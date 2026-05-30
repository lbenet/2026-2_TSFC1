using Plots, LaTeXStrings, LinearAlgebra

include("numDuales.jl")
using .numDuales

# ============================================================
# Mapeo estándar de Chirikov
#   pₙ₊₁ = pₙ + ε sin(θₙ)   (mod 2π, centrado en [-π, π))
#   θₙ₊₁ = θₙ + pₙ₊₁         (mod 2π)
#
# (θ, p) ∈ T² = [0, 2π) × [-π, π)
# ============================================================

"""
    standard_map(p, θ, ε) -> (p_new, θ_new)

Aplica una iteración del mapeo estándar de Chirikov al punto `(p, θ)`
con parámetro `ε`. El mapeo acepta números duales como entradas, lo que
permite calcular derivadas parciales por diferenciación automática.
"""
function standard_map(p, θ, ε)
    p_new = mod(p + ε * sin(θ) + π, 2π) - π   # p ∈ [-π, π)
    θ_new = mod(θ + p_new, 2π)                  # θ ∈ [0, 2π)
    return p_new, θ_new
end

# ============================================================
# Jacobiano via diferenciación automática (números duales)
#
# Para F: ℝ² → ℝ², el Jacobiano DF se calcula con dos pasadas
# forward, sembrando la dirección de diferenciación en cada columna:
#
#   Columna 1 (∂F/∂p): pasar dual(p) y θ como Real
#   Columna 2 (∂F/∂θ): pasar p como Real y dual(θ)
#
# Esto es diferenciación automática en modo forward pura —
# no se escribe ninguna fórmula analítica del Jacobiano.
# ============================================================

"""
    jacobiano(p, θ, ε) -> Matrix{Float64}

Calcula el Jacobiano 2×2 del mapeo estándar en el punto `(p, θ)`
usando diferenciación automática con números duales.
No requiere escribir las derivadas analíticamente.
"""
function jacobiano(p, θ, ε)
    # Pasada 1: semilla en p → columna ∂F/∂p
    p1_new, θ1_new = standard_map(dual(p), float(θ), ε)
    # Pasada 2: semilla en θ → columna ∂F/∂θ
    p2_new, θ2_new = standard_map(float(p), dual(θ), ε)

    return [p1_new.der  p2_new.der;   # ∂p_new/∂p  ∂p_new/∂θ
            θ1_new.der  θ2_new.der]   # ∂θ_new/∂p  ∂θ_new/∂θ
end

"""
    jacobiano_q(p₀, θ₀, ε, q) -> (Vector, Matrix)

Itera el mapeo estándar `q` veces desde `(p₀, θ₀)` y devuelve el punto
final `F^q(p₀, θ₀)` junto con el Jacobiano acumulado `DF^q(p₀, θ₀)`.

El Jacobiano acumulado se obtiene por la regla de la cadena:
    DF^q = DF(xₙ₋₁) · ... · DF(x₁) · DF(x₀)

donde cada DF se calcula por diferenciación automática, sin fórmulas analíticas.
"""
function jacobiano_q(p0, θ0, ε, q)
    x = [p0, θ0]
    J = Matrix{Float64}(I, 2, 2)
    for _ in 1:q
        J = jacobiano(x[1], x[2], ε) * J   # regla de la cadena
        p_new, θ_new = standard_map(x[1], x[2], ε)
        x = [p_new, θ_new]
    end
    return x, J
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

El Jacobiano se calcula en cada iteración por diferenciación automática.
Devuelve el punto `[p, θ]` encontrado y un booleano indicando convergencia.
"""
function newton_orbita(p0, θ0, ε, q; tol=1e-12, maxiter=50)
    x = [p0, θ0]
    for _ in 1:maxiter
        Fq, J  = jacobiano_q(x[1], x[2], ε, q)
        G  = Fq - x        # F^q(x) - x
        DG = J - I         # DF^q - I
        norm(G) < tol && return x, true
        x  = x - DG \ G   # paso de Newton
        x[2] = mod(x[2], 2π)
        x[1] = mod(x[1] + π, 2π) - π
    end
    Fq, _ = jacobiano_q(x[1], x[2], ε, q)
    return x, norm(Fq - x) < tol
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

# ============================================================
# Resultados: retratos de fase y órbitas periódicas
# ============================================================

# Retratos de fase para distintos valores de ε
for ε in [0.0, 0.01, 0.5, 0.95, 1.2, 5.0]
    plt = plot_phase_space(ε; n_orbits=60, n_iter=500)
    fname = "fase_eps_$(replace(string(ε), "." => "p")).png"
    savefig(plt, fname)
    println("Guardado: $fname")
end

# Órbitas periódicas con ε = 0.5
ε_demo = 0.5

println("\n=== Órbitas periódicas (ε = $ε_demo) ===")
for q in [1, 2, 3, 4]
    pts = buscar_orbitas(ε_demo, q; n_seeds=100)
    println("  Periodo $q: $(length(pts)) punto(s) encontrado(s)")
    for pt in pts
        p_r, θ_r = round(pt[1], digits=6), round(pt[2], digits=6)
        _, J = jacobiano_q(pt[1], pt[2], ε_demo, q)
        τ = tr(J)
        tipo = abs(τ) < 2 ? "elíptico" : "hiperbólico"
        println("    (p, θ) = ($p_r, $θ_r)  |  Tr(DF^$q) = $(round(τ, digits=4))  → $tipo")
    end
end

plt_orbitas = plot_orbitas_periodicas(ε_demo, [1, 2, 3, 4])
savefig(plt_orbitas, "orbitas_periodicas_eps_$(replace(string(ε_demo), "." => "p")).png")
println("\nGuardado: orbitas_periodicas_eps_$(replace(string(ε_demo), "." => "p")).png")
