### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ ad8ff974-4b71-11eb-3eb6-790d687615c0
using DrWatson

# ╔═╡ b35cdada-4689-11eb-2629-c1cedd8052bd
begin
	@quickactivate

	using GZ2
	using Dates
	using Colors
	using Random
	using Serialization
	using DataStructures
	using PlaymatSimulator
    using SimpleDirectMediaLayer

    import PlaymatSimulator.Actors.Text
	import PlaymatSimulator.Actors.Image
	import PlaymatSimulator.kill_actor!

	const AN = PlaymatSimulator.Animations
	const SDL2 = SimpleDirectMediaLayer

	game_include("game_rules.jl")

	md"""
	### COMMON MtG FUNCS
	"""
end

# ╔═╡ 409648d8-468e-11eb-2856-5bda6584cf79
function zone_check(a::Actor, gs::Dict)
    for zone in keys(gs[:zone])
        if SDL2.HasIntersection(
            Ref(SDL2.Rect(Int32[
				ceil(a.x + a.w * a.scale[1]/2),
				ceil(a.y + a.h * a.scale[2]/2), 1, 1]...)), # intersection determined from top-left most pixel
            Ref(gs[:stage][zone].position))
            return zone
        end
    end
    @warn "$(a.label) not found in any :stage area!"
end

# ╔═╡ 438d93b6-468e-11eb-2cdd-650d3873e81d
function kill_card!(c::Card)
    global gs

	kill_actor!.(c.faces)
    filter!.(x->x !== c, [ values(gs[:zone])..., values(gs[:group])... ])
end

# ╔═╡ 799c2578-4cb3-11eb-1af7-b1ab01270e6d
function reset_deck!(gs::Dict)
    GAME_NAME = gs[:GAME_NAME]
    GAME_DIR = gs[:GAME_DIR]
    DECK_NAME = gs[:DECK_NAME]
    CARD_WIDTH = gs[:deck][:CARD_WIDTH]
    CARD_HEIGHT = gs[:deck][:CARD_HEIGHT]
    SCREEN_WIDTH = gs[:SCREEN_WIDTH]
    SCREEN_HEIGHT = gs[:SCREEN_HEIGHT]
    SCREEN_BORDER = gs[:SCREEN_BORDER]
	DECK_DIR = "$GAME_DIR/../$GAME_NAME/decks/$DECK_NAME"

    for k in keys(gs[:zone])
        gs[:zone][k] = []
    end

    for k in keys(gs[:group])
        gs[:group][k] = []
    end

    deck = deserialize("$DECK_DIR/$DECK_NAME.jls")
	deck[:Backside] = Image("Backside", deck[:CARD_BACK_IMG])
	gs[:CARDS] = []

	for (name, img) in zip(gs[:deck][:card_names], gs[:deck][:CARD_FRONT_IMGS])
		id = randstring(10)
		c = Card(
			id,
			name,
			"Player1",
			"Player1",
			[ Image("Backside", deck[:CARD_BACK_IMG]), Image(name, img) ],
			false,
			false,
			[1,1],
			Dict(),
		)
		for a in c.faces
			a.data[:parent_id] = c.id
		end

		push!(gs[:CARDS], c)
	end

	gs[:COMMANDERS] = []

	for (name, img) in zip(gs[:deck][:commander_names], gs[:deck][:COMMANDER_FRONT_IMGS])
		id = randstring(10)
		c = Card(
			id,
			name,
			"Player1",
			"Player1",
			[ Image(name, img), Image("Backside", deck[:CARD_BACK_IMG]) ],
			false,
			false,
			[1,1],
			Dict(),
		)
		for a in c.faces
			a.data[:parent_id] = c.id
		end

		push!(gs[:COMMANDERS], c)
	end

	gs[:zone]["Command"] = gs[:COMMANDERS]
	gs[:zone]["Library"] = shuffle(gs[:CARDS])
	gs[:zone]["Hand"] = reverse([ pop!(gs[:zone]["Library"]) for i in 1:7 ])

	for c in gs[:zone]["Hand"]
		c.faces = circshift(c.faces, 1)
	end

	gs[:ALL_CARDS] = vcat(gs[:zone]["Library"], gs[:zone]["Hand"], gs[:zone]["Command"])

	#push!(gs[:overlay][:cards], [ c.faces[begin] for c in gs[:ALL_CARDS] ]...)
	pushfirst!(gs[:group][:clickables], values(gs[:ui][:horizontal_spinners])...)
	pushfirst!(gs[:group][:clickables], values(gs[:ui][:vertical_spinners])...)
	pushfirst!(gs[:group][:clickables], values(gs[:ui][:glass_counters])...)

	pushfirst!(gs[:group][:clickables], [ c.faces[begin] for c in gs[:zone][:"Hand"] ]...)
	pushfirst!(gs[:group][:clickables], [ c.faces[begin] for c in gs[:zone][:"Command"] ]...)
	pushfirst!(gs[:group][:clickables], gs[:zone]["Library"][end].faces[begin])

	AN.splay_actors!([ c.faces[begin] for c in gs[:zone]["Library"] ],  # stack library cards into deck
		SCREEN_BORDER,
		ceil(Int32, SCREEN_HEIGHT - SCREEN_BORDER - 1.6CARD_HEIGHT),
		SCREEN_HEIGHT,
		SCREEN_BORDER,
		pitch=[0.001, -0.005],
	)

	AN.splay_actors!([ c.faces[begin] for c in gs[:zone]["Hand"] ], 	# splay cards into hand zone
        SCREEN_BORDER,
        SCREEN_BORDER,
        SCREEN_HEIGHT,
        SCREEN_BORDER,
        pitch=[0.05, 0.1],
    )

    for (i,c) in enumerate([ c.faces[begin] for c in gs[:zone]["Command"] ])
		c.y = SCREEN_BORDER + (i-1) * 30
        c.x = gs[:stage]["Command"].x + (i-1) * 15
    end

    return gs
