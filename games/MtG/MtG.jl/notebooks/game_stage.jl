### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 1663336c-3902-11eb-0158-f54434ea3080
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

# ╔═╡ ac5c6510-3901-11eb-0c47-bb3143471434
begin
    @quickactivate
    
    using Colors
    using DataStructures

	mtg_dir = projectdir() * "/games/MtG"
	
	PS = ingredients("$(projectdir())/src/PlaymatSimulator.jl")
	GS = ingredients("$mtg_dir/MtG.jl/notebooks/game_settings.jl")
	
	SCREEN_WIDTH = GS.SCREEN_WIDTH
	SCREEN_HEIGHT = GS.SCREEN_HEIGHT
	SCREEN_BORDER = GS.SCREEN_BORDER
	
	Image = PS.PlaymatSimulator.Actors.Image
	GIF = PS.PlaymatSimulator.Actors.GIF
	
	md"""
	## GAME STAGE
	This notebook should define the `stage` of the game. The `stage` should consist of elements to be drawn below the cards and other ui elements such as background images/ANations, some ui elements, game zone/area markers, etc. Provide those objects to the game engine by defining a single dictionary object, `stage = Dict{Symbol, Any}(...)`.
	"""
end

# ╔═╡ fdf59b16-4da2-11eb-204f-0d0e1a522f6c
SHADE_PATH = "$mtg_dir/MtG.jl/ui/zones/area_blk.png"

# ╔═╡ a2195ae4-4da2-11eb-2112-e54a53878565
zone_shade = load(SHADE_PATH)

# ╔═╡ 235edb4c-38fe-11eb-3112-bde291f6f5b5
STAGE = OrderedDict(
	:background => Image("$(GS.BKG_NAME)",
		load(GS.BKG_PATH),
		w=SCREEN_WIDTH, h=SCREEN_HEIGHT
		),
	:library => Image("area_blk",
		load(SHADE_PATH),
		x=SCREEN_BORDER, 
		y=ceil(Int32, SCREEN_HEIGHT * 0.6) + SCREEN_BORDER,
		w=ceil(Int32, SCREEN_WIDTH * 0.15) - SCREEN_BORDER, 
		h=ceil(Int32, SCREEN_HEIGHT * 0.4) - 2SCREEN_BORDER,
		alpha=50,
		),
	:battlefield => Image("area_blk",
		load(SHADE_PATH),
		x=ceil(Int32, SCREEN_WIDTH * 0.15) + SCREEN_BORDER, 
		y=SCREEN_BORDER, 
		w=ceil(Int32, SCREEN_WIDTH * 0.7) - SCREEN_BORDER, 
		h=SCREEN_HEIGHT - 2SCREEN_BORDER,
		alpha=50,
		),
	:command => Image("area_blk",
		load(SHADE_PATH),
		x=ceil(Int32, SCREEN_WIDTH * 0.85) + SCREEN_BORDER,
		y=SCREEN_BORDER,
		w=ceil(Int32, SCREEN_WIDTH * 0.15) - 2SCREEN_BORDER,
		h=ceil(Int32, SCREEN_HEIGHT * 0.4) - SCREEN_BORDER,
		alpha=50,
		),
	:graveyard => Image("area_blk",
		load(SHADE_PATH),
		x=ceil(Int32, SCREEN_WIDTH * 0.85) + SCREEN_BORDER,
		y=ceil(Int32, SCREEN_HEIGHT * 0.4) + SCREEN_BORDER,
		w=ceil(Int32, SCREEN_WIDTH * 0.15) - 2SCREEN_BORDER,
		h=ceil(Int32, SCREEN_HEIGHT * 0.6) - 2SCREEN_BORDER,
		alpha=50,
		),
	:hand => Image("area_blk",
		load(SHADE_PATH),
		x=SCREEN_BORDER,
		y=SCREEN_BORDER,
		w=ceil(Int32, SCREEN_WIDTH * 0.15) - SCREEN_BORDER,
		h=ceil(Int32, SCREEN_HEIGHT * 0.6) - SCREEN_BORDER,
		alpha=50,
		),
	)

# ╔═╡ Cell order:
# ╟─1663336c-3902-11eb-0158-f54434ea3080
# ╟─ac5c6510-3901-11eb-0c47-bb3143471434
# ╟─fdf59b16-4da2-11eb-204f-0d0e1a522f6c
# ╠═a2195ae4-4da2-11eb-2112-e54a53878565
# ╟─235edb4c-38fe-11eb-3112-bde291f6f5b5
