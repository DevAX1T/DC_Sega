--!nonstrict
--Copyright (c) 2021 Skylar Demarco. All Rights Reserved.

local SentryEvent = {}
SentryEvent.__index = SentryEvent

--Constructor
function SentryEvent.new()
	return setmetatable({ level = "error"; }, SentryEvent)
end

--Method to set the level of the event
function SentryEvent:SetLevel(level: string)
	self.level = level
	return self
end

--Method to set the user that generated the event
function SentryEvent:SetUser(user: Player)
	self.user = {
		username = user.Name;
		id       = user.UserId;
	}
	return self
end

--Method to add an exception caused by this event
function SentryEvent:AddException(exceptionType: string, exceptionText: string, stacktrace: string?)
	--If the field for this doesn't exist yet, create it
	local list
	if (not self.exception) then
		list = {}
		self.exception = { values = list; }
	else
		list = self.exception.values
	end
	
	--Generate data
	local data = {
		type = exceptionType;
		value = exceptionText;
	}
	
	--If we have a stacktrace, add it
	if (stacktrace) then
		--Split stacktrace line by line
		local frames: {any} = {}
		
		for s in stacktrace:gmatch("[^\r\n]+") do
			local scriptName, lineNumber = s:match("^(.*), line (%d+)")
			local functionName = s:match("- function (.*)%s*$")
			
			if (scriptName and tonumber(lineNumber)) then
				table.insert(frames, 1, {
					filename = scriptName,
					["function"] = functionName,
					lineno = tonumber(lineNumber)
				})
			else
				table.insert(frames, 1, {
					filename = s,
					["function"] = functionName
				})
			end
		end
		
		if (#frames > 0) then
			--Add stacktrace
			data.stacktrace = { frames = frames; }
		end
	end
	
	--Add exception to the list
	table.insert(list, data)
	return self
end

--Method to add a message to the event
function SentryEvent:SetMessage(message: string)
	self.message = { formatted = message; }
	
	return self
end

--Method to add breadcrumb
function SentryEvent:AddBreadcrumb(breadcrumb: any)
	local breadcrumbs = self.breadcrumbs or {}
	self.breadcrumbs = breadcrumbs
	table.insert(breadcrumbs, breadcrumb)
	
	--If there are more than 300 breadcrumbs recorded, remove old entries
	--This is just to limit the amount of data recorded for a given event
	if (#breadcrumbs > 300) then table.remove(breadcrumbs, 1) end
	
	return self
end

--Method to add tag
function SentryEvent:AddTag(tagName: string, tagValue: string)
	local tags = self.tags or {}
	self.tags = tags
	tags[tagName] = tagValue
	
	return self
end

return SentryEvent