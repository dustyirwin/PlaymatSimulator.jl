
# julia --trace-compile=pms_trace.jl
# PackageCompiler.restore_default_sysimage()


# DO NOT compile GameZero! Julia will not compile local dev pkg changes??

using PackageCompiler

project_symbols = [
    :Colors,
    :DataStructures,
    :DrWatson,
    :GameZero,
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
    :Serialization,
    :Statistics,
    :Rotations,
    ]

create_sysimage(project_symbols,
    precompile_statements_file="tmp/ps-trace.jl",
    sysimage_path="sys-ps.so"
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

# UUID for GameZero 5cf23aef-9907-41d4-9cbf-0482fdc672a3
# UUID for PlaymatSimulator e5f19dc6-78e9-41ab-ba95-fec0547b5fb9
using Dates
using Random
using UUIDs
uuid4(MersenneTwister(Int(floor(datetime2unix(now())))))
