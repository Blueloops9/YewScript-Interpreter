--Made by blueloops9

-- The code is just awful so gl modifying it for your own needs
-- I probably won't be adding Vectors and Dictionaries anytime soon since I don't think many people use it
-- This used to be an older version of YewScript but now it's more of a hybrid (Has features from 2.0.1 but missing some from v1.9.9)
-- The most stable version is probably v1.9.8 but missing misc instructions like signal, dict, music, etc.
-- Hopefully you get some use out of this interpreter as a whole


local function loadyewscript(ExtrasTable)
    local function tostr(Table) for I=1,#Table do Table[I]=tostring(Table[I])end return Table end
    local function split(Str,Sep)
        local Out,Length = {},1
        for I in string.gmatch(Str,"([^"..Sep.."]+)") do Out[Length]=I Length=Length+1 end
        return Out
    end
    local function Loop(Amount)local Table = {}for I=1,Amount do Table[I]=I end return Table end

    -- Probably use a different binding system but later
    local ExtraString = " has no binding, please use the Extras table to implement bindings."
    local Extras={
        ["imgbox"]=function()print("imgbox"..ExtraString)end,
        ["box"]=function()print("box"..ExtraString)end,
        ["change"]=function()print("change"..ExtraString)end,
        ["send"]=function()print("send"..ExtraString)end,
    }
    local ExtraKeywords={
        ["Buffer"]=function()print("Buffer"..ExtraString)end,
        ["CursorX"]=function()print("CursorX"..ExtraString)end,
        ["CursorY"]=function()print("CursorY"..ExtraString)end,
        ["Touch2D"]=function()print("Touch2D"..ExtraString)end,
        ["Port"]=function()print("Port"..ExtraString)end,
    }
    local ExtrasTable = ExtrasTable or {Instructions={},Keywords={}}
    for I,V in pairs(ExtrasTable.Instructions) do Extras[I]=V end
    for I,V in pairs(ExtrasTable.Keywords) do ExtraKeywords[I]=V end
    

    local CurrentLine=1
    local DoRun = true

    local ifinit,Index={},1
    local ForBuffer,IfBuffer,ElseBuffer,EndBuffer={},{},{},{}

    local Variables={
        A={},B={},C={},D={},E={},F={},G={},H={},I={},J={},K={},L={},M={},N={},O={},
        P={},Q={},R={},S={},T={},U={},V={},W={},X={},Y={},Z={},
    }
    local Keywords={
        ["Rand"]=function(Data,Data2)
		    if Data2 then
		    	return {math.random(Data[1],Data2[1])}
		    else
		    	if Data then
		    		return {math.random(Data[1],Data[1])}
		    	else
		    		return {math.random()}
			    end
		    end
	    end,
        ["Time"]=function()return {os.clock()} end,
        ["Self"]=function()return {Code} end,
        ["Year"]=function()return {0} end,
        ["Port"]=function()return {0} end,
        ["RealTime"]=function() return {os.time()} end,
        ["Length'"]=function(Data) return {#tostringyew(Data)} end,
        ["Size'"]=function(Data)return {#Data} end,
        ["Abs"]=function(Data)return {math.abs(Data[1])} end,
        ["Acos"]=function(Data)return {math.acos(Data[1])} end,
        ["Asin"]=function(Data)return {math.asin(Data[1])} end,
        ["Atan"]=function(Data)return {math.atan(Data[1])} end,
        ["Cos"]=function(Data)return {math.cos(Data[1])} end,
        ["Cosh"]=function(Data)return {math.cosh(Data[1])} end,
        ["Deg"]=function(Data)return {math.deg(Data[1])} end,
        ["Rad"]=function(Data)return {math.rad(Data[1])} end,
        ["Sin"]=function(Data)return {math.sin(Data[1])} end,
        ["Sinh"]=function(Data)return {math.sinh(Data[1])} end,
        ["Tan"]=function(Data)return {math.tan(Data[1])} end,
        ["Tanh"]=function(Data)return {math.tanh(Data[1])} end,
        ["CursorX"]=function()return ExtraKeywords.CursorX()end,
        ["CursorY"]=function()return ExtraKeywords.CursorY()end,
        ["Find"]=function(Data,Data2)for I=1,#Data do if tostring(Data[I]) == tostring(Data2[1]) then return {I} end end return {"nil"} end,
        ["Touch2D"]=function(Data2)return ExtraKeywords.Touch2D(Data2)end,
        ["Btan"]=function(Data,Data2)return {math.atan2(Data[1],Data2[1])} end,
        ["Magnitude"]=function(D1,D2,D3)return {math.sqrt(D1[1]*D1[1]+D2[1]*D2[1]+D3[1]*D3[1])} end,
        ["Unit"]=function(D1,D2,D3)local m=math.sqrt(D1[1]*D1[1]+D2[1]*D2[1]+D3[1]*D3[1])return {D1[1]/m,D2[1]/m,D3[1]/m} end,
        ["Buffer"]=function(Data)return ExtraKeywords.Buffer(Data[1])end,
        ["Sub"]=function(D1,D2,D3)local Str = tostringyew(D1,true)return {Str:sub(D2[1],(D3 or {#Str})[1] or #Str)} end,
        ["Swap"]=function(Data) -- Not sure what the limitations are on this so it's just an offset
            local Number = tonumber(Data[1])
            if Number then
                return {string.char(Number-64)}
            else
                return {string.byte(Number)-64}
            end
        end,
        ["Port"]=function()return ExtraKeywords.Port()end,
    }
    function IsVariable2(String) -- Can't remember exactly why I made this
        if String:sub(2,2)=="'" or #String==1 then
            for I,_ in pairs(Variables) do if String:sub(1,1)==I then return I,#I+1 end end
        end
        return false
    end
    local Operations={
        ["="]=function(A,B)
            local Variable = IsVariable2(B)
            local Keyword = IsKeyword(B)
            if Keyword then
                local KeywordReference,Split = Keywords[Keyword],split(B:sub(#Keyword+1),"'")
                if Split then
                    local List,Loc=GetValue(Split[1])
                    local List2,Loc2,List3,Loc3 = {},0,{},0
                    if Split[2] then List2,Loc2=GetValue(Split[2]) end
		    if Split[3] then List3,Loc3=GetValue(Split[3]) end
                    return function()Variables[A]=tostr(KeywordReference(List[Loc],List2[Loc2],List3[Loc3])) end
                else return function()Variables[A]=tostr(KeywordReference()) end end
            elseif Variable then
                local Split = split(B,"'")[2]
                if Split then
                    local List,Loc=GetValue(Split)
                    return function()Variables[A]={Variables[Variable][tonumber(List[Loc][1])]} end
                else return function()local Table = {} for I=1,#Variables[Variable] do Table[I]=Variables[Variable][I] end Variables[A]=Table end end
            elseif B:find(";") then return function()
		local Length,Table = 1,{}
		for I in string.gmatch(B,"([^;]+)") do
			Table[Length]=I
			Length=Length+1
		end
		Variables[A]=Table
	    end
            else local E = tonumber(B) E=E==nil and B or E return function()Variables[A]={B} end
            end
        end,
        ["+"]=function(A,B)
            local Variable = IsVariable2(B)
            if Variable then
        	local Split = split(B,"`")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=tostring(tonumber(Variables[A][1])+tonumber(Variables[Variable][tonumber(List[Loc][1])])) end
                else return function()Variables[A][1]=tostring(tonumber(Variables[A][1])+tonumber(Variables[Variable][1])) end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=tostring(tonumber(Variables[A][1])+E) end
            end
        end,
        ["-"]=function(A,B)
            local Variable = IsVariable2(B)
            if Variable then
                local Split = split(B,"`")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=tostring(tonumber(Variables[A][1])-tonumber(Variables[Variable][tonumber(List[Loc][1])])) end
                else return function()Variables[A][1]=tostring(tonumber(Variables[A][1])-tonumber(Variables[Variable][1])) end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=tostring(tonumber(Variables[A][1])-E) end
            end
        end,
        ["*"]=function(A,B)
            local Variable = IsVariable2(B)
            if Variable then
                local Split = split(B,"`")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=tostring(tonumber(Variables[A][1])*tonumber(Variables[Variable][tonumber(List[Loc][1])])) end
                else return function()Variables[A][1]=tostring(tonumber(Variables[A][1])*tonumber(Variables[Variable][1])) end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=tostring(tonumber(Variables[A][1])*E) end
            end
        end,
        ["\\"]=function(A,B)
            local Variable = IsVariable2(B)
            if Variable then
                local Split = split(B,"`")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=tostring(tonumber(Variables[A][1])/tonumber(Variables[Variable][tonumber(List[Loc][1])])) end
                else return function()Variables[A][1]=tostring(tonumber(Variables[A][1])/tonumber(Variables[Variable][1])) end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=tostring(tonumber(Variables[A][1])/E) end
            end
        end,
        ["^"]=function(A,B)
            local Variable = IsVariable2(B)
            if Variable then
                local Split = split(B,"`")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=tostring(tonumber(Variables[A][1])^tonumber(Variables[Variable][tonumber(List[Loc][1])])) end
                else return function()Variables[A][1]=tostring(tonumber(Variables[A][1])^tonumber(Variables[Variable][1])) end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=tostring(tonumber(Variables[A][1])^E) end
            end
        end,
        ["%"]=function(A,B)
            local Variable = IsVariable2(B)
            if Variable then
                local Split = split(B,"`")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=tostring(tonumber(Variables[A][1])%tonumber(Variables[Variable][tonumber(List[Loc][1])])) end
                else return function()Variables[A][1]=tostring(tonumber(Variables[A][1])%tonumber(Variables[Variable][1])) end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=tostring(tonumber(Variables[A][1])%E) end
            end
        end,
        ["@"]=function(A,B)
            local BL,BLo = GetValue(B)
            return function()
		local Var = tonumber(Variables[A][1])
                if tonumber(BL[BLo][1]) == -1 then Variables[A][1]=tostring(math.floor(Var))
                elseif tonumber(BL[BLo][1]) == 0 then Variables[A][1]=tostring(math.floor(Var+.5))
                else Variables[A][1]=tostring(math.ceil(Var))end
            end
        end,
        [">"]=function(A,B)
            local BL,BLo = GetValue(B)
            return function()
                if tonumber(Variables[A][1]) < tonumber(BL[BLo][1]) then Variables[A][1] = tostring(BL[BLo][1])end
            end
        end,
        ["<"]=function(A,B)
            local BL,BLo = GetValue(B)
            return function()
                if tonumber(Variables[A][1]) > tonumber(BL[BLo][1]) then Variables[A][1] = tostring(BL[BLo][1])end
            end
        end
    }
    Operations["`"]=Operations["*"] -- Not sure if this is even in YewScript anymore

    local LogicOperations={
        ["="]=function(A,B,C,D,Line)return function()
            local E,F = tonumber(tostringyew(A[B])),tonumber(tostringyew(C[D]))
            if E and F then if E~=F then CurrentLine=IfBuffer[Line][2]end
            else if tostringyew(A[B],true)~=tostringyew(C[D],true) then CurrentLine=IfBuffer[Line][2]end end
        end end,
        ["!"]=function(A,B,C,D,Line)return function()
            local E,F = tonumber(tostringyew(A[B])),tonumber(tostringyew(C[D]))
            if E and F then if E==F then CurrentLine=IfBuffer[Line][2]end
            else if tostringyew(A[B],true)==tostringyew(C[D],true) then CurrentLine=IfBuffer[Line][2]end end
        end end,
        [">"]=function(A,B,C,D,Line)return function()
            if not (tonumber(A[B][1])>tonumber(C[D][1])) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["<"]=function(A,B,C,D,Line)return function()
            if not (tonumber(A[B][1])<tonumber(C[D][1])) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["}"]=function(A,B,C,D,Line)return function()
            if not (tonumber(A[B][1])>=tonumber(C[D][1])) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["{"]=function(A,B,C,D,Line)return function()
            if not (tonumber(A[B][1])<=tonumber(C[D][1])) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["]"]=function(A,B,C,D,Line)return function()
            if not tostringyew(A[B]):find(tostringyew(C[D])) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["["]=function(A,B,C,D,Line)return function()
            if tostringyew(A[B]):find(tostringyew(C[D])) then CurrentLine=IfBuffer[Line][2]end
        end end,
    }

    function IsVariable(String)
        for I,_ in pairs(Variables) do if String:sub(1,1)==I then return I,#I+1 end end return false
    end

    function IsKeyword(String)
        for I,_ in pairs(Keywords) do if String:sub(1,#I)==I then return I,#I+1 end end return false
    end

    function tostringyew(Value,t)
        local Type = type(Value)
        if Type=="table" then
            if #Value>1 then
	        return table.concat(Value,";")
            else return (t and tostring(Value[1]) or Value[1])end
        else
            return (t and tostring(Value) or Value)
        end
    end

    function GetValue(Data)
	Data = Data or ""
        local Keyword = IsKeyword(Data)
        if Keyword then return Keywords,Keyword
        else
            local Variable = IsVariable(Data)
            if Variable then return Variables,Variable else local A = tonumber(Data) return {{A==nil and Data or A}},1 end
        end
    end

    function IsInstruction(String)
	String=String:lower()
        for I,V in ipairs(InstructionArray) do if String:sub(1,#V)==V then return V,#V+1 end end
        return false
    end

    local Instructions={
        ["goto"]=function(line)
            local List,Loc = GetValue(line)
            return function()CurrentLine=tonumber(List[Loc][1])-1 end
        end,
        ["leapto"]=function(line)
            local List,Loc = GetValue(line)
            return function()CurrentLine=CurrentLine+tonumber(List[Loc][1])-1 end
        end,
        ["beep"]=function(pitch) -- Should probably switch this to a binding
            local List,Loc = GetValue(pitch)
            return function() print("Beep!",List[Loc][1]) end
        end,
        ["print"]=function(VariableKeywordDatatype) -- Lol overcomplicated
            local Keyword = IsKeyword(VariableKeywordDatatype)
            if Keyword then
                local Split = split(VariableKeywordDatatype,"'")
                if Split[2] then
                    local List,Loc = GetValue(Split[2])
                    return function()print(Keywords[Keyword]()[tonumber(List[Loc])]) end
                else return function()print(tostringyew(Keywords[Keyword]()))end end
            else
                local Variable = IsVariable(VariableKeywordDatatype)
                if Variable then
                    local Split = split(VariableKeywordDatatype,"'")[2]
                    if Split then
                        local List,Loc = GetValue(Split)
                        return function()print(Variables[Variable][tonumber(List[Loc])]) end
                    else return function() print(tostringyew(Variables[Variable])) end end
                else return function() print(VariableKeywordDatatype) end end
            end
        end,
        ["insert"]=function(Data)
            Data = split(Data,"'")
            
            local Variable = Data[1]
            local DatL,DatLoc = GetValue(Data[2])
            local Pos,PosLoc = GetValue(Data[3] or "")

            return function ()
                Variables[Variable][Pos[PosLoc][1]=="" and #Variables[Variable]+1 or tonumber(Pos[PosLoc][1])]=tostring(DatL[DatLoc][1])
            end
        end,
        ["remove"]=function(Data)
            Data = split(Data,"'")
            local Pos,PosLoc = GetValue(Data[2] or "")
            Data = Data[1]

            return function()table.remove(Variables[Data],Pos[PosLoc][1]=="" and #Variables[Data] or tonumber(Pos[PosLoc][1])) end
        end,
        ["reset"]=function()return function()
            ForBuffer,CurrentLine={},0
            for I,_ in pairs(Variables) do Variables[I]={0} end
        end end,
        ["for"]=function(Data)return function()
            ForBuffer[#ForBuffer+1] = {1,#Variables[Data],Variables[Data],CurrentLine,true}
            local a = Variables[Data][1]
            Variables.Z={tonumber(a)==nil and a or tonumber(a)}
        end end,
        ["loop"]=function(Data)
            local DataL,DataLoc = GetValue(Data)
            local Split = split(Data,"'")[2]
            if Split then Bruh=GetValue(Split) end
            return function()
            ForBuffer[#ForBuffer+1] = {1,tonumber(DataL[DataLoc][1]),Loop(tonumber(DataL[DataLoc][1])),CurrentLine} -- No Z update why jaatzy why
        end end,
        ["endloop"]=function()return function()
            local Loop = ForBuffer[#ForBuffer]
            Loop[1]=Loop[1]+1
            if Loop[1]<=Loop[2] then 
                if Loop[5] then
                    local a = Loop[3][Loop[1]]
                    Variables.Z = {tostring(a)}
                end
		CurrentLine=Loop[4]
            else    
                table.remove(ForBuffer,#ForBuffer)
            end
        end end,
        ["if"]=function(Data)
            ifinit[#ifinit+1] = Index

            for I,V in pairs(LogicOperations) do
                local Split = split(Data,I)
                if Split[2] then
                    local A,B = GetValue(Split[1])
                    local C,D = GetValue(Split[2])
                    return V(A,B,C,D,Index)
                end
            end
        end,
        ["else"]=function()
            local Loc = ifinit[#ifinit]
            IfBuffer[Loc]={Index,Index}
            return function()
                CurrentLine=IfBuffer[Loc][1]
            end
        end,
        ["end"]=function()
            if IfBuffer[ifinit[#ifinit]] then IfBuffer[ifinit[#ifinit]][1]=Index
            else IfBuffer[ifinit[#ifinit]]={Index,Index}end
            table.remove(ifinit,#ifinit)
            return function() end
        end,
        ["wait"]=function(Data)
            local A,B = GetValue(Data) -- Could replace current method with os.execute("sleep")??
            return function()local Base=os.clock() repeat until os.clock()>Base+tonumber(A[B][1]) end
        end,
        ["imgbox"]=function(Data)
            local Data = split(Data,"'")
            local IdL,IdI = GetValue(Data[1])local PosXL,PosXI = GetValue(Data[2])local PosYL,PosYI = GetValue(Data[3])local SXL,SXI = GetValue(Data[4])
            local SYL,SYI = GetValue(Data[5])local ImgL,ImgI = GetValue(Data[6])local BCL,BCI = GetValue(Data[7])local CL,CI = GetValue(Data[8])
            return function() Extras.imgbox(IdL[IdI],PosXL[PosXI],PosYL[PosYI],SXL[SXI],SYL[SYI],ImgL[ImgI],BCL[BCI],CL[CI])end
        end,
        ["box"]=function(Data)
            local Data = split(Data,"'")
            local IdL,IdI = GetValue(Data[1])local PosXL,PosXI = GetValue(Data[2])local PosYL,PosYI = GetValue(Data[3])local SXL,SXI = GetValue(Data[4])
            local SYL,SYI = GetValue(Data[5])local TxtL,TxtI = GetValue(Data[6])local BCL,BCI = GetValue(Data[7])local CL,CI = GetValue(Data[8])
            return function() Extras.box(IdL[IdI],PosXL[PosXI],PosYL[PosYI],SXL[SXI],SYL[SYI],TxtL[TxtI],BCL[BCI],CL[CI])end
        end,
        ["change"]=function(Data)
            local Data = split(Data,"'")
            local IdL,IdI = GetValue(Data[1])local PosXL,PosXI = GetValue(Data[2])local PosYL,PosYI = GetValue(Data[3])local SXL,SXI = GetValue(Data[4])
            local SYL,SYI = GetValue(Data[5])local TxtL,TxtI = GetValue(Data[6])local BCL,BCI = GetValue(Data[7])local CL,CI = GetValue(Data[8])
            return function()Extras.change(IdL[IdI],PosXL[PosXI],PosYL[PosYI],SXL[SXI],SYL[SYI],TxtL[TxtI],BCL[BCI],CL[CI])end
        end,
        ["delete"]=function(Data)
            local Data = split(Data,"'")
            local Id,IdLoc = GetValue(Data[1])
            return function() Extras.delete(Id[IdLoc])end
	    end,
        ["affix"]=function(Data)
            local Data = split(Data,"'")
            local Variable,VariableLoc = GetValue(Data[1])
            local String,StringLoc = GetValue(Data[2])
            return function() Variable[VariableLoc][1]=Variable[VariableLoc][1]..String[StringLoc][1]  end
        end,
	["send"]=function(Data)
		local Data = split(Data,"'")
		local Address,AddressLoc = GetValue(Data[1])
		local Data,DataLoc = GetValue(Data[2])
		local Channel,ChannelLoc = GetValue(Data[3])
		return function() Extras.send(Address[AddressLoc],Data[DataLoc],Channel[ChannelLoc]) end
	end,
    }
    InstructionArray={}
    for I,_ in pairs(Instructions) do InstructionArray[#InstructionArray+1] = I end
    table.sort(InstructionArray,function(a,b)return #a>#b end)-- Longest instruction gets checked first

    local function CompileProgram(Code)
        local Program={}

        Code = Code:gsub("\r",""):gsub("\t","") -- Windows does this and Linux hates it on second thought it's probably a bad idea to remove tabs but later I guess
        Code = table.concat(split(Code,"\n"),"/")
        for I,V in pairs(split(Code,"/")) do
            local First = V:sub(1,1)
            if V == "" then error("error at line "..I..": line cannot be empty!") end
	    if First~="-" then
                local Instruction,Start = IsInstruction(V)
                if Instruction then
                    Program[#Program+1] = Instructions[Instruction](V:sub(Start))
                else
                    local Variable,Start = IsVariable(V)
                    if Variable then
                        Program[#Program+1] = Operations[V:sub(Start,Start)](Variable,V:sub(Start+1))
		    else
			Program[#Program+1]=function()end
                    end
                end
            else
                Program[#Program+1] = function() end
            end
            Index=Index+1
        end
    
        local Length = #Program

        return Program, Length
    end
    return function(Code)
	CurrentLine=1
	local Program,Length = CompileProgram(Code)
	return function()
		if CurrentLine>Length then return true end Program[CurrentLine]()CurrentLine = CurrentLine+1 return false
	end
	-- Old code when the step function didn't exist
        --while DoRun do if CurrentLine>Length then break end  Program[CurrentLine]()CurrentLine=CurrentLine+1 end
    end
end

return loadyewscript
