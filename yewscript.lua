-- Made by blueloops9

-- The code is just awful so gl modifying it for your own needs
-- I probably won't be adding Vectors and Dictionaries anytime soon since I don't think many people use it
-- This is based on a older version of YewScript anyway (before v1.9.9 but fixing some of the issues fixed in that version)
-- Hopefully you get some use out of this interpreter as a whole

local function loadyewscript(ExtrasTable)
    local function split(Str,Sep)
        local Out,Length = {},1
        for I in string.gmatch(Str,"([^"..Sep.."]+)") do Out[Length]=I Length=Length+1 end
        return Out
    end
    local function Loop(Amount)local Table = {}for I=1,Amount do Table[I]=I end return Table end

    local ExtraString = " has no binding, please use the Extras table to implement bindings."
    local Extras={
        ["imgbox"]=function()print("imgbox"..ExtraString)end,
        ["box"]=function()print("box"..ExtraString)end,
	["change"]=function()print("change"..ExtraString)end,
    }
    local ExtraKeywords={
        ["CursorX"]=function()print("CursorX"..ExtraString)end,
	["CursorY"]=function()print("CursorY"..ExtraString)end,
	["Touch2D"]=function()print("Touch2D"..ExtraString)end,
    }
    local ExtrasTable = ExtrasTable or {Instructions={},Keywords={}}
    for I,V in pairs(ExtrasTable.Instructions) do Extras[I]=V end
    for I,V in pairs(ExtrasTable.Keywords) do ExtraKeywords[I]=V end
    

    local CurrentLine=1
    local DoRun = true
    local IgnoreErrors = false

    local ifinit,Index={},1
    local ForBuffer,IfBuffer,ElseBuffer,EndBuffer={},{},{},{}

    local Variables={
        A={0},B={0},C={0},D={0},E={0},F={0},G={0},H={0},I={0},J={0},K={0},L={0},M={0},
        N={0},O={0},P={0},Q={0},R={0},S={0},T={0},U={0},V={0},W={0},X={0},Y={0},Z={0},
    }
    local Keywords={
        ["Rand"]=function(Data1,Data2)
            local Min = tonumber(Data1[1])
            if Min == nil then return {math.random()} else
            return {math.random(Min,(Data2 or {Min})[1])} end
        end,
        ["Time"]=function()return {os.clock()} end,
        ["Self"]=function()return {Code} end,
        ["Year"]=function()return {math.floor(os.time()/31536000)+1970} end,
        ["Port"]=function()return {0} end,
        ["Buffer"]=function(Channel)
            if tostring(Channel[1]) == "10" then return {io.read()}else return {0}end
        end,
        ["RealTime"]=function() return {os.time()} end,
        ["Length'"]=function(Variable) return {#tostringyew(Variables[Variable])} end,
        ["Size'"]=function(Data)
            local VariableList,Location = GetValue(Data)
            return {#VariableList[Location]}
        end,
	["User"]=function()return {"Jaatzy"} end,
	["Players"]=function()return {"Jaatzy"} end,
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
	["Touch2D"]=function(Data)return ExtraKeywords.Touch2D(Data)end,
        ["Btan"]=function(Data,Data2)return {math.atan2(Data[1],Data2[1])} end,
    }

    local Operations={
        ["="]=function(A,B)
            local Variable = IsVariable(B)
            local Keyword = IsKeyword(B)
            if Keyword then
                local KeywordReference,Split = Keywords[Keyword],split(B:sub(#Keyword+1),"'")
                if Split then
                    local List,Loc=GetValue(Split[1])
                    local List2,Loc2 = {0},0
                    if Split[2] then List2,Loc2=GetValue(Split[2]) end
                    return function()Variables[A]=KeywordReference(List[Loc],List2[Loc2]) end
                else return function()Variables[A]=KeywordReference() end end
            elseif Variable then
                local Split = split(B,"'")[2]
                if Split then
                    local List,Loc=GetValue(Split)
                    return function()Variables[A]={Variables[Variable][List[Loc][1]]} end
                else return function()local Table = {} for I=1,#Variables[Variable] do Table[I]=Variables[Variable][I] end Variables[A]=Table end end
            elseif B:find(";") then return function()Variables[A]=split(B,";") end
            else local E = tonumber(B) E=E==nil and B or E return function()Variables[A]={E} end
            end
        end,
        ["+"]=function(A,B)
            local Variable = IsVariable(B)
            if Variable then
                local Split = split(B,"'")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=Variables[A][1]+Variables[Variable][List[Loc]] end
                else return function()Variables[A][1]=Variables[A][1]+Variables[Variable][1] end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=Variables[A][1]+E end
            end
        end,
        ["-"]=function(A,B)
            local Variable = IsVariable(B)
            if Variable then
                local Split = split(B,"'")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=Variables[A][1]-Variables[Variable][List[Loc]] end
                else return function()Variables[A][1]=Variables[A][1]-Variables[Variable][1] end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=Variables[A][1]-E end
            end
        end,
        ["*"]=function(A,B)
            local Variable = IsVariable(B)
            if Variable then
                local Split = split(B,"'")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=Variables[A][1]*Variables[Variable][List[Loc]] end
                else return function()Variables[A][1]=Variables[A][1]*Variables[Variable][1] end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=Variables[A][1]*E end
            end
        end,
        ["\\"]=function(A,B)
            local Variable = IsVariable(B)
            if Variable then
                local Split = split(B,"'")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=Variables[A][1]/Variables[Variable][List[Loc]] end
                else return function()Variables[A][1]=Variables[A][1]/Variables[Variable][1] end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=Variables[A][1]/E end
            end
        end,
        ["^"]=function(A,B)
            local Variable = IsVariable(B)
            if Variable then
                local Split = split(B,"'")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=Variables[A][1]^Variables[Variable][List[Loc]] end
                else return function()Variables[A][1]=Variables[A][1]^Variables[Variable][1] end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=Variables[A][1]^E end
            end
        end,
        ["%"]=function(A,B)
            local Variable = IsVariable(B)
            if Variable then
                local Split = split(B,"'")[2]
                if Split then local List,Loc=GetValue(Split)return function()Variables[A][1]=Variables[A][1]%Variables[Variable][List[Loc]] end
                else return function()Variables[A][1]=Variables[A][1]%Variables[Variable][1] end end
            else local E=tonumber(B)E=(E==nil and B or E) return function()Variables[A][1]=Variables[A][1]%E end
            end
        end,
        ["@"]=function(A,B)
            local BL,BLo = GetValue(B)
            return function()
                if BL[BLo][1] == -1 then Variables[A][1]=math.floor(Variables[A][1])
                elseif BL[BLo][1] == 0 then Variables[A][1]=math.floor(Variables[A][1]+.5)
                else Variables[A][1]=math.ceil(Variables[A][1])end
            end
        end,
        [">"]=function(A,B)
            local BL,BLo = GetValue(B)
            return function()
                if Variables[A][1] < BL[BLo][1] then Variables[A][1] = BL[BLo][1]end
            end
        end,
        ["<"]=function(A,B)
            local BL,BLo = GetValue(B)
            return function()
                if Variables[A][1] > BL[BLo][1] then Variables[A][1] = BL[BLo][1]end
            end
        end
    }
    Operations["`"]=Operations["*"]

    local LogicOperations={
        ["="]=function(A,B,C,D,Line)return function()
            if tostringyew(A[B])~=tostringyew(C[D]) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["!"]=function(A,B,C,D,Line)return function()
            if tostringyew(A[B])==tostringyew(C[D]) then CurrentLine=IfBuffer[Line][2]end
        end end,
        [">"]=function(A,B,C,D,Line)return function()
            if not (A[B][1]>C[D][1]) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["<"]=function(A,B,C,D,Line)return function()
            if not (A[B][1]<C[D][1]) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["}"]=function(A,B,C,D,Line)return function()
            if not (A[B][1]>=C[D][1]) then CurrentLine=IfBuffer[Line][2]end
        end end,
        ["{"]=function(A,B,C,D,Line)return function()
            if not (A[B][1]<=C[D][1]) then CurrentLine=IfBuffer[Line][2]end
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

    function tostringyew(Value)
        local Type = type(Value)
        if Type=="table" then return table.concat(Value,";")
        else return Value end
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
            return function()CurrentLine=List[Loc][1]-1 end
        end,
        ["leapto"]=function(line)
            local List,Loc = GetValue(line)
            return function()CurrentLine=CurrentLine+List[Loc][1]-1 end
        end,
        ["beep"]=function(pitch)
            local List,Loc = GetValue(pitch)
            return function() print("Beep!",List[Loc][1]) end
        end,
        ["print"]=function(VariableKeywordDatatype)
            local Keyword = IsKeyword(VariableKeywordDatatype)
            if Keyword then
                local Split = split(VariableKeywordDatatype,"'")
                if Split[2] then
                    local List,Loc = GetValue(Split[2])
                    return function()print(Keywords[Keyword]()[List[Loc]]) end
                else return function()print(tostringyew(Keywords[Keyword]()))end end
            else
                local Variable = IsVariable(VariableKeywordDatatype)
                if Variable then
                    local Split = split(VariableKeywordDatatype,"'")[2]
                    if Split then
                        local List,Loc = GetValue(Split)
                        return function()print(Variables[Variable][List[Loc]]) end
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
                Variables[Variable][Pos[PosLoc]=="" and #Variables[Variable]+1 or Pos[PosLoc]]=DatL[DatLoc]
            end
        end,
        ["remove"]=function(Data)
            Data = split(Data,"'")
            local Pos,PosLoc = GetValue(Data[2] or "")
            Data = Data[1]

            return function()Variables[Data][Pos[PosLoc]=="" and #Variables[Data] or Pos[PosLoc]]=nil end
        end,
        ["reset"]=function()return function()
            ForBuffer,CurrentLine={},0
            for I,_ in pairs(Variables) do Variables[I]={0} end
        end end,
        ["for"]=function(Data)return function()
            ForBuffer[#ForBuffer+1] = {1,#Variables[Data],Variables[Data],CurrentLine}
            local a = Variables[Data][1]
            Variables.Z={tonumber(a)==nil and a or tonumber(a)}
        end end,
        ["loop"]=function(Data)
            local DataL,DataLoc = GetValue(Data)
            local Split = split(Data,"'")[2]
            if Split then Bruh=GetValue(Split) end
            return function()
            Variables.Z={1}
            ForBuffer[#ForBuffer+1] = {1,DataL[DataLoc][1],Loop(DataL[DataLoc][1]),CurrentLine}
        end end,
        ["endloop"]=function()return function()
            local Loop = ForBuffer[#ForBuffer]
            Loop[1]=Loop[1]+1
            if Loop[1]<=Loop[2] then 
                local a = Loop[3][Loop[1]]
                Variables.Z = {tonumber(a)==nil and a or tonumber(a)}
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
            local A,B = GetValue(Data)
            return function()local Base=os.clock() repeat until os.clock()>Base+A[B][1] end
        end,
        ["sweep"]=function(Data)
            local Data = split(Data,"'")
            local A,B = GetValue(Data[1])
            local C,D = GetValue(Data[2])
            return function()local T,V=A[B],tostring(C[D][1]) for I=1,#T do if tostring(T[I])==V then table.remove(T,I) end end end
        end,
        ["remove"]=function(Data)
            local Data = split(Data,"'")
            local A,B = GetValue(Data[1])
            local C,D = GetValue(Data[2])
            return function()table.remove(A[B],C[D])end
        end,
        ["errmode"]=function(Data)
            local A,B = GetValue(Data)
            return function()IgnoreErrors = A[B]==0 end
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
            return function() Extras.change(IdL[IdI],PosXL[PosXI],PosYL[PosYI],SXL[SXI],SYL[SYI],TxtL[TxtI],BCL[BCI],CL[CI])end
        end,
        ["delete"]=function(Data)
            local Data = split(Data,"'")
            local Id,IdLoc = GetValue(Data[1])
            return function() Extras.delete(Id[IdLoc])end
	end,
    }
    InstructionArray={}
    for I,_ in pairs(Instructions) do InstructionArray[#InstructionArray+1] = I end
    table.sort(InstructionArray,function(a,b)return #a>#b end)-- Longest instruction gets checked first

    local function CompileProgram(Code)
        local Program={}

        Code = table.concat(split(Code,"\n"),"/")
        for I,V in pairs(split(Code,"/")) do
            local First = V:sub(1,1)
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
            if CurrentLine>Length then return true end
	    local A, B = pcall(Program[CurrentLine])
            if not A and not IgnoreErrors then error("Error at line "..CurrentLine) end
            CurrentLine = CurrentLine + 1
            return false
	end
        --while DoRun do if CurrentLine>Length then break end  Program[CurrentLine]()CurrentLine=CurrentLine+1 end
    end
end

return loadyewscript
