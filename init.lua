io = require("io")
local motdmsg = ""

local function load_motd()
    local f = io.open(minetest.get_worldpath() .. "/motd.txt", "r")

    if f ~= nil then
        motdmsg = f:read("*all")
        f:close()
    end
    
end
 
local function save_motd()
    local f = io.open(minetest.get_worldpath() .. "/motd.txt", "w")
    
    if f ~= nil then
        f:write(motdmsg)
        f:close()
        return true
    else
        return false
    end
end

minetest.register_privilege("setmotd", "Allow the player to set and unset the motd.")

minetest.register_on_joinplayer(function(player)
    load_motd()
    if (motdmsg ~= "") then
        minetest.chat_send_player(player:get_player_name(), "Server Message: "..motdmsg)
    end
end)

minetest.register_chatcommand("motd", {
	params = "",
	description = "Display the message of the day.",
	privs = {},
	func = function( name )
		if (motdmsg == "") then
            minetest.chat_send_player(name, "There is currently no motd set.")
        else
            minetest.chat_send_player(name, "Server Message: "..motdmsg)
        end
        return True
	end,
})

minetest.register_chatcommand("setmotd", {
	params = "<motd>",
	description = "Set the message of the day.",
	privs = { setmotd=true },
	func = function( name, motd )
        if (motd == "") then
            minetest.chat_send_player(name, "The motd cannot be a blank string. To remove the motd, use the /unsetmotd command.")
            return false
        else
            motdmsg = motd
            minetest.chat_send_player(name, "The motd has been set to: \""..motdmsg.."\"")
            if save_motd() == false then
                return false, "WARNING: The motd could not be saved to the disk and as a result will be lost at next server restart! Please check that you have permission to write to the \"motd.txt\" file in the world folder and try again."
            end
            return true
        end
	end,
})

minetest.register_chatcommand("unsetmotd", {
	params = "",
	description = "Remove the message of the day.",
	privs = { setmotd=true },
	func = function( name )
        motdmsg = ""
        minetest.chat_send_player(name, "The motd has been removed.")
        if save_motd() == false then
            return false, "WARNING: The motd could not be saved to the disk and as a result will be lost at next server restart! Please check that you have permission to write to the \"motd.txt\" file in the world folder and try again."
        end
        return true
	end,
})

