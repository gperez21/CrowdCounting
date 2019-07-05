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
keep _ID STATEFP indivisible_groups trump_margin district swing_2018

// fix mizzou districts
replace indivisible = 11 if district == "MO-01"
replace indivisible = 5 if district == "MO-02"
replace indivisible = 7 if district == "MO-03"
replace indivisible = 6 if district == "MO-04"
replace indivisible = 8 if district == "MO-05"
replace indivisible = 5 if district == "MO-06"
replace indivisible = 4 if district == "MO-07"
replace indivisible = 12 if district == "MO-08"

***********************************************
** plots
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
***********************************************
** median groups by decile

// generate trump margin deciles
xtile trump_decile = trump_margin , n(10)
// generate median groups by decile
egen median_groups = median(indivisible), by(trump_decile)
egen max_margin = max(trump_margin), by(trump_decile)
egen min_margin = min(trump_margin), by(trump_decile)
duplicates drop trump_decile median_groups max min, force

twoway scatter median_groups trump_decile, ///
msize(med) ///
mcolor(lavender%70) ///
mstyle(O) ///
msymbol(D) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
xtitle("Decile of Congressional Districts by Trump Vote Margin vs. Clinton") ///
ytitle("Median Number of Groups in District") ///
title("Median Number of Indivisible Groups in District by Trump Vote Margin Decile")
graph save Graph "$output\Median Groups by Trump Decile.gph", replace

// generate swing_2018 deciles
drop if missing(swing_2018)
xtile swing_decile = swing_2018, n(10)
// generate median groups by decile
egen median_groups = median(indivisible), by(swing_decile)
duplicates drop swing_decile median_groups, force

twoway scatter median_groups swing_decile, ///
msize(med) ///
mcolor(lavender%70) ///
mstyle(O) ///
msymbol(D) ///
graphregion(color(white)) ///
ylab(,nogrid) ///
xtitle("Decile of Congressional Districts by Margin Swing 2016-2018") ///
ytitle("Median Number of Groups in District") ///
title("Median Number of Indivisible Groups in District by Trump Vote Margin Decile")
graph save Graph "$output\Median Groups by Swing Decile.gph", replace


sort trump_margin
keep if _n>110
keep if _n <216
gen won = "D" if trump_margin<0
replace won = "R" if trump_margin>0
tab won
egen median_groups2 = median(indivisible), by(won)
