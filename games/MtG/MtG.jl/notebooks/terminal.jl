### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# ╔═╡ 804078c8-3aa1-11eb-2f4d-69380de7ab92
begin
	function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
	end
end;

# ╔═╡ d6e610fe-3aa2-11eb-1397-31d1f09ef073
begin
	using Serialization
	
	md"""
	## GAME TERMINAL

	Send commands to the game engine via a serialized string. The serialized string file will be deleted after attempting to @eval it. Press the "`" (backquote) key in-game to execute an awaiting serialized string.
	"""
end

# ╔═╡ 7650e106-3aca-11eb-11aa-67e7cd77b705
begin
	terminal = """length(gs[:group][:selected]); println("this is cool!")"""
	serialize(projectdir() * "/terminal.jls", terminal)
	"Command saved to disk @ $(projectdir() * "/terminal.jls")"
end

# ╔═╡ b2696b50-3b5a-11eb-0cd2-ed9365906359
md"""
#### Common commands
"""

# ╔═╡ c2d1f23c-3b5a-11eb-3a24-c3cd27d005d0


# ╔═╡ Cell order:
# ╟─804078c8-3aa1-11eb-2f4d-69380de7ab92
# ╟─d6e610fe-3aa2-11eb-1397-31d1f09ef073
# ╠═7650e106-3aca-11eb-11aa-67e7cd77b705
# ╟─b2696b50-3b5a-11eb-0cd2-ed9365906359
# ╠═c2d1f23c-3b5a-11eb-3a24-c3cd27d005d0
