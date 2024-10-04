
using MicroMagnetic

@using_gpu()

function spatial_Ms(i,j,k, dx,dy,dz)
    if k == 2
        return 5.8e5
    else
        return 5.8e5
    end
end

function init_single_skx(i, j, k, dx, dy, dz)
    r=20
    cx=100
    cy=50
    if k == 3
        return (i - cx)^2 + (j - cy)^2 < r^2 ? (0, 0.01, -1) : (0, 0.01, 1)
    elseif k == 1
        return (i - cx)^2 + (j - cy)^2 < r^2 ? (0, 0.01, 1) : (0, 0.01, -1)
    else
        return (0, 0, 0)
    end
end

function spatial_Ku_pin(i, j, k, dx, dy, dz)
    r_pin1=5
    r_pin2=5
    r1, r2 = sqrt((i - 100)^2 + (j - 50)^2), sqrt((i - 130)^2 + (j - 50)^2)
    if k == 3
        if r1 <= r_pin1
            return 8e5 - (r_pin1 - r1) * 8e3
        elseif r2 <= r_pin2
            return 8e5 - (r_pin2 - r2) * 8e3
        end
    end
    return 8e5
end

function basic_setup(; driver="SD", m0=(0, 0, 1), name="skx")
    mesh = FDMesh(nx=300, ny=150, nz=3, dx=2e-9, dy=2e-9, dz=2e-9, pbc="xy")
    sim = Sim(mesh, driver=driver, name=name)
    set_Ms(sim, spatial_Ms)
    A, D, Ku = 15e-12, 3.5e-3, 1e5
    add_exch(sim, A)
    add_dmi(sim, D, type="interfacial")
    add_exch_int(sim, -6e-2)
    add_anis(sim, spatial_Ku_pin, axis=(0, 0, 1))
    init_m0(sim, m0)
    return sim
end


function relax_system()
    println("relax_system with beta: ")
    sim = basic_setup(m0=init_single_skx)
    relax(sim, maxsteps=20000, stopping_dmdt=0.1)
    save_vtk(sim, "afm")
end

relax_system()