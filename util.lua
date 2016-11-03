
local Global = require "libs.Global"

Global{
	-- Box2D collision filter masks --
	CL_INT   = 0x0001,
	CL_WALL  = 0x0002,
  CL_PLAT  = 0x0003,
	CL_NPC   = 0x0004,
	CL_CHAR  = 0x0008,
	CL_FX	 = 0x0009,
}

local util = {}

----
-- Constrain a value between a min and max.
-- @param {number} x - The value
-- @param {number} min - The minimum value
-- @param {number} max - The maximum value
-- @return x if min <= x <= max; min if x < min; max if x > max.
----
function util.clamp( x, min, max )
	if x > max then
		return max
	elseif x < min then
		return min
	else
		return x
	end
end

function util.create( typename, ... )
	local class = require( typename )
	return class( ... )
end

function util.loopvalue( value, min, max )
	if     value < min then
		return max + min - value - 1
	elseif value > max then
		return min + value - max - 1
	else
		return value
	end
end

----
-- Round val. If the decimal portion of val is < 0.5 it will be rounded down.
-- If it is >= 0.5 it will be rounded up.
-- @param {number} val - The number to round
-- @return the rounded number
----
function util.round( val )
	return math.floor(val + 0.5)
end

----
-- Return true if f is a fucntion.
----
function util.is_function( f )
	return type(f) == "function"
end

----
-- Return true if x is a power of two, false otherwise.
----
function util.is_pot( x )
	local v = 2
	while x > v do
		v = math.pow(v,2)
	end
	return x == v
end

----
-- Determine if an image is POT (Power-of-Two)
-- @param {Image} image - the image to check
-- @return true or false
----
function util.is_pot_texture( image )
	return util.is_pot(image:getWidth()) and util.is_pot(image:getHeight())
end

function util.moveFile( tempname, truename )
	assert(os.rename(love.filesystem.getSaveDirectory() .. "/" .. tempname, truename))
end

----
-- Create a counting function.
-- When called the returned function will return an increasing number each
-- time it is called. The current number can be changed by passing a
-- parameter to the function.
-- @param {number} initial - Number to start counting from. Default is 1.
-- @return a function as described above
----
function util.counter( initial )
	local count = initial or 1
	local ff = function (val)
		count = val or (count + 1)
		return count
	end
	return ff
end

