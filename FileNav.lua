-- vim = vim.api
vim = vim
local os = jit.os 

-- Windows, Darwin(MAC), Linux
if os == "Linux" then 
	common_files = {
		{name = "FileNav", path = ""},
		{name = "=======", path = ""},
		{name = "Home", path = "~/"},
		{name = "University", path = "~/University"},
		{name = "Nvim", path = "~/.config/nvim"},
		{name = "Projects", path = ""},
	}
end

-- Count number of common locations -> Will use info to inform window size
counter = 0
for i, file in ipairs(common_files) do
	counter = counter + 1
end

-- Count number of largest name -> Will also use for window size
largestName = 0
for i, file in ipairs(common_files) do
	if #file.name > largestName then
		largestName = #file.name
	end
end

local lastLocation = ""

local function openWindow()
	-- Create a new buffer and window
	local buf = vim.api.nvim_create_buf(false, true) -- create new empty buffer
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'win',
		width = largestName + 2,
		height = counter,
		col = vim.o.columns - 20,
		row = 1,
		style = 'minimal',
		border = "rounded",
	})

	-- Populate the table with my locations
	local lines = {}
	for i, file in ipairs(common_files) do
		table.insert(lines, file.name)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines) -- populates the buffer with my array of locations
	vim.api.nvim_buf_set_name(buf, "NavMenu")       -- set name for buffer

	vim.keymap.set("n", "q", function()
		vim.cmd("bwipeout! " .. buf) -- Neat function from the docs -> Wipes a buffer with params
	end, { buffer = buf, silent = true })

	vim.keymap.set("n", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local choice = lines[cursor[1]]

		for i, file in ipairs(common_files) do
			if file.name == choice then
				if file.path == "" or file.path == " " then
					return 
				end
				print(file.path)
				lastLocation = vim.fn.getcwd()

				-- vim.nvim_buf_delete(currentBuf, {force = true}) --> was an idea about closing previous buffer, but may cause issues and force closing without a save

				vim.cmd("q!")
				vim.cmd("cd " .. file.path)
				vim.cmd("edit " .. file.path)

				-- table.insert(common_files, {name = "Last Location", path = lastLocation})
			end
		end
	end, {noremap = true, silent = true})

end

-- create a command to open the window
vim.api.nvim_create_user_command('NavMenu', function()
	openWindow()
end, { desc = "Opens a navigation menu" })

-- Mapping to open
vim.keymap.set("n", "<C-l>", ":NavMenu<CR>", { noremap = true, silent = true })
