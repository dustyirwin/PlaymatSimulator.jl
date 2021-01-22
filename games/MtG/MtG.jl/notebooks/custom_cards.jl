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

# ╔═╡ f313719e-56c1-11eb-0151-7fdc92bc5635
using DrWatson

# ╔═╡ 5d891788-56c2-11eb-1723-8361ac5bd415
begin
	@quickactivate

	using Images
	using PlutoUI
	using Serialization
	using ImageTransformations

	DECK_DIR = "$(projectdir())/games/MtG/EDH/decks/Vannifar's Circus"
	
	md"""
	### Vannifar's Circus Custom Cards
	"""
end

# ╔═╡ 8a3f6140-56c4-11eb-1cea-ff327a21d57b
deck = deserialize("$DECK_DIR/Vannifar's Circus.jls")

# ╔═╡ 0152ba30-5ba1-11eb-013e-8dc5191b3c17
md"""
## Custom PNGs, JPGs, etc.!
"""

# ╔═╡ 2f5a332c-56c4-11eb-259b-8b7d51af1b04
custom_card_faces = [ fn => load("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if !occursin(split(fn,".")[begin], join(deck[:commander_names])) && (occursin("png", fn) || occursin("gif", fn))  ];

# ╔═╡ a32c9308-5985-11eb-1f52-553017217312
card_names = [ k for (k,v) in custom_card_faces if occursin(split(k ,".")[begin], join(deck[:card_names])) ];

# ╔═╡ 35174776-598c-11eb-3894-37809424115b
card_imgs = [ v for (k,v) in custom_card_faces if occursin(split(k,".")[begin], join(deck[:card_names])) ];

# ╔═╡ 70971440-5985-11eb-3d51-cdedac799904
md"""
card img index: $(@bind card_index Slider(1:length(card_imgs), show_value=true))
"""

# ╔═╡ 08063488-5973-11eb-0fcd-97b6d199dd11
card_face_info = [ [v,k,i,size(v[begin])] for (i,(k,v)) in enumerate(deck[:CARD_FACE_IMGS]) if occursin(k, card_names[card_index]) ][begin]

# ╔═╡ 77ce8398-5989-11eb-2d3c-d3d0957ae270
md"""
"Replace card face with custom png / gif?" $(@bind swap_card_face CheckBox())
"""

# ╔═╡ e010eb3a-597a-11eb-19da-01375b1d8367
if swap_card_face
	deck[:CARD_FACE_IMGS][ card_face_info[3] ] = card_names[card_index] => [ imresize(card_imgs[card_index], size(card_face_info[1][1])) ]
end

# ╔═╡ 7d1f5e08-5ba0-11eb-008c-87a8474352cd
commanders = [ fn => load("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin(split(fn,".")[begin], join(deck[:commander_names])) && (occursin("png", fn) || occursin("jpg", fn))  ]

# ╔═╡ bfbacc0c-5ba0-11eb-01d9-71825cfc5c59
commander_imgs = [ v for (k,v) in commanders if occursin(split(k,".")[begin], join(deck[:commander_names])) ]

# ╔═╡ 5a42f3ac-5b81-11eb-14e1-e18f037da064
commander_face_info = [ [v,k,i,size(v[begin])] for (i,(k,v)) in enumerate(deck[:COMMANDER_FACE_IMGS]) if occursin(k, join(deck[:commander_names])) ][begin]

# ╔═╡ 0fd7c2f8-5a13-11eb-11b7-8fa222ab3ccd
md"""
commander img index: $(@bind commander_index Slider(1:length(commander_imgs), show_value=true))
"""

# ╔═╡ 402739bc-5ac9-11eb-004a-47068d7520da
md"""
"Replace commander face with custom png?" $(@bind swap_commander_face CheckBox())
"""

# ╔═╡ 17a17ed0-5a15-11eb-199b-45bcc809d56c
if swap_commander_face
	deck[:COMMANDER_FACE_IMGS][ commander_face_info[3] ] = deck[:commander_names][commander_index] => [ imresize(commander_imgs[commander_index], size(commander_face_info[1][1])) ]
end

# ╔═╡ cd27bfd0-5ba0-11eb-0bd4-559470d3907a
md"""
### Custom GIFs!
"""

# ╔═╡ 437c0424-56c5-11eb-29ce-7f0090186512
custom_gifs = [ fn=>LocalResource("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin("gif", fn) ];

# ╔═╡ 2d187afa-598b-11eb-1dec-7b3c22ea634d
md"""
custom gif index: $(@bind gif_index Slider(1:length(custom_gifs), show_value=true))
"""

# ╔═╡ dfa2d2e8-598a-11eb-2e3a-5f9c457e5cae
custom_gif_names = [ k for (k,v) in custom_gifs ];

# ╔═╡ 74abf0a2-5802-11eb-3bcf-79a66eabe3e5
custom_gifs[gif_index]

# ╔═╡ 3c25d5f2-5ba1-11eb-0229-0fbfc8dbbf44
md"""
save custom card face data? $(@bind save_data CheckBox())
"""

# ╔═╡ 72de84ba-598d-11eb-139d-975970c19cc0
if save_data
	serialize("$DECK_DIR/Vannifar's Circus.jls", deck)
end

# ╔═╡ Cell order:
# ╟─f313719e-56c1-11eb-0151-7fdc92bc5635
# ╟─5d891788-56c2-11eb-1723-8361ac5bd415
# ╟─8a3f6140-56c4-11eb-1cea-ff327a21d57b
# ╟─0152ba30-5ba1-11eb-013e-8dc5191b3c17
# ╠═2f5a332c-56c4-11eb-259b-8b7d51af1b04
# ╠═a32c9308-5985-11eb-1f52-553017217312
# ╠═35174776-598c-11eb-3894-37809424115b
# ╟─08063488-5973-11eb-0fcd-97b6d199dd11
# ╟─70971440-5985-11eb-3d51-cdedac799904
# ╠═77ce8398-5989-11eb-2d3c-d3d0957ae270
# ╟─e010eb3a-597a-11eb-19da-01375b1d8367
# ╟─7d1f5e08-5ba0-11eb-008c-87a8474352cd
# ╟─bfbacc0c-5ba0-11eb-01d9-71825cfc5c59
# ╟─17a17ed0-5a15-11eb-199b-45bcc809d56c
# ╟─5a42f3ac-5b81-11eb-14e1-e18f037da064
# ╟─0fd7c2f8-5a13-11eb-11b7-8fa222ab3ccd
# ╟─402739bc-5ac9-11eb-004a-47068d7520da
# ╟─cd27bfd0-5ba0-11eb-0bd4-559470d3907a
# ╟─2d187afa-598b-11eb-1dec-7b3c22ea634d
# ╟─437c0424-56c5-11eb-29ce-7f0090186512
# ╟─dfa2d2e8-598a-11eb-2e3a-5f9c457e5cae
# ╠═74abf0a2-5802-11eb-3bcf-79a66eabe3e5
# ╟─3c25d5f2-5ba1-11eb-0229-0fbfc8dbbf44
# ╠═72de84ba-598d-11eb-139d-975970c19cc0
