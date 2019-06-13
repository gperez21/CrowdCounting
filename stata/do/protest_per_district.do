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

// import DS store and collapse to CD ids
use "$data\DS_mapped_to_districts", clear
gen counter_DS = 1
collapse (sum) counter, by(_ID STATEFP)
// Merge the protests
merge 1:1 _ID using "$data\protests_by_district"
keep if _m == 3

label var counter_gun "Protests for Gun Control"
label var counter_FBT "Families Belong Together"

twoway (scatter counter_FBT counter_DS, ///
graphregion(color(white)) ///
ylab(,nogrid) ///
mcolor(lavender%70) ///
msize(tiny) ///
xtitle("Dollar Stores in District", color(black%71)) ///
xscale(lcolor(black%71)) ///
xlab(,labc(black%71) tlcolor(black%71)) ///
ytitle("Protests", color(black%71)) ///
ylab(,labc(black%71) tlcolor(black%71)) ///
yscale(lcolor(black%71)) ///
mlcolor(lavender%50) ///
mlabs(vsmall) ///
) ///
(scatter counter_gun counter_DS, ///
graphregion(color(white)) ///
ylab(,nogrid) ///
mcolor(orange%70) ///
msize(tiny) ///
xtitle("Dollar Stores in District", color(black%71)) ///
xscale(lcolor(black%71)) ///
xlab(,labc(black%71) tlcolor(black%71)) ///
ytitle("Protests", color(black%71)) ///
ylab(,labc(black%71) tlcolor(black%71)) ///
yscale(lcolor(black%71)) ///
mlcolor(orange%50) ///
mlabs(vsmall) ///
)

graph save Graph "$output\stores_protests_districts.gph", replace
graph export "$output\stores_protests_districts.pdf", as(pdf) replace