----
-- Print out all the key-value pairs in a table. This is only a shallow print
-- and will not print sub-tables.
-- @param {table} table - The table to print
----
function util.print_table( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function util.copytableS(from, to)
	to = to or {}
	for k,v in pairs(from) do
		if rawget(to, k) == nil then to[k] = v end
	end
	return to
end

function util.sign(val)
	return val == 0 and 0 or (val < 0 and -1 or 1) 
end

function util.tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function util.clone_shallow( src )
	return setmetatable(util.copytableS(src), getmetatable(src))
end

function util.concat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end
----
-- Changes the transient parts of an object. When called with no parameters
-- this function makes the object itself transient. When called with
-- parameters it adds those keys to the list of transient keys. Transient
-- keys and objects are not saved when the game is saved.
-- @param {table} object - the object to change the transient table of
-- @param {string...} ... - values to add to the transience table
-- @return the object
----
function util.transient( object, ... )
	local args = {...}
	local result = util.copytableS( object.__transient or {} )
	if #args > 0 then
		for k=1,#args do
			result[args[k]] = true
		end
	else
		result["self"] = true
	end
	local meta_index = getmetatable(object).__index
	if meta_index and meta_index.__transient then -- object's __index has __transient 
		setmetatable(result, {__index = meta_index.__transient})
	end
	object.__transient = result
	return object
end

function util.getClassPath( c )
	if c.type then
		if c.__package then
			return c.__package .. "." .. c.type
		else
			return c.type
		end
	else
		return nil
	end
end

function util.recreateObject( entity )
	local class = require( "objects." .. util.getClassPath( entity ) )
	local inst = class()
	for k,v in pairs( entity ) do
		inst[k] = v
	end
	return inst
end

----
-- Walk a tree of tables to find the node corresponding to path.
-- For example if your tree looks like { a = { b = { foo = "bar" } } } then
-- you would send the path "a.b.foo" to retrieve "bar".
-- 
-- @param {table} root - The root of the tree to search
-- @param {string} path - The path to walk. Each section of the path shall be
--        separated by <separator>.
-- @param {string} [separator] - The separator to use when splitting the string.
--        Default is "."
----
function util.walkTree( root, path, separator )
	assert( type(root) == "table" and type(path) == "string",
		"invalid parameter type" )
	separator = separator or "."
	local pattern = "(%w+)" .. separator .. "?"
	local t = root
	for k in string.gmatch( path, pattern ) do
		assert( t[k], "invalid path specified" )
		t = t[k]
	end
	return t
end

----
-- Prints the run time of the funciton fn.
-- @param {string} name - printable function name
-- @param {function} fn - function to time
-- @param ... - arguments for fn
----
function util.timef( name, fn, ... )
	local getTime = love.timer.getTime
	local tbefore = getTime()
	fn( ... )
	local tdelta = getTime() - tbefore
	print( "Timing of ", name, "was", tdelta )
end

function util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function util.hasValue(table, goal)
    for index, value in ipairs (table) do
        if value == goal then
            return true
        end
    end
    return false
end

function util.deleteFromTable(table, goal)
    for index, value in ipairs (table) do
        if value == goal then
            value = nil
        end
    end
    return false
end

function util.reverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end
-- declare local variables
--// exportstring( string )
--// returns a "Lua" portable version of the string
local function exportstring( s )
  return string.format("%q", s)
end

--// The Save Function
function util.save(  tbl,filename )
  local charS,charE = "   ","\n"
  local file,err = io.open( filename, "wb" )
  if err then return err end

  -- initiate variables for save procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  file:write( "return {"..charE )

  for idx,t in ipairs( tables ) do
     file:write( "-- Table: {"..idx.."}"..charE )
     file:write( "{"..charE )
     local thandled = {}

     for i,v in ipairs( t ) do
        thandled[i] = true
        local stype = type( v )
        -- only handle value
        if stype == "table" then
           if not lookup[v] then
              table.insert( tables, v )
              lookup[v] = #tables
           end
           file:write( charS.."{"..lookup[v].."},"..charE )
        elseif stype == "string" then
           file:write(  charS..exportstring( v )..","..charE )
        elseif stype == "number" then
           file:write(  charS..tostring( v )..","..charE )
        end
     end

     for i,v in pairs( t ) do
        -- escape handled values
        if (not thandled[i]) then
        
           local str = ""
           local stype = type( i )
           -- handle index
           if stype == "table" then
              if not lookup[i] then
                 table.insert( tables,i )
                 lookup[i] = #tables
              end
              str = charS.."[{"..lookup[i].."}]="
           elseif stype == "string" then
              str = charS.."["..exportstring( i ).."]="
           elseif stype == "number" then
              str = charS.."["..tostring( i ).."]="
           end
        
           if str ~= "" then
              stype = type( v )
              -- handle value
              if stype == "table" then
                 if not lookup[v] then
                    table.insert( tables,v )
                    lookup[v] = #tables
                 end
                 file:write( str.."{"..lookup[v].."},"..charE )
              elseif stype == "string" then
                 file:write( str..exportstring( v )..","..charE )
              elseif stype == "number" then
                 file:write( str..tostring( v )..","..charE )
              end
           end
        end
     end
     file:write( "},"..charE )
  end
  file:write( "}" )
  file:close()
end

--// The Load Function
function util.load( sfile )
  local ftables,err = loadfile( sfile )
  if err then return _,err end
  local tables = ftables()
  for idx = 1,#tables do
     local tolinki = {}
     for i,v in pairs( tables[idx] ) do
        if type( v ) == "table" then
           tables[idx][i] = tables[v[1]]
        end
        if type( i ) == "table" and tables[i[1]] then
           table.insert( tolinki,{ i,tables[i[1]] } )
        end
     end
     -- link indices
     for _,v in ipairs( tolinki ) do
        tables[idx][v[2]],tables[idx][v[1]] =  tables[idx][v[1]],nil
     end
  end
  return tables[1]
end

-- Found at http://lua-users.org/wiki/TablePersistence, All credit goes to original creator
local write, writeIndent, writers, refCount;

util.persistence =
{
  store = function (path, ...)
    local file, e = io.open(path, "w");
    if not file then
      return error(e);
    end
    local n = select("#", ...);
    -- Count references
    local objRefCount = {}; -- Stores reference that will be exported
    for i = 1, n do
      refCount(objRefCount, (select(i,...)));
    end;
    -- Export Objects with more than one ref and assign name
    -- First, create empty tables for each
    local objRefNames = {};
    local objRefIdx = 0;
    file:write("-- Persistent Data\n");
    file:write("local multiRefObjects = {\n");
    for obj, count in pairs(objRefCount) do
      if count > 1 then
        objRefIdx = objRefIdx + 1;
        objRefNames[obj] = objRefIdx;
        file:write("{};"); -- table objRefIdx
      end;
    end;
    file:write("\n} -- multiRefObjects\n");
    -- Then fill them (this requires all empty multiRefObjects to exist)
    for obj, idx in pairs(objRefNames) do
      for k, v in pairs(obj) do
        file:write("multiRefObjects["..idx.."][");
        write(file, k, 0, objRefNames);
        file:write("] = ");
        write(file, v, 0, objRefNames);
        file:write(";\n");
      end;
    end;
    -- Create the remaining objects
    for i = 1, n do
      file:write("local ".."obj"..i.." = ");
      write(file, (select(i,...)), 0, objRefNames);
      file:write("\n");
    end
    -- Return them
    if n > 0 then
      file:write("return obj1");
      for i = 2, n do
        file:write(" ,obj"..i);
      end;
      file:write("\n");
    else
      file:write("return\n");
    end;
    if type(path) == "string" then
      file:close();
    end;
  end;

  load = function (path)
    local f, e;
    if type(path) == "string" then
      f, e = loadfile(path);
    else
      f, e = path:read('*a')
    end
    if f then
      return f();
    else
      return nil, e;
    end;
  end;
}

-- Private methods

-- write thing (dispatcher)
write = function (file, item, level, objRefNames)
  writers[type(item)](file, item, level, objRefNames);
end;

-- write indent
writeIndent = function (file, level)
  for i = 1, level do
    file:write("\t");
  end;
end;

-- recursively count references
refCount = function (objRefCount, item)
  -- only count reference types (tables)
  if type(item) == "table" then
    -- Increase ref count
    if objRefCount[item] then
      objRefCount[item] = objRefCount[item] + 1;
    else
      objRefCount[item] = 1;
      -- If first encounter, traverse
      for k, v in pairs(item) do
        refCount(objRefCount, k);
        refCount(objRefCount, v);
      end;
    end;
  end;
end;

-- Format items for the purpose of restoring
writers = {
  ["nil"] = function (file, item)
      file:write("nil");
    end;
  ["number"] = function (file, item)
      file:write(tostring(item));
    end;
  ["string"] = function (file, item)
      file:write(string.format("%q", item));
    end;
  ["boolean"] = function (file, item)
      if item then
        file:write("true");
      else
        file:write("false");
      end
    end;
  ["table"] = function (file, item, level, objRefNames)
      local refIdx = objRefNames[item];
      if refIdx then
        -- Table with multiple references
        file:write("multiRefObjects["..refIdx.."]");
      else
        -- Single use table
        file:write("{\n");
        for k, v in pairs(item) do
          writeIndent(file, level+1);
          file:write("[");
          write(file, k, level+1, objRefNames);
          file:write("] = ");
          write(file, v, level+1, objRefNames);
          file:write(";\n");
        end
        writeIndent(file, level);
        file:write("}");
      end;
    end;
  ["function"] = function (file, item)
      -- Does only work for "normal" functions, not those
      -- with upvalues or c functions
      local dInfo = debug.getinfo(item, "uS");
      if dInfo.nups > 0 then
        file:write("nil --[[functions with upvalue not supported]]");
      elseif dInfo.what ~= "Lua" then
        file:write("nil --[[non-lua function not supported]]");
      else
        local r, s = pcall(string.dump,item);
        if r then
          file:write(string.format("loadstring(%q)", s));
        else
          file:write("nil --[[function could not be dumped]]");
        end
      end
    end;
  ["thread"] = function (file, item)
      file:write("nil --[[thread]]\n");
    end;
  ["userdata"] = function (file, item)
      file:write("nil --[[userdata]]\n");
    end;
}
return util
