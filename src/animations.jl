module Animations

using DrWatson
@quickactivate

using Dates
using Random
using GZ2
using DataStructures
using SimpleDirectMediaLayer

SDL2 = SimpleDirectMediaLayer
AN_list = [:spin, :shake, :fade, :grow, :shrink, :squish]

function bomb_card(a::Actor)
    then = now()
end

function shake_actor!(a::Actor, f=2)
    if a.angle > 0
        a.angle -= ceil(Int32, a.angle / f)
    elseif a.angle < 0
        a.angle += ceil(Int32, abs(a.angle) / f)
    else
        a.angle = rand(-15:15)
    end
end

function spin_actor!(a::Actor; dθ=2)
    a.angle += a.data[:spin_cw] ? dθ : -dθ
end

function squish_actor(a::Actor, dir=:horizontal, limit=10, f=10)
	if dir == :horizontal
		if a.w > limit
			a.w -= f
		end
	elseif dir == :vertical
		if a.h > limit
			a.h -= f
		end
	end
end

function shrink_actor!(a::Actor, h::Number, w::Number, f=25)
	if a.h > h / 2.5 || a.w > w / 2.5
        a.w -= ceil(Int32, w / f)
        a.h -= ceil(Int32, h / f)
    end
end

function grow_actor!(a::Actor, oh::Number, ow::Number, f=25)
	if a.h < oh * 2.5 || a.w < ow * 2.5
        a.w += ceil(Int32, ow / f)
        a.h += ceil(Int32, oh / f)
    end
end

function fade_actor!(a::Actor, f::Int=2)
    if a.data[:fade_out]
        if a.alpha - f < 0
            a.alpha = 0
            a.data[:fade] = false
            a.data[:fade_out] = false
        else
            a.alpha -= f
        end
    else
        if a.alpha + f > 255
            a.alpha = 255
            a.data[:fade] = false
            a.data[:fade_out] = true
        else
            a.alpha += f
        end
    end
end

function reset_actor!(a::Actor, h::Int32, w::Int32)
	a.w = w
	a.h = h
    a.angle = 0

    for AN_sym in AN_list
        a.data[AN_sym] = false
    end

	return a
end

function change_face!(o::T) where T
	@show "Changing face of $(o.name)!"
	o.faces = circshift(o.faces, -1)
	o.faces[begin].angle = o.faces[end].angle
	return o
end

function splay_actors!(actors::Vector{Actor}, x::Int32, y::Int32,
    SCREEN_HEIGHT::Int32, SCREEN_BORDER::Int32; pitch=Float64[1, 1])

    for a in actors

        if pitch[2] < 0 && y < SCREEN_BORDER
            y = SCREEN_HEIGHT - SCREEN_BORDER - a.h * a.scale[2]
            x += ceil(Int32, a.w * pitch[1] > 0 ? 1.25 : -1.25)
        end

        if pitch[2] > 0 && y + a.h * a.scale[2] > SCREEN_HEIGHT - SCREEN_BORDER
            y = SCREEN_BORDER
            @show x += ceil(Int32, pitch[1] > 0 ? 0.55a.w : -0.55a.w)
        end

        a.x = x
        a.y = y

        x += ceil(Int32, a.w * a.scale[1] * pitch[1])
        y += ceil(Int32, a.h * a.scale[2] * pitch[2])
    end

	return actors
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

function next_frame!(a::Actor)
    a.textures = circshift(a.textures, -1)
    a.data[:then] = now()
	return a
end

end # module
