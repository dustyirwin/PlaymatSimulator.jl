
# julia --trace-compile=pms_trace.jl
# PackageCompiler.restore_default_sysimage()


# DO NOT compile GameOne! Julia will not compile local dev pkg changes??

import Pkg

Pkg.add(url="https://botm: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@github.com/dustyirwin/GameOne.jl")
Pkg.instantiate()

using PackageCompiler

project_symbols = [
    :Colors
    :DataStructures
    :GameOne
    :HTTP
    :ImageFiltering
    :ImageMagick
    :ImageTransformations
    :Images
    :JSON
    :Pluto
    :PlutoUI
    :Reexport
    :Revise
    :Rotations
    :ShiftedArrays
    :Dates
    :Logging
    :Pkg
    :Random
    :SHA
    :Serialization
]

create_sysimage(project_symbols,
    precompile_statements_file = "BotM-trace.jl",
    sysimage_path = "botm.so"
)

#=
PackageCompiler.audit_app(".")  # passing!

create_app(
    "../PlaymatSimulator.jl",
    "../PS.compiled",
    filter_stdlibs = false,
    #precompile_statements_file="tmp/trace.jl",
    incremental = true,
    #force=true
)

# UUID for GameOne b831c3d0-16f1-4eaa-ad23-1d0424ad4597
# UUID for PlaymatSimulator e5f19dc6-78e9-41ab-ba95-fec0547b5fb9
using Dates
using Random
using UUIDs
uuid4(MersenneTwister(Int(floor(datetime2unix(now())))))


=#