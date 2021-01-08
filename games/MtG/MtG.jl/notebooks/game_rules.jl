### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 0ce5327a-393b-11eb-1c38-4d48c8b2cdb6
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

# ╔═╡ 18e233a2-393b-11eb-2a6e-e77e896a6ce3
begin
	@quickactivate

	using DataStructures
	using GZ2	

	md"""
	## GAME RULES (INACTIVE)

	Provide the game's rules (things to check for every frame) by defining custom types, functions, and objects below. Some basic rules funcionality is provided.
	"""
end

# ╔═╡ 2e3ae5ee-5019-11eb-0e4f-fd8ceaa8a8f7
abstract type AbstractCard end

# ╔═╡ 387cd682-5019-11eb-16b6-7dff158de31b
abstract type AbstractSpell <: AbstractCard end

# ╔═╡ 62ea38ec-5019-11eb-0060-c5e3ae62838c
abstract type AbstractLand <: AbstractCard end

# ╔═╡ 09703f54-4fcf-11eb-3a14-45a4cfafbe5d
mutable struct Card <: AbstractCard
	id::Int
    name::String
	owner::String
	controller::String
	zone::Symbol
	actors::Vector{Actor}
	tapped::Bool
	d::Dict{Symbol,Any}
end

# ╔═╡ 49b31c24-5012-11eb-2d79-9bfc1514c3aa
mutable struct CardEffect
	source::Card
	effect::Function
	exit_condition::Function
end

# ╔═╡ 7b5b091c-500d-11eb-35c5-45af2e6c4e29
mutable struct Zone
	name::String
	cards::Vector{Card}
	effects::Vector{CardEffect}
end

# ╔═╡ d61fed94-5016-11eb-1b20-edc6a8b86bb5
mutable struct Planeswalker
	loyalty::Int
end

# ╔═╡ fbce7bf4-4fce-11eb-3205-b31b312ef4e5
mutable struct Player
    name::String
	portrait::Actor
    health::Int
    poison::Int
    priority::Bool
    resources::Dict{Symbol,Any}
    effects::Vector{CardEffect}
    zones::Vector{Zone}
end

# ╔═╡ 88d425c0-5011-11eb-11f9-271c42ea3c50
mutable struct PlaymatSimulatorGame
	player_names::Vector{Player}
	global_effects::Vector{CardEffect}
	server_address::String
	stack::Vector{CardEffect}
	gs::Dict
end

# ╔═╡ a938ca5c-393a-11eb-0557-d1580caa7d9d
gr = OrderedDict(
    :turn_order => [:untap, :upkeep, :draw, :main_phase_one, :declare_attackers, :declare_blockers, :main_phase_two, :end_phase ],
	:win_conditions => [ :all_opponents_lost, :no_opponents_left ],
	:loss_conditions => [ :zero_health, :cant_draw, :poisoned, :commander_dmg ],
	)

# ╔═╡ 16ac23e8-393b-11eb-2c98-b9460bc51ec1
stack = []

# ╔═╡ 26a74f36-393b-11eb-296b-5dce05b5e22c
game_step = [
    "untap",
    "upkeep",
    "draw",
    "precombat_main",
    "combat",
    "postcombat_main",
    "end",
    "cleanup",
    ]

# ╔═╡ 96f9024e-3aa7-11eb-2916-c3f03b94b5e6
begin
	resource_types = ["{W}","{U}","{B}","{R}","{G}",:E,:X,:L,:E,:P]

	md"""
	Resource types:

	Mana
	:W - white
	:U - blue
	:B - black
	:R - red
	:G - green
	:C - colorless

	Other
	:L - life
	:E - energy
	:P - poison

	"""
end

# ╔═╡ 084fbf90-393c-11eb-0e3f-e1cf9b126e31
function declare_creature_attack(target::Union{Player, Planeswalker}, creatures::Dict, opponents::Dict, planeswalkers::Dict)
end

# ╔═╡ 712f3b76-393c-11eb-0ae4-f1c8a5eac20a
function declare_blockers(p::Player, creatures::Dict)
end

# ╔═╡ 877f03ac-393c-11eb-1f6f-3bfb1f3a008a
function shuffle_deck(p::Player)
end

# ╔═╡ 9147eeda-393c-11eb-04ee-e1587dfb35c4
function draw_card(p::Player, num::Int)
end

# ╔═╡ 973e3aa4-393c-11eb-08a4-59338f595c15
function discard_card(p::Player, amount::Int, random=false)
end

