
using MicroMagnetic
using Printf
using NPZ

#global parameters
Rd = 8.0
lambda = 0.05

@using_gpu()

spatial_Ms = (i,j,k,dx,dy,dz) -> k == 2 ? 0 : 5.8e5

function init_single_skx(i, j, k, dx, dy, dz)
    r=20
    cx=100
    cy=80
    if k == 3
        return (i - cx)^2 + (j - cy)^2 < r^2 ? (0, 0.01, 1) : (0, 0.01, -1)
    elseif k == 1
        return (i - cx)^2 + (j - cy)^2 < r^2 ? (0, 0.01, -1) : (0, 0.01, 1)
    else
        return (0, 0, 0)
    end
end

function spatial_Ku_pin(i, j, k, dx, dy, dz)
    r = sqrt((i - 100)^2 + (j - 80)^2)
    if k == 3
        return 8e5*(1-lambda*exp(-r^2/Rd^2))
    end
    return 8e5
end

function basic_setup(; driver="SD", m0=(0, 0, 1), name="skx")
    mesh = FDMesh(nx=200, ny=160, nz=3, dx=1e-9, dy=1e-9, dz=2e-9, pbc="xy")
    sim = Sim(mesh, driver=driver, name=name)
    set_Ms(sim, spatial_Ms)
    add_exch(sim, 15e-12)
    add_dmi(sim, 3.5e-3, type="interfacial")
    add_exch_int(sim, -6e-3)
    add_anis(sim, spatial_Ku_pin, axis=(0, 0, 1))
    init_m0(sim, m0)
    return sim
end

function run_system(;dual=false, ux=100)
    sim = basic_setup(m0=init_single_skx)
    relax(sim, maxsteps=20000, stopping_dmdt=0.01)
    npzwrite("m0.npy", Array(sim.spin))

    spatial_ux = (i, j, k, dx, dy, dz) -> k == 3 ? -ux : (dual ? -ux : 0.0)
    set_driver(sim; driver="LLG_STT", alpha=0.03, beta=0.05, ux=spatial_ux)

    txt_name = dual ? "dual.txt" : "single.txt"
    steps = dual ? 50 : 5
    open(txt_name, "w") do f
        write(f, "#time X  Y\n")

        dt = 1e-11
        for i in 0:steps
            run_until(sim, dt * i, save_data = false)
            Rx, Ry = compute_guiding_center(sim, z=3)
            time = dt * i
            write(f, "$time   $Rx    $Ry\n")
        end
    end

    name = dual ? "dual.npy" : "single.npy"
    npzwrite(name, Array(sim.spin))
    
end


run_system()
run_system(dual=true)