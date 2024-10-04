using MicroMagnetic
using Printf

@using_gpu()

function init_single_skx(i, j, k, dx, dy, dz)
    if k == 3
        return (i - 100)^2 + (j - 80)^2 < 20^2 ? (0, 0.01, -1) : (0, 0.01, 1)
    elseif k == 1
        return (i - 100)^2 + (j - 80)^2 < 20^2 ? (0, 0.01, 1) : (0, 0.01, -1)
    else
        return (0, 0, 0)
    end
end

function basic_setup(; driver="SD", m0=(0, 0, 1), name="skx", kappa=0.01, Rd=10.0)
    mesh = FDMesh(nx=200, ny=160, nz=3, dx=1e-9, dy=1e-9, dz=2e-9, pbc="xy")
    sim = Sim(mesh, driver=driver, name=name)
    spatial_Ms = (i, j, k, dx, dy, dz) -> k == 2 ? 0 : 5.8e5
    set_Ms(sim, spatial_Ms)
    add_exch(sim, 15e-12)
    add_dmi(sim, 3.5e-3, type="interfacial")
    add_exch_int(sim, -6e-3)
    spatial_Ku = (i, j, k, dx, dy, dz) -> k == 3 ? 8e5*(1-kappa*exp(-(hypot(i - 100, j - 80)/Rd)^2)) : 8e5
    add_anis(sim, spatial_Ku, axis=(0, 0, 1))
    init_m0(sim, m0)
    return sim
end


function run_system(;Rd=8.0, kappa=0.05, beta=0.0, ux=0.0, lambda=0)
    sim = basic_setup(m0=read_vtk("m0.vts"), Rd=Rd, kappa=kappa)
    
    spatial_ux = (i, j, k, dx, dy, dz) -> k == 3 ? -ux : -ux*lambda
    set_driver(sim; driver="LLG_STT", alpha=0.03, beta=beta, ux=spatial_ux)

    dt = 1e-10
    Rx0, Ry0 = compute_guiding_center(sim, z=3)
    Rx_pre, Ry_pre = Rx0, Ry0
    for i in 1:500
        run_until(sim, dt * i, save_data = false)
        Rx, Ry = compute_guiding_center(sim, z=3)
        
        speed = hypot(Rx-Rx_pre, Ry-Ry_pre)/dt
        println("i=  ", i, "  Rx1=", Rx * 1e9, "   Ry1= ", Ry * 1e9, "  speed=", speed)
        Rx_pre, Ry_pre = Rx, Ry
        if speed < 1e-5*ux
            return false
        end

        if hypot(Rx-Rx0, Ry-Ry0) > 20e-9
            return true
        end

    end
    return false
end

function find_uc(;Rd=Rd, kappa=kappa, beta=beta, lambda=lambda, steps=10, u2_max=100)
    println("find_uc beta", beta)
    u1, u2 = 0, u2_max
    ux = (u1 + u2) / 2

    for i in 1:steps
        ux = (u1 + u2) / 2
        println("i= ", i, "   ux=", ux)
        
        moved = run_system(Rd=Rd, kappa=kappa, beta=beta, ux=ux, lambda=lambda)
        
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

#run_system(ux=5.0, kappa=0.05)

txt_name = "uc_lambda.txt"
open(txt_name, "w") do f
    write(f, "#lambda uc1  Rd=8, kappa=0.05, beta=0.05\n")
    for lambda in 0:0.1:1
        #if !isfile("lambda_$lambda.txt")
        #touch("lambda_$lambda.txt")
        uc1 = find_uc(lambda=lambda, Rd=8.0, kappa=0.05, beta=0.05, steps=8, u2_max=100)
        write(f, "$lambda   $uc1\n")
            #end
    end
end