end

# ╔═╡ 47f50362-468e-11eb-211d-f561273a906c
function on_mouse_move(g::Game, pos::Tuple)
    global gs

    gs[:ui][:cursor_icon].x = gs[:ui][:cursor].x = gs[:MOUSE_POS][1] = pos[1]
    gs[:ui][:cursor_icon].y = gs[:ui][:cursor].y = gs[:MOUSE_POS][2] = pos[2]

    for c in gs[:group][:selected]
        if c == gs[:ui][:sel_box]
            c.w = gs[:ui][:cursor].x - c.x
            c.h = gs[:ui][:cursor].y - c.y

		elseif !(g.keyboard.RSHIFT || g.keyboard.LSHIFT)
			c.x = gs[:MOUSE_POS][1] + c.data[:mouse_offset][1]
            c.y = gs[:MOUSE_POS][2] + c.data[:mouse_offset][2]
        end
    end
end

# ╔═╡ 69917186-468e-11eb-1175-dd4bbfe2f109
function draw(g::Game)
    draw.([
        # bottom layer
        values(gs[:stage])...,
		gs[:ALL_CARDS]...,
        [ (values(gs[:overlay])... )... ]...,
        values(gs[:texts])...,
        values(gs[:ui][:glass_counters])...,
        values(gs[:ui][:horizontal_spinners])...,
        values(gs[:ui][:vertical_spinners])...,
        gs[:group][:selected]...,
        gs[:ui][:cursor_icon],
        # top layer
    ])
end

