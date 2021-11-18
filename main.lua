-- Bootstraps the plugin

-- load config as lua
dofile("votekick.cfg")

local function handle_init()
    local bad = false
    if not votekick_percent then
        print("error: votekick_percent missing from `votekick.cfg`")
        bad = true
    end
    if not votekick_command then
        print("error: votekick_command missing from `votekick.cfg`")
        bad = true
    end
    if not votekick_yes then
        print("error: votekick_yes missing from `votekick.cfg`")
        bad = true
    end
    if not votekick_no then
        print("error: votekick_no missing from `votekick.cfg`")
        bad = true
    end
    if not votekick_timeout_minutes then
        print("error: votekick_timeout_minutes missing from `votekick.cfg`")
        bad = true
    end
    if not votekick_repeatable then
        print("error: votekick_repeatable missing from `votekick.cfg`")
        bad = true
    end
    if bad then
        print("error: votekick plugin failed to read all values from votekick.cfg, it's likely missing or misformatted. votekick plugin will not work.")
        return
    end
    print("lionkor/votekick: Votekick requirement set to " .. tostring(votekick_percent) .. "%. This can be changed in the config file `votekick.cfg`.")
    MP.RegisterEvent("onChatMessage", "handle_chat_message")
    MP.CreateEventTimer("votekick_timeout_timer", 60 * 1000)
    MP.RegisterEvent("votekick_timeout_timer", "votekick_timeout_handler")
end

-- id, name
local function get_player_by_name(name)
    if name and #name > 0 then
        local players = MP.GetPlayers()
        for id,name in players do
            if name == name then
                return id, name
            end
        end
    end
    return nil
end

local function send_help(id)
    local help = string.format("Votekick plugin: To votekick, enter `%s name`, like `%s LionKor` to kick `LionKor`", votekick_command, votekick_command)
    MP.SendChatMessage(id, help)
end

local votekick_in_progress = false
local votekick_players_at_time_of_vote = {}
local votekick_needed = nil
local votekick_votes_yes = nil
local votekick_votes_no = nil
local votekick_id = nil
local votekick_name = nil
local votekick_starter = nil
local votekick_timer = nil

local function votekick_timeout_handler()
    if votekick_timer then
        if votekick_timer:GetCurrent() > votekick_timeout_minutes * 60 then
            votekick_timer = nil
            votekick_in_progress = false
            MP.SendChatMessage(-1, "VOTEKICK: Votekick to kick '".. votekick_name .."' is older than " .. tostring(votekick_timeout_minutes) .. " minutes and was cancelled. It can be restarted with `" .. votekick_command .. " " .. votekick_name .. "`")
            print("votekick to kick '" .. votekick_name .. "' (" ..tostring(votekick_id) .. ") timed out after " .. tostring(votekick_timeout_minutes) .. " minutes")
        end
    end
end

local function handle_disconnect(id)
    if id == votekick_id then
        votekick_in_progress = false
        MP.SendChatMessage(-1, "VOTEKICK: Player '" .. votekick_name .. "' left, so the votekick kicking them was cancelled.")
        print("votekick to kick '" .. votekick_name  .. "' was cancelled, because the player left")
    end
end

local function check_amount()
    local needed = votekick_needed - votekick_votes_yes
    if needed <= 0 then
        MP.DropPlayer(votekick_id, "Votekicked with " .. tostring(votekick_votes_yes) .. " YES votes, " .. tostring(votekick_votes_no) .. " NO votes")
        MP.SendChatMessage(-1, "VOTEKICK: Player '" .. votekick_name .. "' was kicked (" .. tostring(votekick_votes_yes) .. " YES / " .. tostring(votekick_votes_no) .. " NO)")
        print("player '" .. votekick_name .. "' was kicked by votekick")
    end
end

local function send_needed_amount()
    local needed = votekick_needed - votekick_votes_yes
    MP.SendChatMessage(-1, "VOTEKICK: " .. tostring(needed) .. " more YES vote(s) needed to kick '" .. votekick_name .. "'")
    print("votekick for '" .. votekick_name .. "' needs " .. tostring(needed) .. " more votes")
end

local function handle_chat_message(sender_id, sender_name, message)
    if #message >= #votekick_command and string.sub(message, 1, #votekick_command) == votekick_command then
        local subcmd = string.sub(message, #votekick_command, -1)
        if #subcmd == 0 then
            send_help(sender_id)
        else if votekick_in_progress then
            MP.SendChatMessage(sender_id, "VOTEKICK: A vote is already in progress (to kick '"..votekick_name .."', started by '".. votekick_starter .."')")
            print("'" .. sender_name .. "' tried to start a votekick, but one is already in progress")
        else
            if MP.GetPlayerCount() < 3 then
                MP.SendChatMessage(sender_id, "VOTEKICK: More than 2 people needed for a votekick to start.")
            else
                local id, name = get_player_by_name(subcmd)
                if id and name then
                    votekick_in_progress = true
                    votekick_name = name
                    votekick_timer = MP.CreateTimer()
                    votekick_id = id
                    votekick_needed = MP.GetPlayerCount() * votekick_percent
                    votekick_players_at_time_of_vote = MP.GetPlayers()
                    votekick_votes_no = 1 -- assume player to-be-kicked always votes no
                    votekick_votes_yes = 1 -- assume sender voted yes implicitly
                    print("votekick started on player `" .. name .. "` (" ..  tostring(id) .. ") by `" .. sender_name .. "` (" .. tostring(sender_id) .. ")")
                    MP.SendChatMessage(-1, "VOTEKICK: Votekick started on player '" .. name .. "' (started by '" .. sender_name .. "'), vote cancels after " .. tostring(votekick_timeout_minutes) .. " minutes")
                    MP.SendChatMessage(-1, "VOTEKICK: To vote 'YES', type in chat `" .. votekick_yes .. "` (without the `)")
                    MP.SendChatMessage(-1, "VOTEKICK: To vote 'NO', type in chat `" .. votekick_no .. "` (without the `)")
                    MP.SendChatMessage(id, "VOTEKICK (to you): Since you're the target of a votekick, you count as a NO vote automatically and your vote has no effect")
                    MP.SendChatMessage(sender_id, "VOTEKICK (to you): Since you're the creator of this votekick, you count as a YES vote automatically and your vote has no effect")
                    send_needed_amount()
                end
            end
        end
    else if #message >= #votekick_yes and string.sub(message, 1, #votekick_yes) == votekick_yes then
        if votekick_in_progress then
            MP.SendChatMessage(sender_id, "VOTEKICK: You voted YES")
            MP.SendChatMessage(-1, "VOTEKICK: '" .. sender_name .. "' voted YES on vote to kick '" .. votekick_name .. "'")
            print(sender_name .. " voted YES")
            votekick_votes_yes = votekick_votes_yes + 1
            if check_amount() then
                do_kick()
            else
                send_needed_amount()
            end
        end
    else if #message >= #votekick_no and string.sub(message, 1, #votekick_no) == votekick_no then
        if votekick_in_progress then
            MP.SendChatMessage(sender_id, "VOTEKICK: You voted NO")
            MP.SendChatMessage(-1, "VOTEKICK: '" .. sender_name .. "' voted NO on vote to kick '" .. votekick_name .. "'")
            print(sender_name .. " voted NO")
            votekick_votes_no = votekick_votes_no + 1
            if check_amount() then
                do_kick()
            else
                send_needed_amount()
            end
        end
    end
    end
end

MP.RegisterEvent("onInit", "handle_init")

