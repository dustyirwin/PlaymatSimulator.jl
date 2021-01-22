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
	using PlutoUI
	using Statistics
	using ImageFiltering
	using ImageTransformations
	using ShiftedArrays
	using Rotations
end

# ╔═╡ 655ffa72-5cf2-11eb-36f7-07fa9ef7ebd3
imgo = imresize(load("$(projectdir())/games/Tarot/Tarot/decks/Rider-Waite/images/Major/The Hanged Man XII.png"), ratio=0.5)

# ╔═╡ a8b0e9ba-5cf9-11eb-2cdd-9141805b666c
imgr = rotr90(imgo);

# ╔═╡ 72c7f7b6-5c8e-11eb-26a8-61e826cea075
md"Compute shrunk image: $(@bind shrink_greedy CheckBox())"

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
		# To make it easier to see, we'll color not just
		# the pixels of the seam, but also those adjacent to it
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

# ╔═╡ 3fe076c8-5c8e-11eb-3222-ad52ddd23256
if shrink_greedy
	greedy_carved = shrink_n(imgr, 200, greedy_seam, show_lightning=false)
	md"Shrink by: $(@bind greedy_n Slider(1:200; show_value=true))"
end

# ╔═╡ a3c7f5f8-5c8e-11eb-3807-290228dc3ea8
if shrink_greedy
	rotl90(greedy_carved[greedy_n])
end

# ╔═╡ Cell order:
# ╟─bf40c8ca-5c8c-11eb-2e48-7b906e8e6c5e
# ╟─1ef22dae-5c88-11eb-1276-231730d144f6
# ╟─655ffa72-5cf2-11eb-36f7-07fa9ef7ebd3
# ╟─a8b0e9ba-5cf9-11eb-2cdd-9141805b666c
# ╟─72c7f7b6-5c8e-11eb-26a8-61e826cea075
# ╠═3fe076c8-5c8e-11eb-3222-ad52ddd23256
# ╟─a3c7f5f8-5c8e-11eb-3807-290228dc3ea8
# ╟─deffb654-5c8d-11eb-3138-a5c7634793bc
# ╟─e5dad786-5c8d-11eb-1da6-e5fd55842485
# ╟─f334877c-5ce4-11eb-1d51-83452cede3d8
# ╟─ed9f0b4c-5c8d-11eb-0bda-4d2fe4942325
# ╟─88d7b806-5c88-11eb-220a-9bae6e26693b
# ╟─93f5643a-5ba3-11eb-3bfa-3f1e453ec23b
# ╠═a1b7250c-5ba3-11eb-0e28-2b8e62c2007a
# ╟─a7b310bc-5ba3-11eb-38e5-3d025712d57e