# ╔═╡ cdd4c524-4cba-11eb-07a2-c7651ae7f211
function add_texts!(gs::Dict)
    SCREEN_WIDTH = gs[:SCREEN_WIDTH]
    SCREEN_HEIGHT = gs[:SCREEN_HEIGHT]
    SCREEN_BORDER = gs[:SCREEN_BORDER]
    GAME_DIR = gs[:GAME_DIR]

    gs[:ui][:vertical_spinners] = OrderedDict{Symbol,Actor}(
        :plus_minus_counter => Text(
            """    +
            +1/+1
                 -""",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf",
            x=ceil(Int32, SCREEN_WIDTH * 0.79),
            y=SCREEN_HEIGHT - 12SCREEN_BORDER,
            pt_size=26,
            wrap_length=100,
            ),
        )

    gs[:ui][:horizontal_spinners] = OrderedDict{Symbol,Actor}(
        :life => Text("40:L ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf",
            ),
        :white_mana => Text(" 0:W ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf", font_color = [255,255,255,255]
            ),
        :blue_mana => Text(" 0:U ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf", font_color = [0,0,255,255]
            ),
        :black_mana => Text(" 0:B ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf", font_color = [0,0,0,255]
            ),
        :red_mana => Text(" 0:R ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf", font_color = [255,0,0,255]
            ),
        :green_mana => Text(" 0:G ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf", font_color = [0,255,0,255]
            ),
        :colorless_mana => Text(" 0:C ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf", font_color = [125,125,125,255]
            ),
        :energy => Text(" 0:E ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf",
            ),
        :poison => Text(" 0:P ",
            "$GAME_DIR/fonts/OpenSans-Semibold.ttf", font_color = [255,0,255,255]
            ),
        )

	gs[:texts] = Dict{Symbol,Actor}()
    gs[:texts][:deck_info] = Text("Library: $(length(gs[:zone]["Library"]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=2SCREEN_BORDER,
        y=SCREEN_HEIGHT - 4SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:hand_info] = Text("Hand: $(length(gs[:zone]["Hand"]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=2SCREEN_BORDER,
        y=gs[:stage]["Hand"].h - 2SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:battlefield_info] = Text("Battlefield: $(length(gs[:zone]["Battlefield"]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=gs[:stage]["Hand"].w + 10SCREEN_BORDER,
        y=SCREEN_HEIGHT - 4SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:command_info] = Text("Command / Exile: $(length(gs[:zone]["Command"]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=gs[:stage]["Command"].x + SCREEN_BORDER,
        y=gs[:stage]["Command"].h - 2SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:graveyard_info] = Text("Graveyard: $(length(gs[:zone]["Graveyard"]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=gs[:stage]["Graveyard"].x + SCREEN_BORDER,
        y=SCREEN_HEIGHT - 4SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:welcome_text] = Text("PlaymatSimulator",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=ceil(Int32, SCREEN_WIDTH * 0.3),
        y=ceil(Int32, SCREEN_HEIGHT * 0.5),
        pt_size=85,
        font_color=[220,220,220,40],
        wrap_length=1000,
        )

    push!(gs[:overlay][:texts],
        values(gs[:ui][:horizontal_spinners])...,
        values(gs[:ui][:vertical_spinners])...,
        values(gs[:texts])...,
        )

    AN.splay_actors!([ values(gs[:ui][:horizontal_spinners])... ],
        ceil(Int32, SCREEN_WIDTH * 0.955),
        Int32(2SCREEN_BORDER),
        SCREEN_HEIGHT,
        SCREEN_BORDER,
        pitch=Float64[0,1]
        )

    gs[:group][:clickables] = [
        gs[:zone]["Command"]...,
        gs[:zone]["Hand"]...,
        values(gs[:ui][:vertical_spinners])...,
        values(gs[:ui][:horizontal_spinners])...,
        values(gs[:ui][:glass_counters])...,
        ]

    for s in values(gs[:ui][:horizontal_spinners])
        s.data[:value] = 0
    end

    gs[:ui][:horizontal_spinners][:life].data[:value] = 40
    gs[:ui][:vertical_spinners][:plus_minus_counter].data[:value] = 1

    reverse(gs[:group][:clickables])
    return gs
end

# ╔═╡ 7ef01b58-523d-11eb-0c16-2b1d02dd1836
function in_bounds(gs::Dict, as=Actor[])

	for a in gs[:group][:clickables]

		pos = if a.angle == 90 || a.angle == 270  # corrects for 90 & 270 rot abt center
            SDL2.Rect(
                ceil(Int32, a.x - (a.scale[2] * a.h - a.scale[1] * a.w) / 2),
                ceil(Int32, a.y + (a.scale[2] * a.h - a.scale[1] * a.w) / 2),
                a.h,
                a.w,
            )
        else
            a.position
        end

        if SDL2.HasIntersection(
            Ref(pos), Ref(gs[:ui][:cursor].position))
            push!(as, a)
        end
    end
    return as
