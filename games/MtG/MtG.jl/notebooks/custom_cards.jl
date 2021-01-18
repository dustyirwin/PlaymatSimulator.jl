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

# ╔═╡ 77ce8398-5989-11eb-2d3c-d3d0957ae270
md"""
"Replace face with custom png?" $(@bind swap_face CheckBox())
"""

# ╔═╡ 2f5a332c-56c4-11eb-259b-8b7d51af1b04
custom_pngs = [ fn=>load("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin("png", fn) ]

# ╔═╡ 70971440-5985-11eb-3d51-cdedac799904
md"""
custom png index: $(@bind custom_png_index Slider(1:length(custom_pngs), show_value=true))
"""

# ╔═╡ a32c9308-5985-11eb-1f52-553017217312
custom_png_names = [ k for (k,v) in custom_pngs ]

# ╔═╡ 08063488-5973-11eb-0fcd-97b6d199dd11
deck_card_info = [ [v,k,i,size(v[begin])] for (i,(k,v)) in enumerate(deck[:CARD_FACE_IMGS]) if occursin(k, custom_png_names[ custom_png_index ]) ][begin]

# ╔═╡ 35174776-598c-11eb-3894-37809424115b
custom_png_imgs = [ imresize(v, size(deck_card_info[1][1])) for (k,v) in custom_pngs ]

# ╔═╡ e010eb3a-597a-11eb-19da-01375b1d8367
if swap_face
	deck[:CARD_FACE_IMGS][ deck_card_info[3] ] = custom_png_names[custom_png_index] => [ custom_png_imgs[custom_png_index] ]
end

# ╔═╡ 437c0424-56c5-11eb-29ce-7f0090186512
custom_gifs = [ fn=>LocalResource("$DECK_DIR/custom_images/$fn") for fn in readdir("$DECK_DIR/custom_images") if occursin("gif", fn) ]

# ╔═╡ 2d187afa-598b-11eb-1dec-7b3c22ea634d
md"""
custom gif index: $(@bind custom_gif_index Slider(1:length(custom_gifs), show_value=true))
"""

# ╔═╡ dfa2d2e8-598a-11eb-2e3a-5f9c457e5cae
custom_gif_names = [ k for (k,v) in custom_gifs ]

# ╔═╡ 74abf0a2-5802-11eb-3bcf-79a66eabe3e5
custom_gifs[1]

# ╔═╡ 72de84ba-598d-11eb-139d-975970c19cc0
serialize("$DECK_DIR/Vannifar's Circus.jls", deck)

# ╔═╡ b7601e20-588f-11eb-3bc0-17e1d1b00984
dice_gifs = [ LocalResource("$(projectdir())/games/MtG/MtG.jl/ui/dice/$fn") for fn in readdir("$(projectdir())/games/MtG/MtG.jl/ui/dice") if occursin("gif", fn) ]

# ╔═╡ ffd7435e-588f-11eb-31fd-392884e81292
counter_gifs = [ LocalResource("$(projectdir())/games/MtG/MtG.jl/ui/counters/$fn") for fn in readdir("$(projectdir())/games/MtG/MtG.jl/ui/counters") if occursin("gif", fn) ]

# ╔═╡ 4f7bf6da-596d-11eb-1b25-27d4fa0d8566
function carve_card()
end

# ╔═╡ d4e484ce-5970-11eb-00ff-c159e6942b1a
function remove_in_each_row_views(img, column_numbers)
	@assert size(img, 1) == length(column_numbers)
	m, n = size(img)
	local img′ = similar(img, m, n-1)

	for (i, j) in enumerate(column_numbers)
		img′[i, 1:j-1] .= @view img[i, 1:j-1]
		img′[i, j:end] .= @view img[i, j+1:end]
	end
	
	img′
end

# ╔═╡ 70015780-5970-11eb-09c6-b52abe8a5a15
function shrink_n(img, n, min_seam, imgs=[]; show_lightning=true)
	n==0 && return push!(imgs, img)

	e = energy(img)
	
	seam_energy(seam) = sum(e[i, seam[i]]  for i in 1:size(img, 1))
	_, min_j = findmin(map(j->seam_energy(min_seam(e, j)), 1:size(e, 2)))
	min_seam_vec = min_seam(e, min_j)
	img′ = remove_in_each_row_views(img, min_seam_vec)
	
	if show_lightning
		push!(imgs, mark_path(img, min_seam_vec))
	else
		push!(imgs, img′)
	end
	shrink_n(img′, n-1, min_seam, imgs)
end

# ╔═╡ 861ccb6c-5970-11eb-0550-ad5098aa5670
function greedy_seam(energies, starting_pixel::Int)
	is = [ starting_pixel ]
	m, n = size(energies)
	
	for k in 2:m
		es = energies[k, clamp(is[end]-1,1,n):clamp(is[end]+1,1,n)]
		push!(is, clamp(last(is) + argmin(es) - clamp(last(is),0,2), 1, n))
	end
	
	return is
end

# ╔═╡ Cell order:
# ╟─f313719e-56c1-11eb-0151-7fdc92bc5635
# ╟─5d891788-56c2-11eb-1723-8361ac5bd415
# ╠═8a3f6140-56c4-11eb-1cea-ff327a21d57b
# ╠═08063488-5973-11eb-0fcd-97b6d199dd11
# ╠═e010eb3a-597a-11eb-19da-01375b1d8367
# ╟─70971440-5985-11eb-3d51-cdedac799904
# ╟─77ce8398-5989-11eb-2d3c-d3d0957ae270
# ╟─a32c9308-5985-11eb-1f52-553017217312
# ╠═35174776-598c-11eb-3894-37809424115b
# ╟─2f5a332c-56c4-11eb-259b-8b7d51af1b04
# ╟─2d187afa-598b-11eb-1dec-7b3c22ea634d
# ╟─437c0424-56c5-11eb-29ce-7f0090186512
# ╟─dfa2d2e8-598a-11eb-2e3a-5f9c457e5cae
# ╠═74abf0a2-5802-11eb-3bcf-79a66eabe3e5
# ╠═72de84ba-598d-11eb-139d-975970c19cc0
# ╟─b7601e20-588f-11eb-3bc0-17e1d1b00984
# ╟─ffd7435e-588f-11eb-31fd-392884e81292
# ╟─4f7bf6da-596d-11eb-1b25-27d4fa0d8566
# ╟─d4e484ce-5970-11eb-00ff-c159e6942b1a
# ╟─70015780-5970-11eb-09c6-b52abe8a5a15
# ╟─861ccb6c-5970-11eb-0550-ad5098aa5670
