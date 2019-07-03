** Make master file with district information and district merge vars

clear
set type double

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
********************************************************************************
** import CDI file from city labs wtih general election results
import excel "$raw\general_results.xlsx", sheet("Results") cellrange(A2:I437) firstrow clear
ren H Obama08
ren Obama Obama12

gen General_2016 = "R" if Trump>Clinton
replace General_2016 = "D" if Trump<Clinton

gen General_2012 = "R" if Romney>Obama12
replace General_2012 = "D" if Romney<Obama12
//Florida 7th went narrowly Obama
replace General_2012 = "D" if CD == "FL-07"
ren CD district
// gen trump obama margins
gen trump_margin = Trump - Clinton
save "$data/General_data.dta", replace
********************************************************************************
** import 2018 2016 swing data
use "$data\2016_results.dta", clear
* merge in 2016 congressional results
merge m:1 district using "$data\2018_results" 
drop _m total2016 pct2016other

* Find difference between rep and dem pct in 2016 & 2018
gen diff_2016 = pct2016dem - pct2016rep
gen diff_2018 = pct2018dem - pct2018rep
gen swing_2018 = diff_2018 - diff_2016
//dont include PA districts or those uncontested in either election
replace swing_2018 =. if unc2016 != "" | unc2016 != ""
replace swing_2018 =. if strpos(district, "PA")
save "$data/2018_swing_data.dta", replace

********************************************************************************
* prepare geo info file with variables for merging
use "$data\Districts_data.dta", clear
//drop extraneous
drop if CD116FP == "ZZ"
drop if NAME == "Resident Commissioner District (at Large)"
drop MTFCC FUNCSTAT ALAND AWATER INTPTLAT INTPTLON

gen district = NAMELSAD
drop NAMELSAD
replace district = subinstr(district, "Congressional District ", "",.)
drop if district == "Delegate District (at Large)" // DC isnt in the CDI data
replace district = "AL" if district == "(at Large)"
ren district number
replace number = (2-length(number))*"0" +number
gen state = ""
// get abbrv from fip
{
replace state = "CA" if STATEFP == "06"
replace state = "NY" if STATEFP == "36"
replace state = "VA" if STATEFP == "51"
replace state = "NJ" if STATEFP == "34"
replace state = "MD" if STATEFP == "24"
replace state = "MA" if STATEFP == "25"
replace state = "TX" if STATEFP == "48"
replace state = "CT" if STATEFP == "09"
replace state = "IL" if STATEFP == "17"
replace state = "WA" if STATEFP == "53"
replace state = "MN" if STATEFP == "27"
replace state = "GA" if STATEFP == "13"
replace state = "MO" if STATEFP == "29"
replace state = "CO" if STATEFP == "08"
replace state = "MI" if STATEFP == "26"
replace state = "PA" if STATEFP == "42"
replace state = "NC" if STATEFP == "37"
replace state = "KS" if STATEFP == "20"
replace state = "AZ" if STATEFP == "04"
replace state = "HI" if STATEFP == "15"
replace state = "WI" if STATEFP == "55"
replace state = "NH" if STATEFP == "33"
replace state = "FL" if STATEFP == "12"
replace state = "IN" if STATEFP == "18"
replace state = "OR" if STATEFP == "41"
replace state = "OH" if STATEFP == "39"
replace state = "RI" if STATEFP == "44"
replace state = "NV" if STATEFP == "32"
replace state = "ME" if STATEFP == "23"
replace state = "NE" if STATEFP == "31"
replace state = "SC" if STATEFP == "45"
replace state = "IA" if STATEFP == "19"
replace state = "VT" if STATEFP == "50"
replace state = "AL" if STATEFP == "01"
replace state = "AK" if STATEFP == "02"
replace state = "LA" if STATEFP == "22"
replace state = "UT" if STATEFP == "49"
replace state = "DE" if STATEFP == "10"
replace state = "ND" if STATEFP == "38"
replace state = "WY" if STATEFP == "56"
replace state = "NM" if STATEFP == "35"
replace state = "KY" if STATEFP == "21"
replace state = "SD" if STATEFP == "46"
replace state = "TN" if STATEFP == "47"
replace state = "OK" if STATEFP == "40"
replace state = "ID" if STATEFP == "16"
replace state = "AR" if STATEFP == "05"
replace state = "MT" if STATEFP == "30"
replace state = "WV" if STATEFP == "54"
replace state = "MS" if STATEFP == "28"
}
gen district = state + "-" + number
drop number

* merge general election data
merge 1:1 district using "$data/General_data.dta"
drop _m
* merge in congressional election data
merge 1:1 district using "$data/2018_swing_data.dta"
drop _m

save "$data\Congressional_district_master", replace


