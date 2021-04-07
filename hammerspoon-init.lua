local hyper = {"alt", "cmd"}
local BITLY_API_ACCESS_TOKEN = "0304c31fccbfd280d46049beef7103a7042313b4"
-- Load Spoons

hs.loadSpoon("MiroWindowsManager")
hs.loadSpoon("ReloadConfiguration")
--hs.loadSpoon("BingDaily")
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
local PASTEBIN_API_DEVELOPER_KEY = "4u4rX4aNA3phF9ZZJQxZe2B_YFUhckFE"

 -- Generate your api_user_key here: http://pastebin.com/api/api_user_key.html
 local PASTEBIN_API_USER_KEY = "44538f0017dc9d1cb143f2ea05a891d7"

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
local PASTEBIN_API_PASTE_EXPIRE = "N"

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "P", function()
  local board = hs.pasteboard.getContents()
  local response = hs.http.asyncPost(
    "https://pastebin.com/api/api_post.php",
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

-- set up your windowfilter
switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces
switcher_space = hs.window.switcher.new(hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{}) -- include minimized/hidden windows, current Space only
switcher_browsers = hs.window.switcher.new{'Safari','Google Chrome'} -- specialized switcher for your dozens of browser windows :)

-- bind to hotkeys; WARNING: at least one modifier key is required!
hs.hotkey.bind('alt','tab','Next window',function()switcher:next()end)
hs.hotkey.bind('alt-shift','tab','Prev window',function()switcher:previous()end)

-- alternatively, call .nextWindow() or .previousWindow() directly (same as hs.window.switcher.new():next())
hs.hotkey.bind('alt','tab','Next window',hs.window.switcher.nextWindow)
-- you can also bind to `repeatFn` for faster traversing
hs.hotkey.bind('alt-shift','tab','Prev window',hs.window.switcher.previousWindow,nil,hs.window.switcher.previousWindow)

-- Fuzzy Window Switcher

_fuzzyChoices = nil
_fuzzyChooser = nil
_fuzzyLastWindow = nil

function fuzzyQuery(s, m)
  s_index = 1
  m_index = 1
  match_start = nil
  while true do
    if s_index > s:len() or m_index > m:len() then
      return -1
    end
    s_char = s:sub(s_index, s_index)
    m_char = m:sub(m_index, m_index)
    if s_char == m_char then
      if match_start == nil then
        match_start = s_index
      end
      s_index = s_index + 1
      m_index = m_index + 1
      if m_index > m:len() then
        match_end = s_index
        s_match_length = match_end-match_start
        score = m:len()/s_match_length
        return score
      end
    else
      s_index = s_index + 1
    end
  end
end

function _fuzzyFilterChoices(query)
  if query:len() == 0 then
    _fuzzyChooser:choices(_fuzzyChoices)
    return
  end
  pickedChoices = {}
  for i,j in pairs(_fuzzyChoices) do
    fullText = (j["text"] .. " " .. j["subText"]):lower()
    score = fuzzyQuery(fullText, query:lower())
    if score > 0 then
      j["fzf_score"] = score
      table.insert(pickedChoices, j)
    end
  end
  local sort_func = function( a,b ) return a["fzf_score"] > b["fzf_score"] end
  table.sort( pickedChoices, sort_func )
  _fuzzyChooser:choices(pickedChoices)
end

function _fuzzyPickWindow(item)
  if item == nil then
    if _fuzzyLastWindow then
      -- Workaround so last focused window stays focused after dismissing
      _fuzzyLastWindow:focus()
      _fuzzyLastWindow = nil
    end
    return
  end
  saveTime(6)
  id = item["windowID"]
  window = hs.window.get(id)
  window:focus()
end

function windowFuzzySearch()
  windows = hs.window.filter.default:getWindows(hs.window.filter.sortByFocusedLast)
  -- windows = hs.window.orderedWindows()
  _fuzzyChoices = {}
  for i,w in pairs(windows) do
    title = w:title()
    app = w:application():name()
    item = {
      ["text"] = app,
      ["subText"] = title,
      --["image"] = w:snapshot(),
      ["windowID"] = w:id()
    }
    -- Handle special cases as necessary
    --if app == "Safari" and title == "" then
      -- skip, it's a weird empty window that shows up sometimes for some reason
    --else
      table.insert(_fuzzyChoices, item)
    --end
  end
  _fuzzyLastWindow = hs.window.focusedWindow()
  _fuzzyChooser = hs.chooser.new(_fuzzyPickWindow):choices(_fuzzyChoices):searchSubText(true)
  _fuzzyChooser:queryChangedCallback(_fuzzyFilterChoices) -- Enable true fuzzy find
  _fuzzyChooser:show()
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "J", function()
  windowFuzzySearch()
end)