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

**** Gun Protests ****
import excel "$raw\Gun Protests Geocoded.xlsx", sheet("Sheet1") firstrow clear
gen _X = Longitude
gen _Y = Latitude

* drop the gun rights protests
drop if pro_anti_flag == 2
* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\Districts_coor.dta"

* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\Districts_data.dta", keep(master match) 
keep if _m == 3
drop _m
gen protest = "Gun Control"
preserve
gen counter_gun_control = 1
collapse (sum) counter, by(_ID STATEFP)
tempfile gun_events
save `gun_events'
restore
save "$Data\Gun_protests_mapped_to_dist.dta", replace
keep if strpos(Date, "3/24/2018")
gen counter_mfol = 1
collapse (sum) counter, by(_ID STATEFP)
tempfile mfol
save `mfol'

**** Families Belong Tog ****
import excel "$raw\geo_coded_FBT_1.xlsx", sheet("Sheet1") firstrow clear
gen _X = g_lon
gen _Y = g_lat

* Spatial join using geoinpoly points to polygons
geoinpoly _Y _X using "$Data\Districts_coor.dta"

* merge the matched polygons with the database and get attributes
merge m:1 _ID using "$Data\Districts_data.dta", keep(master match) 
keep if _m == 3
drop _m
gen protest = "Families Belong Together"
preserve
gen counter_FBT = 1
collapse (sum) counter, by(_ID STATEFP)
tempfile FBT_events
save `FBT_events'
restore
save "$Data\FBT_mapped_to_dist.dta", replace

use "$Data\FBT_mapped_to_dist.dta",  clear

use `gun_events', clear
merge 1:1 _ID using `FBT_events'
drop _m
save "$data\protests_by_district", replace

merge 1:1 _ID using `mfol'
drop _m
save "$data\protests_by_district", replace

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


