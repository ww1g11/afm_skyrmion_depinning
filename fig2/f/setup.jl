
using MicroMagnetic
using Printf

@using_gpu()

function init_single_skx(i, j, k, dx, dy, dz)
    if k == 3
        return (i - 60)^2 + (j - 100)^2 < 20^2 ? (0, 0.01, -1) : (0, 0.01, 1)
    elseif k == 1
        return (i - 60)^2 + (j - 100)^2 < 20^2 ? (0, 0.01, 1) : (0, 0.01, -1)
    else
        return (0, 0, 0)
    end
end

function basic_setup(; driver="SD", m0=(0, 0, 1), name="skx", lambda=0.01, Rd=10.0, yc=100)
    mesh = FDMesh(nx=200, ny=200, nz=3, dx=1e-9, dy=1e-9, dz=2e-9, pbc="xy")
    sim = Sim(mesh, driver=driver, name=name)
    spatial_Ms = (i, j, k, dx, dy, dz) -> k == 2 ? 0 : 5.8e5
    set_Ms(sim, spatial_Ms)
    add_exch(sim, 15e-12)
    add_dmi(sim, 3.5e-3, type="interfacial")
    add_exch_int(sim, -6e-3)
    spatial_Ku = (i, j, k, dx, dy, dz) -> k == 3 ? 8e5*(1-lambda*exp(-(hypot(i - 120, j - yc)/Rd)^2)) : 8e5
    add_anis(sim, spatial_Ku, axis=(0, 0, 1))
    init_m0(sim, m0)
    return sim
end


function run_system(;Rd=10.0, lambda=0.01, beta=0.0, ux=0.0, b=0.0)
    # Simulation setup
    sim = basic_setup(m0=read_vtk("m0.vts"), Rd=Rd, lambda=lambda, yc=100+b)
    set_driver(sim; driver="LLG_STT", alpha=0.03, beta=beta, ux=-ux)
    
    dt = 2e-10
    Rx_pre, Ry_pre = compute_guiding_center(sim, z=3)
    for i in 1:1000
        run_until(sim, dt * i, save_data = false)
        Rx, Ry = compute_guiding_center(sim, z=3)
        
        speed = abs(Rx-Rx_pre) / dt
        println("i=  ", i, "  Rx1=", Rx * 1e9, "   Ry1= ", Ry * 1e9, "  speed=", speed)
        Rx_pre, Ry_pre = Rx, Ry
        if speed < 1e-6*ux
            return false
        end

        if Rx > 140e-9
            return true
        end
            
    end

    return false
end

function find_uc(;Rd=10.0, lambda=0.01, beta=0.05, b=0.0, steps=10, u2=100, u1=0)

    ux = (u1 + u2) / 2
    if u2 < u1
        return u1
    end

    for i in 1:steps
        ux = (u1 + u2) / 2
        println("i= ", i, "   ux=", ux)
        
        moved = run_system(Rd=Rd, lambda=lambda, beta=beta, ux=ux, b=b)
        
        if moved
            u2 = ux
        else
            u1 = ux
        end
    end
    return (u1 + u2) / 2
end

function relax_system()
    sim = basic_setup(m0=init_single_skx)
    relax(sim, maxsteps=20000, stopping_dmdt=0.01)
    save_vtk(sim, "m0")
end

if !isfile("m0.vts")
    relax_system()
end

function bisection_steps(u1, u2, eps)
    if u1 >= u2
        return 1
    end
    return ceil(Int, log2((u2 - u1) / eps))
end


#run_system(ux=5.0, lambda=0.05, beta=0.05)

txt_name = "uc.txt"
open(txt_name, "w") do f
    write(f, "#b, uc\n")
    u1, u2 = 1, 499
    eps = 0.1
    uc = -1
    for b in 0:2:60
        u2 = uc > 0 ? uc : 499
        steps =  bisection_steps(u1, u2, eps)
        println("b= $b   u1=$u1   u2=$u2  steps=$steps")

        uc = find_uc(Rd=8, lambda=0.05, beta=0.05, steps=steps, b=b, u1=u1, u2=u2)
        write(f, "$b   $uc\n")
    end
end