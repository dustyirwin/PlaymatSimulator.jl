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

# ╔═╡ bf40c8ca-5c8c-11eb-2e48-7b906e8e6c5e
using DrWatson

# ╔═╡ 1ef22dae-5c88-11eb-1276-231730d144f6
begin
	@quickactivate

	using Images
	using Random
	using PlutoUI
	using Statistics
	using Rotations
	using Serialization
	
	deck_dir = "$(projectdir())/games/MtG/EDH/decks/Vannifar's Circus"
	deck = deserialize("$deck_dir/Vannifar's Circus.jls")
	custom_imgs_dir = "$(projectdir())/games/MtG/EDH/decks/Vannifar's Circus/custom_images/"
	custom_img_names = [ fn for fn in readdir(custom_imgs_dir) if occursin("png", fn) ]
	
	md"""
## Carve custom faces for $(deck[:name])!
	"""
end

# ╔═╡ b978978c-5ee0-11eb-1443-33825d99e295
md"""
#### $(@bind carve_custom_card CheckBox()) Carve cards in custom images dir $(@bind custom_img_select Slider(1:length(custom_img_names), show_value=true))
"""

# ╔═╡ 39f36f30-5d75-11eb-137f-53e5fcb95134
begin
	custom_img = load("$custom_imgs_dir/$(custom_img_names[custom_img_select])")

	md"""
	Custom cards in $deck_dir
	"""
end

# ╔═╡ c4bb34e4-5ede-11eb-0871-e16410f0c048
if carve_custom_card
	md"""Shrink custom card $(@bind custom_img_ratio Slider(0:0.01:1, default=0.5, show_value=true)) by percentage or $(@bind specify_custom_size CheckBox(default=true)) specify card width $(@bind custom_width NumberField(200:10:300, default=270))"""
end

# ╔═╡ b92971e6-5d70-11eb-1713-7327a0bca668
md"""
#### $(@bind carve_deck_card CheckBox()) Carve cards in deck $(@bind deck_img_select Slider(1:length(deck[:CARD_FACES]), show_value=true)) 
"""

# ╔═╡ 501cb384-5d73-11eb-20cb-d3b96fc930d0
imgs = carve_deck_card ? [deck_img] : [custom_img];

# ╔═╡ 4c43b0ba-5ed7-11eb-3fa3-7d9b1ba5e434
if carve_custom_card
	card_ratio = height(custom_img) / width(custom_img)
	imgs[end] = specify_custom_size ? imresize(custom_img, ceil(Int, custom_width * card_ratio), custom_width) : imresize(custom_img, ratio=custom_img_ratio)
end

# ╔═╡ 6ff626d4-5d72-11eb-110e-49b0464e95a7
if carve_deck_card
	deck_imgs = deck[:CARD_FACES][deck_img_select][end]
	deck_imgs[end]
end

# ╔═╡ 4ecd1258-5d11-11eb-1b53-71740a55b68d
md"""
##### Vertically shrink image up to : $(@bind vert_shrink_by NumberField(0:200, default=100)) pixels $(@bind shrink_greedy_v CheckBox())
"""

# ╔═╡ 72c7f7b6-5c8e-11eb-26a8-61e826cea075
md"""
##### Horizontally shrink image up to : $(@bind hor_shrink_by NumberField(0:40, default=20)) pixels $(@bind shrink_greedy_h CheckBox())
"""

# ╔═╡ 4a156ba2-5d1b-11eb-07a5-730b3f65033f
md"""
#####  Export img? $(@bind export_img CheckBox())
"""

# ╔═╡ 148ab572-5d15-11eb-2a54-89eaf1d95ca4
if export_img
	save("$deck_dir/mini$(randstring(5)).png", imgs[end])
	if carve_deck_card
		deck[:CARD_FACES][deck_img_select] = deck[:CARD_FACES][deck_img_select][begin] => [ imgs[end] ]
	end
end

