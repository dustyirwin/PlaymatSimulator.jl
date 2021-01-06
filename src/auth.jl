module Authorization

using HTTP
using SHA

function login()
    win = Sys.iswindows()
    
    un = prompt("username/email: ")
    if sha2_512(prompt("password: ")) == USERS[un][:sha_pass]
        println("continue login") 
    else 
        println("invalid credentials, please try again.")
    end 
end

function register_credentials()
    win = Sys.iswindows()

    username = Base.prompt("Enter a username")
    email = Base.prompt("Enter an email address")
    pass = Base.getpass("Enter a password")
    sha_pass = sha2_512(pass)
    
    Base.shred!(pass)

    while true
        break
        #=
        if length(read(user_pass, String)) > 7
            break
        else
            println("Invalid password. Passwords must contain at least 8 characters. Please try again.")
        end
        =#
    end

    Dict(
        :username=>username,
        :email=>email,
        :sha_pass=>sha_pass,
        )
end

end # module
