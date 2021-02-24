### A Pluto.jl notebook ###
# v0.12.20

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
	using Images: load, RGB
	using PlutoUI
	using Serialization
	using PlaymatSimulator
	using DataStructures
	using ImageTransformations: imresize

	AC = PlaymatSimulator.Actors
	
	mtg_cards = JSON.parsefile("$(projectdir())/games/MtG/MtG.jl/json/oracle-cards-20201224220555.json")

	md"""
	*mtg_cards loaded from JSON*

	## MtG EDH Deck: Vannifar's Circus (UG Creature Ramp Combo) by Dustin Irwin
	For simple games, a "deck" in PlaymatSimulator is simply a collection of images, one for each card in the deck. Let's build an example EDH deck `Vannifar's Circus`.

	To get started, define a `deck` Dict object below of type Dict{String,Int} where the key is the official card name and the value is the quantity of that card in the deck.
	"""
end

# ╔═╡ 621b08a4-384e-11eb-0109-61e9b9ecf125
if !(@isdefined deck)
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
else 
	nothing
end

# ╔═╡ fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
length(deck[:card_names])

# ╔═╡ c61fa79e-4583-11eb-3b71-2d334aca843d
md"""
Look OK? Keep in mind that images that do not require in-game scaling will suffer less distortion.

Alright, lets load up a JSON file with the URIs we need to grab the card images. For MtG, we can use the .json file available here: TODO

Save the json file to the /json directory in the MtG project directory and modify the following cell to point at the json file.

##### MtG database loaded! Found $(length(mtg_cards)) unique cards (by name).

mtg_cards is of type Array{Any}. The dicts contained within are of type Dict{String,Any}.

Alrighty, let's collect the data we need to download the card images:
"""

# ╔═╡ 7420cf10-45cc-11eb-2780-4f320bd8a2cf
begin
	cards = []

	for n in sort(deck[:card_names])

		for c in mtg_cards

			if n == c["name"]
				push!(cards, c)
			end
		end
	end

	md"""
	Found $(length(cards)) matching cards in mtg_cards!
	"""
end

# ╔═╡ c31dd202-50c6-11eb-0631-13c70535635e
missing_cards = filter!(x->!(x in [ c["name"] for c in cards ]), vcat(deck[:card_names], deck[:commander_names]))

# ╔═╡ c5374766-4ef1-11eb-2555-c159dba953f0
md"""Card #: $(@bind i Slider(1:length(cards), default=50, show_value=true))
Shrink card by $(@bind card_ratio Slider(0.1:0.05:1.25, default=0.5, show_value=true)) 

or: $(@bind customw CheckBox(default=true)) specify the default card width: $(@bind card_width NumberField(1:10; default=270)) in pixels
"""

# ╔═╡ 0899b1d0-5972-11eb-0470-4d480cf95d53
md"""
##### Download card imgs? $(@bind download_imgs CheckBox()) 
"""

# ╔═╡ be2af776-5971-11eb-13ec-3d7982a01ea3
md"""
##### Save data to disk? $(@bind save_data CheckBox()) 
"""

# ╔═╡ 43cdcbdc-5f68-11eb-11bd-51fbbf610333
deck

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
if length(cards) > 0 && (@isdefined cards)
	
	if customw
		fs = get_card_faces(cards[i])
		sz = size(fs[end])
		imresize.(fs, ceil(Int, card_width * sz[1]/sz[2]), card_width)[end]
	else
		imresize.(get_card_faces(cards[i]), ratio=card_ratio)[end]
	end
else
	nothing
end

# ╔═╡ dfc9b56e-50ce-11eb-0e7f-83ec6e831901
if download_imgs
	CARD_FACES = []

	for c in cards
		faces = get_card_faces(c)
		
		if customw
			sz = size(faces[end])
			faces = imresize.(faces, ceil(Int, card_width * sz[1]/sz[2]), card_width)
		else
			faces = imresize.(faces, ratio=card_ratio)
		end
		
		push!(CARD_FACES, c["name"] => faces)
		sleep(0.1)
	end
