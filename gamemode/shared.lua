
GM.Name 	= "Yet Another Wave Defence"
GM.Version = "0.1"
GM.Author 	= "SneakySquid & Nak"

-- Include/Run the lua-file
local function HandleFile(str)
		local c = SysTime()
		local path = str
		if string.find(str,"/") then
			path = string.GetFileFromFilename(str)
		end
		local _type = string.sub(path,0,3)
		if SERVER then
			if _type == "cl_" or _type == "sh_" then
				AddCSLuaFile(str)
			end
			if _type ~= "cl_" then
				return include(str)
			end
		elseif _type ~= "sv_" then
			return include(str)
		end
	end
-- Handle folders
    local function HandleLocalFolder(str, bIgnoreSubFolders)
        local files,folders = file.Find(str .. "/*.lua","LUA")
        if not bIgnoreSubFolders then
            for _,fol in ipairs(folders or {}) do
	    		HandleLocalFolder(GM.FolderName .. "/gamemode/" .. str .. "/" .. fol)
		    end
        end
		for _,fil in ipairs(files) do
			HandleFile(GM.FolderName .. "/gamemode/" .. str .. "/" .. fil)
		end
    end
	local function HandleFolder(str)
        HandleLocalFolder(GM.FolderName .. "/gamemode/" .. str)
	end

-- Load order
    HandleFolder("lib")
    HandleFolder("framework")
    hook.Run("YAWD.PreLoad")

    HandleFolder("yawd")
    hook.Run("YAWD.Loaded")

MsgC(GM.Name .. " loaded.")