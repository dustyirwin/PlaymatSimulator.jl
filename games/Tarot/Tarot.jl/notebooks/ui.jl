### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 91e8b4ee-50b3-11eb-2c4b-a552b3ccfbc8
begin
	using DrWatson

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

# ╔═╡ 99b2c3b8-50b3-11eb-184e-e18dff29b3d1


# ╔═╡ Cell order:
# ╠═91e8b4ee-50b3-11eb-2c4b-a552b3ccfbc8
# ╠═99b2c3b8-50b3-11eb-184e-e18dff29b3d1
