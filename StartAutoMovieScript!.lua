function getClientInfo()
  return {
    name = "StartAutoMovieScript!!",
    category = "Playful",
    author = "Auxilyrica",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end


function makeTrack()
  local project = SV:getProject()
  local noteGroup = SV:create("NoteGroup")
  project:addNoteGroup(noteGroup)
  
  local track = SV:create("Track")
  track:setName("BadApple!!")
  project:addTrack(track)
end


function main()
  local myForm = {
    title = "AutoMovieScript!!",
    message = "Start Setting",
    buttons = "OkCancel",
    widgets = {
      {
        name = "size", type = "Slider",
        label = "size",
        format = "%1.0f",
        minValue = 12,
        maxValue = 48,
        interval = 12,
        default = 36
      },
      {
        name = "movie_fps", type = "Slider",
        label = "movie_fps",
        format = "%1.0f",
        minValue = 1,
        maxValue = 60,
        interval = 1,
        default = 30
      },
      {
        name = "refresh_rate", type = "Slider",
        label = "refresh_rate",
        format = "%0.1f",
        minValue = 0.1,
        maxValue = 2,
        interval = 0.1,
        default = 0.5
      },
      {
        name = "path", type = "TextBox",
        label = "mp4 Path (can't use japanese!)",
        default = "input mp4 Full Path (can't use japanese!)"
      },
      {
        name = "test", type = "CheckBox",
        text = "short version for test",
        default = false
      }
    }
  }
  --SV:getMainEditor():getNavigation():setValueCenter((56.5+110.125)/2)
  --SV:getMainEditor():getNavigation():setTimeScale(60/SV.QUARTER)
  
  local result = SV:showCustomDialog(myForm)
  if result.status == true then
    local size=tostring(result.answers.size)
    local movie_fps=tostring(result.answers.movie_fps)
    local refresh_rate=tostring(result.answers.refresh_rate)
    local test=tostring(result.answers.test)
    local path = tostring(result.answers.path)
    if string.sub(path, 1, 1)~='"' then
      path = '"'..path..'"'
    end
    local popenText = 'script\\AutoMovieScript.py ' ..size .." "..movie_fps.." "..refresh_rate.." "..test.." "..path
    --makeTrack()
    --SV:showMessageBox("title", popenText)
    io.popen(popenText)
    
  end
end