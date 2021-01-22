### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 88419b2e-5c5a-11eb-2885-fb367995002b
begin
	using DrWatson
	using PlutoUI
	using Serialization
end

# ╔═╡ 7dbb3cb4-5c5a-11eb-3191-db2a1e5dddd5
mtg_dir = projectdir() * "/games/MtG"

# ╔═╡ 75678b5a-5c5a-11eb-195e-2f7e93faacb1
dice_faces = [ load("$mtg_dir/MtG.jl/ui/dice/$fn") for fn in
	readdir("$mtg_dir/MtG.jl/ui/dice") if occursin("gif", fn) ];

# ╔═╡ 94e33342-5c5a-11eb-348a-01e6747337f8
face_preview = [ LocalResource("$mtg_dir/MtG.jl/ui/dice/$fn") for fn in
	readdir("$mtg_dir/MtG.jl/ui/dice") if occursin("gif", fn) ]

# ╔═╡ e807667e-5c5a-11eb-2175-7b84dffeb740
md"""
Save data to jls file? $(@bind save_data CheckBox())
"""

# ╔═╡ 80fa2680-5c5a-11eb-3e92-05a4be927f4e
if save_data
	serialize("$mtg_dir/MtG.jl/ui/dice/dice_faces.jls", dice_faces)
end

# ╔═╡ Cell order:
# ╠═88419b2e-5c5a-11eb-2885-fb367995002b
# ╠═7dbb3cb4-5c5a-11eb-3191-db2a1e5dddd5
# ╠═75678b5a-5c5a-11eb-195e-2f7e93faacb1
# ╠═94e33342-5c5a-11eb-348a-01e6747337f8
# ╟─e807667e-5c5a-11eb-2175-7b84dffeb740
# ╠═80fa2680-5c5a-11eb-3e92-05a4be927f4e