end

# ╔═╡ 4cbb84f2-468e-11eb-09af-718f893c0449
function on_mouse_down(g::Game, pos::Tuple, button::GZ2.MouseButtons.MouseButton)
    global gs
    ib = in_bounds(gs)
	@show length(ib)
	GAME_DIR = projectdir() * "games/MtG/MtG.jl"
	DEFAULT_CARD_WIDTH = gs[:deck][:CARD_WIDTH]
    DEFAULT_CARD_HEIGHT = gs[:deck][:CARD_HEIGHT]

    if button == GZ2.MouseButtons.LEFT
        if isempty(ib) && isempty(gs[:group][:selected])
            gs[:ui][:sel_box].x = gs[:MOUSE_POS][1]
            gs[:ui][:sel_box].y = gs[:MOUSE_POS][2]
            gs[:ui][:sel_box].w = 1
            gs[:ui][:sel_box].h = 1
            gs[:ui][:sel_box].alpha = 50
            push!(gs[:group][:selected], gs[:ui][:sel_box])

        elseif !isempty(ib)
            if g.keyboard.LSHIFT || g.keyboard.RSHIFT
                play_sound("$GAME_DIR/sounds/select.wav")
                ib[end].scale=[1.025,1.025]
                push!(gs[:group][:selected], ib[end])

                for a in gs[:group][:selected]
                    a.data[:mouse_offset] = [ a.x - gs[:MOUSE_POS][1], a.y - gs[:MOUSE_POS][2] ]
                end

            elseif ib[end] === gs[:zone]["Library"][end] && length(gs[:zone]["Library"]) > 0 # pull card from top of deck into hand & selected if any cards left in library
                c = pop!(gs[:zone]["Library"])
				c.faces = circshift!(c.faces, 1)
				a.scale = [1.02, 1.02]
                a.x = ceil(Int32, (length(gs[:zone]["Hand"]) > 0 ?
                    gs[:zone]["Hand"][end].faces[begin].x : gs[:stage]["Hand"].x) + a.w * 0.05)
                a.y = ceil(Int32, (length(gs[:zone]["Hand"]) > 0 ?
                    gs[:zone]["Hand"][end].faces[begin].y : gs[:stage]["Hand"].y) + a.h * 0.1)

                push!(gs[:group][:selected], a)
				push!(gs[:group][:clickables], gs[:zone]["Library"][end].faces[begin])

            elseif ib[end] === gs[:ui][:vertical_spinners][:plus_minus_counter]
                if g.keyboard.LCTRL || g.keyboard.RCTRL
                    push!(gs[:group][:selected], ib[end])
                else
                    val = ib[end].data[:value]
                    val_str = val < 0 ? "$val / $val" : "+$val / +$val"
                    fp = "$GAME_DIR/fonts/OpenSans-Semibold.ttf"
                    pt_size = 24
                    copy = Text(val_str, fp)
                    push!(gs[:group][:selected], copy)
                    push!(gs[:overlay][:counters], copy)
                end

            elseif ib[end] in values(gs[:ui][:glass_counters])
                if g.keyboard.LCTRL || g.keyboard.RCTRL
                    push!(gs[:group][:selected], ib[end])
                else
                    copy = Image(ib[end].label, x=gs[:MOUSE_POS][1], y=gs[:MOUSE_POS][2])
                    push!(gs[:group][:selected], copy)
                    push!(gs[:overlay][:counters], copy)
                end

            elseif isempty(gs[:group][:selected]) &&
                !(ib[end] in values(gs[:ui][:horizontal_spinners])) &&
                !(ib[end] in values(gs[:ui][:vertical_spinners]))

                play_sound("$GAME_DIR/sounds/select.wav")

                ib[end].scale=[1.02, 1.02]
                zs = zone_check(ib[end], gs)

                counters = [ ctr for ctr in values(gs[:overlay][:counters])  # "sticky" counters
                    if SDL2.HasIntersection(
                        Ref(ib[end].position),
                        Ref(ctr.position)) && !(ib[end] in gs[:overlay][:counters])
                    ]
                for ctr in counters
                    ctr.data[:mouse_offset] = [
						ctr.x - gs[:MOUSE_POS][1], ctr.y - gs[:MOUSE_POS][2] ]
                end

                push!(gs[:group][:selected], [ counters..., ib[end] ]...)

                if zs !== nothing
                    filter!(x->x!==ib[end], gs[:zone][zs])
                end

                ib[end].data[:mouse_offset] = [ ib[end].x -
					gs[:MOUSE_POS][1], ib[end].y - gs[:MOUSE_POS][2] ]
            end
        end

    elseif button == GZ2.MouseButtons.RIGHT
        if !isempty(gs[:group][:selected])
            for a in gs[:group][:selected]
                a.angle = a.angle == 0 ? 90 : 0
            end

        elseif !isempty(ib)
            if ib[end] === gs[:zone]["Library"][end]
                filter!(x->!(x in [gs[:zone]["Hand"]..., gs[:zone]["Battlefield"]...]), gs[:group][:clickables])
                sort!(gs[:zone]["Library"], by=x->x.name)
                push!(gs[:group][:clickables], gs[:zone]["Library"][begin:end-1]...)

                if SDL2.HasIntersection(
                    Ref(gs[:zone]["Library"][end].position), Ref(gs[:stage]["Library"].position))

                    splay_elements!(
                        gs[:zone]["Library"],
                        ceil(Int32, gs[:stage]["Hand"].w + 2SCREEN_BORDER),
                        SCREEN_BORDER,
                        SCREEN_HEIGHT,
                        SCREEN_BORDER,
                        pitch=[0.03, 0.1]
                    )
                else
					for c in reverse(gs[:zone]["Library"])
						a = c.faces[begin]
                        if SDL2.HasIntersection(Ref(a.position), Ref(gs[:stage]["Hand"].position))
                            c_inds = findfirst(x->x.label==a.label, gs[:zone]["Library"])
                            a = deepcopy(gs[:zone]["Library"][c_inds])
                            deleteat!(gs[:zone]["Library"], c_inds)
                        end
                    end

                    shuffle!(gs[:zone]["Library"])

					for c in gs[:zone]["Library"]
						filter!(x->x==c, gs[:group][:clickables])
					end

                    splay_elements!([ c.faces[begin] for c in gs[:zone]["Library"] ],
                        SCREEN_BORDER,
                        SCREEN_HEIGHT - SCREEN_BORDER - DEFAULT_CARD_HEIGHT,
                        SCREEN_HEIGHT,
                        SCREEN_BORDER,
                        pitch=[0.001, -0.005]
                    )

                    gs[:group][:clickables] = [
                        [ c.faces[begin] for c in values(gs[:zone]) ]...,
                        values(gs[:ui][:horizontal_spinners])...,
                        values(gs[:ui][:vertical_spinners])...,
                        values(gs[:ui][:glass_counters])...,
                    ]

					filter!(x->!(x in gs[:zone]["Library"][begin:end-1]), gs[:group][:clickables])
                end

            elseif ib[end] in values(gs[:ui][:horizontal_spinners])
                delta = g.keyboard.LSHIFT || g.keyboard.RSHIFT ? 5 : 1
                f = gs[:MOUSE_POS][1] > ib[end].x + ib[end].w / 2 ? 1 : -1
                ib[end].data[:value] += f * delta

                AN.update_text_actor!(ib[end],
                    " $(ib[end].data[:value])" * ib[end].label[end-2:end]
                )

            elseif ib[end] === gs[:ui][:vertical_spinners][:plus_minus_counter]
                delta = g.keyboard.LSHIFT || g.keyboard.RSHIFT ? 5 : 1
                f = gs[:MOUSE_POS][2] > ib[end].y + ib[end].h / 2 ? -1 : 1
                v = ib[end].data[:value] = ib[end].data[:value] + delta * f
                AN.update_text_actor!(gs[:ui][:vertical_spinners][:plus_minus_counter],
                    """    +
                     $(v>-1 ? "+" : "")$(ib[end].data[:value])/$(v>-1 ? "+" : "")$(ib[end].data[:value])
                          -""")

			else
            	ib[end].angle = ib[end].angle == 0 ? 90 : 0
            end
        end
    end
