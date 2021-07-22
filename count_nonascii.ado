// Dominic R, 7/22/2021

program count_nonascii
	syntax [varlist(string default=none)]

	if "`varlist'"=="" {
		quietly ds, has(type string)
		local varlist `r(varlist)'
	}

	local affected 0
	local total 0
	foreach v of varlist `varlist' {
		quietly count if ustrregexm(`v',"[^ -~]")
		local affected = `affected' + r(N)

		quietly generate int _nonascii = ustrlen(`v') - ustrlen(ustrregexra(`v',"[^ -~]",""))
		quietly egen _subtotal = total(_nonascii)
		local total = `total' + _subtotal[1]

		quietly drop _nonascii _subtotal
	}
	display "There are `total' Unicode characters in `affected' values"
end

