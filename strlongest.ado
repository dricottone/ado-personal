// Dominic R, 7/1/2021

program strlongest
	syntax [varlist(string default=none)] [, id(varname)]
	
	if "`varlist'"=="" {
		quietly ds, has(type string)
		local varlist `r(varlist)'
	}
	
	foreach v of varlist `varlist' {
		display "Examining `v'..."

		quietly generate Length = ustrlen(`v')
		quietly generate Last10 = usubstr(`v', -10, .)
		gsort -Length
		list `id' Length Last10 in 1/3

		drop Length Last10
	}
end

