vim.api.nvim_create_user_command("OpenAPI", function(args)
	local path = args.args ~= "" and args.args
		or (vim.api.nvim_buf_get_name(0):match("openapi%.json$") and vim.api.nvim_buf_get_name(0))
		or vim.fn.getcwd() .. "/" .. "openapi.json"

	local ok, spec = pcall(function()
		return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
	end)

	if not ok then
		return vim.notify("OpenAPI: " .. spec, vim.log.levels.ERROR)
	end

	local function keys(value)
		local result = vim.tbl_keys(value or {})
		table.sort(result)

		return result
	end

	local function schema(value)
		value = value or {}
		if value["$ref"] then
			return value["$ref"]:match("[^/]+$")
		end

		if value.type == "array" then
			local item = schema(value.items)
			return (item:find(" ") and "(" .. item .. ")" or item) .. "[]" .. (value.uniqueItems and " unique" or "")
		end

		if value.type == "object" or value.properties then
			local required, fields = {}, {}

			for _, name in ipairs(value.required or {}) do
				required[name] = true
			end

			for _, name in ipairs(keys(value.properties)) do
				fields[#fields + 1] = name .. (required[name] and "*" or "") .. ": " .. schema(value.properties[name])
			end

			return #fields > 0 and "{ " .. table.concat(fields, ", ") .. " }" or "object"
		end

		local result = value.type or "any"
		if value.format then
			result = result .. "(" .. value.format .. ")"
		end

		if value.minimum then
			result = result .. " ≥" .. value.minimum
		end

		return result
	end

	local function content(value)
		local all = value and value.content or {}
		local media = all["application/json"] and "application/json" or keys(all)[1]
		return media, media and schema(all[media].schema) or nil
	end

	local components = spec.components or {}
	local function parameter(value)
		if not value["$ref"] then
			return value
		end

		return (components.parameters or {})[value["$ref"]:match("[^/]+$")] or value
	end

	local info = spec.info or {}
	local title = "# " .. (info.title or "OpenAPI") .. (info.version and " · " .. info.version or "")
	local lines = { title }
	if info.description then
		lines[#lines + 1] = info.description
	end

	for _, route in ipairs(keys(spec.paths)) do
		local item = spec.paths[route]
		for _, method in ipairs({ "get", "post", "put", "patch", "delete", "options", "head", "trace" }) do
			local operation = item[method]
			if operation then
				lines[#lines + 1] = ""
				lines[#lines + 1] = ("## `%s` %s%s"):format(
					method:upper(),
					route,
					operation.operationId and " · `" .. operation.operationId .. "`" or ""
				)
				if operation.summary or operation.description then
					lines[#lines + 1] = operation.summary or operation.description
				end

				local parameters = vim.list_extend(vim.deepcopy(item.parameters or {}), operation.parameters or {})
				for _, raw in ipairs(parameters) do
					local p = parameter(raw)
					lines[#lines + 1] = ("- %s%s: %s (%s)%s"):format(
						p.name or "?",
						p.required and "*" or "",
						schema(p.schema),
						p["in"] or "?",
						p.description and " — " .. p.description or ""
					)
				end

				if operation.requestBody then
					local media, kind = content(operation.requestBody)
					lines[#lines + 1] = ("- Body%s%s: %s"):format(
						operation.requestBody.required and "*" or "",
						media and " (" .. media .. ")" or "",
						kind or "any"
					)
				end

				for _, code in ipairs(keys(operation.responses)) do
					local response = operation.responses[code]
					local _, kind = content(response)
					lines[#lines + 1] = ("- `%s`%s%s"):format(
						code,
						kind and " → " .. kind or "",
						response.description and " — " .. response.description or ""
					)
				end
			end
		end
	end

	local schemas = components.schemas or {}
	if next(schemas) then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "## Schemas (`*` required)"
		for _, name in ipairs(keys(schemas)) do
			lines[#lines + 1] = "- **" .. name .. "**: " .. schema(schemas[name])
		end
	end

	vim.cmd.new()
	vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
	vim.bo.filetype = "markdown"
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.modified, vim.bo.modifiable = false, false
	vim.wo.foldmethod, vim.wo.foldexpr, vim.wo.foldlevel = "expr", "getline(v:lnum)=~'^## '?'>1':'='", 99
end, { nargs = "?", complete = "file" })
