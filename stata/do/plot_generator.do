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

// make plot 
use "$data\DS_mapped_to_districts", clear
keep _X _Y _ID STATEFP CD116FP GEOID NAMELSAD LSAD CDSESSN MTFCC FUNCSTAT ALAND AWATER INTPTLAT INTPTLON
gen Stores = 1
collapse (sum) Stores, by(_ID STATEFP CD116FP GEOID NAMELSAD)
// Missouri 29 Pennsylvania 42
keep if STATEFP == "29" | STATEFP == "42"
local space = 5
local pa = `space'*2
local mo = `space'
sort STATE Store
gen     x_graph = `mo' if STATE == "29"
replace x_graph = `pa' if STATE == "42"
replace x = x - .08*`space' if Store[_n+1] == Store[_n] & STATE[_n+1] == STATE[_n] 
replace x = x + .08*`space' if Store[_n-1] == Store[_n] & STATE[_n-1] == STATE[_n] 
gen pos = 3 
replace pos = 9 if (Store[_n+1] - Store[_n]) < 5 & pos[_n-1] == pos[_n] 

gen     state_label = "PA-" + substr(NAME,-2,.) if STATE == "42"
replace state_label = "MO-" + substr(NAME,-2,.) if STATE == "29"
replace state_label = subinstr(state_label, " ","",.)

// Column graphs of two states on same plot

local bottom = `mo'-3
local top = `pa' + 3
twoway scatter Stores x_graph, ///
ylab(, nogrid) ///
xtitle("") ///
xlab( `mo' "Missouri" `pa' "Pennsylvania", labc(black%71) notick) ///
xscale(range(`bottom' `top')) ///
xscale(lcolor(black%71)) ///
ytitle("Dollar Stores in District", color(black%71)) ///
ylab(,labc(black%71) tlcolor(black%71)) ///
yscale(lcolor(black%71)) ///
msize(small) ///
mcolor(lavender%50) ///
mlcolor(lavender%90) ///
mlabel(state_label) ///
mlabs(tiny) ///
mlabv(pos) ///
graphregion(color(white))



////////////////////////////////////////////////////////////////////////////////
* christmas tree plot of tranches and swings
replace swing_2018 = swing_2018*100

egen box = cut(swing_2018), at(-20(1)40)
gen x = 0
gen y = box

sort bin box 
egen rank = rank(_n), by(bin box )
egen box_num = max(rank), by(bin box )
egen group1 = group(bin)
replace x = (rank-(box_num/2))+15*group1

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( -10 "-10" 0 "0" 10 "10" 20 "20" 30 "30") /// 
ytitle("Swing R to D, 2016-2018 (pts)", size(small) margin(small)) ///
yline(0, lcolor(black%30)) /// 
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

////////////////////////////////////////////////////////////////////////////////
* christmas tree plot of tranches and swings
use "$Data\dollar_master_clean", clear

replace swing_2018 = swing_2018*100
egen median_2018 = median(swing_2018), by(bin)

graph dot median_2018, ///
over(bin) ///
vertical 

 
twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( -10 "-10" 0 "0" 10 "10" 20 "20" 30 "30") /// 
ytitle("Swing R to D, 2016-2018 (pts)", size(small) margin(small)) ///
yline(0, lcolor(black%30)) /// 
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))



///////////////////////////////////////////////////////////////////////////////
* arrow graph of sparse suburban
use "$Data\dollar_master_clean", clear

keep if cluster == "Rural-suburban mix"
gen x1 = diff_2016
gen x2 = diff_2018
gen y1 = Number

twoway (pcarrow y1 x1 y1 x2 if map2016 == 2, ///
msize(tiny) mcolor(cranberry%50) lcolor(cranberry%50) ///
ylab(,nogrid) ///
graphregion(color(white))) ///
(pcarrow y1 x1 y1 x2 if map2016 == 1, ///
msize(tiny) mcolor(midblue%50) lcolor(midblue%50) ///
)

///////////////////////////////////////////////////////////////////////////////
* map of bins
spmap group1 using "$Data\Districts_coor.dta", id(_ID) fcolor(Reds) ///
clmethod(custom) clbreaks(0 1.1 2.1 3.1 4.1 5.1 6.1) ///
legend(symy(*2) symx(*2) size(*2) position (4)) 


///////////////////////////////////////////////////////////////////////////////
* income index dot plot
use "$Data\dollar_master_clean", clear

// drop if district == "AK-AL" | district == "HI-02"  | district == "HI-01" 

egen box = cut(IncomeIndex), at(0(.25)10)
gen x = 0
gen y = box

sort bin box 
egen rank = rank(_n), by(bin box )
egen box_num = max(rank), by(bin box )
egen group1 = group(bin)
replace x = (rank-(box_num/2))+15*group1

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ytitle("SSRC Income Index", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

///////////////////////////////////////////////////////////////////////////////
* income index dot plot
use "$Data\dollar_master_clean", clear

egen box = cut(EducationIndex), at(0(.25)10)
gen x = 0
gen y = box

sort bin box 
egen rank = rank(_n), by(bin box )
egen box_num = max(rank), by(bin box )
egen group1 = group(bin)
replace x = (rank-(box_num/2))+15*group1

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( 10 "Max" ) /// 
ytitle("SSRC Education Index", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

///////////////////////////////////////////////////////////////////////////////
* income index dot plot
use "$Data\dollar_master_clean", clear

gen x = 0
gen y = 0

egen box = group(cluster)
egen group1 = group(bin)

twoway scatter box group1 , jitter(10) msize(vsmall)


// set up x
sort bin box 
egen rank = rank(_n), by(bin box)
egen box_num = max(rank), by(bin box)
replace x = (rank-(box_num/2))+15*group1

sort box group1

//set up y
// sort cluster group1 
// egen rank2 = rank(_n), by(cluster group1)
// egen box_num2 = max(rank), by(cluster group1 )
// replace y = (rank2-(box_num2/2))+15*box
replace y = box*15

twoway ///
(scatter y x if map2016 == 1, ///
msize(small) msymbol(o) ylab(,nogrid) leg(off) ///
mcolor(midblue%50) ///
xlabel(15 "0-15" 30 "15-30" 45 "30-45" 60 "45-60" 75 "60-75" 90 "75+", tlength(0)) ///
xtitle(Number of Stores in District, size(small) margin(small)) ///
ylabel( 10 "Max" ) /// 
ytitle("", size(msmall) margin(small)) ///
graphregion(color(white)) ///
) ///
(scatter y x if map2016 == 2, ///
msize(small) msymbol(o) mcolor(cranberry%50) ylab(,nogrid) leg(off))

