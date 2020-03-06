local hyper = {"alt", "cmd"}
local BITLY_API_ACCESS_TOKEN = "0304c31fccbfd280d46049beef7103a7042313b4"
-- Load Spoons

hs.loadSpoon("MiroWindowsManager")
hs.loadSpoon("ReloadConfiguration")
hs.loadSpoon("BingDaily")
hs.loadSpoon("Caffeine")

spoon.ReloadConfiguration:start()

hs.window.animationDuration = 0.1

spoon.Caffeine:bindHotkeys({toggle={hyper, "c"}})
spoon.Caffeine:start()

spoon.MiroWindowsManager:bindHotkeys({
  up = {hyper, "up"},
  right = {hyper, "right"},
  down = {hyper, "down"},
  left = {hyper, "left"},
  fullscreen = {hyper, "f"}
})

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "D", function()
	hs.urlevent.openURL("https://devdocs.io")

end)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
	hs.urlevent.openURL("http://reload.extensions")

end)


hs.hotkey.bind({"cmd", "alt", "ctrl"}, "S", function()
    local board = hs.pasteboard.getContents()
    if board:match("^https?://") then
        local response = hs.http.asyncGet(
            "https://api-ssl.bitly.com/v3/shorten" ..
            "?access_token=" .. BITLY_API_ACCESS_TOKEN ..
            "&longUrl=" .. hs.http.encodeForQuery(board),
            {},
            function(status, response, headers)
                if status == 200 then
                    local msg = hs.json.decode(response)

                    hs.pasteboard.setContents(msg.data.url)
                    hs.notify.new({title="Bitly URL Shorten: Success", informativeText=msg.data.url}):send()
                      hs.alert.show(msg.data.url)
                else
                    hs.notify.new({title="Bitly URL Shorten: Failure", informativeText=response}):send()
                end
            end
        )
    else
        hs.notify.new({title="Bitly URL Shorten: Failure", informativeText="Expected: URL"}):send()
    end
end)


-- View your api_dev_key here: http://pastebin.com/api
 local PASTEBIN_API_DEVELOPER_KEY = "d5747520988e69c4d187c7c01f77e74b"

 -- Generate your api_user_key here: http://pastebin.com/api/api_user_key.html
 local PASTEBIN_API_USER_KEY = "1bdc5d08a85cafb5fa7969caf3792d78"

 -- This makes a paste public or private, public = 0, unlisted = 1, private = 2
 local PASTEBIN_API_PASTE_PRIVATE = "1"

 --[[
There are 7 valid values available which you can use with the 'api_paste_expire_date' parameter:
    N = Never
    10M = 10 Minutes
    1H = 1 Hour
    1D = 1 Day
    1W = 1 Week
    2W = 2 Weeks
    1M = 1 Month
--]]
local PASTEBIN_API_PASTE_EXPIRE = "1M"

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "P", function()
    local board = hs.pasteboard.getContents()
    local response = hs.http.asyncPost(
        "http://pastebin.com/api/api_post.php",
        "api_option=paste" ..
            "&api_dev_key=" .. PASTEBIN_API_DEVELOPER_KEY ..
            "&api_user_key=" .. PASTEBIN_API_USER_KEY ..
            "&api_paste_private=" .. PASTEBIN_API_PASTE_PRIVATE ..
            "&api_paste_expire_date=" .. PASTEBIN_API_PASTE_EXPIRE ..
            "&api_paste_code=" .. hs.http.encodeForQuery(board),
        {},
        function(http_code, response)
            if http_code == 200 then
                hs.pasteboard.setContents(response)
                hs.notify.new({title="Pastebin Paste Successful", informativeText=response}):send()
                hs.alert.show(response)
            else
                hs.notify.new({title="Pastebin Paste Failed!", informativeText=response}):send()
                hs.alert.show(response)
            end
        end
        )
    end)


-- Auto config reload
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
        bingRequest()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config (re)loaded")



require "string"

function checkBluetoothResult(rc, stderr, stderr)
    if rc ~= 0 then
        print(string.format("Unexpected result executing `blueutil`: rc=%d stderr=%s stdout=%s", rc, stderr, stdout))
    end
end

function bluetooth(power)
    print("Setting bluetooth to " .. power)
    local t = hs.task.new("/usr/local/bin/blueutil", checkBluetoothResult, {"--power", power})
    t:start()
end

function f(event)
    if event == hs.caffeinate.watcher.systemWillSleep then
        bluetooth("off")
    elseif event == hs.caffeinate.watcher.screensDidWake then
        bluetooth("on")
        
    end
end

watcher = hs.caffeinate.watcher.new(f)
watcher:start()