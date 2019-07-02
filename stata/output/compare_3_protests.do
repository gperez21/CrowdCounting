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

// get FBT and MFL
use "$data\protests_by_district.dta", clear
tempfile p1
save `p1'

// get LFL
use "$data\LFL_mapped_to_dist.dta",  clear
drop if _ID == 81
collapse (sum) counter, by(_ID STATEFP NAMELSAD)
merge 1:1 _ID STATEFP using `p1'
drop _m
save "$data/protests_mapped_to_dist.dta", replace
// merge in electoral data

* import CDI file from city labs
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

save "$data/General_data.dta", replace

// * Disricts that swung
// import delimited "$Electoral_data/flipped_seats.csv", varnames(1) clear
// ren flipped district
// gen flipped = "Flipped"
// save "$Data/Flipped_seats.dta", replace


* create matching number and state variables for the store file
use "$data/protests_mapped_to_dist.dta", clear
ren NAMELSAD district
replace district = subinstr(district, "Congressional District ", "",.)
drop if district == "Delegate District (at Large)" // DC isnt in the CDI data
replace district = "AL" if district == "(at Large)"
ren district number
replace number = (2-length(number))*"0" +number

* merge in General results from Daily Kos
merge m:1 district using "$Data/General_data.dta"
// keep if _m == 3
drop _m
