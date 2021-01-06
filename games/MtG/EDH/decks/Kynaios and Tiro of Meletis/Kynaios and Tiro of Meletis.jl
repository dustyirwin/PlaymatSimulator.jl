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

# ╔═╡ c7952ee6-45b5-11eb-1158-5bb2ff274ce9
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

# ╔═╡ 0c145632-3927-11eb-19b9-877e05c1bcdc
begin
	@quickactivate
	
	using JSON
	using HTTP
	using Plots
	using Images
	using PlutoUI
	using Serialization
	using ImageTransformations: imresize
	
	plotly()
	
	GS = ingredients("$(projectdir())/games/MtG/MtG.jl/notebooks/game_settings.jl")
	
	md"""*game settings loaded!*
	
	## MtG EDH Kynaios and Tiro of Meletis ???
	"""
end

# ╔═╡ 621b08a4-384e-11eb-0109-61e9b9ecf125
deck = Dict{Symbol,Any}(
	:name => split(@__DIR__, "/")[end],
    :commanders => [
        "Kynaios and Tiro of Meletis",
    	],
    :cards => [
		"Altar of the Pantheon",
		"Angel of Sanctions",
		"Armillary Sphere",
		"Ash Barrens",
		"Azorius Chancery",
		"Back from the Brink",
		"Boros Guildgate",
		"Brudiclad, Telchor Engineer",
		"Caller of the Pack",
		"Commander's Sphere",
		"Command Tower",
		"Cultivate",
		"Desolation Twin",
		"Doomed Artisan",
		"Draconic Disciple",
		"Dragonmaster Outcast",
		"Druid's Deliverance",
		"Emmara Tandris",
		"Ephara, God of the Polis",
		"Evolving Wilds",
		"Exotic Orchard",
		"Feldon of the Third Path",
		"Forbidden Orchard",
		"Forest",
		"Forest",
		"Forest",
		"Forest",
		"Forest",
		"Forest",
		"Full Flowering",
		"Gargoyle Castle",
		"Garruk, Primal Hunter",
		"Ghired, Conclave Exile",
		"Ghired's Belligerence",
		"Giant Adephage",
		"God-Pharaoh's Gift",
		"Golden Guardian // Gold-Forge Garrison",
		"Growing Ranks",
		"Gruul Turf",
		"Heart-Piercer Manticore",
		"Hellion Crucible",
		"Helm of the Host",
		"Hour of Reckoning",
		"Idol of Oblivion",
		"Intangible Virtue",
		"Island",
		"Island",
		"Island",
		"Island",
		"Island",
		"Island",
		"Island",
		"Island",
		"Island",
		"Island",
		"Island",
		"Izzet Boilerworks",
		"Kazandu Tuskcaller",
		"Kiora, the Crashing Wave",
		"Metallurgic Summonings",
		"Mimic Vat",
		"Mirror Match",
		"Mist-Syndicate Naga",
		"Moonsilver Spear",
		"Mountain",
		"Mountain",
		"Mountain",
		"Mountain",
		"Mountain",
		"Mountain",
		"Myriad Landscape",
		"Overwhelming Stampede",
		"Parhelion II",
		"Phyrexian Rebirth",
		"Rogue's Passage",
		"Rampaging Baloths",
		"Rootborn Defenses",
		"Saheeli Rai",
		"Saheeli's Artistry",
		"Second Harvest",
		"Selesnya Eulogist",
		"Selesnya Sanctuary",
		"Simic Growth Chamber",
		"Song of the Worldsoul",
		"Soul Foundry",
		"Soul of Eternity",
		"Spawning Grounds",
		"Spectral Searchlight",
		"Spitting Image",
		"Stolen Identity",
		"Sundering Growth",
		"Tempt with Discovery",
		"Terramorphic Expanse",
		"Titan Forge",
		"Trostani, Selesnya's Voice",
		"Trostani's Judgment",
		"Vitu-Ghazi Guildmage",
		"Wayfaring Temple",
		"Wingmate Roc",
		]
	)

# ╔═╡ fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
md"""
Found $(length(deck[:cards]) + length(deck[:commanders])) cards in deck!
"""

# ╔═╡ c61fa79e-4583-11eb-3b71-2d334aca843d
begin
	mtg_cards = JSON.parsefile("$(projectdir())/games/MtG/MtG.jl/json/oracle-cards-20201224220555.json")
	
	md"""
	###### MtG database loaded. Found $(length(mtg_cards)) unique cards (by name).
	Most recent data available here: https://scryfall.com/docs/api/bulk-data
	"""
end

