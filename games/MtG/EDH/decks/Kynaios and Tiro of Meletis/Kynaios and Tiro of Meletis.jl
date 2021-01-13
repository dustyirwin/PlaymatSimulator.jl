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
using DrWatson

# ╔═╡ 0c145632-3927-11eb-19b9-877e05c1bcdc
begin
	@quickactivate

	using GZ2
	using JSON
	using HTTP
	using Plots
	using Images: load, ARGB
	using PlutoUI
	using Serialization
	using PlaymatSimulator
	using ImageTransformations: imresize

	AC = PlaymatSimulator.Actors

	plotly()

	md"""
	*game settings loaded!*

	## MtG EDH Deck: Vannifar's Circus (UG Creature Ramp Combo) by Dustin Irwin
	For simple games, a "deck" in PlaymatSimulator is simply a collection of images, one for each card in the deck. Let's build an example EDH deck `Vannifar's Circus`.

	To get started, define a `deck` Dict object below of type Dict{String,Int} where the key is the official card name and the value is the quantity of that card in the deck.
	"""
end

# ╔═╡ 621b08a4-384e-11eb-0109-61e9b9ecf125
deck = Dict{Symbol,Any}(
	:name => split(@__DIR__, "/")[end],
	:commander_names => [
	    "Kynaios and Tiro of Meletis",
	    ],
	:card_names => [
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
(length(deck[:card_names]) + length(deck[:commander_names]))

# ╔═╡ c61fa79e-4583-11eb-3b71-2d334aca843d
begin
	mtg_cards = JSON.parsefile("$(projectdir())/games/MtG/MtG.jl/json/oracle-cards-20201224220555.json")

	md"""Look OK? Keep in mind that images that do not require in-game scaling will suffer less distortion.

	Alright, lets load up a JSON file with the URIs we need to grab the card images. For MtG, we can use the .json file available here: TODO

	Save the json file to the /json directory in the MtG project directory and modify the following cell to point at the json file.

	##### MtG database loaded! Found $(length(mtg_cards)) unique cards (by name).

	mtg_cards is of type Array{Any}. The dicts contained within are of type Dict{String,Any}.

	Alrighty, let's collect the data we need to download the card images!
	"""
end

# ╔═╡ 7420cf10-45cc-11eb-2780-4f320bd8a2cf
begin  # note: this func only downloads the first card with a matching name and then moves to the next.
	deck_cards = []
	commander_cards = []

	for n in sort(deck[:card_names])

		for c in mtg_cards

			if n == c["name"]
				push!(deck_cards, c)
			end
		end
	end

	for n in deck[:commander_names]

		for c in mtg_cards

			if n == c["name"]
				push!(commander_cards, c)
			end
		end
	end

	all_cards = vcat(commander_cards, deck_cards)

	md"""
	Found $(length(deck_cards) + length(commander_cards)) matching cards in mtg_cards!
	"""
end

# ╔═╡ c31dd202-50c6-11eb-0631-13c70535635e
missing_cards = filter!(x->!(x in [ c["name"] for c in all_cards ]), vcat(deck[:card_names], deck[:commander_names]))

# ╔═╡ 2775088a-4648-11eb-2218-af69e0e95f1f
@bind i Slider(1:length(all_cards), show_value=true)

# ╔═╡ c5374766-4ef1-11eb-2555-c159dba953f0
md"""
##### *Adjust this slider to shrink / grow the cards while preserving the aspect ratio*

$(@bind card_ratio Slider(0.1:0.05:1.25, default=0.5, show_value=true))
"""

# ╔═╡ 5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
begin
	CARD_BACK_PATH = "$(projectdir())/games/MtG/MtG.jl/ui/cards/card_back.png"
	CARD_BACK_IMG = imresize(load(CARD_BACK_PATH), ratio=card_ratio)
end

# ╔═╡ 614764b8-4648-11eb-0493-732a00df7bca
md"""
#### Look good? These images will be displayed in-game!
TODO: write support for previews of double-sided cards
"""

# ╔═╡ dfc9b56e-50ce-11eb-0e7f-83ec6e831901
begin
	#=
	CARD_FRONT_IMGS = []
	COMMANDER_FRONT_IMGS = []

	for c in deck_cards
		push!(CARD_FRONT_IMGS, imresize(get_mtg_card_front_img(c), ratio=card_ratio))
		sleep(0.1)
	end

	for c in commander_cards
		push!(COMMANDER_FRONT_IMGS, imresize(get_mtg_card_front_img(c), ratio=card_ratio+0.05))
		sleep(0.1)
	end

	COMMANDER_FRONT_IMGS, CARD_FRONT_IMGS
	=#
end

# ╔═╡ ce216c54-468a-11eb-13b8-7f3dac7af44a
function get_card_img(img_uri::String)
	img_resp = HTTP.get(img_uri)
	card_img = img_resp.body |> IOBuffer |> load
end

# ╔═╡ 2ab53d00-50cd-11eb-1cd4-5bf94ce53692
function get_mtg_card_img(c)
	if haskey(all_cards[i], "card_faces") && haskey(all_cards[i]["card_faces"][1], "image_uris")
		hcat([
			get_card_img(f["image_uris"]["border_crop"]) for f in all_cards[i]["card_faces"]
			]...)
	else
		get_card_img(all_cards[i]["image_uris"]["border_crop"])
	end
end

# ╔═╡ 73d1cd18-4647-11eb-3994-7d4eb92eddca
if (@isdefined all_cards) && length(all_cards) > 0
	deck_card_preview = imresize(get_mtg_card_img(all_cards[i]), ratio=card_ratio)
else
	nothing
end

# ╔═╡ 97bc3768-50ce-11eb-3f74-95d4fefe3792
function get_mtg_card_front_img(c)
	if haskey(c, "card_faces") && haskey(c["card_faces"][1], "image_uris")
		get_card_img(c["card_faces"][1]["image_uris"]["border_crop"])
	else
		get_card_img(c["image_uris"]["border_crop"])
	end
end

# ╔═╡ d654ad1e-468a-11eb-2348-695621b7b9b0
function search_mtg_cards_by_keyword(q::String, mtg_cards::Array)
	[ n for n in [ c["name"] for c in mtg_cards ] if occursin(q, n) ]
end

# ╔═╡ cec924ac-50c7-11eb-3795-85b3c183a8eb
search_mtg_cards_by_keyword("Meletis", mtg_cards)

# ╔═╡ 5e6f7046-4da5-11eb-0122-bd82397aab4f
begin
	#=
	deck[:CARD_WIDTH] = Int32(size(CARD_BACK_IMG)[1])
	deck[:CARD_HEIGHT] = Int32(size(CARD_BACK_IMG)[2])
	deck[:CARD_FRONT_IMGS] = CARD_FRONT_IMGS
	deck[:CARD_BACK_IMG] = CARD_BACK_IMG
	deck[:COMMANDER_FRONT_IMGS] = COMMANDER_FRONT_IMGS

	fn = "$(projectdir())/games/MtG/EDH/decks/$(deck[:name])/$(deck[:name]).jls"
	serialize(fn, deck)
	=#
end

# ╔═╡ Cell order:
# ╟─c7952ee6-45b5-11eb-1158-5bb2ff274ce9
# ╟─0c145632-3927-11eb-19b9-877e05c1bcdc
# ╟─621b08a4-384e-11eb-0109-61e9b9ecf125
# ╠═fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
# ╟─5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
# ╟─c61fa79e-4583-11eb-3b71-2d334aca843d
# ╟─7420cf10-45cc-11eb-2780-4f320bd8a2cf
# ╟─c31dd202-50c6-11eb-0631-13c70535635e
# ╠═cec924ac-50c7-11eb-3795-85b3c183a8eb
# ╟─73d1cd18-4647-11eb-3994-7d4eb92eddca
# ╟─2775088a-4648-11eb-2218-af69e0e95f1f
# ╠═c5374766-4ef1-11eb-2555-c159dba953f0
# ╟─614764b8-4648-11eb-0493-732a00df7bca
# ╠═dfc9b56e-50ce-11eb-0e7f-83ec6e831901
# ╟─ce216c54-468a-11eb-13b8-7f3dac7af44a
# ╟─2ab53d00-50cd-11eb-1cd4-5bf94ce53692
# ╟─97bc3768-50ce-11eb-3f74-95d4fefe3792
# ╟─d654ad1e-468a-11eb-2348-695621b7b9b0
# ╠═5e6f7046-4da5-11eb-0122-bd82397aab4f
