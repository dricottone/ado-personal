// Dominic R, 7/1/2021

program cf_vallabels
	args file1 file2

	clear
	use "`file1'"
	tempfile labels1
	quietly log using "`labels1'", text
	label list
	quietly log close

	clear
	quietly import delimited "`labels1'"
	quietly {
		generate flag_variable=strpos(v1,":")==strlen(v1)
		generate flag_value=strpos(v1,"        ")==1
		keep if flag_variable==1 | flag_value==1
		generate variable=v1 if flag_variable==1
		replace variable=variable[_n-1] if flag_variable==0
		generate value=v1 if flag_value==1
		keep if flag_value==1
	}
	keep variable value
	tempfile dictionary1
	save "`dictionary1'"

	clear
	use "`file2'"
	tempfile labels2
	quietly log using "`labels2'", text
	label list
	quietly log close

	clear
	quietly import delimited "`labels2'"
	quietly {
		generate flag_variable=strpos(v1,":")==strlen(v1)
		generate flag_value=strpos(v1,"        ")==1
		keep if flag_variable==1 | flag_value==1
		generate variable=v1 if flag_variable==1
		replace variable=variable[_n-1] if flag_variable==0
		generate value=v1 if flag_value==1
		keep if flag_value==1
	}
	keep variable value

	merge 1:1 variable value using "`dictionary1'"
	list _merge variable value if _merge!=3
end

