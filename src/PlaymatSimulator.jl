module PlaymatSimulator

using SimpleDirectMediaLayer
using Reexport

@reexport using GameZero

export Actors, Animations, in_bounds, copy_actor


SDL2 = SimpleDirectMediaLayer
Animations = include("animations.jl")
Actors = include("actors.jl")
include("terminal.jl")
include("auth.jl")
include("IO.jl")
include("logging.jl")


function copy_actor(a::Actor)
    c = occursin(".", a.label) ? Actors.Image(a.label) : Actors.Text(a.label, a.data[:font_path])
    c.w = a.w
    c.h = a.h
    c.x = a.x + 20
    c.y = a.y + 20
    c.data = a.data
    return c
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
