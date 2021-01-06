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

# ╔═╡ 67d98a4a-4da0-11eb-3ff8-db5e68b54f8d
using DrWatson

# ╔═╡ c656c348-3852-11eb-2806-0df5baa0d2e1
begin
	@quickactivate
	
	using Colors
	using PlutoUI
	using Images

	md"""
	## BASIC MtG GAME SETTINGS
	
	#### Edit the elements below to modify basic game options.
	"""
end


# ╔═╡ 52c3d32e-4e2f-11eb-20f7-4d61ff865e75
mtg_dir = "$(projectdir())/games/MtG"

# ╔═╡ 3ffcf8a4-385b-11eb-25da-fd9bfc189e06
md"""
`SCREEN_WIDTH`:
$(SCREEN_WIDTH = Int32( 1920 )) pixels
"""

# ╔═╡ 519b147e-385b-11eb-30ef-9354da78c3b2
md"""
`SCREEN_HEIGHT:`
$(SCREEN_HEIGHT = Int32( 1080 )) pixels
"""

# ╔═╡ 731afc68-385b-11eb-1084-1f85f3b05ed0
md"""
`SCREEN_BORDER:`
$(SCREEN_BORDER = Int32( 10 )) pixels
"""

# ╔═╡ bb07906a-3db6-11eb-0a62-7f1f1a07ddc4
md"""
`CARD_HEIGHT:`
$(CARD_HEIGHT = ceil(Int32, SCREEN_HEIGHT / 3.5 )) pixels
"""

# ╔═╡ f41ff52e-3db6-11eb-0fbc-b179d4818776
md"""
`CARD_WIDTH:`
$(CARD_WIDTH = ceil(Int32, CARD_HEIGHT * 2.5 / 3.5 )) pixels
"""

# ╔═╡ a913a358-3930-11eb-104b-a1e5b1b9091c
md"""
`DEFAULT_FONT:`
$(DEFAULT_FONT = "../fonts/OpenSans-Regular.ttf")
"""

# ╔═╡ 2936eba6-3942-11eb-14ec-05cab84f472d
md"""
`MAX_FPS:`
$(MAX_FPS = Int32( 60 )) *inactive
"""

# ╔═╡ 3fe53d58-4d9c-11eb-11c3-1f1ea0505f98
begin
	BKG_NAMES = [ f=>f for f in readdir("$mtg_dir/MtG.jl/ui/backgrounds") ]
	
	md"""
	`BKG_NAMES:`
	$(@bind BKG_NAME Select(BKG_NAMES,  default="sakura_blossom.png"))
	"""
end

# ╔═╡ 089d469c-4da1-11eb-2c82-6132328b548c
BKG_PATH = "$mtg_dir/MtG.jl/ui/backgrounds/$BKG_NAME"

# ╔═╡ 2b99d0d8-4d9d-11eb-3f90-2fd6c50a9fa8
BACKGROUND_IMG = LocalResource(BKG_PATH)

# ╔═╡ 0c14a126-3852-11eb-2561-9dd3f0f435b0
md"""
`BACKGROUND:`
$(BACKGROUND = colorant"black")

*Available colornames can be found here: http://juliagraphics.github.io/Colors.jl/stable/namedcolors/*
"""

# ╔═╡ 1fd3ee0a-4faa-11eb-1ee9-a5b89af3d078
html"""<br><br><br><br><br><br>"""

# ╔═╡ e3105084-4c1e-11eb-297d-e1654170ec4a
GS = Dict(
	:SCREEN_WIDTH=>SCREEN_WIDTH,
	:SCREEN_HEIGHT=>SCREEN_HEIGHT,
	:SCREEN_BORDER=>SCREEN_BORDER,
	:CARD_WIDTH=>CARD_WIDTH,
	:CARD_HEIGHT=>CARD_HEIGHT,
	:BACKGROUND=>BACKGROUND,
	:DEFAULT_FONT=>DEFAULT_FONT,
	:MAX_FPS=>MAX_FPS,
	);

# ╔═╡ Cell order:
# ╟─67d98a4a-4da0-11eb-3ff8-db5e68b54f8d
# ╟─c656c348-3852-11eb-2806-0df5baa0d2e1
# ╟─52c3d32e-4e2f-11eb-20f7-4d61ff865e75
# ╟─3ffcf8a4-385b-11eb-25da-fd9bfc189e06
# ╟─519b147e-385b-11eb-30ef-9354da78c3b2
# ╟─731afc68-385b-11eb-1084-1f85f3b05ed0
# ╟─bb07906a-3db6-11eb-0a62-7f1f1a07ddc4
# ╟─f41ff52e-3db6-11eb-0fbc-b179d4818776
# ╟─a913a358-3930-11eb-104b-a1e5b1b9091c
# ╟─2936eba6-3942-11eb-14ec-05cab84f472d
# ╟─3fe53d58-4d9c-11eb-11c3-1f1ea0505f98
# ╟─089d469c-4da1-11eb-2c82-6132328b548c
# ╟─2b99d0d8-4d9d-11eb-3f90-2fd6c50a9fa8
# ╟─0c14a126-3852-11eb-2561-9dd3f0f435b0
# ╟─1fd3ee0a-4faa-11eb-1ee9-a5b89af3d078
# ╠═e3105084-4c1e-11eb-297d-e1654170ec4a
