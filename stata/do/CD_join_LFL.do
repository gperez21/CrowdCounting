// This file spatially joins xy data to shapefiles

* set up
clear
set type double
cd "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store\Stata\Programs"

gl root "C:\Users\perez_g\Desktop\Data_vis_wa\data_vis_wa\Dollar store"
gl GIS "$root\GIS"
gl Stata "$root\Stata"
gl Dollar_data "$root\Dollar store data"
gl Data "$Stata\Data"
gl Dollar_data "$root\Dollar store data"
gl Electoral_data "$root\Electoral data"
gl Citylab_data "$root\City lab data"
 
*Create a Dta from a shape file
capture shp2dta using "$GIS/Shapefiles/tl_2018_us_cd116.shp", genid(_ID) data("$Data\Districts_data.dta") coor("$Data\Districts_coor.dta") replace

use "$Data\Districts_data", clear

*Import CSV with xy data
import excel "C:\Users\perez_g\Desktop\Politics Data\CrowdCounting\stata\output\geo_coded_LFL.xlsx", sheet("Sheet1") firstrow clear
// fix some missing
replace g_lat = 39.366608 if address == "SOUTH JERSEY, NJ, USA"
replace g_lon = -74.439445 if address == "SOUTH JERSEY, NJ, USA"
replace g_lat = 28.216795 if address == "LAND O’LAKES, FL, USA"
replace g_lon = -82.457840 if address == "LAND O’LAKES, FL, USA"

gen _X = g_lon
gen _Y = g_lat

save "$Data\LFL_info.dta", replace

* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\Districts_coor.dta"


* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\Districts_data.dta" 
keep if _m == 3
drop _m

save "$Data\LFL_mapped_to_dist.dta", replace
export excel using "$output\geo_coded_LFL.xlsx", sheet("With CD") firstrow(variables) sheetreplace

use "$Data\LFL_mapped_to_dist.dta",  clear

* Stores per district
gen counter = 1
collapse (sum) counter, by(_ID STATEFP)
* CD Map
spmap counter using "$Data\Districts_coor.dta" , id(_ID) fcolor(Reds) ///
clmethod(custom) clbreaks(0 1 2 3 4 5) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 
