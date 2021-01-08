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
	import PlaymatSimulator.in_bounds
	import PlaymatSimulator.kill_actor!
	import PlaymatSimulator.Animations.flip_card!

	const SDL2 = SimpleDirectMediaLayer

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

	md"""
	### COMMON MtG FUNCS
	"""
end

# ╔═╡ 409648d8-468e-11eb-2856-5bda6584cf79
function zone_check(a::Actor, gs::Dict)
    for zone_sym in keys(gs[:zone])
        if SDL2.HasIntersection(
            Ref(SDL2.Rect(Int32[ceil(a.x + a.w * a.scale[1]/2), ceil(a.y + a.h * a.scale[2]/2), 1, 1]...)), # intersection determined from top-left most pixel
            Ref(gs[:stage][zone_sym].position))
            return zone_sym
        end
    end
    @warn "$(a.label) not found in any :stage area!"
end

# ╔═╡ 438d93b6-468e-11eb-2cdd-650d3873e81d
function kill_card!(a::Actor)
    global gs

    filter!.(x->x !== a, [ values(gs[:zone])..., values(gs[:group])... ])
    kill_actor!(a)
end

# ╔═╡ 799c2578-4cb3-11eb-1af7-b1ab01270e6d
function reset_deck!(gs::Dict)
    GAME_NAME = gs[:GAME_NAME]
    GAME_DIR = gs[:GAME_DIR]
    DECK_NAME = gs[:DECK_NAME]
    CARD_WIDTH = gs[:CARD_WIDTH]
    CARD_HEIGHT = gs[:CARD_HEIGHT]
    SCREEN_WIDTH = gs[:SCREEN_WIDTH]
    SCREEN_HEIGHT = gs[:SCREEN_HEIGHT]
    SCREEN_BORDER = gs[:SCREEN_BORDER]
	CARD_IMG_RATIO = gs[:deck][:CARD_IMG_RATIO]
	DECK_DIR = "$GAME_DIR/../$GAME_NAME/decks/$DECK_NAME"

    for k in keys(gs[:zone])
        gs[:zone][k] = []
    end

    for k in keys(gs[:group])
        gs[:group][k] = []
    end

    deck = deserialize("$DECK_DIR/$DECK_NAME.jls")

	deck[:Backside] = Image("Backside", deck[:CARD_BACK_IMG])

	CARDS = []

	for (name, img) in zip(gs[:deck][:card_names], gs[:deck][:CARD_FRONT_IMGS])
		c = Card(
			rand(1:9999),
			name,
			"player1",
			"player1",
			:library,
			[ Image(name, img), deck[:Backside] ],
			false,
			false,
			Dict(),
			)

		push!(CARDS, c)
	end

	COMMANDERS = []

	for (name, img) in zip(gs[:deck][:commander_names], gs[:deck][:COMMANDER_FRONT_IMGS])
		c = Card(
			rand(1:9999),
			name,
			"player1",
			"player1",
			:library,
			[ Image(name, img), deck[:Backside] ],
			false,
			false,
			Dict(),
			)

		push!(COMMANDERS, c)
	end

	gs[:zone][:library] = shuffle([ c.faces[begin] for c in CARDS ])

	#for c in gs[:zone][:library]
	#	PlaymatSimulator.Animations.flip_card!(c, gs[:deck][:CARD_BACK_PATH])
	#end

    gs[:zone][:command] = [ c.faces[begin] for c in COMMANDERS ]

	push!(gs[:group][:all_cards], gs[:zone][:command]...)
	push!(gs[:group][:all_cards], gs[:zone][:library]...)
	pushfirst!(gs[:group][:clickables], values(gs[:ui][:horizontal_spinners])...)
	pushfirst!(gs[:group][:clickables], values(gs[:ui][:vertical_spinners])...)
	pushfirst!(gs[:group][:clickables], values(gs[:ui][:glass_counters])...)

    gs[:zone][:hand] = reverse([ pop!(gs[:zone][:library]) for i in 1:7 ])

	pushfirst!(gs[:group][:clickables], gs[:zone][:library][end])
	pushfirst!(gs[:group][:clickables], gs[:zone][:hand]...)
	pushfirst!(gs[:group][:clickables], gs[:zone][:command]...)

	#for c in gs[:zone][:hand]
	#	PlaymatSimulator.Animations.flip_card!(c, gs[:deck][:CARD_BACK_PATH])
	#end

    PlaymatSimulator.Animations.splay_actors(gs[:zone][:hand], 	# splay cards into hand zone
        SCREEN_BORDER,
        SCREEN_BORDER,
        SCREEN_HEIGHT,
        SCREEN_BORDER,
        pitch=[0.05, 0.1],
    )

    PlaymatSimulator.Animations.splay_actors(gs[:zone][:library],  # stack library cards into deck
        SCREEN_BORDER,
        SCREEN_HEIGHT - SCREEN_BORDER - CARD_HEIGHT,
        SCREEN_HEIGHT,
        SCREEN_BORDER,
        pitch=[0.001, -0.005],
    )

    for (i,c) in enumerate(gs[:zone][:command])
        c.y = SCREEN_BORDER + (i-1) * 30
        c.x = gs[:stage][:command].x + (i-1) * 15
		c.w = ceil(Int32, c.w * 1.2)
		c.h = ceil(Int32, c.h * 1.2)
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

