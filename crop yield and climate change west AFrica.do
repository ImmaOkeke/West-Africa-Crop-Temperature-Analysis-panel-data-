
* PROJECT: West Africa Climate Shock and Agricultural Yield Panel (2000-2024)
* COUNTRIES: Ghana, Nigeria, Senegal, Sierra Leone, Togo
* CROPS: Maize, Sorghum, Cassava, Yam, Groundnut
* AUTHOR: Immaculata Okeke
*===============================================================================
clear all
set more off
capture log close
cd "C:\Users\Immaculata Okeke\Downloads\stata"
import delimited "faostat_crops.csv.csv", clear
keep area item year value
rename area country
rename item crop
rename value yield_raw
replace country = strtrim(country)
replace crop = strtrim(crop)
replace crop = "Yam" if strpos(crop, "Yam") > 0
replace crop = "Maize" if strpos(crop,"Maize") > 0
replace crop = "Cassava" if strpos(crop, "Cassava") > 0
replace crop = "Sorghum" if strpos(crop, "Sorghum") > 0
replace crop = "Groundnut" if strpos(crop, "Groundnut") > 0
tempfile crops_clean
save `crops_clean', replace
display "Crop dataset successfully cleaned!"

import delimited "faostat_climate.csv.csv", clear
keep area year value
rename area country
rename value temp_change
replace country = strtrim(country)
tempfile climate_clean
save `climate_clean', replace
display "climate dataset successfully cleaned!"
use `crops_clean', clear
merge m:1 country year using `climate_clean'
tabulate _merge
keep if _merge ==3
drop _merge
duplicates drop country crop year, force
egen panel_id = group(country crop)
label variable panel_id "Uniques country-crop pair ID"
gen ln_yield = log(yield_raw)
label variable ln_yield "Log of crop yield"
label variable temp_change "Annual Temp change anomaly (°C)"
sort panel_id year
save "west_africa_climate_yield_panel.dta", replace
display "Final panel dataset merged and saved successfully"
xtset panel_id year
xtreg ln_yield temp_change,re
xttest0
xtreg ln_yield temp_change, fe
estimates store fixed
xtreg ln_yield temp_change, re
estimates store random
hausman fixed random
encode crop, generate(crop_code)
xtreg ln_yield c.temp_change##i.crop_code, re vce(cluster panel_id)
margins crop_code, dydx(temp_change)
encode country, generate(country_code)
xtreg ln_yield c.temp_change##i.country_code##i.crop_code, re vce(cluster panel_id)
margins country_code#crop_code, dydx(temp_change)
ssc install ftools, replace
ssc install reghdfe, replace
ssc install require, replace
reghdfe ln_yield c.temp_change##i.crop_code, absorb(country_code year) vce(cluster panel_id)
margins crop_code, dydx(temp_change)
marginsplot, recast(scatter) yline(0) title("Crop-specific Marginal Effects of Temperature Anomalies") ytitle("Marginal Effect on Crop Yield")