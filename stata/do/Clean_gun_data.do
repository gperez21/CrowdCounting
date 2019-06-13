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
gl GIS "C:\Users\perez_g\Desktop\Politics Data\CrowdCounting\GIS"

*Create a Dta from a shape file
capture shp2dta using "$GIS/Shapefiles/tl_2018_us_cd116.shp", genid(_ID) data("$data\Districts_data.dta") coor("$data\Districts_coor.dta") replace

import excel "$raw\Gun Protests Geocoded.xlsx", sheet("Sheet1") firstrow clear
gen _X = Longitude
gen _Y = Latitude

* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\Districts_coor.dta"

* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\Districts_data.dta", keep(master match) 
keep if _m == 3
drop _m

save "$Data\Gun_protests_mapped_to_dist.dta", replace

use "$Data\Gun_protests_mapped_to_dist.dta",  clear

* Stores per district
gen counter = 1
collapse (sum) counter, by(_ID STATEFP)
drop if STATEFP == "15"
drop if STATEFP == "02"
* Make PA map
spmap counter using "$Data\Districts_coor.dta" , id(_ID) fcolor(Blues) ///
clmethod(custom) clbreaks(0 10 20 30 40 46) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 

graph save Graph "$GIS\Maps\Protests_per_CD.gph"
graph export "$GIS\Maps\Protests_per_CD.pdf", as(pdf) replace
