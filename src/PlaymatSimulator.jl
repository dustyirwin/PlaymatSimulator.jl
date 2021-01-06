module PlaymatSimulator

using GZ2
using SimpleDirectMediaLayer

export Actors, Animations, make_name_safe, in_bounds, copy_actor

SDL2 = SimpleDirectMediaLayer
Animations = include("animations.jl")
Actors = include("actors.jl")
include("terminal.jl")
include("auth.jl")
include("IO.jl")
include("logging.jl")

function make_name_safe(card_name::String)
    card_name = lowercase(card_name)
    card_name = replace(card_name, " "=>"_")
    card_name = replace(card_name, ","=>"")
    card_name = replace(card_name, "//"=>"--")
end

function copy_actor(a::Actor)
    c = occursin(".", a.label) ? Actors.Image(a.label) : Actors.Text(a.label, a.data[:font_path])
    c.w = a.w
    c.h = a.h
    c.x = a.x + 20
    c.y = a.y + 20
    c.data = a.data
    return c
end

function in_bounds(gs::Dict, as=Actor[])
    for a in gs[:group][:clickables]
        pos = if a.angle == 90 || a.angle == 270  # corrects for 90 & 270 rot abt center
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
            Ref(pos), Ref(gs[:ui][:cursor].position))
            push!(as, a)
        end
    end
    return as
end

function download_card_by_name(card_name::String, card_data::Array, found_card=false)
	for (i,c) in enumerate(card_data)
		if card_data[i]["name"] == c["name"]
			download_mtg_imgs([ c ])
			found_card = true
			break
		end
	end

	if !found_card
		@warn "$card_name not found in the database!"
	else
		return card_name
	end
end

function kill_actor!(a::Actor)
    for (i,sf) in enumerate(a.surfaces)
        a.surfaces[i] = SDL2.C_NULL
    end

    for (i,tx) in enumerate(a.textures)
        a.textures[i] = SDL2.C_NULL
    end

    SDL2.FreeSurface.(a.surfaces)
    SDL2.DestroyTexture.(a.textures)
end

function download_mtg_imgs(deck_cards::Vector{Any}, save_dir="images", throttle=0.1)
	for card in deck_cards
		println("""Processing MtG card $(card["name"])""")

		try
			if "card_faces" in keys(card)

				if "image_uris" in keys(card["card_faces"][begin])
					uri_front = card["card_faces"][1]["image_uris"]["border_crop"]
					uri_back = card["card_faces"][2]["image_uris"]["border_crop"]

					img_front = get_card_img(uri_front)
					img_back = get_card_img(uri_back)

					safesave("$save_dir/$(card["name"]).png", img_front)
					safesave("$save_dir/$(card["name"]).png", img_back)
				else
					img = get_card_img(card["image_uris"]["border_crop"])
					safesave("$save_dir/$(card["name"]).png", img)
				end

			else
				img = get_card_img(card["image_uris"]["border_crop"])
				safesave("images/$(card["name"]).png", img)
			end

		catch e
			@warn e
		end

		sleep(throttle)
	end
end

finalizer(kill_actor!, Actor)

SimpleDirectMediaLayer.ShowCursor(Int32(0))  # hides system mouse cursor

end # module
