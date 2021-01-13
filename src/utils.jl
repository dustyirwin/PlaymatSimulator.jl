
# julia --trace-compile=pms_trace.jl
# PackageCompiler.restore_default_sysimage()


# DO NOT compile GZ2! Julia will not compile local dev pkg changes??

using PackageCompiler

project_symbols = [
    :Colors,
    :DataStructures,
    :DrWatson,
    :Flux,
    :GZ2,
    :HTTP,
    :ImageMagick,
    :ImageTransformations,
    :Images,
    :ImageIO,
    :JSON,
    :PackageCompiler,
    :Plots,
    :Pluto,
    :PlutoUI,
    :ShiftedArrays,
    :SimpleDirectMediaLayer,
    :Dates,
    :Pkg,
    :Random,
    :Serialization
    ]

create_sysimage(project_symbols,
    precompile_statements_file="tmp/trace.jl",
    sysimage_path="sys_PS-unix.so"
    )

PackageCompiler.audit_app(".")  # passing!

create_app(
    "../PlaymatSimulator.jl",
    "../PS.compiled",
    filter_stdlibs=false,
    #precompile_statements_file="tmp/trace.jl",
    incremental=true,
    #force=true
)

# UUID for GZ2 5cf23aef-9907-41d4-9cbf-0482fdc672a3
# UUID for PlaymatSimulator
using Dates
using UUID
using Random

uuid4(MersenneTwister(Int(floor(datetime2unix(now())))))


M = Module(:M)

using Main.M




M
