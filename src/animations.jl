module Animations

using Dates
using Random
using GZ2
using DataStructures
using SimpleDirectMediaLayer

export flip_card!

SDL2 = SimpleDirectMediaLayer
AN_list = [:spin, :shake, :fade, :grow, :shrink, :squish]

function bomb_card(c::Actor)
    then = now()
    push!(gs[:ui][:effects][:bomb1], gs[:battlefield])

end

function break_card(c::Actor)
    push!(gs[:ui][:effects][:break1], gs[:battlefield])
end

function shake_card(c::Actor, f=2)
    if c.angle > 0
        c.angle -= ceil(Int32, c.angle / f)
    elseif c.angle < 0
        c.angle += ceil(Int32, abs(c.angle) / f)
    else
        c.angle = rand(-20:20)
    end
end

function spin_card(c::Actor; dθ=1)
    c.angle += c.data[:spin_cw] ? dθ : -dθ
end

function flip_card!(c::Actor, CARD_BACK_PATH::String)
	if c.label == CARD_BACK_PATH
		c.label = c.data[:label]
		c.surfaces = c.data[:surfaces]
	else
		c.label = c.data[:label]
		c.data[:surfaces] = c.surfaces
		c.surfaces = [ GZ2.image_surface(CARD_BACK_PATH) ]
	end
	c.textures = []
	return c
end

function squish_card(c::Actor, dir=:horizontal, limit=10, f=10)
	if dir == :horizontal
		if c.w > limit
			c.w -= f
		end
	elseif dir == :vertical
		if c.h > limit
			c.w -= f
		end
	end
end

function shrink_card(c::Actor, h::Number, w::Number, f=25)
    if c.h > h / 2.5 || c.w > w / 2.5
        c.w -= ceil(w / f)
        c.h -= ceil(h / f)
    end
end

function grow_card(c::Actor, oh::Number, ow::Number, f=25)
    if c.h < oh * 2.5 || c.w < ow * 2.5
        c.w += ceil(ow / f)
        c.h += ceil(oh / f)
    end
end

function fade_card(c::Actor, f::Int=2)
    if c.data[:fade_out]
        if c.alpha - f < 0
            c.alpha = 0
            c.data[:fade] = false
            c.data[:fade_out] = false
            return
        else
            c.alpha -= f
        end
    else
        if c.alpha + f > 255
            c.alpha = 255
            c.data[:fade] = false
            c.data[:fade_out] = true
            return
        else
            c.alpha += f
        end
    end
end

function reset_card(c::Actor, w::Int32, h::Int32)
    c.w = w
    c.h = h
    c.angle = 0

    for AN_sym in AN_list
        c.data[AN_sym] = false
    end
end

function splay_cards(cards::Vector{Actor}, x::Int32, y::Int32,
    SCREEN_HEIGHT::Int32, SCREEN_BORDER::Int32; pitch=Float64[10, 10])

    for c in cards

        if pitch[2] < 0 && y < SCREEN_BORDER
            y = SCREEN_HEIGHT - SCREEN_BORDER - c.h * c.scale[2]
            x -= ceil(Int32, c.w * pitch[1] > 0 ? 0.5 : -0.5)
        end

        if pitch[2] > 0 && y + c.h * c.scale[2] > SCREEN_HEIGHT - SCREEN_BORDER
            y = SCREEN_BORDER
            x -= ceil(Int32, c.w * pitch[1] > 0 ? 0.5 : -0.5)
        end

        c.x = x
        c.y = y

        x += ceil(Int32, c.w * c.scale[1] * pitch[1])
        y += ceil(Int32, c.h * c.scale[2] * pitch[2])
    end
end

function update_text_actor!(a::Actor, new_text::String)
    font = SDL2.TTF_OpenFont(a.data[:font_path], a.data[:pt_size])
    a.surfaces = [ SDL2.TTF_RenderText_Blended_Wrapped(font, new_text,
        SDL2.Color(a.data[:font_color]...), UInt32(a.data[:wrap_length])) ]
    a.w, a.h = size(a.surfaces[begin])
    a.label = new_text
    a.textures = []
    return a
end

function next_frame(a::Actor)
    a.textures = circshift(a.textures, -1)
    a.data[:then] = now()
end

end # module