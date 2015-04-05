--[[

Solar Mana mod [solarmana]
==========================

A mana regeneration controller: only regenerate mana in sunlight.

Copyright (C) 2015 Ben Deutsch <ben@bendeutsch.de>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA

]]


local time_total_regen_check = 0.5
local time_next_regen_check = time_total_regen_check

-- just for debugging: see below
local time_total_mana_reset = 10.0
local time_next_mana_reset = time_total_mana_reset

minetest.register_globalstep(function(dtime)

    -- We do not care if this does not run as often as possible,
    -- as all it does is change the regeneration to a fixed number
    time_next_regen_check = time_next_regen_check - dtime
    if time_next_regen_check < 0.0 then
        time_next_regen_check = time_total_regen_check
        for _,player in ipairs(minetest.get_connected_players()) do
            local name = player:get_player_name()
            local pos  = player:getpos()
            -- the middle of the block with the player's head
            pos.y = math.floor(pos.y) + 1.5
            local node = minetest.get_node(pos)

            -- Currently uses 'get_node_light' to determine whether
            -- a node is "in sunlight".
            local light_day   = minetest.get_node_light(pos, 0.5)
            local light_night = minetest.get_node_light(pos, 0.0)
            local light_now   = minetest.get_node_light(pos)
            local regen_to = 0

            -- simplest version checks for "full sunlight now"
            if light_now >= 15 then
                regen_to = 1
            end

            -- we can get a bit more lenience by testing whether
            -- * a node is "affected by sunlight" (day > night)
            -- * the node is "bright enough now"
            -- However: you could deny yourself mana regeneration
            --          with torches :-/
            --[[
            if light_day > light_night and light_now > 12 then
                regen_to = 1
            end
            --]]

            mana.setregen(name, regen_to)
            --print("Regen to "..regen_to.." : "..light_day.."/"..light_now.."/"..light_night)
        end
    end

    --[[ Comment this in for testing if you have no mana sink

    time_next_mana_reset = time_next_mana_reset - dtime
    if time_next_mana_reset < 0.0 then
        time_next_mana_reset = time_total_mana_reset
        mana.set('singleplayer', 100)
        print("Resetting mana")
    end

    --]]

end)
