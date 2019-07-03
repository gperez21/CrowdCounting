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

// fix Alaska and Hawaii to appear next to mainlaind
use "$data\Districts_coor.dta",clear
// use "$Data\Districts_data.dta", clear
gen order = _n
drop if _X < -165 & (_X !=  . &  _ID == 222) |(_X !=  . &  _ID == 221)
replace _X = _X  + 55  if  (_X !=  . &  _ID == 222) |(_X !=  . &  _ID == 221)
replace _Y = _Y  + 4  if (_Y != .  & _ID == 222) | (_Y != .  & _ID == 221)

replace _X = _X*.4 -55 if  (_X !=  . &  _ID == 285) 
replace _Y = _Y*.4 + 1 if (_Y != .  & _ID == 285) 
drop if _X > -10 & _X != . & _ID == 285
drop if _X > -10 & _X != . & _ID == 285
sort order 
sort _ID
drop order
save "$Data\Districts_coor_small.dta",replace

// get FBT and MFL
use "$data\protests_by_district.dta", clear
replace counter_FBT = 0 if counter_FBT ==.


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$data\Districts_data.dta" 
replace counter_FBT = 0 if counter_FBT ==.
replace counter_gun = 0 if counter_gun ==.
replace counter_mfol = 0 if counter_mfol ==.
destring STATEFP, gen(num_fip)
drop if num_fip > 56
drop _m num_fip
* CD Map families belong together
spmap counter_FBT using "$Data\Districts_coor_small.dta", id(_ID) fcolor (black%20 lavender purple) ///
clmethod(custom) clbreaks(0 .1 2.1 100) ///
legend( label(2 "0") ///
		label(3 "1-2") ///
		label(4 "3+") ///
		symy(*2) symx(*2) size(*2) position (4)) ///
title("Families Belong Together Protests by Congressional district")
graph save Graph "$output\FBT_USA_cloro.gph", replace

* CD Map Gun Protests
spmap counter_gun using "$Data\Districts_coor_small.dta", id(_ID) fcolor (black%20 orange%20 orange%50 orange%95) ///
clmethod(custom) clbreaks(0 .1 4.9 9.9 100) ///
legend( label(2 "  0") ///
		label(3 "< 5") ///
		label(4 "< 10") ///
		label(5 "10+") ///
		symy(*2) symx(*2) size(*2) position (4)) ///
title("Gun-Reform Protests by Congressional district")
graph save Graph "$output\Gun_USA_cloro.gph", replace

* CD Map March for Our Lives
spmap counter_mfol using "$Data\Districts_coor_small.dta", id(_ID) fcolor (black%20 orange%20 orange%50 orange%95) ///
clmethod(custom) clbreaks(0 .1 2.1 100) ///
legend( label(2 "0") ///
		label(3 "1-2") ///
		label(4 "3+") ///
		symy(*2) symx(*2) size(*2) position (4)) ///
title("March for Our Lives Events by Congressional district")
graph save Graph "$output\MfoL_USA_cloro.gph", replace
