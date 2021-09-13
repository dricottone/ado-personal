// Dominic R
// Updated 9/13/2021

program cf_vallabels
	args file1 file2

	quietly {
		clear
		use "`file1'"

		// Save label definition syntax to a tempfile
		tempfile labels1
		label save using "`labels1'"

		// Save a lookup table for variable names to value labels
		tempfile labelnames1
		describe, replace
		keep if !missing(vallab)
		keep name vallab
		save "`labelnames1'"

		// Import label definition syntax as a text file
		clear
		import delimited using "`labels1'", delimiter(" ")
		rename v3 vallab
		rename v4 value
		rename v5 label1
		replace label1 = substr(label1, 1, length(label1)-3) if substr(label1, -3, 3)==char(34)+char(39)+char(44)
		replace label1 = substr(label1, 3, .) if substr(label1, 1, 2)==char(96)+char(34)

		// Uee lookup table to merge variable names on label definitions
		merge m:1 vallab using "`labelnames1'"
		keep if _merge==3
		keep name value label1

		// Save metadata for file 1
		tempfile dictionary1
		save "`dictionary1'"

		// Now repeat for file 2...

		clear
		use "`file2'"

		tempfile labels2
		label save using "`labels2'"

		tempfile labelnames2
		describe, replace
		keep if !missing(vallab)
		keep name vallab
		save "`labelnames2'"

		clear
		import delimited using "`labels2'", delimiter(" ")
		rename v3 vallab
		rename v4 value
		rename v5 label2
		replace label2 = substr(label2, 1, length(label2)-3) if substr(label2, -3, 3)==char(34)+char(39)+char(44)
		replace label2 = substr(label2, 3, .) if substr(label2, 1, 2)==char(96)+char(34)

		merge m:1 vallab using "`labelnames2'"
		keep if _merge==3
		keep name value label2

		// Merge metadata between file 1 and 2, using variable names and values
		merge 1:1 name value using "`dictionary1'"
		generate msg = ""
		replace msg = "file 1 only" if _merge==1
		replace msg = "file 2 only" if _merge==2
		rename _merge merge_between_dictionaries

		// Check for variables that are entirely unlabeled in a file
		tempfile groupedlabels
		preserve
		contract name merge_between_dictionaries
		sort name
		by name: generate dup=cond(_N==1,0,_n)
		keep if dup==0 & merge_between_dictionaries!=3
		keep name
		save "`groupedlabels'"
		restore
		merge m:1 name using "`groupedlabels'"
		rename _merge merge_to_groupedlabels

		// Sort variable-value pairs and mark the first row per variable
		sort name value
		by name: generate groupedorder=cond(_N==1,0,_n)
	}

	display "These variables are unlabeled in a file:"
	list name msg if merge_to_groupedlabels==3 & inlist(groupedorder,0,1)
	display ""
	
	display "These values are unlabeled in a file:"
	list name value msg if merge_between_dictionaries!=3
	display ""
	
	quietly {
		// Shrink file to just the labels that should be manually examined
		keep if merge_between_dictionaries==3 & label1!=label2
		keep name value label1 label2
		order name value label1 label2
		compress
	}
	
	display "These labels differ:"
	list name value label1 label2
end
