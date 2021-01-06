try
    using Pluto
catch
    Pkg.instantiate()
    using Revise
    using Pluto
end

function real_main()
    Pluto.run(notebook="src/welcome.jl", workspace_use_distributed=false)
end

function julia_main()::Cint
    try
        real_main()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

julia_main()