end

# ╔═╡ 54761f68-468e-11eb-3ab9-db06b7174615
function on_mouse_up(g::Game, pos::Tuple, button::GZ2.MouseButtons.MouseButton)
    global gs
    ib = in_bounds(gs)
	GAME_DIR = projectdir() * "games/MtG/MtG.jl"

    if button == GZ2.MouseButtons.LEFT

		if gs[:ui][:sel_box] in gs[:group][:selected]
            sb = gs[:ui][:sel_box]

            for a in gs[:group][:clickables]

                pos = if a.angle == 90 || a.angle == 270  # corrects for sideways rot abt center
                    SDL2.Rect(
                        ceil(a.x - (a.scale[2] * a.h - a.scale[1] * a.w) / 2),
                        ceil(a.y + (a.scale[2] * a.h - a.scale[1] * a.w) / 2),
                        a.h,
                        a.w,
                    )
                else
                    a.position
                end

                if SDL2.HasIntersection(
                    Ref(SDL2.Rect(
                        sb.w < 0 ? sb.x + sb.w : sb.x,
                        sb.h < 0 ? sb.y + sb.h : sb.y,
                        sb.w < 0 ? -sb.w : sb.w,
                        sb.h < 0 ? -sb.h : sb.h)
                        ),
                    Ref(pos)) &&
                        !(a in values(gs[:ui][:horizontal_spinners])) &&
                        !(a in values(gs[:ui][:vertical_spinners])) &&
                        !(a in values(gs[:ui][:glass_counters]))

					push!(gs[:group][:selected], a)
                    filter!(x->x!==a, [ (values(gs[:zone])...)... ] )
                end
            end

            filter!(x->x!=sb, gs[:group][:selected])
            filter!(x->x!==gs[:zone]["Library"][end].faces[begin], gs[:group][:selected])

            if length(gs[:group][:selected]) > 0

				for a in gs[:group][:selected]
					a.scale = [1.025, 1.025]
                    a.data[:mouse_offset] = [ a.x - gs[:MOUSE_POS][1], a.y - gs[:MOUSE_POS][2] ]
                end

				play_sound("$GAME_DIR/sounds/select.wav")
            end

        elseif !isempty(gs[:group][:selected]) && !(g.keyboard.LSHIFT || g.keyboard.RSHIFT)

			for a in gs[:group][:selected]
				zone = zone_check(a, gs)

                if zone !== nothing
					for c in gs[:ALL_CARDS]
						if a.data[:parent_id] == c.id
							filter!(x->x!==c, [ (gs[:zone]...)... ])
							push!(gs[:zone][zone], c)
						end
					end

					AN.update_text_actor!(gs[:texts][:deck_info],
		                "Library: $(length(gs[:zone]["Library"]))")
		            AN.update_text_actor!(gs[:texts][:hand_info],
		                "Hand: $(length(gs[:zone]["Hand"]))")
		            AN.update_text_actor!(gs[:texts][:graveyard_info],
		                "Graveyard: $(length(gs[:zone]["Graveyard"]))")
		            AN.update_text_actor!(gs[:texts][:command_info],
		                "Command / Exile: $(length(gs[:zone]["Command"]))")
		            AN.update_text_actor!(gs[:texts][:battlefield_info],
		                "Battlefield: $(length(gs[:zone]["Battlefield"]))")

					filter!(x->x!==a, gs[:group][:clickables])

				else
					a.scale = [1, 1]
				end
			end

			push!(gs[:group][:clickables], gs[:group][:selected]...)
		    gs[:group][:selected] = []
		end
	end
