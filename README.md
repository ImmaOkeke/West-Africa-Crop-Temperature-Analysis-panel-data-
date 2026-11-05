# Econometric Analysis of Crop-Specific Temperature Sensitivity in West Africa (2000–2024)

## Project Overview

This project examines how changes in temperature affect the yields of selected staple crops across five West African countries between 2000 and 2024.

The main objective is to investigate whether different crops respond differently to temperature changes. Rather than assuming that temperature anomalies have the same effect on all crops, this analysis looks at crop-specific responses.

The analysis uses panel data at the country-crop-year level and applies a High-Dimensional Fixed Effects (HDFE) regression approach in Stata. Country and year fixed effects are included to account for differences in agricultural productivity across countries and shocks that affect all observations over time.

## 1. Data and Variables

The dataset is structured as a balanced panel covering five countries, five crops, and 25 years (2000–2024).

The main variables used in the analysis are:

| Variable | Description |
|---|---|
| `ln_yield` | Natural logarithm of crop yield. This is the dependent variable. |
| `temp_change` | Annual temperature anomaly, measured as a continuous variable. |
| `crop_code` | Categorical variable identifying the five crops. |
| `country_code` | Identifier for the five countries included in the analysis. |
| `year` | Annual observations from 2000 to 2024. |
| `panel_id` | Unique identifier for each country-crop combination. |

**Crops included:**
- Cassava (reference category)
- Groundnut
- Maize
- Sorghum
- Yam

Cassava is used as the reference category in the regression model. This allows the temperature sensitivity of the other crops to be compared against cassava.

## 2. Methodology

The analysis initially considered a basic pooled regression approach. However, to account for unobserved differences across countries and common annual shocks, I proceeded with a fixed effects specification using Stata's `reghdfe` command.

The model includes country and year fixed effects.

The main specification is:

\[
\ln(Yield_{ict}) = \alpha + \beta_1 TempChange_{ct}
+ \sum_{k=2}^{5}\beta_k(TempChange_{ct}\times Crop_{ik})
+ \sum_{k=2}^{5}\theta_k Crop_{ik}
+ \gamma_c + \delta_t + \varepsilon_{ict}
\]

Where:

- **Country fixed effects (\(\gamma_c\))** control for time-invariant differences in agricultural productivity across countries.
- **Year fixed effects (\(\delta_t\))** account for common annual shocks that may affect agricultural production, including regional climate and economic shocks.
- **Temperature change** captures the relationship between annual temperature anomalies and crop yields.
- **Crop-temperature interactions** allow the temperature response to differ across crops.
- **Error term (\(\varepsilon_{ict}\))** captures other factors not explained by the model.

Standard errors are clustered at the country-crop panel level (`panel_id`) to account for potential correlation within each panel over time.

There are 25 country-crop panels in the dataset.

## 3. Stata Implementation

The analysis was conducted in Stata using the `reghdfe` package.

### Required packages

The following packages should be installed before running the analysis:

```stata
ssc install ftools
ssc install reghdfe
```

### Regression estimation

The main regression is specified as follows:

```stata
reghdfe ln_yield c.temp_change##i.crop_code, ///
    absorb(country_code year) ///
    vce(cluster panel_id)
```

The interaction specification allows the marginal effect of temperature change to vary across the five crops, while controlling for country and year fixed effects.

### Joint significance test

I used a post-estimation Wald test to examine whether the temperature interaction coefficients are jointly significant.

```stata
testparm c.temp_change#i.crop_code
```

This tests whether the temperature sensitivity of the other four crops differs significantly from the cassava reference category.

### Marginal effects

To obtain the temperature sensitivity for each crop, I calculated the average marginal effects:

```stata
margins crop_code, dydx(temp_change)
```

These estimates show the estimated change in log crop yield associated with a one-unit increase in the temperature anomaly for each crop.

### Visualisation

The marginal effects were plotted to make the differences in temperature sensitivity across crops easier to interpret.

```stata
marginsplot, recast(scatter) yline(0) ///
    title("Crop-Specific Marginal Effects of Temperature Anomalies") ///
    ytitle("Marginal Effect on Log Yield")

graph export "crop_temperature_effects.png", ///
    replace width(2000)
```

## 4. Main Findings

The results highlight the importance of accounting for country-level differences and common annual shocks when examining the relationship between temperature changes and crop yields.

Some of the key observations from the analysis are:

**1. The importance of year fixed effects**

Including year fixed effects changed the estimated temperature response for some crops. One example is yam, whose marginal effect shifted from negative to statistically insignificant after controlling for annual effects (p = 0.495).

This suggests that some of the initial relationship may have been influenced by common annual shocks rather than crop-specific temperature sensitivity alone.

**2. Joint significance of crop-specific temperature responses**

The joint significance test produced the following result:

- F-statistic: 1.66
- Degrees of freedom: F(4, 24)
- P-value: 0.1927

The result is not statistically significant at the conventional 5% level.

Therefore, I cannot reject the null hypothesis that the temperature interaction coefficients are jointly equal to zero. In other words, the analysis does not provide sufficient statistical evidence that the temperature sensitivity of the four other crops differs jointly from that of cassava.

This does not necessarily mean that all crops respond identically to temperature changes. Rather, the differences observed in this specification are not jointly statistically significant.

## 5. Repository Structure

The repository contains the following files:

```text
├── analysis_script.do
├── crop_temperature_effects.png
└── README.md
```

- **analysis_script.do:** Stata script containing the regression estimation, post-estimation tests, marginal effects and graph generation.
- **crop_temperature_effects.png:** Visualisation of the estimated crop-specific marginal effects.
- **README.md:** Documentation of the research question, data, methodology and main findings.

## 6. Tools Used

- Stata
- reghdfe
- ftools
- Panel data regression
- Fixed effects estimation
- Marginal effects analysis
- Data visualisation

## 7. Conclusion

This project provides an econometric assessment of how temperature anomalies relate to the yields of selected staple crops across five West African countries.

By incorporating country and year fixed effects, the analysis attempts to separate crop-specific temperature responses from persistent country differences and common annual shocks.

Although the results do not show statistically significant differences in temperature sensitivity across crops relative to cassava, the exercise highlights the importance of model specification and controlling for unobserved factors when conducting climate-related agricultural research.

The project also demonstrates the application of panel econometric techniques in analysing agricultural and climate-related data.
