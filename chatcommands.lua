minetest.register_chatcommand('msg', {
	params = '<name> <message>',
	description = 'Send a private message.',
	privs = {shout = true},
	func = function(name, param)
		local sendto, message = param:match('^(%S+)%s(.+)$')
		if not sendto then
			return false, 'Invalid usage, see /help msg.'
		end
		if not minetest.get_player_by_name(sendto) then
			return false, 'The player '..sendto..' is not online.'
		end
		minetest.log('action', 'PM from '..name..' to '..sendto..': '..message)
		minetest.chat_send_player(sendto, 'PM from '..name..': '..message)
		minetest.sound_play('chat_next_pm', {to_player = sendto, gain = 0.9})
		return true, 'Message sent.'
	end,
})

-- Alias for msg.
minetest.register_chatcommand('@', minetest.chatcommands['msg'])
-- Alias for teleport.
minetest.register_chatcommand('tp', minetest.chatcommands['teleport'])

minetest.register_privilege('physics', {
	description = 'Can set their own physics values.',
})

minetest.register_chatcommand('speed', {
	params = '<number> [player]',
	description = 'Sets player\'s speed multiplier.',
	privs = {physics = true},
	func = function(name, params)
		local value, p_name = params:match('^(%S+)%s+(.+)')
		if not p_name then
			value = params:match('^(%S+)')
			p_name = name
		end
		value = tonumber(value)
		if not value then
			return false, 'Invalid parameters (see /help speed).'
		elseif value < 0 then
			return false, 'Cannot set speed below zero. Just turn around.'
		elseif value > 4 then
			return false, 'Cannot set speed greater than 4.'
		end
		local player = minetest.env:get_player_by_name(p_name)
		if not player then
			minetest.chat_send_player(name, p_name..' is not online!')
			return false
		end
		player:set_physics_override({speed = value})
		minetest.chat_send_player(name, 'Speed multiplier: '..tostring(value))
		if name ~= p_name then
			minetest.chat_send_player(p_name, 'Speed multiplier: '..tostring(value))
		end
	end,
})

minetest.register_chatcommand('gravity', {
	params = '<number>',
	description = 'Sets player\'s gravity multiplier.',
	privs = {physics = true},
	func = function(name, params)
		local value, p_name = params:match('^(%S+)%s+(.+)')
		if not p_name then
			value = params:match('^(%S+)')
			p_name = name
		end
		value = tonumber(value)
		if not value then
			return false, 'Invalid parameters (see /help gravity).'
		elseif value < 0 then
			return false, 'Anti-gravity does not exist.'
		elseif value < 0.01 then
			return false, 'micro-gravity is dangerous. You might jump off the planet.'
		elseif value > 10 then
			return false, 'Setting gravity greater than 10 will crush you.'
		end
		local player = minetest.env:get_player_by_name(p_name)
		if not player then
			minetest.chat_send_player(name, p_name..' is not online!')
			return false
		end
		player:set_physics_override({gravity = value})
		minetest.chat_send_player(name, 'Gravity multiplier: '..tostring(value))
		if name ~= p_name then
			minetest.chat_send_player(p_name, 'Gravity multiplier: '..tostring(value))
		end
	end,
})

minetest.register_chatcommand('jump', {
	params = '<number>',
	description = 'Sets player\'s jump height multiplier.',
	privs = {physics = true},
	func = function(name, params)
		local value, p_name = params:match('^(%S+)%s+(.+)')
		if not p_name then
			value = params:match('^(%S+)')
			p_name = name
		end
		value = tonumber(value)
		if not value then
			return false, 'Invalid parameters (see /help jump).'
		elseif value < 0 then
			return false, 'That is not called jumping.'
		elseif value > 10 then
			return false, 'Cannot set jump greater than 10.'
		end
		local player = minetest.env:get_player_by_name(p_name)
		if not player then
			minetest.chat_send_player(name, p_name..' is not online!')
			return false
		end
		player:set_physics_override({jump = value})
		minetest.chat_send_player(name, 'Jump multiplier: '..tostring(value))
		if name ~= p_name then
			minetest.chat_send_player(p_name, 'Jump multiplier: '..tostring(value))
		end
	end,
})

minetest.register_chatcommand('whois', {
	params = '[name]',
	description = 'Lists online players IP\'s.',
	privs = {ban = true},
	func = function(name, param)
		minetest.log('action', name..' invoked /whois, param='..param)
		if param == '' then
			local players = minetest.get_connected_players()
			minetest.chat_send_player(name, '======')
			for number,data in ipairs(players) do
				local pname = data:get_player_name()
				local who = chatnext.whois(pname)
				minetest.chat_send_player(name, pname..' : '..chatnext.whois(pname))
			end
			minetest.chat_send_player(name, '======')
		else
			local player = minetest.get_player_by_name(param)

			if player == nil then
				minetest.chat_send_player(name, param..' is not online!')
				return false
			end

			local pname = player:get_player_name()
			minetest.chat_send_player(name, chatnext.whois(pname))
		end
	end,
})

minetest.register_chatcommand('who', {
	description = 'Lists online players (better run in console (press F10)).',
	func = function(name)
		local players = minetest.get_connected_players()
		local player_count = table.getn(players)
		minetest.chat_send_player(name,
			'List of players online ('..tostring(player_count)..'):')
		for number,data in ipairs(players) do
			local pname = data:get_player_name()
			if not pname:find('Guest') then
				minetest.chat_send_player(name, pname)
			end
		end
		minetest.chat_send_player(name, 'End of /who list.')
	end,
})

