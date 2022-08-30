--!nonstrict
--Copyright (c) 2021 Skylar Demarco. All Rights Reserved.

--Service dependencies
local HttpService      = game:GetService("HttpService")

--Module dependencies
local SentryEvent      = require(script.Event)
local SentryBreadcrumb = require(script.Breadcrumb)

--Configurables
local SDK_NAME         = "Roblox-Sentry-SDK"
local SDK_VERSION      = "1.0"

--Define module
local Sentry = {}
Sentry.__index    = Sentry
Sentry.Event      = SentryEvent
Sentry.Breadcrumb = SentryBreadcrumb

--Enums
Sentry.Enums = {
	--Event levels
	EventLevel = {
		Fatal   = "fatal";
		Error   = "error";
		Warning = "warning";
		Info    = "info";
		Debug   = "debug";
	};
	
	--Breadcrumb types
	BreadcrumbType = {
		Default     = { "default",    nil                                                    };
		Info        = { "info",       nil                                                    };
		Debug       = { "debug",      nil                                                    };
		Error       = { "error",      nil                                                    };
		Query       = { "query",      nil                                                    };
		Http        = { "http",       nil,                 { "url", "method", "status_code" }};
		Navigation  = { "navigation", nil,                 { "from", "to" }                  };
		Transaction = { "default",    "sentry.transaction"                                   };
		Click       = { "default",    "ui.click",                                            };
		KeyDown     = { "default",    "ui.key_down"                                          };
		KeyUp       = { "default",    "ui.key_up"                                            };
	}
}

--Helper function to convert Sentry timestamp strings back into Unix timestamps
function toUnixTimestamp(text: string)
	local timestampPattern = "(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d[%.]?%d*)Z"
	local year, month, day, hour, minute, second = text:match(timestampPattern)
	local unixTimestamp = os.time({
		day = day;
		month = month;
		year = year;
		hour = hour;
		min = minute;
		sec = second;
	})
	
	return unixTimestamp
end

--Constructor to generate a new Sentry object
function Sentry.new(data: any)
	--Make sure all information is available
	assert(data.OrganizationName, "Sentry E001: OrganizationName is required")
	assert(data.ProjectName,      "Sentry E001: ProjectName is required")
	assert(data.BearerToken,      "Sentry E001: BearerToken is required")
	assert(data.DSN,              "Sentry E001: DSN is required")
	
	--Get information from input object
	local environment: string  = data.Environment or "production"
	local organization: string = data.OrganizationName
	local project: string      = data.ProjectName
	local bearerToken: string  = data.BearerToken
	local dsn: string          = data.DSN
	
	--Dissect the DSN and get required information from it
	--This requires a DSN that contains the secret (legacy DSN)
	local protocol, public_key, secret_key, host, project_id 
		= dsn:match("^([^:]+)://([^:]+):([^@]+)@([^/]+)/(.*)$")
	
	--Make sure we have everything
	--We only need one assert here, because all values will be nil if the DSN can't be parsed
	assert(protocol, "Sentry E002: Invalid DSN!")
	
	--Generate base URI
	local base_uri = string.format("%s://%s", protocol, host)
	
	--Create new Sentry object
	return setmetatable({
		BaseURI      = base_uri;
		PublicKey    = public_key;
		SecretKey    = secret_key;
		ProjectId    = project_id;
		Organization = organization;
		ProjectName  = project;
		Environment  = environment;
		BearerToken  = bearerToken;
	}, Sentry)
end

--Helper function to generate a conforming GUID
function generateGUID()
	local base = HttpService:GenerateGUID(false)
	return base:gsub("%-", ""):lower()
end

--Method to submit an event
function Sentry:submitEvent(event: any)
	assert(event, "Must pass an event")
	
	local sentry_time = os.time()
	
	local url = string.format("%s/api/%s/store/", self.BaseURI, self.ProjectId)
	local data = {
		event_id    = generateGUID();
		timestamp   = sentry_time;
		platform    = "other";
		environment = self.Environment;
	}
	
	--Copy event fields to data
	for k, v in pairs(event) do
		data[k] = v
	end
	
	--Repeat until we managed to send the event
	while true do
		--Actually send the POST request
		local out = HttpService:RequestAsync({
			Url = url;
			Method = "POST";
			Headers = {
				["Content-Type"] = "application/json";
				["X-Sentry-Auth"] = "Sentry sentry_version=7,"
					.. "sentry_timestamp="  .. sentry_time .. ","
					.. "sentry_key="        .. self.PublicKey .. ","
					.. "sentry_secret="     .. self.SecretKey .. ","
				    .. "sentry_client="     .. SDK_NAME .. "/" .. SDK_VERSION
			};
			
			Body = HttpService:JSONEncode(data);
		})
		
		--Handle output
		if (out.Success) then
			return {
				Success = true;
				EventId = HttpService:JSONDecode(out.Body).id;
			}
		elseif (out.StatusCode == 429) then
			--If we hit a rate limit, retry automatically after some amount of time
			local retryAfter = out.Headers and out.Headers["Retry-After"] or 15
			task.wait(retryAfter)
		else
			return { Success = false; }
		end
	end
end

--Method to retrieve an event by event ID
function Sentry:retrieveEvent(eventId: string)
	--Set up URL and headers
	local url = string.format("%s/api/0/projects/%s/%s/events/%s/", self.BaseURI, self.Organization, self.ProjectName, eventId)
	local headers = {
		Authorization = string.format("Bearer %s", self.BearerToken);
	}
	
	--Set up request
	local request = {
		Url = url;
		Method = "GET";
		Headers = headers;
	}
	
	--Retrieve event
	local response
	
	while true do
		--Perform request
		local out = HttpService:RequestAsync(request)
		
		--Handle output
		if (out.Success) then
			--If successful, exit the loop and keep note of the HTTP response
			response = out
			break
		elseif (out.StatusCode == 429) then
			--If we hit a rate limit, retry automatically after some amount of time
			local retryAfter = out.Headers and out.Headers["Retry-After"] or 15
			task.wait(retryAfter)
		else
			return { Success = false; }
		end
	end
	
	--Post-process data
	local data = HttpService:JSONDecode(response.Body)
	
	--Create new Event
	local event = SentryEvent.new()
	event:SetLevel(data.type)
	event:SetMessage(data.message)
	
	--Set user
	if (data.user) then
		--Can't use the method here because the method requires a Player instance
		event.user = data.user
	end
	
	--Add tags
	if (data.tags) then
		for i = 1, #data.tags do
			local tag = data.tags[i]
			event:AddTag(tag.key, tag.value)
		end
	end
	
	--Add other entries
	if (data.entries) then
		for i = 1, #data.entries do
			local entry = data.entries[i]
			local entryType = entry.type
			
			--Check what type the entry is
			--Only supports breadcrumbs right now
			if (entryType == "breadcrumbs") then
				local data = entry.data.values
				
				for j = 1, #data do
					local info = data[j]
					
					--Create breadcrumb
					local breadcrumb = SentryBreadcrumb.new(info.type, info.data, toUnixTimestamp(info.timestamp))
					breadcrumb:SetLevel(info.level)
					breadcrumb:SetMessage(info.message)
					
					if (info.category) then breadcrumb.category = info.category end
					
					--Add breadcrumb to event
					event:AddBreadcrumb(breadcrumb)
				end
			end
		end
	end
	
	--Return event
	return {
		Success = true;
		Event   = event;
		RawData = data;
	}
end

return Sentry