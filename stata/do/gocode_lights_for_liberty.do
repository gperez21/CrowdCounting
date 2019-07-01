clear
set more off

cd "C:\Users\perez_g\Desktop\Politics Data\CrowdCounting\stata"
gl root "C:\Users\perez_g\Desktop\Politics Data\CrowdCounting\stata"
capture mkdir "$root\do"
capture mkdir "$root\raw"
capture mkdir "$root\data"
capture mkdir "$root\output"
gl do "$root\do"
gl raw "$root\raw"
gl data "$root\data"
gl output "$root\output"
gl GIS "C:\Users\perez_g\Desktop\Politics Data\CrowdCounting\GIS"


// import excel "$raw\Anti-gun.xlsx", sheet("Sheet1") firstrow clear
// keep if _n < 1001 | _n > 2500
// gen address = CityTown + " "+", "+ StateTerritory + ", " + Country
import excel "C:\Users\perez_g\Desktop\Politics Data\CrowdCounting\stata\raw\Lights for Liberty 7-1.xlsx", sheet("Sheet1") firstrow
gen address = City +", "+ State + ", USA"

forvalues n = 1/`c(N)'{
	di "`n'"
	gocode address, obs(`n')
}

export excel using "$output\geo_coded_LFL.xlsx", firstrow(varlabels) sheet("Sheet1") sheetreplace
save "$data\geo_coded_LFL", replace
// use "$data\geo_coded_LFL", clear