minetest.register_chatcommand('whereis', {
	params = '<name>',
	description = 'Shows the current position of a player.',
	privs = {ban = true},
	func = function(name, param)
		if param == '' then
			minetest.chat_send_player(name, '/whereis needs an argument')
			return
		elseif param == name then
			minetest.chat_send_player(name, name..
				' is at... Wait, you are kidding me, right?')
			return
		end

		minetest.log('action', name..' invoked /whereis, param='..param)
		local player = minetest.get_player_by_name(param)

		if (player == nil) then
			minetest.chat_send_player(name, param..' is not online!')
			return false
		end

		-- distance
		local myPos = minetest.get_player_by_name(name):getpos()
		local playerPos = player:getpos()
		local distance = math.floor(vector.distance(myPos, playerPos)+0.5)
		minetest.chat_send_player(name, param..' is at '..
			minetest.pos_to_string(vector.round(playerPos))..' about '..
			tostring(distance)..' meters away.')
	end
})

-- Toggle messages.
minetest.register_chatcommand('setopt', {
	params = '<option> <value>',
	description = 'Sets or reads player settings.',
	privs = {interact = true},
	func = function(name, param)
		minetest.log('action', name..' invoked /setopt, param='..param)
		local setname, setvalue = string.match(param, '([^ ]+) (.+)')
		if setname and setvalue then
			if setname == 'joins' then
				chatnext.setopt_command(name, 'Join/leave messages', setname,
					tonumber(setvalue))
			elseif setname == 'tpr' then
				chatnext.setopt_command(name, 'Teleport requests', setname,
					tonumber(setvalue))
			end
		elseif setname then
			minetest.chat_send_player(name, 'Current value: '..
				chatnext.getopt(name, setname))
		end
	end
})

minetest.register_chatcommand('tpr', {
	params = '<name>',
	description = 'Requests teleport to another player.',
	privs = {interact = true},
	func = chatnext.tpr_send
})

minetest.register_chatcommand('tphr', {
	params = '<name>',
	description = 'Requests to teleport another player to you.',
	privs = {interact = true},
	func = chatnext.tphr_send
})

minetest.register_chatcommand('tpy', {
	description = 'Accepts a teleport request from another player.',
	func = chatnext.tpr_accept
})

minetest.register_chatcommand('tpn', {
	description = 'Denies a teleport request from another player.',
	func = chatnext.tpr_deny
})

minetest.register_chatcommand('kill', {
	params = '<name>',
	description = 'Kills the specified player.',
	privs = {ban = true},
	func = function(name, param)
		minetest.log('action', name..' invoked /kill, param='..param)
		local player = minetest.get_player_by_name(param)
		if player ~= nil then
			player:set_hp( 0 )
		end
	end,
})

minetest.register_chatcommand('mypos', {
	description = 'Shows your position.',
	privs = {interact = true},
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		minetest.chat_send_player(name, 'Your position: '..
			minetest.pos_to_string(pos))
	end
})

-- by kaeza
minetest.register_chatcommand('notice', {
	params = '<player> <text>',
	description = 'Sends a notice to a player.',
	privs = {ban = true},
	func = function(name, params)
		local target, text = params:match('(%S+)%s+(.+)')
		if not (target and text) then
			minetest.chat_send_player(name, 'Usage: /notice <player> <text>')
			return
		end
		local player = minetest.get_player_by_name(target)
		if not player then
			minetest.chat_send_player(name,
				('There\'s no player named \'%s\'.'):format(target))
			return
		end
		local fs = {}
		local y = 0
		for _, line in ipairs(text:split('|')) do
			table.insert(fs,
				('label[1,%f;%s]'):format(y+1, minetest.formspec_escape(line)))
			y = y + 0.5
		end
		table.insert(fs, 1, ('size[8,%d]'):format(y+3))
		table.insert(fs, ('button_exit[3,%f;2,0.5;ok;OK]'):format(y+2))
		fs = table.concat(fs)
		minetest.chat_send_player(name, 'Notice sent.')
		minetest.after(0.3, function()
			minetest.show_formspec(target, 'notice:notice', fs)
		end)
	end,
})

minetest.register_chatcommand('clearobj', {
	description = 'Clears non-player objects in loaded areas.',
	privs = {server = true},
	func = function(name, param)
		local objects = minetest.get_objects_inside_radius({x=0,y=0,z=0}, 100000)
		for _, obj in pairs(objects) do
			if not obj:is_player() then
				obj:remove()
			end
		end
	end,
})

-- rsthud is disabled because it does not restore the hunger, health, breath or
-- armor  bars.
--[[
minetest.register_chatcommand('rsthud', {
	params = '[player]',
	description = 'Resets a player\'s HUD.',
	privs = {server = true},
	func = function(name, param)
		if param == '' then
			param = name
		end

		local player = minetest.get_player_by_name(param)
		if player == nil then
			return false, 'The player '..param..' is not online'
		end

		for id = 0,30,1 do
			player:hud_remove(id)
		end

		-- These functions no longer exist.
		--if landrush ~= nil then
			--landrush.hud_destroy(player)
			--landrush.hud_init(player)
		--end

		if hud.init_hud then
			hud.init_hud(player)
		end
		minetest.log('action', name..' invoked /rsthud, param='..param)
		return true, 'HUD has been reset!'
	end
})
--]]