# ╔═╡ 9cdcbf34-393c-11eb-15f3-c716ca844b1b
function add_mana_to_pool(p::Player, mana_type)
end

# ╔═╡ 9ffdeb8c-393c-11eb-3900-8d09fa3ce1fb
function subtract_mana_from_pool(p::Player, mana_type)
end

# ╔═╡ a3426304-393c-11eb-047a-71ebc4f070fd
function tap_card(p::Player, card)
end

# ╔═╡ a73a4918-393c-11eb-0ecc-b58671c0c518
function untap_card(p::Player, card)
end

# ╔═╡ aa969f8a-393c-11eb-3f11-5f32374e939c
function play_land(p::Player)
end

# ╔═╡ ae6acabe-393c-11eb-235f-59a50435ecff
function play_spell(p::Player)
end

# ╔═╡ b13dba94-393c-11eb-21f4-ab7d7f18db74
function take_damage(p::Player, creature=nothing)
end

# ╔═╡ b3d88946-393c-11eb-2e79-9d3c657bb6d8
function heal_damage(p::Player, creature=nothing)
end

# ╔═╡ b85ee3d4-393c-11eb-3062-139a585a91a4
function gain_life(p::Player)
end

# ╔═╡ bb80fa16-393c-11eb-0f56-e713be77eebe
function lose_life(p::Player)
end

# ╔═╡ bebd3406-393c-11eb-1210-85373fd1d8ad
function end_phase(p::Player)
end

# ╔═╡ c1ff5a6a-393c-11eb-3bb0-6d4be308bbc6
function end_turn(p::Player)
end

# ╔═╡ c4f23038-393c-11eb-3bd8-b73d5c00f8f5
function run_upkeep(p::Player)
end

# ╔═╡ Cell order:
# ╟─0ce5327a-393b-11eb-1c38-4d48c8b2cdb6
# ╠═18e233a2-393b-11eb-2a6e-e77e896a6ce3
# ╠═2e3ae5ee-5019-11eb-0e4f-fd8ceaa8a8f7
# ╠═387cd682-5019-11eb-16b6-7dff158de31b
# ╠═62ea38ec-5019-11eb-0060-c5e3ae62838c
# ╠═09703f54-4fcf-11eb-3a14-45a4cfafbe5d
# ╠═49b31c24-5012-11eb-2d79-9bfc1514c3aa
# ╠═7b5b091c-500d-11eb-35c5-45af2e6c4e29
# ╠═d61fed94-5016-11eb-1b20-edc6a8b86bb5
# ╠═fbce7bf4-4fce-11eb-3205-b31b312ef4e5
# ╠═88d425c0-5011-11eb-11f9-271c42ea3c50
# ╠═a938ca5c-393a-11eb-0557-d1580caa7d9d
# ╟─16ac23e8-393b-11eb-2c98-b9460bc51ec1
# ╟─26a74f36-393b-11eb-296b-5dce05b5e22c
# ╟─96f9024e-3aa7-11eb-2916-c3f03b94b5e6
# ╟─084fbf90-393c-11eb-0e3f-e1cf9b126e31
# ╟─712f3b76-393c-11eb-0ae4-f1c8a5eac20a
# ╟─877f03ac-393c-11eb-1f6f-3bfb1f3a008a
# ╟─9147eeda-393c-11eb-04ee-e1587dfb35c4
# ╟─973e3aa4-393c-11eb-08a4-59338f595c15
# ╟─9cdcbf34-393c-11eb-15f3-c716ca844b1b
# ╟─9ffdeb8c-393c-11eb-3900-8d09fa3ce1fb
# ╟─a3426304-393c-11eb-047a-71ebc4f070fd
# ╟─a73a4918-393c-11eb-0ecc-b58671c0c518
# ╟─aa969f8a-393c-11eb-3f11-5f32374e939c
# ╟─ae6acabe-393c-11eb-235f-59a50435ecff
# ╟─b13dba94-393c-11eb-21f4-ab7d7f18db74
# ╟─b3d88946-393c-11eb-2e79-9d3c657bb6d8
# ╟─b85ee3d4-393c-11eb-3062-139a585a91a4
# ╟─bb80fa16-393c-11eb-0f56-e713be77eebe
# ╟─bebd3406-393c-11eb-1210-85373fd1d8ad
# ╟─c1ff5a6a-393c-11eb-3bb0-6d4be308bbc6
# ╟─c4f23038-393c-11eb-3bd8-b73d5c00f8f5