end

# ╔═╡ 6159d724-468e-11eb-05fb-db68237e3fa0
function on_key_down(g::Game, key, keymod)
    global gs
	GAME_DIR = projectdir() * "games/MtG/MtG.jl/"
	DECK_NAME = gs[:deck]

    ib = in_bounds(gs)

    if key == Keys.C # && keymod !== 0 && keymod == Keymods.LCTRL || keymod == Keymods.RCTRL
        if !isempty(gs[:group][:selected])
            as = copy_actor.(gs[:group][:selected])
            push!(gs[:group][:selected], as...)
            push!(gs[:group][:clickables], as...)

        elseif !isempty(ib)
            copy = copy_actor(ib[end])
            push!(gs[:group][:selected], copy)
            push!(gs[:group][:clickables], copy)
        end

    elseif key == Keys.K
        if !isempty(gs[:group][:selected])
            for c in gs[:group][:selected]
                c.data[:shake] = c.data[:shake] ? false : true
            end
        elseif !isempty(ib)
            ib[end].data[:shake] = ib[end].data[:shake] ? false : true
        end

    elseif key == Keys.F

        if !isempty(gs[:group][:selected])

			for a in gs[:group][:selected]

				for c in gs[:ALL_CARDS]

					if a.data[:parent_id] == c.id
						@show "Changing faces for $(c.name)!"
						c.faces = circshift(c.faces, 1)
						c.faces[begin].position = a.position
					end
				end
            end

		elseif !isempty(ib)

			for c in gs[:ALL_CARDS]

				if ib[end].data[:parent_id] == c.id
					@show "Changing faces for $(c.name)!"
					c.faces = circshift(c.faces, 1)
					c.faces[begin].position = ib[end].position
					filter!(x->x==ib[end], gs[:group][:clickables])
					push!(gs[:group][:clickables], c.faces[begin])
					break
				end
			end
        end

    elseif key == Keys.V
        if !isempty(gs[:group][:selected])
            for c in gs[:group][:selected]
                c.data[:fade] = true
            end
        elseif !isempty(ib)
            ib[end].data[:fade] = true
        end

    elseif key == Keys.S
        spin_cw = g.keyboard.RALT || g.keyboard.LALT ? false : true
        if !isempty(gs[:group][:selected])
            for c in gs[:group][:selected]
                c.data[:spin_cw] = spin_cw
                c.data[:spin] = c.data[:spin] ? false : true
            end
        elseif !isempty(ib)
            ib[end].data[:spin_cw] = spin_cw
            ib[end].data[:spin] = ib[end].data[:spin] ? false : true
        end

    elseif key == Keys.L
        if !isempty(gs[:group][:selected])
            for c in gs[:group][:selected]
                if haskey(c.data, :next_frame)
					c.data[:next_frame] = c.data[:next_frame] ? false : true
				end
            end
        elseif !isempty(ib)
			if haskey(ib[end].data, :next_frame)
            	ib[end].data[:next_frame] = ib[end].data[:next_frame] ? false : true
			end
        end

    elseif key == Keys.DELETE
        if !isempty(gs[:group][:selected])
            kill_card!.(gs[:group][:selected])
            play_sound("$GAME_DIR/sounds/wilhelm.mp3")
        elseif !isempty(ib)
            kill_card!(ib[end])
            play_sound("$GAME_DIR/sounds/wilhelm.mp3")
        end

    elseif key == Keys.TAB
        if g.keyboard.RSHIFT || g.keyboard.LSHIFT
            if g.keyboard.RCTRL || g.keyboard.LCTRL
                reset_deck!(gs)
            else
                AN.reset_actor!.(gs[:group][:all_cards], gs[:deck][:CARD_WIDTH], gs[:deck][:CARD_HEIGHT])
            end

        elseif !isempty(gs[:group][:selected])
            AN.reset_actor!.(gs[:group][:selected], gs[:deck][:CARD_WIDTH], gs[:deck][:CARD_HEIGHT])

        elseif !isempty(ib)
            AN.reset_actor!(ib[end], gs[:deck][:CARD_WIDTH], gs[:deck][:CARD_HEIGHT])
        end

    elseif key == Keys.EQUALS
        if !isempty(gs[:group][:selected])
            AN.grow_actor!.(gs[:group][:selected], gs[:deck][:CARD_WIDTH], gs[:deck][:CARD_HEIGHT])
        elseif !isempty(ib)
            AN.grow_card(ib[end], gs[:deck][:CARD_WIDTH], gs[:deck][:CARD_HEIGHT])
        end

    elseif key == Keys.MINUS
        if !isempty(gs[:group][:selected])
            AN.shrink_actor!.(gs[:group][:selected], gs[:deck][:CARD_WIDTH], gs[:deck][:CARD_HEIGHT])
        elseif !isempty(ib)
            AN.shrink_actor!(ib[end], gs[:deck][:CARD_WIDTH], gs[:deck][:CARD_HEIGHT])
        end

    elseif key == Keys.SPACE && ib[end] !== gs[:zone]["Library"][end]
        zone_sym = zone_check(ib[end], gs)

        if zone_sym !== nothing
            if zone_sym == :graveyard
                AN.splay_actors!(
                    [ c.faces[begin] for c in gs[:zone][zone_sym] ],
                    gs[:stage][zone_sym].x,
                    gs[:stage][zone_sym].y,
                    SCREEN_HEIGHT,
                    SCREEN_BORDER,
                    pitch=[0.02, 0.04],
                    )
            elseif zone_sym !== :library
                AN.splay_actors!(
                    [ c.faces[begin] for c in gs[:zone][zone_sym] ],
                    gs[:stage][zone_sym].x,
                    gs[:stage][zone_sym].y,
                    SCREEN_HEIGHT,
                    SCREEN_BORDER,
                    pitch=[0.05, 0.1],
                )
            end
        end
        play_sound("$GAME_DIR/sounds/splay_actors.mp3")

    elseif key == Keys.BACKQUOTE
        try
            if "terminal.jls" in readdir(projectdir())
                @show eval(g.game_module, Meta.parse(deserialize(projectdir() * "/terminal.jls")))
                rm(projectdir() * "/terminal.jls")
            end
        catch e
            @warn e
        end

	elseif key == Keys.F11
        #SDL2.SetWindowFullscreen(g.screen.window, SDL2.WINDOW_FULLSCREEN)
        SDL2.SetWindowFullscreen(g.screen.window, SDL2.WINDOW_FULLSCREEN_DESKTOP)
    end