# ╔═╡ 4cbb84f2-468e-11eb-09af-718f893c0449
function on_mouse_down(g::Game, pos::Tuple, button::GZ2.MouseButtons.MouseButton)
    global gs
    ib = in_bounds(gs)
	GAME_DIR = projectdir() * "games/MtG/MtG.jl"
	DEFAULT_CARD_WIDTH = gs[:CARD_WIDTH]
    DEFAULT_CARD_HEIGHT = gs[:CARD_HEIGHT]

    if button == GZ2.MouseButtons.WHEEL_UP && !isempty(ib)
        AN.grow_card(ib[end])

    elseif button == GZ2.MouseButtons.WHEEL_DOWN && !isempty(ib)
        AN.shrink_card(ib[end])

    elseif button == GZ2.MouseButtons.LEFT
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

                for c in gs[:group][:selected]
                    c.data[:mouse_offset] = [ c.x - gs[:MOUSE_POS][1], c.y - gs[:MOUSE_POS][2] ]
                end

            elseif ib[end] === gs[:zone][:library][end] && g.keyboard.LCTRL || g.keyboard.RCTRL
                push!(gs[:group][:selected], gs[:zone][:library][end])

            elseif ib[end] === gs[:zone][:library][end] && length(gs[:zone][:library]) > 1 # pull card from top of deck into hand & selected if any cards left in library
                c = pop!(gs[:zone][:library])

                c.scale = [1.02, 1.02]
                c.x = ceil(Int32, (length(gs[:zone][:hand]) > 0 ?
                    gs[:zone][:hand][end].x : gs[:stage][:hand].x) + c.w * 0.05)
                c.y = ceil(Int32, (length(gs[:zone][:hand]) > 0 ?
                    gs[:zone][:hand][end].y : gs[:stage][:hand].y) + c.h * 0.1)

                push!(gs[:group][:selected], c)
                push!(gs[:group][:all_cards], c)
                push!(gs[:group][:clickables], c)
				push!(gs[:group][:clickables], gs[:zone][:library][end])

            elseif ib[end] === gs[:ui][:vertical_spinners][:plus_minus_counter]
                if g.keyboard.LCTRL || g.keyboard.RCTRL
                    push!(gs[:group][:selected], ib[end])
                else
                    val = ib[end].data[:value]
                    val_str = val < 0 ? "$val / $val" : "+$val / +$val"
                    fp = "$GAME_DIR/fonts/OpenSans-Semibold.ttf"
                    pt_size = 24

                    copy = AC.Text(val_str, fp)
                    push!(gs[:group][:selected], copy)
                    push!(gs[:overlay][:counters], copy)
                end

            elseif ib[end] in values(gs[:ui][:glass_counters])
                if g.keyboard.LCTRL || g.keyboard.RCTRL
                    push!(gs[:group][:selected], ib[end])
                else
                    copy = AC.Image(ib[end].label, x=gs[:MOUSE_POS][1], y=gs[:MOUSE_POS][2])
                    push!(gs[:group][:selected], copy)
                    push!(gs[:overlay][:counters], copy)
                end

            elseif isempty(gs[:group][:selected]) &&
                !(ib[end] in values(gs[:ui][:horizontal_spinners])) &&
                !(ib[end] in values(gs[:ui][:vertical_spinners]))

                play_sound("$GAME_DIR/sounds/select.wav")
                @show ib[end].label, ib[end].x, ib[end].y
                ib[end].scale=[1.02, 1.02]
                zs = zone_check(ib[end], gs)

                ctrs = [ c for c in values(gs[:overlay][:counters])
                    if SDL2.HasIntersection(
                        Ref(ib[end].position),
                        Ref(c.position)) && !(ib[end] in gs[:overlay][:counters])
                    ]
                for c in ctrs
                    c.data[:mouse_offset] = [ c.x - gs[:MOUSE_POS][1], c.y - gs[:MOUSE_POS][2] ]
                end

                push!(gs[:group][:selected], [ ctrs..., ib[end] ]...)

                if zs !== nothing
                    filter!(x->x!==ib[end], gs[:zone][zs])
                end

                ib[end].data[:mouse_offset] = [ ib[end].x - gs[:MOUSE_POS][1], ib[end].y - gs[:MOUSE_POS][2] ]
            end
        end

    elseif button == GZ2.MouseButtons.RIGHT
        if !isempty(gs[:group][:selected])
            for c in gs[:group][:selected]
                c.angle = c.angle == 0 ? 90 : 0
            end

        elseif !isempty(ib)
            if ib[end] === gs[:zone][:library][end]
                filter!(x->!(x in [gs[:zone][:hand]..., gs[:zone][:battlefield]...]), gs[:group][:clickables])
                sorted = SortedDict(a.label=>a for a in gs[:zone][:library])
                gs[:zone][:library] = [ values(sorted)... ]
                push!(gs[:group][:clickables], gs[:zone][:library]...)

                if SDL2.HasIntersection(
                    Ref(gs[:zone][:library][end].position), Ref(gs[:stage][:library].position))

                    AN.splay_actors(
                        gs[:zone][:library],
                        ceil(Int32, gs[:stage][:hand].w + 2SCREEN_BORDER),
                        SCREEN_BORDER,
                        SCREEN_HEIGHT,
                        SCREEN_BORDER,
                        pitch=[0.065, 0.1]
                    )
                else
                    for c in reverse(gs[:zone][:library])
                        if SDL2.HasIntersection(Ref(c.position), Ref(gs[:stage][:hand].position))
                            c_inds = findfirst(x->x.label==c.label, gs[:zone][:library])
                            c = deepcopy(gs[:zone][:library][c_inds])
                            deleteat!(gs[:zone][:library], c_inds)
                        end
                    end

                    shuffle!(gs[:zone][:library])

					for c in gs[:zone][:library]
						filter!(x->x==c, gs[:group][:clickables])
					end

                    AN.splay_actors(gs[:zone][:library],
                        SCREEN_BORDER,
                        SCREEN_HEIGHT - SCREEN_BORDER - DEFAULT_CARD_HEIGHT,
                        SCREEN_HEIGHT,
                        SCREEN_BORDER,
                        pitch=[0.001, -0.005]
                    )

                    gs[:group][:clickables] = [
                        (values(gs[:zone])... )...,
                        values(gs[:ui][:horizontal_spinners])...,
                        values(gs[:ui][:vertical_spinners])...,
                        values(gs[:ui][:glass_counters])...,
                    ]

					filter!(x->!(x in gs[:zone][:library][begin:end-1]), gs[:group][:clickables])
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

            for c in gs[:group][:clickables]

                pos = if c.angle == 90 || c.angle == 270  # corrects for 90 & 270 rot abt center
                    SDL2.Rect(
                        ceil(c.x - (c.scale[2] * c.h - c.scale[1] * c.w) / 2),
                        ceil(c.y + (c.scale[2] * c.h - c.scale[1] * c.w) / 2),
                        c.h,
                        c.w,
                    )
                else
                    c.position
                end

                if SDL2.HasIntersection(
                    Ref(SDL2.Rect(
                        sb.w < 0 ? sb.x + sb.w : sb.x,
                        sb.h < 0 ? sb.y + sb.h : sb.y,
                        sb.w < 0 ? -sb.w : sb.w,
                        sb.h < 0 ? -sb.h : sb.h)
                        ),
                    Ref(pos)) &&
                        !(c in values(gs[:ui][:horizontal_spinners])) &&
                        !(c in values(gs[:ui][:vertical_spinners])) &&
                        !(c in values(gs[:ui][:glass_counters]))

                    push!(gs[:group][:selected], c)
                    filter!(x->x!==c, [ (values(gs[:zone])...)... ] )
                end
            end

            filter!(x->x!=sb, gs[:group][:selected])
            filter!(x->x!==gs[:zone][:library][end], gs[:group][:selected])

            if length(gs[:group][:selected]) > 0
                for c in gs[:group][:selected]
                    z = zone_check(c, gs)
                    if z !== nothing
                        filter!(x->x!==c, gs[:zone][z])
                    end
                    c.scale = [1.02, 1.02]
                    c.data[:mouse_offset] = [ c.x - gs[:MOUSE_POS][1], c.y - gs[:MOUSE_POS][2] ]
                end
                play_sound("$GAME_DIR/sounds/select.wav")
            end

        elseif !isempty(gs[:group][:selected]) && !(g.keyboard.LSHIFT || g.keyboard.RSHIFT)
            for c in gs[:group][:selected]
                c.scale = [1, 1]
                z = zone_check(c, gs)

                if z !== nothing
                    filter!(x->x !== c, gs[:zone][z])
                    push!(gs[:zone][z], c)
                end

                filter!(x->x !== c, gs[:group][:clickables])
            end
            push!(gs[:group][:clickables], gs[:group][:selected]...)

            AN.update_text_actor!(gs[:texts][:deck_info],
                "Library: $(length(gs[:zone][:library]))"
            )
            AN.update_text_actor!(gs[:texts][:hand_info],
                "Hand: $(length(gs[:zone][:hand]))"
            )
            AN.update_text_actor!(gs[:texts][:graveyard_info],
                "Graveyard: $(length(gs[:zone][:graveyard]))"
            )
            AN.update_text_actor!(gs[:texts][:command_info],
                "Command / Exile: $(length(gs[:zone][:command]))"
            )
            AN.update_text_actor!(gs[:texts][:battlefield_info],
                "Battlefield: $(length(gs[:zone][:battlefield]))"
            )
            gs[:group][:selected] = Actor[]
        end
    end
