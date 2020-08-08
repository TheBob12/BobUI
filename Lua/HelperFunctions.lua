 -- https://stackoverflow.com/questions/49501359/lua-checking-multiple-values-for-equailty
 -- Instead of writing long chains of: if a == b or a == c or a == d ... then, just use if set(b,c,d,e,f...)[a] then
function set(...)
	local ret = {}
	for _,k in ipairs({...}) do ret[k] = true end
	return ret
 end