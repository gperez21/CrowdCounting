clear
set more off


// import excel "$raw\Anti-gun.xlsx", sheet("Sheet1") firstrow clear
// keep if _n < 1001 | _n > 2500
// gen address = CityTown + " "+", "+ StateTerritory + ", " + Country

import excel "$raw\Families Belong Together.xlsx", sheet("Sheet1") firstrow clear
gen address = CityTown + " "+", "+ StateTerritory + ", " + Country

forvalues n = 1/`c(N)'{
	di "`n'"
	gocode address, obs(`n')
}

export excel using "$output\geo_coded_FBT_1.xlsx", firstrow(varlabels) replace
save "$data\geo_coded_FBT_1", replace

