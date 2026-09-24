local client_id = "1157438221865717891"

local group = vim.api.nvim_create_augroup("discord_presence", { clear = true })

local pipe, ready, last_buffer
local timer = vim.uv.new_timer()

local function frame(opcode, payload)
	local body = vim.json.encode(payload)

	local function u32(n)
		return string.char(
			n % 256,
			math.floor(n / 256) % 256,
			math.floor(n / 65536) % 256,
			math.floor(n / 16777216) % 256
		)
	end

	return u32(opcode) .. u32(#body) .. body
end

local function activity(buffer)
	local file = buffer and vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_get_name(buffer) or ""
	return {
		details = "Working in " .. vim.fs.basename(vim.fn.getcwd()),
		state = "Editing " .. (file == "" and "no file" or vim.fs.basename(file)),
		assets = {
			large_image = "https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9f/Vimlogo.svg/1280px-Vimlogo.svg.png",
			large_text = "Neovim",
		},
	}
end

local function send()
	if ready and pipe and not pipe:is_closing() then
		pipe:write(frame(1, {
			cmd = "SET_ACTIVITY",
			nonce = tostring(vim.uv.hrtime()),
			args = { pid = vim.uv.os_getpid(), activity = activity(last_buffer) },
		}))
	end
end

local function update(buffer)
	if buffer and vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_get_name(buffer) ~= "" then
		last_buffer = buffer
	end

	if timer then
		timer:stop()
		timer:start(300, 0, vim.schedule_wrap(send))
	end
end

local function disconnect()
	ready = false

	if timer then
		timer:stop()
	end

	if pipe and not pipe:is_closing() then
		pipe:read_stop()
		pipe:close()
	end

	pipe = nil
end

local function connect()
	disconnect()

	for index = 0, 9 do
		local socket = (vim.env.XDG_RUNTIME_DIR or "/tmp") .. "/discord-ipc-" .. index

		if vim.uv.fs_stat(socket) then
			local new_pipe = vim.uv.new_pipe(false)
			if not new_pipe then
				return
			end
			pipe = new_pipe

			new_pipe:connect(socket, function(err)
				if err or pipe ~= new_pipe then
					return
				end

				vim.schedule(function()
					if pipe ~= new_pipe or new_pipe:is_closing() then
						return
					end

					new_pipe:read_start(function(_, data)
						if data and not ready and pipe == new_pipe then
							ready = true
							vim.schedule(function()
								update(vim.api.nvim_get_current_buf())
							end)
						end
					end)

					new_pipe:write(frame(0, { v = 1, client_id = client_id }))
				end)
			end)

			return
		end
	end
end

connect()

vim.api.nvim_create_user_command("PresenceRefresh", connect, {})

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	group = group,
	callback = function(event)
		update(event.buf)
	end,
})