# ╔═╡ 2c06e12e-5d7d-11eb-0da4-c71de86166e8
if export_img
	serialize("$deck_dir/Vannifar's Circus.jls", deck)
end

# ╔═╡ 26ba7e48-5ecb-11eb-22f1-b5013af4ec24
md"""
Custom functions
"""

# ╔═╡ deffb654-5c8d-11eb-3138-a5c7634793bc
begin
	brightness(c::RGB) = mean((c.r, c.g, c.b))
	brightness(c::RGBA) = mean((c.r, c.g, c.b))
end

# ╔═╡ e5dad786-5c8d-11eb-1da6-e5fd55842485
convolve(img, k) = imfilter(img, reflect(k))

# ╔═╡ f334877c-5ce4-11eb-1d51-83452cede3d8
energy(∇x, ∇y) = sqrt.(∇x.^2 .+ ∇y.^2)

# ╔═╡ ed9f0b4c-5c8d-11eb-0bda-4d2fe4942325
function energy(img)
	∇y = convolve(brightness.(img), Kernel.sobel()[1])
	∇x = convolve(brightness.(img), Kernel.sobel()[2])
	energy(∇x, ∇y)
end

# ╔═╡ 88d7b806-5c88-11eb-220a-9bae6e26693b
function mark_path(img, path)
	img′ = copy(img)
	m = size(img, 2)
	for (i, j) in enumerate(path)
		for j′ in j-1:j+1
			img′[i, clamp(j′, 1, m)] = RGB(1,0,1)
		end
	end
	img′
end

# ╔═╡ 93f5643a-5ba3-11eb-3bfa-3f1e453ec23b
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

# ╔═╡ a1b7250c-5ba3-11eb-0e28-2b8e62c2007a
function shrink_n(img, n, min_seam, imgs=[]; show_lightning=false)
	n==0 && return push!(imgs, img)
	e = energy(img)

	seam_energy(seam) = sum(e[i, seam[i]] for i in 1:size(img, 1))
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

# ╔═╡ 26500512-5d00-11eb-37a8-458570a946fd
function shrink!(img, min_seam, cols=true)
	img = cols ? img : rotr90(img)
	e = energy(img)
	
	seam_energy(seam) = sum(e[i, seam[i]] for i in 1:size(img, 1))
	_, min_j = findmin(map(j->seam_energy(min_seam(e, j)), 1:size(e, 2)))
	min_seam_vec = min_seam(e, min_j)
	
	img = remove_in_each_row_views(img, min_seam_vec)
	img = cols ? img : rotl90(img)
	
	return img
end

# ╔═╡ a7b310bc-5ba3-11eb-38e5-3d025712d57e
function greedy_seam(energies, starting_pixel::Int)
	is = [ starting_pixel ]
	m, n = size(energies)

	for k in 2:m
		es = energies[k, clamp(is[end]-1,1,n):clamp(is[end]+1,1,n)]
		push!(is, clamp(is[end] + argmin(es) - clamp(is[end],0,2), 1, n))
	end

	return is
end

# ╔═╡ d1dd1162-5d10-11eb-3d7f-8f10be30efa7
if shrink_greedy_v
	greedy_carved_v = shrink_n(rotr90(imgs[end]), vert_shrink_by, greedy_seam, show_lightning=false)
	md"""Shrink by: $(@bind greedy_v Slider(1:vert_shrink_by, show_value=true)) Save changes to img? $(@bind save_v CheckBox())"""
end

# ╔═╡ 38bc0512-5ee4-11eb-1576-1fac86b5e112
if shrink_greedy_v
	size(rotl90(greedy_carved_v[greedy_v]))
end

# ╔═╡ e061aca2-5d12-11eb-3661-59430c9f0ce4
if shrink_greedy_v && (@isdefined greedy_carved_v)
	rotl90(greedy_carved_v[greedy_v])
end

