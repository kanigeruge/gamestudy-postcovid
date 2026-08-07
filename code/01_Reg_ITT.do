	global work "C:/path/to/this/repository"

	use "$work/data/data.dta", clear
	
	//
	global job student spouse self part unemployed
	global marital2 married2 havechild2 divorce2
	global jobind job4r_1 job4r_2 job4r_3 job4r_4 job4r_5 job4r_6 job4r_7 job4r_8 job4r_9 job4r_10 job4r_11 job4r_12 job4r_13
	global guess guess_baseline_1 guess_baseline_2 guess_baseline_3 guess_baseline_4 guess_baseline_5
	global round round_6 round_7 round_8
	global pref pref_*
	
	
	//
	/*
	Notes on variable names.
	
	1. njoin_member is the number of times joining game console lotteries.
	
	2. guess_1 guess_2 guess_3 guess_4 guess_5 are the five dummies of gaming preferenecs.
	
	3. jobind: dummies of job industry variables.	
	
	4. win: dummy of winning a game console lottery.
	
	5. pref: dummies of prefecture of residence.
		round: dummies of survey rounds.
	
	6. happiness: SWLS
		k6: K6.
	
	7. lottery: dummy indicating joining game console lotteries.
	
	8. other variables.
		gender: male=1
		married2: married or not.
		havechild2: had child or not.
		divorce2: divorced or not.		
		
	9. game engagement variables
		have_ps5: PS5 Ownership
		play1m_ps5: PS5 Usage over the last 30 days.
		averageplaytime1: Time spent playing video games.
		
	10. round and round_*: survey rounds.	
	
	*/

****************************************************************	
****************************************************************	
****************************************************************	
*1. Figure1 : Causal effects on mental well-being from winning PS5 lotteries in Japan
	
****************************************************************	
****************************************************************	
****************************************************************

//1 Regression
			
					//preparation for outreg2
					local save "/figures/figure1_reg"					
					capture erase "$work/figures/figure1_reg.txt"				
			
foreach outcome of varlist k6 happiness{			
				
					reghdfe `outcome' win i.round njoin_member age gender $job $marital2 $jobind $guess if lottery == 1, absorb(pref) vce(cluster pref)
					
						local coef=round(el(r(table),1,1),.000001)
						local se=round(el(r(table),2,1),.000001)
						
						sum `outcome' if e(sample) == 1
						local mean = round(r(mean),.001)
						local sd = round(r(sd),.001)
						
						local temp1 = `coef' / `sd'
						local temp2 = `se' / `sd'
						local standcoef = round(`temp1',.0001)
						local standse = round(`temp2',.0001)
						local pvaltemp = (2 * ttail(e(df_r), abs(_b[win] / _se[win]) ) )
						local pval = round(`pvaltemp',.000001)
						local stars = cond(`pval'<0.01,"***",cond(`pval'<0.05,"**",cond(`pval'<0.1,"*","empty")))
						local low = `standcoef' - 2.01*`standse'
						local hi = `standcoef' + 2.01*`standse'	
					
						outreg2 using "$work`save'.xls", dec(3) fmt(gc) addtext(Mean, "`mean'", SD, "`sd'", Coef, "`coef'", SE, "`se'", Standardized Coef, "`standcoef'", Standardized SE, "`standse'", "P-value", "`pval'", Stars, `stars', Low, `low', Hi, `hi') keep(win) nocon label nonotes append
												
}