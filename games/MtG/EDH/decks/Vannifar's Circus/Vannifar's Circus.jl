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
	using DataStructures
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
        "Prime Speaker Vannifar",
    	],
    :card_names => [
		"Arixmethes, Slumbering Isle",
		"Alchemist's Refuge",
		"Birds of Paradise",
        "Botanical Sanctum",
        "Brainstorm",
        "Breeding Pool",
        "City of Brass",
        "Coiling Oracle",
        "Command Tower",
        "Counterspell",
        "Crop Rotation",
        "Cryptic Command",
        "Cultivate",
        "Deadeye Navigator",
        "Devoted Druid",
        "Dryad Arbor",
        "Dryad of the Ilysian Grove",
        "Elvish Mystic",
        "Elvish Reclaimer",
        "Eternal Witness",
        "Experiment Kraj",
        "Fae of Wishes // Granted",
        "Faerie Conclave",
        "Fblthp, the Lost",
        "Flooded Grove",
        "Flooded Strand",
        "Forbidden Orchard",
        "Forest",
		"Forest",
        "Glen Elendra Archmage",
        "Grand Architect",
		"Green Sun's Zenith",
		"Growth Spiral",
		"Gyre Engineer",
        "Hinterland Harbor",
		"Incubation Druid",
		"Island",
		"Island",
		"Jwari Disruption // Jwari Ruins",
        "Kinnan, Bonder Prodigy",
        "Kiora's Follower",
        "Kodama's Reach",
        "Leech Bonder",
        "Lesser Masticore",
        "Ley Weaver",
        "Lightning Greaves",
        "Llanowar Elves",
        "Llanowar Reborn",
        "Lore Weaver",
        "Magosi, the Waterveil",
        "Maze of Ith",
        "Meekstone",
        "Minamo, School at Water's Edge",
        "Misty Rainforest",
        "Murkfiend Liege",
        "Mystic Sanctuary",
        "Nykthos, Shrine to Nyx",
        "Paradise Mantle",
		"Parcelbeast",
		"Pemmin's Aura",
		"Phyrexian Metamorph",
		"Pili-Pala",
		"Prime Speaker Vannifar",
        "Ramunap Excavator",
        "Reclamation Sage",
        "Reflecting Pool",
        "Regrowth",
        "Remand",
        "Rishkar, Peema Renegade",
        "Safe Haven",
        "Sapseep Forest",
        "Seedborn Muse",
        "Sensei's Divining Top",
        "Simic Growth Chamber",
        "Skullclamp",
        "Snapcaster Mage",
        "Solemn Simulacrum",
        "Sol Ring",
        "Spellseeker",
        "Spore Frog",
        "Strip Mine",
        "Teferi, Mage of Zhalfir",
        "Temple of Mystery",
        "Temporal Mastery",
        "Thousand-Year Elixir",
        "Tolaria West",
        "Trinket Mage",
        "Tropical Island",
		"Vastwood Fortification // Vastwood Thicket",
        "Venser, Shaper Savant",
        "Scryb Ranger",
        "Vizier of Tumbling Sands",
		"Walking Ballista",
		"Waterlogged Grove",
        "Willbreaker",
        "Wirewood Symbiote",
        "Worldly Tutor",
        "Yavimaya Coast",
        "Yavimaya Elder",
        "Young Wolf",
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

	Alrighty, let's collect the data we need to download the card images:
	"""
end

# ╔═╡ 7420cf10-45cc-11eb-2780-4f320bd8a2cf
begin
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

# ╔═╡ 312411ce-5a06-11eb-35e6-efa6cc924b90
md"""
or:
$(@bind customhw CheckBox(default=false)) specify the default card width: $(@bind card_width NumberField(1:10; default=237)) and height: $(@bind card_height NumberField(1:500; default=332)) in pixels
"""

# ╔═╡ 614764b8-4648-11eb-0493-732a00df7bca
md"""
#### Look good? These images will be displayed in-game!
"""

# ╔═╡ 0899b1d0-5972-11eb-0470-4d480cf95d53
md"""
##### Download card imgs? $(@bind download_imgs CheckBox()) 
"""

# ╔═╡ be2af776-5971-11eb-13ec-3d7982a01ea3
md"""
##### Save data to disk? $(@bind save_data CheckBox()) 
"""

# ╔═╡ ce216c54-468a-11eb-13b8-7f3dac7af44a
function get_face_img(img_uri::String)
	img_resp = HTTP.get(img_uri)
	card_img = img_resp.body |> IOBuffer |> load
end

# ╔═╡ 2ab53d00-50cd-11eb-1cd4-5bf94ce53692
function get_card_preview_img(c)
	if haskey(all_cards[i], "card_faces") && haskey(all_cards[i]["card_faces"][1], "image_uris")
		hcat([get_face_img(f["image_uris"]["border_crop"]) 
			for f in all_cards[i]["card_faces"] ]...)
	else
		get_face_img(all_cards[i]["image_uris"]["border_crop"])
	end
end

# ╔═╡ 97bc3768-50ce-11eb-3f74-95d4fefe3792
function get_card_faces(c, faces=[])
	if haskey(c, "image_uris")
		push!(faces, get_face_img(c["image_uris"]["border_crop"]))
	
	elseif haskey(c, "card_faces")
		for f in c["card_faces"]
			push!(faces, get_face_img(f["image_uris"]["border_crop"]))
		end
	end
			
	return faces
end

# ╔═╡ 73d1cd18-4647-11eb-3994-7d4eb92eddca
if length(all_cards) > 0 && (@isdefined all_cards)
	deck_card_preview = if customhw
		imresize.(get_card_faces(all_cards[i]), card_height, card_width)
	else
		imresize.(get_card_faces(all_cards[i]), ratio=card_ratio)
	end
else
	nothing
end

# ╔═╡ dfc9b56e-50ce-11eb-0e7f-83ec6e831901
if download_imgs
	CARD_FACES = []
	COMMANDER_FACES = []

	for c in deck_cards
		faces = get_card_faces(c)
		
		face = if customhw
			imresize.(faces, card_height, card_width)
		else
			imresize.(faces, ratio=card_ratio)
		end
		
		push!(CARD_FACES, c["name"] => face)
		sleep(0.1)
	end

	for c in commander_cards
		faces = get_card_faces(c)
		
		face = if customhw
			imresize.(faces, card_height, card_width)
		else
			imresize.(faces, ratio=card_ratio)
		end
		
		push!(COMMANDER_FACES, c["name"] => imresize.(faces, ratio=1.1))
		sleep(0.1)
	end

	CARD_FACES, COMMANDER_FACES
end

# ╔═╡ 5e6f7046-4da5-11eb-0122-bd82397aab4f
if save_data
	deck[:CARD_BACK_IMG] = CARD_BACK_IMG
	deck[:CARD_FACES] = CARD_FACES
	deck[:COMMANDER_FACES] = COMMANDER_FACES

	fn = "$(projectdir())/games/MtG/EDH/decks/$(deck[:name])/$(deck[:name]).jls"
	serialize(fn, deck)
end

# ╔═╡ d654ad1e-468a-11eb-2348-695621b7b9b0
function search_mtg_cards_by_keyword(q::String, mtg_cards::Array)
	[ n for n in [ c["name"] for c in mtg_cards ] if occursin(q, n) ]
end

# ╔═╡ cec924ac-50c7-11eb-3795-85b3c183a8eb
search_mtg_cards_by_keyword("Jwari", mtg_cards)

# ╔═╡ 8961102a-5eb5-11eb-3c58-8bae7d3766c0


# ╔═╡ 7cbdfda6-5eb5-11eb-2be6-0f93c3374a47
function hbox(x, y, gap=16; sy=size(y), sx=size(x))
	w,h = (max(sx[1], sy[1]),
		   gap + sx[2] + sy[2])
	
	slate = fill(RGB(1,1,1), w,h)
	slate[1:size(x,1), 1:size(x,2)] .= RGB.(x)
	slate[1:size(y,1), size(x,2) + gap .+ (1:size(y,2))] .= RGB.(y)
	slate
end

# ╔═╡ 85103516-5eb5-11eb-3abc-dfc9ae9caf96
vbox(x,y, gap=16) = hbox(x', y')'

# ╔═╡ Cell order:
# ╟─c7952ee6-45b5-11eb-1158-5bb2ff274ce9
# ╟─0c145632-3927-11eb-19b9-877e05c1bcdc
# ╠═cec924ac-50c7-11eb-3795-85b3c183a8eb
# ╟─621b08a4-384e-11eb-0109-61e9b9ecf125
# ╟─fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
# ╟─5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
# ╟─c61fa79e-4583-11eb-3b71-2d334aca843d
# ╠═7420cf10-45cc-11eb-2780-4f320bd8a2cf
# ╟─c31dd202-50c6-11eb-0631-13c70535635e
# ╟─2775088a-4648-11eb-2218-af69e0e95f1f
# ╟─73d1cd18-4647-11eb-3994-7d4eb92eddca
# ╟─c5374766-4ef1-11eb-2555-c159dba953f0
# ╟─312411ce-5a06-11eb-35e6-efa6cc924b90
# ╟─614764b8-4648-11eb-0493-732a00df7bca
# ╟─0899b1d0-5972-11eb-0470-4d480cf95d53
# ╟─dfc9b56e-50ce-11eb-0e7f-83ec6e831901
# ╟─be2af776-5971-11eb-13ec-3d7982a01ea3
# ╠═5e6f7046-4da5-11eb-0122-bd82397aab4f
# ╟─ce216c54-468a-11eb-13b8-7f3dac7af44a
# ╟─2ab53d00-50cd-11eb-1cd4-5bf94ce53692
# ╟─97bc3768-50ce-11eb-3f74-95d4fefe3792
# ╟─d654ad1e-468a-11eb-2348-695621b7b9b0
# ╠═8961102a-5eb5-11eb-3c58-8bae7d3766c0
# ╟─7cbdfda6-5eb5-11eb-2be6-0f93c3374a47
# ╟─85103516-5eb5-11eb-3abc-dfc9ae9caf96
