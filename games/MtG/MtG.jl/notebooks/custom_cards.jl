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
	
	DECK_DIR = "$(projectdir())/games/MtG/EDH/decks/Vannifar's Circus"
end

# ╔═╡ 25ae7b58-56c4-11eb-1e42-e7b3a9336ca2
md"""
### Custom cards
"""

# ╔═╡ 8a3f6140-56c4-11eb-1cea-ff327a21d57b
deck = deserialize("$DECK_DIR/Vannifar's Circus.jls")

# ╔═╡ 2f5a332c-56c4-11eb-259b-8b7d51af1b04
custom_imgs = [ load("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin("png", fn) ]

# ╔═╡ 437c0424-56c5-11eb-29ce-7f0090186512


# ╔═╡ Cell order:
# ╠═f313719e-56c1-11eb-0151-7fdc92bc5635
# ╠═5d891788-56c2-11eb-1723-8361ac5bd415
# ╠═25ae7b58-56c4-11eb-1e42-e7b3a9336ca2
# ╠═8a3f6140-56c4-11eb-1cea-ff327a21d57b
# ╠═2f5a332c-56c4-11eb-259b-8b7d51af1b04
# ╠═437c0424-56c5-11eb-29ce-7f0090186512
