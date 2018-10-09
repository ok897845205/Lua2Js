require "lfs"
require "json"

--读取文件内容
function readFile(path)
    local file = io.open(path, "r")
    local data=""
    if file ~= nil then
        data = file:read("*a")
        file:close()

        if data ~= nil then
            --print("readFile : load OK")
        else
            print("readFile : load fail")
        end
    else
        print("readFile : can not get data:",path)
    end

    return data
end


function writeFile(path, data)
    local file = io.open(path, "w+")
    if file then
        file:write(data)
        file:flush()
        file:close()
    else
        print("writeFile : load fail")
    end
end

function isContainArray(s)
    local sa = string.find(s, "%b[]")
    if sa then
        return true
    end
    return false
end

-- global function
function gswitchToLet(s)
    s = string.gsub(s, "%.%.", "+")
    s = string.gsub(s, "(=%s*)nil", "%1null")
    s = string.gsub(s, "nil(%s*=)", "null%1")
    return string.gsub(s, "local%s+", "let ")
end

-- 注释
function gswitchToComment(s)
    s = string.gsub(s, "%-%-%[%[(.-)]]", "/*%1*/")
    return string.gsub(s, "%-%-", "//")
end

function gswitchToRequire(s)
    return string.gsub(s, "require%s*%(?\"(.-)\"%)?", function (req)
        req = string.gsub(req, "%.", "/")
        req = "./" .. req 
        req = "require(\'" .. req .. "\')"
        return req
    end)
end

function switchToColon(s)
    s = string.gsub(s, "(%w%s*)=(%s*-?\"?[^=])", "%1:%2")   -- k-v
    s = string.gsub(s, "(%w%s*)=(%s*{)", "%1:%2")           -- table in table
    s = string.gsub(s, "(]%s*)=", "%1:")                    -- array
    return s
end

function switchToIfElse(s)
    s = string.gsub(s, "if%s+", "if (")
    s = string.gsub(s, "%s+then", ") {")
    s = string.gsub(s, "else(i?f?)(%s+)", function (res1, res2)
        if res1 == "" then
            return "} else {" .. res2
        else
            return "} else if " .. res2
        end
    end)
    s = string.gsub(s, "(%s+)end(%s+)", "%1}%2")
    s = string.gsub(s, "(%s+)end,", "%1},")
    s = string.gsub(s, "(%s+)end(%s*)}", "%1}%2}")
    
    return s
end

function switchToFunction(s)
    s = string.gsub(s, "(function%(.-%))", "%1 {")
    return s
end

function gswitchToReturn(s)
    s = string.gsub(s, "return%s+([^}]+)(%s*)(}?)", function (res1, res2, res3)
        if res3 == "" or not res3 then
            return "module.exports = " .. res1
        else
            local function tailFindSpace(s )
                for i = #s, 1, -1 do
                    if s:sub(i, i) ~= " " then
                        return true, i - 1
                    end
                end

                return false
            end
            
            local frontStr = res1
            local ok, pos = tailFindSpace(res1)
            if ok then
                frontStr = string.sub(res1, 1, pos)
                frontStr = frontStr .. ";" .. string.sub(res1, pos + 1, #res1)
            end
            return "return " .. frontStr .. res2 .. res3
        end
    end)
    return s
end

function switchToArray(s)
    s = string.gsub(s, "%[\"(-?%d+)\"%]", "[\"_%1\"]")
    s = string.gsub(s, "{%s*{%s*", "[[")
    s = string.gsub(s, "%s*}%s*,%s*{%s*", "], [")
    s = string.gsub(s, "(,%s*%[%s*.-)%s*}%s*}%s*,?", "%1]],")
    return s
end

function switchToJs(cf)
    local result = string.gsub(cf, "%b{}", function (s)
        if s == "{}" then
            return s
        end

        s = switchToColon(s)
        s = switchToArray(s)
        s = switchToIfElse(s)
        s = switchToFunction(s)
        return s
    end)

    return result
end

function convert(luaName, LuaPath)
    local jsonName = luaName
    print(luaName .. ".lua" .. " >>>>>> " .. jsonName .. ".js")

    local cf = readFile(LuaPath)
    cf = gswitchToLet(cf)
    cf = gswitchToComment(cf)
    cf = gswitchToRequire(cf)

    local result = switchToJs(cf)
    result = gswitchToReturn(result)

    local Jspath = "./js/" .. jsonName .. ".js"
    writeFile(Jspath, result)
end

function start(path)
    for fileName in lfs.dir(path) do
        if fileName ~= "." and fileName ~= ".." then
            if string.find(fileName, ".lua") ~= nil then
                local filePath = path .. '/' .. fileName
                fileName = string.sub(fileName, 1, string.find(fileName, ".lua") - 1)
                convert(fileName, filePath)
            end
         end
    end
end

print(">>>>>> begin <<<<<<\n")

start("./lua")

print("\n>>>>>>  end  <<<<<<\n")