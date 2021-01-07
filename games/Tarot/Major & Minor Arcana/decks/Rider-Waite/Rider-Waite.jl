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
	using DataStructures
	using ImageTransformations: imresize
	
	plotly()
	
	md"""
	*game settings loaded!*
	
	## Rider-Waite Tarot Deck
	"""
end

# ╔═╡ 621b08a4-384e-11eb-0109-61e9b9ecf125
deck = Dict{Symbol,Any}(
	:name => "Rider-Waite",
	:cards => OrderedDict{String, String}(
		"backside" => "http://blogimg.goo.ne.jp/user_image/07/b1/6ebb2d3d2427526a2e5b1318a56c1b70.jpg",
		"The Hanged Man" => "https://i.imgur.com/KNiZDJ0.png",
		"The Fool" => "http://blogimg.goo.ne.jp/user_image/7c/98/6cf5c9e139a36cb06a5cdd5a7505afde.jpg",
		"The Magician" => "http://blogimg.goo.ne.jp/user_image/77/cb/481628b008f6379a765139553c4db783.jpg",
		"The High Priestess" => "http://blogimg.goo.ne.jp/user_image/46/fc/2cf480c9bfd704f816b73911a620f44c.jpg",
	)	
)

# ╔═╡ fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
md"""
Found $(length(deck[:cards])) cards in $(deck[:name])!
"""

# ╔═╡ 1839b1f4-5020-11eb-0905-61ab4d615e87
@bind i Slider(1:length(deck[:cards]), show_value=true)

# ╔═╡ c5374766-4ef1-11eb-2555-c159dba953f0
md"""
##### *Adjust this slider to shrink / grow the cards while preserving the aspect ratio*

$(@bind ratio Slider(0.1:0.05:1, default=0.5, show_value=true))
"""

# ╔═╡ 614764b8-4648-11eb-0493-732a00df7bca
md"""
#### Look good? These images will be displayed in-game.
TODO: write support for previews of double-sided cards
"""

# ╔═╡ 4e2ebff0-4d7a-11eb-30e1-33800c54c2c6
html"""<br><br><br><br><br><br>"""

# ╔═╡ ce216c54-468a-11eb-13b8-7f3dac7af44a
function get_card_img(img_uri::String)
	img_resp = HTTP.get(img_uri)
	card_img = img_resp.body |> IOBuffer |> load
end

# ╔═╡ 73d1cd18-4647-11eb-3994-7d4eb92eddca
deck_card_img = imresize(get_card_img([ values(deck[:cards])...][i]), ratio=ratio)

# ╔═╡ d654ad1e-468a-11eb-2348-695621b7b9b0
function search_cards_by_keyword(q::String, mtg_cards::Array)
	[ n for n in [ c["name"] for c in mtg_cards ] if occursin(q, n) ]
end

# ╔═╡ 5e6f7046-4da5-11eb-0122-bd82397aab4f
begin
	deck[:CARD_IMG_RATIO] = ratio
	deck[:CARD_IMGS] = [ ARGB.(imresize(get_card_img(c), ratio=ratio)) for c in values(deck[:cards]) ]
	#serialize("$(deck[:name]).jls", deck)
	
	#deserialize("$(projectdir())/games/Tarot/Tarot/decks/$(deck[:name])/$(deck[:name]).jls")
end

# ╔═╡ Cell order:
# ╟─c7952ee6-45b5-11eb-1158-5bb2ff274ce9
# ╟─0c145632-3927-11eb-19b9-877e05c1bcdc
# ╟─621b08a4-384e-11eb-0109-61e9b9ecf125
# ╟─fb61d01c-458d-11eb-2c2a-f711dc7ab7f4
# ╠═73d1cd18-4647-11eb-3994-7d4eb92eddca
# ╠═1839b1f4-5020-11eb-0905-61ab4d615e87
# ╠═c5374766-4ef1-11eb-2555-c159dba953f0
# ╟─614764b8-4648-11eb-0493-732a00df7bca
# ╟─4e2ebff0-4d7a-11eb-30e1-33800c54c2c6
# ╟─ce216c54-468a-11eb-13b8-7f3dac7af44a
# ╟─d654ad1e-468a-11eb-2348-695621b7b9b0
# ╟─5e6f7046-4da5-11eb-0122-bd82397aab4f
