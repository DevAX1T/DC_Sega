--!nonstrict
--Copyright (c) 2021 Skylar Demarco. All Rights Reserved.

local Breadcrumb = {}
Breadcrumb.__index = Breadcrumb

function Breadcrumb.new(breadcrumbType: any, data: any, timestamp: number?)
	local new = {
		type      = breadcrumbType[1];
		category  = breadcrumbType[2];
		timestamp = timestamp or os.time();
	}
	
	--Check required data fields
	if (breadcrumbType[3]) then
		--Make sure we actually have a data field
		assert(data, "Data is required for this breadcrumb type!")
		
		--Ensure we have the required information
		for i, v in ipairs(breadcrumbType[3]) do
			assert(data[v], "Field " .. v .. " is required")
		end
		
		--Set data
		new.data = data
	end
	
	return setmetatable(new, Breadcrumb)
end

--Method to set category
function Breadcrumb:SetCategory(category: string)
	assert(not self.category, "Category has already been set!")
	self.category = category
	
	return self
end

--Method to set message
function Breadcrumb:SetMessage(message: string)
	self.message = message
	return self
end

--Method to set level
function Breadcrumb:SetLevel(level: string)
	self.level = level
	return self
end

return Breadcrumb