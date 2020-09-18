function getClientInfo()
  return {
    name = "AutoMovieScript! (Not use)",
    category = "Playful",
    author = "Auxilyrica",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end

function split(str, ts)
  if ts == nil then return {} end
  local t = {} ; 
  local i=1
  for s in string.gmatch(str, "([^"..ts.."]+)") do
    t[i] = s
    i = i + 1
  end
  return t
end
  

  
function readFile()
  local f=io.input("script//movie.txt")
  
  local project = SV:getProject()
  local track = project:getTrack(project:getNumTracks())
  local noteGroups
  for line in f:lines() do
    noteGroups = setNotes2(line, 0)
  end
  f:close()
  
  for i=1, project:getNumNoteGroupsInLibrary() do
    project:removeNoteGroup(1)
  end
  
  local groupRefs = {}
  for i=1, #noteGroups do
    groupRefs[i] = SV:create("NoteGroupReference")
    project:addNoteGroup(noteGroups[i])
    groupRefs[i]:setTarget(noteGroups[i])

    track:addGroupReference(groupRefs[i])
  end
  
  
  SV:finish()
end

function setNotes2(line, page)
  local noteGroup = {}
  
  
  local split_lines = split(line,",")
  
  for y=1, #split_lines do
    noteGroup[y] = SV:create("NoteGroup")
    noteGroup[y]:setName("My Group"..y)
  
    local lines = split(split_lines[y], " ")
    local color = tonumber(lines[1])
    
    local changeCount = 2
    local now = 0
    local start_x =0
    
    for x=1,math.floor(#split_lines/3*4+0.1) do
      local change = lines[changeCount]
      
      if change == nil or x==1 then 
        change=100 
      else 
        change = tonumber(change)+1
      end
      
      if change ==x then
        color = color*-1+1
        changeCount = changeCount + 1
      end
      
      if color ==1 then
        if now == 0 then
          now=1
          start_x=x
        elseif x==math.floor(#split_lines/3*4+0.1) then
          local ithNote = SV:create("Note")
          ithNote:setLyrics(" ")
          ithNote:setPitch(60+#split_lines-y)
          ithNote:setTimeRange(SV.QUARTER*3+(SV.QUARTER/2)*(start_x-1), SV.QUARTER/2*(x-start_x+1)) --開始地点, 長さ
          noteGroup[y]:addNote(ithNote)
        end
      elseif now == 1 then
        now=0
        local ithNote = SV:create("Note")
        ithNote:setLyrics(" ")
        ithNote:setPitch(60+#split_lines-y)
        ithNote:setTimeRange(SV.QUARTER*3+(SV.QUARTER/2)*(start_x-1), SV.QUARTER/2*(x-start_x)) --開始地点, 長さ
        noteGroup[y]:addNote(ithNote)
      end
    end
  end
  
  return noteGroup
end


function main()
  --pythonをos.executeにて実行
  --音楽の再生→オーディオトラックの追加できないのでスルー
  --pythonはsynthVを前面に出し、ショートカットキーにてスクリプトを連続実行
  --実行されたスクリプトは画像を出す。
  --SV:showMessageBox("title", "message")
  
  readFile()
  
end
