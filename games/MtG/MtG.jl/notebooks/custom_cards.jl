### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ f313719e-56c1-11eb-0151-7fdc92bc5635
using DrWatson

# ╔═╡ 5d891788-56c2-11eb-1723-8361ac5bd415
begin
	@quickactivate
	
	using Images
	using Serialization
	using PlutoUI
	
	DECK_DIR = "$(projectdir())/games/MtG/EDH/decks/Vannifar's Circus"
end

# ╔═╡ 25ae7b58-56c4-11eb-1e42-e7b3a9336ca2
md"""
### Custom Cards
"""

# ╔═╡ 8a3f6140-56c4-11eb-1cea-ff327a21d57b
deck = deserialize("$DECK_DIR/Vannifar's Circus.jls")

# ╔═╡ d627369a-589b-11eb-1964-dda299d31a58
zip(deck[:card_names], deck[:CARD_FRONT_IMGS])

# ╔═╡ 2f5a332c-56c4-11eb-259b-8b7d51af1b04
custom_pngs = [ load("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin("png", fn) ]

# ╔═╡ 437c0424-56c5-11eb-29ce-7f0090186512
custom_gifs = [ LocalResource("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin("gif", fn) ]

# ╔═╡ 74abf0a2-5802-11eb-3bcf-79a66eabe3e5
custom_gifs[1]

# ╔═╡ b7601e20-588f-11eb-3bc0-17e1d1b00984
dice_gifs = [ LocalResource("$(projectdir())/games/MtG/MtG.jl/ui/dice/$fn") for fn in readdir("$(projectdir())/games/MtG/MtG.jl/ui/dice") if occursin("gif", fn) ]

# ╔═╡ ffd7435e-588f-11eb-31fd-392884e81292
counter_gifs = [ LocalResource("$(projectdir())/games/MtG/MtG.jl/ui/counters/$fn") for fn in readdir("$(projectdir())/games/MtG/MtG.jl/ui/counters") if occursin("gif", fn) ]

# ╔═╡ Cell order:
# ╟─f313719e-56c1-11eb-0151-7fdc92bc5635
# ╠═5d891788-56c2-11eb-1723-8361ac5bd415
# ╠═25ae7b58-56c4-11eb-1e42-e7b3a9336ca2
# ╠═8a3f6140-56c4-11eb-1cea-ff327a21d57b
# ╠═d627369a-589b-11eb-1964-dda299d31a58
# ╠═2f5a332c-56c4-11eb-259b-8b7d51af1b04
# ╠═437c0424-56c5-11eb-29ce-7f0090186512
# ╠═74abf0a2-5802-11eb-3bcf-79a66eabe3e5
# ╠═b7601e20-588f-11eb-3bc0-17e1d1b00984
# ╠═ffd7435e-588f-11eb-31fd-392884e81292
