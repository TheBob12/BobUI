function set(...) -- https://stackoverflow.com/questions/49501359/lua-checking-multiple-values-for-equailty
	local ret = {}
	for _,k in ipairs({...}) do ret[k] = true end
	return ret
 end