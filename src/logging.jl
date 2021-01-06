module Logging
    using Logging
    using Colors

    function start_logger()
        printstyled("Logger started!", bold=true, color=colorant"blue")
    end
end