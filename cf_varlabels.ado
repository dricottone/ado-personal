// Dominic R, 7/1/2020

program cf_varlabels
	args file1 file2
	if "`file1'"=="" {
		display as error "No such file '`file1''"
		error(601)
	}
	if "`file2'"=="" {
		display as error "No such file '`file2''"
		error(601)
	}
	use "`file1'", clear
	foreach v of varlist _all {
		if strlen("`v'")==31 {
			local shortened = substr("`v'",1,30)
			local _`shortened': variable label `v'
		}
		else {
			local _`v': variable label `v'
		}
	}
	use "`file2'", clear
	foreach v of varlist _all {
		local file2label: variable label `v'
		
		if strlen("`v'")==31 {
			local shortened = substr("`v'",1,30)
			local file1label `_`shortened''
		}
		else {
			local file1label `_`v''
		}
		
		capture assert "`file1label'"=="`file2label'"
		if _rc!=0 {
			display "Labels changed in `v':"
			display "  File 1: `file1label'"
			display "  File 2: `file2label'"
		}
	}
end