# ╔═╡ 0d2b79d4-5d13-11eb-03c5-f90edc2114e0
if (@isdefined save_v) && save_v
	imgs[end] = deepcopy(rotl90(greedy_carved_v[greedy_v]))
	"Changes saved!"
end

# ╔═╡ 3fe076c8-5c8e-11eb-3222-ad52ddd23256
if shrink_greedy_h
	greedy_carved_h = shrink_n(imgs[end], hor_shrink_by, greedy_seam, show_lightning=false)
	
	md"""
	Shrink by: $(@bind greedy_h Slider(1:hor_shrink_by, show_value=true))
	Save changes to img? $(@bind save_h CheckBox())
	"""
end

# ╔═╡ e1c05af0-5ee4-11eb-153f-af5abf6bd5a9
if shrink_greedy_h
	size(greedy_carved_h[greedy_h])
end

# ╔═╡ a3c7f5f8-5c8e-11eb-3807-290228dc3ea8
if shrink_greedy_h && (@isdefined greedy_carved_h)
	greedy_carved_h[greedy_h]
end

# ╔═╡ b4d3252a-5d10-11eb-16c2-1330d81f5f7c
if (@isdefined save_h) && save_h
	imgs[end]=deepcopy(greedy_carved_h[greedy_h])
	"Changes saved!"
end

# ╔═╡ Cell order:
# ╟─bf40c8ca-5c8c-11eb-2e48-7b906e8e6c5e
# ╟─1ef22dae-5c88-11eb-1276-231730d144f6
# ╟─501cb384-5d73-11eb-20cb-d3b96fc930d0
# ╟─39f36f30-5d75-11eb-137f-53e5fcb95134
# ╟─b978978c-5ee0-11eb-1443-33825d99e295
# ╟─c4bb34e4-5ede-11eb-0871-e16410f0c048
# ╟─4c43b0ba-5ed7-11eb-3fa3-7d9b1ba5e434
# ╟─b92971e6-5d70-11eb-1713-7327a0bca668
# ╟─6ff626d4-5d72-11eb-110e-49b0464e95a7
# ╟─4ecd1258-5d11-11eb-1b53-71740a55b68d
# ╟─38bc0512-5ee4-11eb-1576-1fac86b5e112
# ╟─d1dd1162-5d10-11eb-3d7f-8f10be30efa7
# ╟─e061aca2-5d12-11eb-3661-59430c9f0ce4
# ╟─0d2b79d4-5d13-11eb-03c5-f90edc2114e0
# ╟─72c7f7b6-5c8e-11eb-26a8-61e826cea075
# ╟─3fe076c8-5c8e-11eb-3222-ad52ddd23256
# ╟─e1c05af0-5ee4-11eb-153f-af5abf6bd5a9
# ╟─a3c7f5f8-5c8e-11eb-3807-290228dc3ea8
# ╟─b4d3252a-5d10-11eb-16c2-1330d81f5f7c
# ╟─4a156ba2-5d1b-11eb-07a5-730b3f65033f
# ╟─148ab572-5d15-11eb-2a54-89eaf1d95ca4
# ╟─2c06e12e-5d7d-11eb-0da4-c71de86166e8
# ╟─26ba7e48-5ecb-11eb-22f1-b5013af4ec24
# ╟─deffb654-5c8d-11eb-3138-a5c7634793bc
# ╟─e5dad786-5c8d-11eb-1da6-e5fd55842485
# ╟─f334877c-5ce4-11eb-1d51-83452cede3d8
# ╟─ed9f0b4c-5c8d-11eb-0bda-4d2fe4942325
# ╟─88d7b806-5c88-11eb-220a-9bae6e26693b
# ╟─93f5643a-5ba3-11eb-3bfa-3f1e453ec23b
# ╟─a1b7250c-5ba3-11eb-0e28-2b8e62c2007a
# ╟─26500512-5d00-11eb-37a8-458570a946fd
# ╟─a7b310bc-5ba3-11eb-38e5-3d025712d57e
