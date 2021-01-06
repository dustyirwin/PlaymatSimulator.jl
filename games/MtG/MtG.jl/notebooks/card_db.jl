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

# ╔═╡ d069eed0-4fa1-11eb-3dc7-b533e91cdd83
using DrWatson

# ╔═╡ dc35a05c-3907-11eb-27ee-35fa47c0d2f3
begin
	@quickactivate
	
	using GZ2
	using HTTP
	using JSON
	using Plots
	using Images
	using PlutoUI
	
	plotly()
	
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
	
	function get_card_img(img_uri::String)
		img_resp = HTTP.get(img_uri)
		card_img = img_resp.body |> IOBuffer |> load
	end
	
	JSON_DIR = "$(projectdir())/games/MtG/MtG.jl/json"
	DATA_FILES = readdir(JSON_DIR)
	DATA_FILE = DATA_FILES[end]
	CARD_DATA = JSON.parsefile("$JSON_DIR/$DATA_FILE")
	
	md"""
	## MtG Database

	Import / define common card properties
	"""
end

# ╔═╡ 3ba3f3fa-3eb6-11eb-0521-0736dc692258
CREATURES = [ c for c in CARD_DATA if haskey(c, "type_line") && occursin("Creature", c["type_line"]) ]

# ╔═╡ 03b2e1e0-3ebb-11eb-320e-45a1bb06baaa
length(CREATURES)

# ╔═╡ 5ee2ef20-4fcc-11eb-0f00-47f0c1f708b8
k = "type_line"

# ╔═╡ ff6ad0e4-3eb9-11eb-13a2-8d558b83f605
res = ([ c for c in CREATURES if haskey(c,k) && occursin("bird", lowercase(c[k])) ])

# ╔═╡ 455f9bc8-4fd0-11eb-05e9-f93f7f1b1d55
@bind i Slider(1:length(res), show_value=true)

# ╔═╡ 99da634e-4fc5-11eb-37e8-a7cefb18bbe2
C = res[i]

# ╔═╡ 020e45b2-4fc3-11eb-1830-fdc88af88183
sort([keys(C)...])

# ╔═╡ 964caa22-4fc3-11eb-2793-d9a6fd4a5467
try
	get_card_img(C["image_uris"]["border_crop"])
catch
	f = get_card_img(C["card_faces"][1]["image_uris"]["border_crop"])
	r = get_card_img(C["card_faces"][2]["image_uris"]["border_crop"])
	b = vcat(f,r)
end

# ╔═╡ e26a05fc-4fd0-11eb-0865-e5ed03832806
plot([ c["cmc"] for c in res ], ylabel="CMC", xlabel="index")

# ╔═╡ 2e6b3562-4fd0-11eb-0d53-c7f4ac8e6082
length(res)

# ╔═╡ 61295c8e-4fce-11eb-0f8a-3f56656381c1
CARD_DATA;

# ╔═╡ Cell order:
# ╟─d069eed0-4fa1-11eb-3dc7-b533e91cdd83
# ╟─dc35a05c-3907-11eb-27ee-35fa47c0d2f3
# ╠═3ba3f3fa-3eb6-11eb-0521-0736dc692258
# ╠═03b2e1e0-3ebb-11eb-320e-45a1bb06baaa
# ╠═020e45b2-4fc3-11eb-1830-fdc88af88183
# ╟─964caa22-4fc3-11eb-2793-d9a6fd4a5467
# ╠═99da634e-4fc5-11eb-37e8-a7cefb18bbe2
# ╠═455f9bc8-4fd0-11eb-05e9-f93f7f1b1d55
# ╠═5ee2ef20-4fcc-11eb-0f00-47f0c1f708b8
# ╠═ff6ad0e4-3eb9-11eb-13a2-8d558b83f605
# ╠═e26a05fc-4fd0-11eb-0865-e5ed03832806
# ╠═2e6b3562-4fd0-11eb-0d53-c7f4ac8e6082
# ╟─61295c8e-4fce-11eb-0f8a-3f56656381c1
