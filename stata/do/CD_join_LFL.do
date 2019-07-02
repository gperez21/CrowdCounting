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
 
*Create a Dta from a shape file
capture shp2dta using "$GIS/Shapefiles/tl_2018_us_cd116.shp", genid(_ID) data("$Data\Districts_data.dta") coor("$Data\Districts_coor.dta") replace

* make a map that shows alaska and HI
// Alaska is reduced in size by 60% and then both Alaska and Hawaii are re-positioned under the southwestern states.
//Drop northwest islands of Hawaii and western part of Aleutian Islands 


*Import CSV with xy data
import excel "C:\Users\perez_g\Desktop\Politics Data\CrowdCounting\stata\output\geo_coded_LFL.xlsx", sheet("Sheet1") firstrow clear
// fix some missing
replace g_lat = 39.366608 if address == "SOUTH JERSEY, NJ, USA"
replace g_lon = -74.439445 if address == "SOUTH JERSEY, NJ, USA"
replace g_lat = 28.216795 if address == "LAND O’LAKES, FL, USA"
replace g_lon = -82.457840 if address == "LAND O’LAKES, FL, USA"

gen _X = g_lon
gen _Y = g_lat

save "$data\LFL_info.dta", replace

* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$data\Districts_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$data\Districts_data.dta" 
gen counter = 0 if _m != 3
replace counter = 1 if _m == 3
destring STATEFP, gen(num_fip)
drop if num_fip > 56
drop _m num_fip

save "$data\LFL_mapped_to_dist.dta", replace
export excel using "$output\geo_coded_LFL.xlsx", sheet("With CD") firstrow(variables) sheetreplace


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


use "$Data\LFL_mapped_to_dist.dta",  clear

* Stores per district
collapse (sum) counter, by(_ID STATEFP)
* CD Map
spmap counter using "$Data\Districts_coor_small.dta", id(_ID) fcolor (grey purple) ///
clmethod(custom) clbreaks(0 .1 1.1 10) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 
