
using MicroMagnetic
using Printf
using NPZ

#global parameters
Rd = 8.0
kappa = 0.05

@using_gpu()

spatial_Ms = (i,j,k,dx,dy,dz) -> k == 2 ? 0 : 5.8e5

function init_single_skx(i, j, k, dx, dy, dz)
    r=20
    cx=50
    cy=100
    if k == 3
        return (i - cx)^2 + (j - cy)^2 < r^2 ? (0, 0.01, 1) : (0, 0.01, -1)
    elseif k == 1
        return (i - cx)^2 + (j - cy)^2 < r^2 ? (0, 0.01, -1) : (0, 0.01, 1)
    else
        return (0, 0, 0)
    end
end

function spatial_Ku_pin(i, j, k, dx, dy, dz)
    
    periodic_points = 50:100:300 
    
    Ku = 8e5
    if k == 3
        for x0 in periodic_points
            r_periodic = sqrt((i - x0)^2 + (j - 100)^2)
            Ku -= 8e5 * kappa * exp(-r_periodic^2 / Rd^2) 
        end
    end
    
    return Ku
end


function basic_setup(; driver="SD", m0=(0, 0, 1), name="skx")
    mesh = FDMesh(nx=300, ny=200, nz=3, dx=1e-9, dy=1e-9, dz=2e-9, pbc="xy")
    sim = Sim(mesh, driver=driver, name=name)
    set_Ms(sim, spatial_Ms)
    add_exch(sim, 15e-12)
    add_dmi(sim, 3.5e-3, type="interfacial")
    add_exch_int(sim, -6e-3)
    add_anis(sim, spatial_Ku_pin, axis=(0, 0, 1))
    init_m0(sim, m0)
    return sim
end

function run_system()
    sim = basic_setup(m0=init_single_skx)
    relax(sim, maxsteps=20000, stopping_dmdt=0.01)
    npzwrite("m0.npy", Array(sim.spin))

    spatial_ux = (i, j, k, dx, dy, dz) -> k == 3 ? -10 : 0
    spatial_ux2 = (i, j, k, dx, dy, dz) -> k == 3 ? -10 : -10.5
    set_driver(sim; driver="LLG_STT", alpha=0.03, beta=0.05, ux=spatial_ux)

    open("XY.txt", "w") do f
        write(f, "#time X  Y\n")

        dt = 1e-11
        time = 0
        for i in 0:50
            run_until(sim, dt * i, save_data = false)
            Rx, Ry = compute_guiding_center(sim, z=3)
            time = i * dt
            println("time= ", time, " ", Rx*1e9, " ", Ry*1e9, " ",sqrt((Rx-50e-9)^2+(Ry-100e-9)^2)*1e9)
            write(f, "$time   $Rx    $Ry\n")
        end

        set_driver(sim; driver="LLG_STT", alpha=0.03, beta=0.05, ux=spatial_ux2)
        for i in 1:65
            time += 1e-10
            
            run_until(sim, time, save_data = false)
            Rx, Ry = compute_guiding_center(sim, z=3)
            println("time= ", time, " ", Rx*1e9, " ", Ry*1e9, " ",sqrt((Rx-50e-9)^2+(Ry-100e-9)^2)*1e9)
            
            write(f, "$time   $Rx    $Ry\n")
        end

        set_driver(sim; driver="LLG_STT", alpha=0.03, beta=0.05, ux=0)
        for i in 1:10
            time += 1e-10
            run_until(sim, time, save_data = false)
            Rx, Ry = compute_guiding_center(sim, z=3)
            println("time= ", time, " ", Rx*1e9, " ", Ry*1e9, " ",sqrt((Rx-50e-9)^2+(Ry-100e-9)^2)*1e9)
            write(f, "$time   $Rx    $Ry\n")
        end

    end
    
end

run_system()