end

# ╔═╡ 64b89860-468e-11eb-2b22-fff8ae5ea566
function update(g::Game)
    global gs, then

    ib = in_bounds(gs)

    for a in gs[:group][:clickables]
		if a isa Card
			a = a.faces[begin]
		end
        if a.data[:spin]; AN.spin_card(a) end
        if a.data[:shake]; AN.shake_card(a) end
        if a.data[:fade]; AN.fade_card(a) end
        if haskey(a.data, :next_frame) && a.data[:next_frame]
            if now() - a.data[:then] > a.data[:frame_delays][begin]
                AN.next_frame!(a)
            end
        end
    end
end

# ╔═╡ 70d25e54-468e-11eb-160f-9bdafa1ee16c
begin
	draw(c::Card) = draw(c.faces[begin])
	#play_music(gs[:music][end], 1)  # play_music(name, loops=-1)

	#SDL2.SetWindowFullscreen(game[].screen.window, SDL2.WINDOW_FULLSCREEN_DESKTOP)
end

# ╔═╡ Cell order:
# ╟─ad8ff974-4b71-11eb-3eb6-790d687615c0
# ╠═b35cdada-4689-11eb-2629-c1cedd8052bd
# ╟─409648d8-468e-11eb-2856-5bda6584cf79
# ╠═438d93b6-468e-11eb-2cdd-650d3873e81d
# ╟─799c2578-4cb3-11eb-1af7-b1ab01270e6d
# ╟─47f50362-468e-11eb-211d-f561273a906c
# ╟─4cbb84f2-468e-11eb-09af-718f893c0449
# ╟─54761f68-468e-11eb-3ab9-db06b7174615
# ╟─6159d724-468e-11eb-05fb-db68237e3fa0
# ╟─64b89860-468e-11eb-2b22-fff8ae5ea566
# ╠═69917186-468e-11eb-1175-dd4bbfe2f109
# ╟─cdd4c524-4cba-11eb-07a2-c7651ae7f211
# ╟─7ef01b58-523d-11eb-0c16-2b1d02dd1836
# ╠═70d25e54-468e-11eb-160f-9bdafa1ee16c
