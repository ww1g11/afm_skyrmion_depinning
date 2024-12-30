
using MicroMagnetic

function init_single_skx(i, j, k, dx, dy, dz)
    if k == 1
        return (i - 100)^2 + (j - 80)^2 < 20^2 ? (0, 0.01, -1) : (0, 0.01, 1)
    elseif k == 3
        return (i - 100)^2 + (j - 80)^2 < 20^2 ? (0, 0.01, 1) : (0, 0.01, -1)
    else
        return (0, 0, 0)
    end
end

function basic_setup(; driver="SD", m0=(0, 0, 1), name="skx", lambda=0.01, Rd=10.0)
    mesh = FDMesh(nx=200, ny=160, nz=1, dx=1e-9, dy=1e-9, dz=2e-9, pbc="xy")
    sim = Sim(mesh, driver=driver, name=name)
    spatial_Ms = (i, j, k, dx, dy, dz) -> k == 2 ? 0 : 5.8e5
    set_Ms(sim, spatial_Ms)
    add_exch(sim, 15e-12)
    add_dmi(sim, 3.5e-3, type="interfacial")
    add_anis(sim, 8e5, axis=(0, 0, 1))
    init_m0(sim, m0)
    return sim
end


function relax_system()
    sim = basic_setup(m0=init_single_skx)
    relax(sim, max_steps=20000, stopping_dmdt=0.01)
    F = MicroMagnetic.compute_shape_factor(sim.spin, sim.mesh)
    println("shape factor tensor:", F)
end

relax_system()