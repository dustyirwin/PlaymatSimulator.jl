### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 1581f9f4-4b6f-11eb-34df-cb1e958aaab6
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

# ╔═╡ 1a6beb1e-4b6f-11eb-2a42-5f72fd775375
begin
	@quickactivate

    using GZ2
    using Colors
	using Serialization
    using PlaymatSimulator

	md"""
	## Elder Dragon Highlander aka Commander

	EDH is a variant of an MtG game that uses a 100 card singleton deck with 1 or more cards designated as the "Commander" and a 40 point lifepool. The Commander should start on the battlefield and be visible to all players.
	"""
end

# ╔═╡ ac928f18-4e0b-11eb-1228-efffa1646e24
USER_SETTINGS = deserialize(
	"$(projectdir())/tmp/user_selection.jls")

# ╔═╡ 2d5304e4-4e2e-11eb-1856-a594b65b33a1
mtg_dir = "$(projectdir())/games/MtG"

# ╔═╡ ac00106c-4bff-11eb-29db-b1f869ba2c70
begin
	game_include("$mtg_dir/MtG.jl/notebooks/MtG.jl")
	game_include("$mtg_dir/MtG.jl/notebooks/game_settings.jl")
	deck = game_include("$mtg_dir/EDH/decks/$(USER_SETTINGS[:DECK_NAME])/$(USER_SETTINGS[:DECK_NAME]).jl")
	gs = game_include("$mtg_dir/EDH/notebooks/game_state.jl")
end

# ╔═╡ 1e72fb94-4c0a-11eb-1186-e717e9acc1e6
begin
	merge!(gs, USER_SETTINGS)
	gs[:deck] = deck
end

# ╔═╡ c811ed82-4c09-11eb-3506-9b30dae8eaa6
add_texts!(gs)

# ╔═╡ 5d5e4990-4c1b-11eb-04c8-5da74ff7c314
gs[:deck] = deck

# ╔═╡ 0146b240-4c0a-11eb-371c-19ef327394c7
reset_deck!(gs)

# ╔═╡ 32229134-4cc0-11eb-2c68-d11134987c56
begin  # required GZ2 variables
	SCREEN_HEIGHT = gs[:SCREEN_HEIGHT]
	SCREEN_WIDTH = gs[:SCREEN_WIDTH]
	BACKGROUND = gs[:BACKGROUND]
end

# ╔═╡ Cell order:
# ╟─1581f9f4-4b6f-11eb-34df-cb1e958aaab6
# ╟─1a6beb1e-4b6f-11eb-2a42-5f72fd775375
# ╟─ac928f18-4e0b-11eb-1228-efffa1646e24
# ╟─2d5304e4-4e2e-11eb-1856-a594b65b33a1
# ╠═ac00106c-4bff-11eb-29db-b1f869ba2c70
# ╟─1e72fb94-4c0a-11eb-1186-e717e9acc1e6
# ╠═c811ed82-4c09-11eb-3506-9b30dae8eaa6
# ╠═5d5e4990-4c1b-11eb-04c8-5da74ff7c314
# ╠═0146b240-4c0a-11eb-371c-19ef327394c7
# ╠═32229134-4cc0-11eb-2c68-d11134987c56
