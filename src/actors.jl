module Actors

using Dates
using Images
using GameOne
using ShiftedArrays

const SDL2 = GameOne.SDL2

function Image(img_name::String, img; x=0, y=0, kv...)
    @show img_name
    img = ARGB.(transpose(img))
    w, h = Int32.(size(img))
    sf = SDL2.CreateRGBSurfaceWithFormatFrom(
        img,
        w,
        h,
        Int32(32),
        Int32(4w),
        SDL2.PIXELFORMAT_ARGB32,
    )

    r = SDL2.Rect(x, y, w, h)
    a = GameOne.Actor(
        img_name,
        [sf],
        [],
        r,
        [1,1],
        C_NULL,
        0,
        255,
        Dict(
            :img=>img,
            :label=>img_name,
            :sz=>[w,h],
            :fade=>false,
            :fade_out=>true,
            :spin=>false,
            :spin_cw=>true,
            :shake=>false,
            :mouse_offset=>Int32[0,0],
        )
    )

    for (k, v) in kv
        setproperty!(a, k, v)
    end
    return a
end


function Text(text::String, font_path::String; x=0, y=0, pt_size=24,
    font_color=Int[255,255,0,200], wrap_length=800, kv...)
    @show text

    text_font = SDL2.TTF_OpenFont(font_path, pt_size)
    sf = SDL2.TTF_RenderText_Blended_Wrapped(text_font, text, SDL2.Color(font_color...), UInt32(wrap_length))
    w, h = size(sf)
    r = SDL2.Rect(x, y, w, h)

    a = GameOne.Actor(
        text,
        [sf],
        [],
        r,
        [1,1],
        C_NULL,
        0,
        255,
        Dict(
            :sz=>[w,h],
            :fade=>false,
            :fade_out=>true,
            :spin=>false,
            :spin_cw=>true,
            :shake=>false,
            :next_frame=>false,
            :font_path=>font_path,
            :pt_size=>pt_size,
            :wrap_length=>wrap_length,
            :mouse_offset=>Int32[0,0],
            :font_color=>font_color,
        )
    )
    for (k, v) in kv
        setproperty!(a, k, v)
    end

    return a
end

function GIF(gif_name::String, gif; x=0, y=0, frame_delay=Millisecond(120), kv...)
    @show gif_name
    h, w, n = Int32.(size(gif))
    frame_delays = [ frame_delay for i in 1:n ]
    surfaces = []

    for i in 1:n
        gimg = ARGB.(transpose(gif[:,:,i]))
        sf = SDL2.CreateRGBSurfaceWithFormatFrom(
            gimg,
            w,
            h,
            Int32(32),
            Int32(4 * w),
            SDL2.PIXELFORMAT_ARGB32,
        )
        push!(surfaces, sf)
    end

    r = SDL2.Rect(x, y, w, h)
    a = GameOne.Actor(
        gif_name,
        surfaces,
        [],
        r,
        [1,1],
        C_NULL,
        0,
        255,
        Dict(
            :sz=>[w, h],
            :fade=>false,
            :fade_out=>true,
            :spin=>false,
            :spin_cw=>true,
            :shake=>false,
            :then=>now(),
            :next_frame=>false,
            :frame_delays=>frame_delays,
            :mouse_offset=>Int32[0,0],
        )
    )

    for (k, v) in kv
        setproperty!(a, k, v)
    end
    return a
end

end # module