end

# ╔═╡ 3a17fc4c-5f69-11eb-29a1-c9bb584fee32
if @isdefined CARD_FACES
	CARD_FACES[i][end][end]
end

# ╔═╡ d654ad1e-468a-11eb-2348-695621b7b9b0
function search_mtg_cards_by_keyword(q::String, mtg_cards::Array)
	[ n for n in [ c["name"] for c in mtg_cards ] if occursin(q, n) ]
end

# ╔═╡ cec924ac-50c7-11eb-3795-85b3c183a8eb
search_mtg_cards_by_keyword("Jwari", mtg_cards)

# ╔═╡ 7cbdfda6-5eb5-11eb-2be6-0f93c3374a47
function hbox(x, y, gap=16; sy=size(y), sx=size(x))
	w,h = (max(sx[1], sy[1]),
		   gap + sx[2] + sy[2])
	
	slate = fill(RGB(1,1,1), w,h)
	slate[1:size(x,1), 1:size(x,2)] .= RGB.(x)
	slate[1:size(y,1), size(x,2) + gap .+ (1:size(y,2))] .= RGB.(y)
	slate
end

# ╔═╡ 5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
begin
	CARD_BACK_PATH = "$(projectdir())/games/MtG/MtG.jl/ui/cards/card_back.png"
	CARD_BACK_IMG = imresize(load(CARD_BACK_PATH), ratio=card_ratio)
	
	hbox(CARD_BACK_IMG, CARD_BACK_IMG)
end

# ╔═╡ 5e6f7046-4da5-11eb-0122-bd82397aab4f
if save_data
	deck[:CARD_BACK_IMG] = CARD_BACK_IMG
	deck[:CARD_FACES] = CARD_FACES

	fn = "$(projectdir())/games/MtG/EDH/decks/$(deck[:name])/$(deck[:name]).jls"
	serialize(fn, deck)
	
	md"Deck data saved to $fn"
end

# ╔═╡ 85103516-5eb5-11eb-3abc-dfc9ae9caf96
vbox(x,y, gap=16) = hbox(x', y')'

# ╔═╡ Cell order:
# ╟─c7952ee6-45b5-11eb-1158-5bb2ff274ce9
# ╟─0c145632-3927-11eb-19b9-877e05c1bcdc
# ╠═cec924ac-50c7-11eb-3795-85b3c183a8eb
# ╟─621b08a4-384e-11eb-0109-61e9b9ecf125
# ╟─fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
# ╠═5f7ebd78-3db7-11eb-0690-1b8ee4ebe7db
# ╟─c61fa79e-4583-11eb-3b71-2d334aca843d
# ╟─7420cf10-45cc-11eb-2780-4f320bd8a2cf
# ╟─c31dd202-50c6-11eb-0631-13c70535635e
# ╟─c5374766-4ef1-11eb-2555-c159dba953f0
# ╟─73d1cd18-4647-11eb-3994-7d4eb92eddca
# ╟─0899b1d0-5972-11eb-0470-4d480cf95d53
# ╟─3a17fc4c-5f69-11eb-29a1-c9bb584fee32
# ╟─dfc9b56e-50ce-11eb-0e7f-83ec6e831901
# ╟─be2af776-5971-11eb-13ec-3d7982a01ea3
# ╟─5e6f7046-4da5-11eb-0122-bd82397aab4f
# ╟─43cdcbdc-5f68-11eb-11bd-51fbbf610333
# ╟─ce216c54-468a-11eb-13b8-7f3dac7af44a
# ╟─2ab53d00-50cd-11eb-1cd4-5bf94ce53692
# ╟─97bc3768-50ce-11eb-3f74-95d4fefe3792
# ╟─d654ad1e-468a-11eb-2348-695621b7b9b0
# ╟─7cbdfda6-5eb5-11eb-2be6-0f93c3374a47
# ╟─85103516-5eb5-11eb-3abc-dfc9ae9caf96
