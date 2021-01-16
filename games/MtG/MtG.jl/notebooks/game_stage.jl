### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 1663336c-3902-11eb-0158-f54434ea3080
using DrWatson

# ╔═╡ ac5c6510-3901-11eb-0c47-bb3143471434
begin
    @quickactivate

    using Colors
	using ImageIO
    using DataStructures

	import PlaymatSimulator.Actors.Image

	mtg_dir = projectdir() * "/games/MtG"

	PS = ingredients("$(projectdir())/src/PlaymatSimulator.jl")
	GS = ingredients("$mtg_dir/MtG.jl/notebooks/game_settings.jl")

	SCREEN_WIDTH = GS.SCREEN_WIDTH
	SCREEN_HEIGHT = GS.SCREEN_HEIGHT
	SCREEN_BORDER = GS.SCREEN_BORDER

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
begin
	dice_faces = [ load("$mtg_dir/MtG.jl/ui/dice/$fn") for fn in
		readdir("$mtg_dir/MtG.jl/ui/dice") if occursin("gif", fn) ]

	serialize("$mtg_dir/MtG.jl/ui/dice/dice_faces.jls", dice_faces)

	dfs = deserialize("$mtg_dir/MtG.jl/ui/dice/dice_faces.jls")

	function create_die(dfs; id="die_$(randstring(5))", x=0, y=0)
		d = Dice(id,
			[ GIF("dieface_$(randstring(5))", f) for f in dfs ],
			length(dfs),
			)

		for f in d.faces
			f.data[:parent_id] = id
			f.x = x
			f.y = y
		end

		return d
	end

	function create_glass_counter(id="ctr_$(randstring(5))"; x=0, y=0)
		c = Counter("ctr_$(randstring(5))",
			[ GIF("ctrface_$(randstring(5))", load("$mtg_dir/MtG.jl/ui/counters/glass.gif")) ],
			nothing,
			)
		c.faces[begin].data[:parent_id] = id
		c.faces[begin].x = x
		c.faces[begin].y = y
		return c
	end

	STAGE = OrderedDict(
		:background => Image("$(GS.BKG_NAME)",
			load(GS.BKG_PATH),
			w=SCREEN_WIDTH, h=SCREEN_HEIGHT
			),
		:six_sided_die => create_die(dfs,
			x=ceil(Int32, 0.85SCREEN_WIDTH),
			y=ceil(Int32, 0.9SCREEN_HEIGHT)
			),
		:glass_counter => create_glass_counter(
			x=ceil(Int32, 0.8SCREEN_WIDTH),
			y=ceil(Int32, 0.9SCREEN_HEIGHT)
			),
		"Library" => Image("Library",
			load(SHADE_PATH),
			x=SCREEN_BORDER,
			y=ceil(Int32, SCREEN_HEIGHT * 0.6) + SCREEN_BORDER,
			w=ceil(Int32, SCREEN_WIDTH * 0.15) - SCREEN_BORDER,
			h=ceil(Int32, SCREEN_HEIGHT * 0.4 - 2SCREEN_BORDER),
			alpha=50,
			),
		"Battlefield" => Image("Battlefield",
			load(SHADE_PATH),
			x=ceil(Int32, SCREEN_WIDTH * 0.15) + SCREEN_BORDER,
			y=SCREEN_BORDER,
			w=ceil(Int32, SCREEN_WIDTH * 0.7) - SCREEN_BORDER,
			h=ceil(Int32, SCREEN_HEIGHT - 2SCREEN_BORDER),
			alpha=50,
			),
		"Command" => Image("Command",
			load(SHADE_PATH),
			x=ceil(Int32, SCREEN_WIDTH * 0.85 + SCREEN_BORDER),
			y=SCREEN_BORDER,
			w=ceil(Int32, SCREEN_WIDTH * 0.15 - 2SCREEN_BORDER),
			h=ceil(Int32, SCREEN_HEIGHT * 0.4 - SCREEN_BORDER),
			alpha=50,
			),
		"Graveyard" => Image("Graveyard",
			load(SHADE_PATH),
			x=ceil(Int32, SCREEN_WIDTH * 0.85 + SCREEN_BORDER),
			y=ceil(Int32, SCREEN_HEIGHT * 0.4 + SCREEN_BORDER),
			w=ceil(Int32, SCREEN_WIDTH * 0.15 - 2SCREEN_BORDER),
			h=ceil(Int32, SCREEN_HEIGHT * 0.6 - 2SCREEN_BORDER),
			alpha=50,
			),
		"Hand" => Image("Hand",
			load(SHADE_PATH),
			x=SCREEN_BORDER,
			y=SCREEN_BORDER,
			w=ceil(Int32, SCREEN_WIDTH * 0.15 - SCREEN_BORDER),
			h=ceil(Int32, SCREEN_HEIGHT * 0.6 - SCREEN_BORDER),
			alpha=50,
			),
		)
end

# ╔═╡ Cell order:
# ╟─1663336c-3902-11eb-0158-f54434ea3080
# ╟─ac5c6510-3901-11eb-0c47-bb3143471434
# ╟─fdf59b16-4da2-11eb-204f-0d0e1a522f6c
# ╠═a2195ae4-4da2-11eb-2112-e54a53878565
# ╟─235edb4c-38fe-11eb-3112-bde291f6f5b5
