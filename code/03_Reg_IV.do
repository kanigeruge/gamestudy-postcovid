* Set Stata's working directory to the repository root before running:
    cd "C:/path/to/this/repository"
	global work "`c(pwd)'"

	use "$work/data/data.dta", clear
	
	//
	global job student spouse self part unemployed
	global marital2 married2 havechild2 divorce2
	global jobind job4r_1 job4r_2 job4r_3 job4r_4 job4r_5 job4r_6 job4r_7 job4r_8 job4r_9 job4r_10 job4r_11 job4r_12 job4r_13
	global guess guess_baseline_1 guess_baseline_2 guess_baseline_3 guess_baseline_4 guess_baseline_5
	global round round_6 round_7 round_8
	global pref pref_*

****************************************************************	
****************************************************************	
****************************************************************	
*2. Figure: Causal effects of video game engagement on mental well-being in post-COVID Japan
	
****************************************************************	
****************************************************************	
****************************************************************	

//3 Instrumental Variable IV

	//preparation for outreg2
	local save "/figures/postcovid3iv"	
	capture erase "$work/figures/postcovid3iv.txt"	

	//a
		foreach outcome of varlist k6 happiness {		
		foreach endogenous of varlist have_ps5 play1m_ps5 averageplaytime1 {
	
			ivreghdfe `outcome' (`endogenous' = win) njoin_member age gender $job $marital2 $guess if lottery == 1, absorb(pref round job4r) cluster(pref) first
				local coef=round(el(e(b),1,1),.000001)
				local t1=el(e(V),1,1)
				local t2=`t1'^(1/2)
				local se=round(`t2',.000001)
				display `se'
				sum `outcome' if e(sample) == 1
				local mean = round(r(mean),.001)
				local sd = round(r(sd),.001)						
				local temp1 = `coef' / `sd'
				local temp2 = `se' / `sd'
				local standcoef = round(`temp1',.0001)
				local standse = round(`temp2',.0001)
							local pvaltemp = (2 * ttail(e(df_r), abs(_b[`endogenous'] / _se[`endogenous']) ) )
							local pval = round(`pvaltemp',.000001)
							local stars = cond(`pval'<0.01,"***",cond(`pval'<0.05,"**",cond(`pval'<0.1,"*","empty")))
							local low = `standcoef' - 2.01*`standse'
							local hi = `standcoef' + 2.01*`standse'	
					outreg2 using "$work`save'.xls", dec(3) fmt(gc) addtext(Controls, Yes, Prefecture FE, Yes, Mean, "`mean'", SD, "`sd'", Coef, "`coef'", SE, "`se'", Standardized Coef, "`standcoef'", Standardized SE, "`standse'", "P-value", "`pval'", Stars, `stars', Low, `low', Hi, `hi') adds("Kleibergen-Paap rk Wald F statistic", e(widstat)) keep(`endogenous') nor2 nocon label nonotes append			
		}
		}


		

		
