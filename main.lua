function loadImg(imgs)
	local start = love.timer.getTime()
	local img = love.image.newImageData("images/"..imgs)
	if not img then
		error(img.. "isnt a image!")
	end
	local t = {"local as = game:GetService('AssetService')\nlocal ie = as:CreateEditableImage({Size = Vector2.new("..img:getWidth()..", "..img:getHeight()..")})"}
	table.insert(t,"local l = {")

	-- load all pixels
	for y = 0, img:getHeight()-1 do
		for x = 0, img:getWidth()-1 do
			local r,g,b,a = img:getPixel(x,y)
			table.insert(t,"	[Vector2.new("..x..","..y..")] = {"..r..","..g..","..b..","..1-a.."},")
		end
	end
	table.insert(t, "}")
	table.insert(t,"for i, c in pairs(l) do")
	table.insert(t, "	ie:drawRectangle(i,Vector2.one,Color3.new(c[1],c[2],c[3]),c[4],Enum.ImageCombineType.Overwrite)")
	table.insert(t,"end")
	table.insert(t,'local target = game:GetService("Selection"):get()[1]')
	table.insert(t,'target.ImageContent = Content.fromObject(ie)')
	table.insert(t,'target:setAttribute("Width",'..img:getWidth()..')')
	table.insert(t,'target:setAttribute("Height",'..img:getHeight()..')')
	table.insert(t,"if target:FindFirstChildOfClass('UIAspectRatioConstraint') then")
	table.insert(t,"	target:FindFirstChildOfClass('UIAspectRatioConstraint').AspectRatio = "..tostring(img:getWidth()).."/"..tostring(img:getHeight()))
	table.insert(t,"end")
	love.system.setClipboardText(table.concat(t,"\n"))
	love.window.showMessageBox("Completed","Image \"".. imgs .. "\" loaded successfully!\nResolution: "..tostring(img:getWidth()).."x"..tostring(img:getHeight()).."\nTook "..love.timer.getTime()-start.." seconds.")
end

function table.clone(org)
  return {unpack(org)}
end

function love.run()
	love.filesystem.setIdentity("eic",false)
	local exists = love.filesystem.getInfo("images")
	if exists == nil then
		love.filesystem.createDirectory("images")
	end
	local files = love.filesystem.getDirectoryItems("images")
	local options = table.clone(files)
	table.insert(options,1,"Open Folder")
	table.insert(options,1,"Cancel")
	local choice = love.window.showMessageBox("Selection","Select the image that you would prefer.",options,"info")
	if choice > 2 then
		loadImg(files[choice-2])
	elseif choice == 2 then
		love.system.openURL("file://" .. love.filesystem.getSaveDirectory().."")
	end
end

function love.errorhandler(err)
	love.window.showMessageBox("Error","Error: "..err,"warning")
end