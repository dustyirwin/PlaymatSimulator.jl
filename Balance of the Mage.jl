### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 3c08e2ed-0a46-4188-9d31-b96025c392e9
begin
	import Pkg
	Pkg.activate(".")

	using Revise
	using PlaymatSimulator
	using Serialization
	using PlutoUI
	using Colors
	using Images
end

# ╔═╡ 08f5a3b3-4c9f-43a1-b560-6e9c1910c549
# page/cell width control
"""
<style>
	main {
	max-width: 1100px;
	align-left: flex-start;
	margin-left: 50px;
	}
""" |> HTML

# ╔═╡ 3859690e-5214-11ec-258b-ff4a0841015f
md"""
# ⚖️ Balance of the Mage 

Welcome to Balance of the Mage development tool
"""

# ╔═╡ 32e063d1-0ffe-4995-81d3-903a04df46b9
gd = "C:\\Users\\dusty\\Documents\\PlaymatProjects\\PlaymatGames\\BotM"

# ╔═╡ 914ee99a-ddef-4987-abb5-e6386780ff4d
deckDir = "$gd\\Standard\\decks\\"

# ╔═╡ 1d64c448-dc20-4109-94fd-005800c348cb
begin
	deckNames = ["", readdir(deckDir)... ]
	
	md"""
	What deck would you like to use? $(@bind deckName Select(deckNames))
	"""
end

# ╔═╡ ccf656dc-4c3b-45aa-b463-a40e143e6431
if deckName != ""	
	userSettings = Dict(
		:GAME_NAME => "Balance of the Mage",
		:DECK_NAME => deckName,
	)

	serialize("tmp/user_selection.jls", userSettings)
end;

# ╔═╡ 03e708d5-6289-49dc-8def-fef7cb287177
md"""
Start game: $(@bind startGame CheckBox())
"""

# ╔═╡ 7c2e4991-c3d9-4d14-b807-45a1253b2176
if startGame && @isdefined(userSettings)
	PlaymatSimulator.GameOne.rungame("$gd/Standard/Standard.jl")
end

# ╔═╡ Cell order:
# ╟─08f5a3b3-4c9f-43a1-b560-6e9c1910c549
# ╟─3859690e-5214-11ec-258b-ff4a0841015f
# ╟─3c08e2ed-0a46-4188-9d31-b96025c392e9
# ╠═32e063d1-0ffe-4995-81d3-903a04df46b9
# ╠═914ee99a-ddef-4987-abb5-e6386780ff4d
# ╟─1d64c448-dc20-4109-94fd-005800c348cb
# ╠═ccf656dc-4c3b-45aa-b463-a40e143e6431
# ╠═7c2e4991-c3d9-4d14-b807-45a1253b2176
# ╟─03e708d5-6289-49dc-8def-fef7cb287177