end

# ╔═╡ 6159d724-468e-11eb-05fb-db68237e3fa0
function on_key_down(g::Game, key, keymod)
    global gs
	GAME_DIR = projectdir() * "games/MtG/MtG.jl/"
	DEFAULT_CARD_WIDTH = gs[:CARD_WIDTH]
	DEFAULT_CARD_HEIGHT = gs[:CARD_HEIGHT]
	DECK_NAME = gs[:deck]

    #@show key, keymod
    ib = in_bounds(gs)

    if key == Keys.C # && keymod !== 0 && keymod == Keymods.LCTRL || keymod == Keymods.RCTRL
        if !isempty(gs[:group][:selected])
            as = copy_actor.(gs[:group][:selected])
            push!(gs[:group][:selected], as...)
            push!(gs[:group][:clickables], as...)
            #push!(gs[:group][:all_cards], as...)

        elseif !isempty(ib)
            copy = copy_actor(ib[end])
            push!(gs[:group][:selected], copy)
            push!(gs[:group][:clickables], copy)
            #push!(gs[:group][:all_cards], copy)
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
            for (i,c) in enumerate(gs[:group][:selected])
                gs[:group][:selected][i] = flip_card!(c)
            end
        elseif !isempty(ib)
            ib[end] = flip_card!(ib[end])
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
                AN.reset_card.(gs[:group][:all_cards], DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT)
            end

        elseif !isempty(gs[:group][:selected])
            AN.reset_card.(gs[:group][:selected], DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT)

        elseif !isempty(ib)
            AN.reset_card(ib[end], DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT)
        end

    elseif key == Keys.EQUALS
        if !isempty(gs[:group][:selected])
            AN.grow_card.(gs[:group][:selected], DEFAULT_CARD_HEIGHT, DEFAULT_CARD_WIDTH)
        elseif !isempty(ib)
            AN.grow_card(ib[end], DEFAULT_CARD_HEIGHT, DEFAULT_CARD_WIDTH)
        end

    elseif key == Keys.MINUS
        if !isempty(gs[:group][:selected])
            AN.shrink_card.(gs[:group][:selected], DEFAULT_CARD_HEIGHT, DEFAULT_CARD_WIDTH)
        elseif !isempty(ib)
            AN.shrink_card(ib[end], DEFAULT_CARD_HEIGHT, DEFAULT_CARD_WIDTH)
        end


    elseif key == Keys.SPACE && ib[end] !== gs[:zone][:library][end]
        zone_sym = zone_check(ib[end], gs)

        if zone_sym !== nothing
            if zone_sym == :graveyard
                AN.splay_actors(
                    gs[:zone][zone_sym],
                    gs[:stage][zone_sym].x,
                    gs[:stage][zone_sym].y,
                    SCREEN_HEIGHT,
                    SCREEN_BORDER,
                    pitch=[0.02, 0.04],
                    )
            elseif zone_sym !== :library
                AN.splay_actors(
                    gs[:zone][zone_sym],
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
        if a.data[:spin]; AN.spin_card(a) end
        if a.data[:shake]; AN.shake_card(a) end
        if a.data[:fade]; AN.fade_card(a) end
        if haskey(a.data, :next_frame) && a.data[:next_frame]
            if now() - a.data[:then] > a.data[:frame_delays][begin]
                AN.next_frame(a)
            end
        end
    end
end

# ╔═╡ 69917186-468e-11eb-1175-dd4bbfe2f109
function draw(g::Game)
    draw.([
        # bottom layer
        values(gs[:stage])...,
        [ (values(gs[:zone])... )... ]...,
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
    gs[:texts][:deck_info] = Text("Library: $(length(gs[:zone][:library]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=2SCREEN_BORDER,
        y=SCREEN_HEIGHT - 4SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:hand_info] = Text("Hand: $(length(gs[:zone][:hand]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=2SCREEN_BORDER,
        y=gs[:stage][:hand].h - 2SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:battlefield_info] = Text("Battlefield: $(length(gs[:zone][:battlefield]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=gs[:stage][:hand].w + 10SCREEN_BORDER,
        y=SCREEN_HEIGHT - 4SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:command_info] = Text("Command / Exile: $(length(gs[:zone][:command]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=gs[:stage][:command].x + SCREEN_BORDER,
        y=gs[:stage][:command].h - 2SCREEN_BORDER,
        pt_size=22,
        )
    gs[:texts][:graveyard_info] = Text("Graveyard: $(length(gs[:zone][:graveyard]))",
        "$GAME_DIR/fonts/OpenSans-Regular.ttf",
        x=gs[:stage][:graveyard].x + SCREEN_BORDER,
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

    PlaymatSimulator.Animations.splay_actors(Actor[ s for s in values(gs[:ui][:horizontal_spinners])],
        ceil(Int32, SCREEN_WIDTH * 0.955),
        Int32(2SCREEN_BORDER),
        SCREEN_HEIGHT,
        SCREEN_BORDER,
        pitch=Float64[0,1]
        )

    gs[:group][:clickables] = [
        gs[:zone][:command]...,
        gs[:zone][:hand]...,
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

# ╔═╡ 70d25e54-468e-11eb-160f-9bdafa1ee16c
begin
	#play_music(gs[:music][end], 1)  # play_music(name, loops=-1)

	#SDL2.SetWindowFullscreen(game[].screen.window, SDL2.WINDOW_FULLSCREEN_DESKTOP)
end

# ╔═╡ Cell order:
# ╟─ad8ff974-4b71-11eb-3eb6-790d687615c0
# ╟─b35cdada-4689-11eb-2629-c1cedd8052bd
# ╟─409648d8-468e-11eb-2856-5bda6584cf79
# ╟─438d93b6-468e-11eb-2cdd-650d3873e81d
# ╠═799c2578-4cb3-11eb-1af7-b1ab01270e6d
# ╟─47f50362-468e-11eb-211d-f561273a906c
# ╟─4cbb84f2-468e-11eb-09af-718f893c0449
# ╟─54761f68-468e-11eb-3ab9-db06b7174615
# ╟─6159d724-468e-11eb-05fb-db68237e3fa0
# ╟─64b89860-468e-11eb-2b22-fff8ae5ea566
# ╟─69917186-468e-11eb-1175-dd4bbfe2f109
# ╟─cdd4c524-4cba-11eb-07a2-c7651ae7f211
# ╠═70d25e54-468e-11eb-160f-9bdafa1ee16c
