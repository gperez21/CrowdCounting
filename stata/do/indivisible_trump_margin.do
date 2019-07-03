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

use "$data\indivisble_events_CD.dta", clear

merge 1:1 _ID using "$data\Congressional_district_master"
keep _ID STATEFP indivisible_groups trump_margin district

// fix mizzou districts
replace indivisible = 11 if district == "MO-01"
replace indivisible = 5 if district == "MO-02"
replace indivisible = 7 if district == "MO-03"
replace indivisible = 6 if district == "MO-04"
replace indivisible = 8 if district == "MO-05"
replace indivisible = 5 if district == "MO-06"
replace indivisible = 4 if district == "MO-07"
replace indivisible = 12 if district == "MO-08"


twoway (scatter indivisible trump_margin, ///
msize(vsmall) ///
mcolor(lavender%50) ///
mstyle(o) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
ytitle("Indivisible Groups") ///
xtitle("Trump Margin over Clinton, 2016")) ///
(lfit indivisible trump_margin)

twoway (scatter swing_2018 indivisible, ///
msize(vsmall) ///
mcolor(lavender%50) ///
mstyle(o) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
xtitle("Indivisible Groups") ///
ytitle("Margin Swing (pts)") ///
title("Margin Swing 2016-2018 Congressional Election")) ///
(lfit swing_2018 indivisible)
