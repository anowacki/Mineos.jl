# This benchmark mirrors that of the Mineos manual (available at
# http://geoweb.cse.ucdavis.edu/cig/software/mineos/mineos-manual.pdf).
# Specifically, it reproduces Figure B.4, comparing dispersion curves
# between the CIG version of Mineos and Bob Herrman's code
# available at https://www.eas.slu.edu/eqc/eqccps.html.
#
# Thanks to Mariano Simon Arnaiz Rodriguez (UCM, Spain) for
# initiating this test.

using Mineos
using Plots
using SeisModels

"""
    dispersion_curve(model, rayleigh=true; kwargs...) -> freqs, periods, phase_vels, group_vels

Compute a dispersion curve for `model` using `Mineos.eigenmodes`, returning
frequencies in mHz, `freqs`, periods in s `periods`, and phase and group
velocities in km/s `phase_vels` and `group_vels`, respectively.

`kwargs` are passed to `Mineos.eigenfrequencies` and should be adjusted for
the frequency range and mode order range requested.

Inner core toroidal modes are not computed; pass `ic_toroidal=true` to enable them.
"""
function dispersion_curve(model::LinearLayeredModel, rayleigh=true; kwargs...)
    default_parameters = (nmax=0, lmin=1, lmax=20000, wmax=1000,
        radial=rayleigh, spheroidal=rayleigh, toroidal=!rayleigh, ic_toroidal=false)
    modes = eigenmodes(model; default_parameters..., kwargs...)
    mode_vals = values(modes)
    freqs = getfield.(mode_vals, :frequency)
    periods = getfield.(mode_vals, :period)
    phase_vels = getfield.(mode_vals, :phase_vel)
    group_vels = getfield.(mode_vals, :group_vel)
    freqs, periods, phase_vels, group_vels
end

dispersion_curve(model, args...; kwargs...) =
    dispersion_curve(LinearLayeredModel(model),args...; kwargs...)

# Create isotropic PREM_NOOCEAN
model = let m = PREM_NOOCEAN
    PREMPolyModel(; r=m.r, vp=m.vp, vs=m.vs, density=m.density, Qκ=m.Qκ, Qμ=m.Qμ)
end

# Period range of interest, in s
Tmin, Tmax = 7, 220

# Computation parameters, passed to `eigenmodes`
params = (
    wmin=1000/Tmax, wmax=1000/Tmin, # minimum and maximum frequency in mHz
    lmin=10, lmax=20000, # Minimum and maximum angular order
    wgrav=0, # Turn off gravity
    eps=1e-12 # Integration error; bumped up a bit to ensure accuracy
)

p = plot(xlabel="Period / s", ylabel="Velocity / km/s", xticks=0:20:220,
    legend=:bottomright, fontfamily="Helvetica", grid=false, framestyle=:box,
    xlim=(Tmin, Tmax), ylim=(2.5,5))

for type in (:S, :T)
    freq, period, phase, group = dispersion_curve(model, (type == :S); params...)
    plot!(p, period, [phase group], label=["$type phase" "$type group"])
end

savefig(p, "mineos-prem_noocean.pdf")
