### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ b99805ba-3931-11eb-0e18-6ffb5497630d
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

# ╔═╡ d840fcce-3931-11eb-0d08-59ed4b60b2f9
begin
	@quickactivate

	using GameZero
	using Random
    using DataStructures
    using Serialization
	using PlaymatSimulator
	import PlaymatSimulator.Actors.Image
	import PlaymatSimulator.Actors.GIF

	mtg_dir = projectdir() * "/games/MtG"

	md"""
	## EDH GAME STATE
	Provide an initial game state function for the game engine to load upon launch by defining a `gs` Dict{Symbol,Any}(...) object below with all of the game assets.
	"""
end

# ╔═╡ ebd61216-4da3-11eb-2e77-5900d3980b8e
STAGE = game_include("$mtg_dir/MtG.jl/notebooks/game_stage.jl")

# ╔═╡ f1e8642e-4da3-11eb-26bc-234df79ed8a6
GS = game_include("$mtg_dir/MtG.jl/notebooks/game_settings.jl")

# ╔═╡ 2e97f2d2-4c1d-11eb-23d5-3fc9bcd4bc47
SCREEN_WIDTH = Int32(1080)

# ╔═╡ 93af0788-4c12-11eb-2c17-8ddd05dfc94d
SCREEN_BORDER = Int32(10)

# ╔═╡ 988ca2cc-4c12-11eb-284d-f51814cbf3a3
SCREEN_HEIGHT = Int32(1920)

# ╔═╡ 22163bfc-3932-11eb-37cc-0701ba61483e
const gs = Dict{Symbol,Any}(
	:GAME_NAME => "EDH",
    :GAME_DIR => "$mtg_dir/MtG.jl",
	:MOUSE_POS => Int32[0,0],
    :MOUSE_OFFSETS => [ Int32[0,0] ],
	:music => readdir("$mtg_dir/MtG.jl/music"),
	:ui => OrderedDict(
		:cursor_icon => Image("mouse_cursor_icon",
			load("$mtg_dir/MtG.jl/ui/icons/RavenmoreIconPack/64/swordWood.png")),
        :cursor => Image("mouse_cursor",
			load("$mtg_dir/MtG.jl/ui/zones/area_wht.png"), alpha=0, w=1, h=1),
		),
    :stage => STAGE,
	:resources => Dict{Symbol,Any}(
        :mana => Dict{Symbol,Int32}(
            :white=>0,
            :blue=>0,
            :black=>0,
            :red=>0,
            :green=>0,
            :colorless=>0,
            ),
        :energy=>0,
        :life=>40,  # EDH life adjustment
        ),
	:resource_spinners => OrderedDict{Symbol,Actor}(
        :life => Text("40:L ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf",
            ),
        :white_mana => Text(" 0:W ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf", font_color = [255,255,255,255]
            ),
        :blue_mana => Text(" 0:U ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf", font_color = [0,0,255,255]
            ),
        :black_mana => Text(" 0:B ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf", font_color = [0,0,0,255]
            ),
        :red_mana => Text(" 0:R ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf", font_color = [255,0,0,255]
            ),
        :green_mana => Text(" 0:G ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf", font_color = [0,255,0,255]
            ),
        :colorless_mana => Text(" 0:C ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf", font_color = [125,125,125,255]
            ),
        :energy => Text(" 0:E ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf",
            ),
        :poison => Text(" 0:P ",
            "$mtg_dir/MtG.jl/fonts/OpenSans-Semibold.ttf", font_color = [255,0,255,255]
            ),
        ),
    :sfx => OrderedDict(
        :shade_wht=>Image("shade_wht",
			load("$mtg_dir/MtG.jl/ui/zones/area_wht.png")),
        :shade_blk=>Image("shade_blk",
			load("$mtg_dir/MtG.jl/ui/zones/area_blk.png")),
		:sel_box => Image("sel_box",
			load("$mtg_dir/MtG.jl/ui/zones/area_wht.png"), alpha=35, w=0, h=0),
        ),
    :overlay => OrderedDict(
        :texts => Actor[],
        :effects => Actor[],
		:dice => Dice[],
		:counters => Counter[],
		:shades => Actor[],
        ),
    :zone => OrderedDict(
        "Command" => Card[],  # EDH-specific zone
        "Graveyard" => Card[],
        "Battlefield" => Card[],
        "Library" => Card[],
        "Hand" => Card[],
		#"Exile" => Card[],  # replaced with Command
		#"Stack" => Union{Card,Spell}  # not implemented
        ),
    :group => OrderedDict(
        :clickables => Actor[],
        :selected => Actor[],
        ),
	:stack => OrderedDict(),
	)

# ╔═╡ 4339c7e0-4c1f-11eb-1372-5b42b11fa88e
begin
	merge!(gs, GS)
	gs
end

# ╔═╡ Cell order:
# ╟─b99805ba-3931-11eb-0e18-6ffb5497630d
# ╠═d840fcce-3931-11eb-0d08-59ed4b60b2f9
# ╠═ebd61216-4da3-11eb-2e77-5900d3980b8e
# ╠═f1e8642e-4da3-11eb-26bc-234df79ed8a6
# ╠═2e97f2d2-4c1d-11eb-23d5-3fc9bcd4bc47
# ╠═93af0788-4c12-11eb-2c17-8ddd05dfc94d
# ╟─988ca2cc-4c12-11eb-284d-f51814cbf3a3
# ╠═22163bfc-3932-11eb-37cc-0701ba61483e
# ╠═4339c7e0-4c1f-11eb-1372-5b42b11fa88e