# ╔═╡ 7420cf10-45cc-11eb-2780-4f320bd8a2cf
begin  # note: this func only downloads the first card with a matching name and then moves to the next.
	deck_cards = []
	commander_cards = []
	
	for c in mtg_cards
		
		for n in deck[:cards]
		 	if n == c["name"]
				push!(deck_cards, c)
			end
		end
		
		for n in deck[:commanders]
			if n == c["name"]
				push!(commander_cards, c)
			end
		end
	end
	
	md"""
	Found $(length(deck_cards) + length(commander_cards)) matching cards in mtg_cards!
	"""
end

# ╔═╡ 908b651c-4f3a-11eb-12c8-f95c2adb3e13
sort([c["name"] for c in deck_cards ])

# ╔═╡ 489f3da8-4681-11eb-26af-f75d8ecc552e
@bind i Slider(1:length(deck_cards), show_value=true)

# ╔═╡ 52dc1a52-4ef3-11eb-2e73-371bef933add
md"""
##### *Adjust this slider to shrink / grow the cards while preserving the aspect ratio*

$(@bind ratio Slider(0.1:0.05:1.5, default=0.75, show_value=true))
"""

# ╔═╡ 5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
begin
	CARD_BACK_PATH = "$(projectdir())/games/MtG/MtG.jl/ui/cards/card_back.png"
	CARD_BACK_IMG = imresize(load(CARD_BACK_PATH), ratio=ratio)
end

# ╔═╡ 4666005c-4d62-11eb-1215-e7e010c3125c
md"""
#### Look good? These images will be displayed in-game.
TODO: write support for previews of double-sided cards
"""

# ╔═╡ 457f0ee2-4d6f-11eb-310f-cf4784a06469
html"""<br><br><br><br><br><br>"""

# ╔═╡ 9ded258e-468d-11eb-3428-d915bfe9e13e
function get_card_img(img_uri::String)
	img_resp = HTTP.get(img_uri)
	card_img = img_resp.body |> IOBuffer |> load
end

# ╔═╡ 73d1cd18-4647-11eb-3994-7d4eb92eddca
try
	deck_card_img = imresize(get_card_img(deck_cards[i]["image_uris"]["border_crop"]), ratio=ratio)
catch
	"Sorry, no preview for double-sided or split cards..."
end

# ╔═╡ a26b32f4-468d-11eb-1ddd-7958d61b4ac6
function search_cards_by_keyword(q::String, mtg_cards::Array)
	[ n for n in [ c["name"] for c in mtg_cards ] if occursin(q, n) ]
end

# ╔═╡ cb8e3b6c-4661-11eb-152e-3f2ce56cdd9d
search_cards_by_keyword("Fool", mtg_cards)

# ╔═╡ 5629c102-4da5-11eb-24c3-b9aefeaf4149
begin
	#deck[:CARD_BACK_PATH] = CARD_BACK_PATH
	#deck[:CARD_IMG_RATIO] = ratio
	#deck[:CARD_BACK_IMG] = ARGB.(CARD_BACK_IMG)
	#deck[:CARD_IMGS] = [ ARGB.(imresize(get_card_img(c["image_uris"]["border_crop"]), ratio=ratio)) for c in deck_cards if haskey(c, "image_uris") ]
	#deck[:COMMANDER_IMGS] = [ ARGB.(imresize(get_card_img(c["image_uris"]["border_crop"]), ratio=ratio)) for c in commander_cards if haskey(c, "image_uris") ]
	#serialize("$(deck[:name]).jls", deck)
	deserialize(
		"$(projectdir())/games/MtG/EDH/decks/$(deck[:name])/$(deck[:name]).jls")
end

# ╔═╡ Cell order:
# ╟─c7952ee6-45b5-11eb-1158-5bb2ff274ce9
# ╟─0c145632-3927-11eb-19b9-877e05c1bcdc
# ╟─621b08a4-384e-11eb-0109-61e9b9ecf125
# ╟─fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
# ╠═5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
# ╟─c61fa79e-4583-11eb-3b71-2d334aca843d
# ╟─7420cf10-45cc-11eb-2780-4f320bd8a2cf
# ╟─908b651c-4f3a-11eb-12c8-f95c2adb3e13
# ╟─73d1cd18-4647-11eb-3994-7d4eb92eddca
# ╟─489f3da8-4681-11eb-26af-f75d8ecc552e
# ╠═52dc1a52-4ef3-11eb-2e73-371bef933add
# ╟─4666005c-4d62-11eb-1215-e7e010c3125c
# ╟─457f0ee2-4d6f-11eb-310f-cf4784a06469
# ╠═cb8e3b6c-4661-11eb-152e-3f2ce56cdd9d
# ╟─9ded258e-468d-11eb-3428-d915bfe9e13e
# ╟─a26b32f4-468d-11eb-1ddd-7958d61b4ac6
# ╠═5629c102-4da5-11eb-24c3-b9aefeaf4149
