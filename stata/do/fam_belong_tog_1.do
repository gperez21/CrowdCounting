// This file spatially joins xy data to shapefiles

* set up
clear
set type double

cd "C:\Users\perez_g\Desktop\crowd counting\stata"
gl root "C:\Users\perez_g\Desktop\crowd counting\stata"
capture mkdir "$root\do"
capture mkdir "$root\raw"
capture mkdir "$root\data"
capture mkdir "$root\output"
gl do "$root\do"
gl raw "$root\raw"
gl data "$root\data"
gl output "$root\output"

* geocode
// save "$data\raw_fam_belong_tog", replace
// use "$data\raw_fam_belong_tog", clear
// address broken up format GEOcode 
// opencagegeo, key(e4c5a22b9a9540e880b666c332b7351f) street(location) city(citytown) state(stateterritory) country(country)
// save a geocoded raw file
// save "$data\geo_fam_belong_tog", replace

use "$data\geo_fam_belong_tog", clear
// drop ones that didnt work (5)
drop if g_quality <3
// make data set for arcgis online
ren (g_lat g_lon) (y x)
destring y x estimatelow, replace force
gen best_guess = (estimatelow + estimatehigh)/2 if estimatelow & estimatehigh
replace best_guess = estimatelow if missing(best_guess)
replace best_guess = estimatehigh if missing(best_guess)
replace best_guess = 1 if missing(best_guess)
keep x y eventtype source1 estimatetext best_guess estimatehigh estimatelow citytown state
// export esri file
ren eventtype Type
ren source1 Source
ren estimatetext Blurb
ren best_guess Crowd
ren citytown City
ren state State
drop if x > -5
drop if y < 15
export delimited using "$output\families_belong_tog_esri.csv", nolabel replace
