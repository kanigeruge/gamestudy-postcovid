	global work "C:/path/to/this/repository"

	use "$work/data/data.dta", clear
	
	//
	global job student spouse self part unemployed
	global marital2 married2 havechild2 divorce2
	global jobind job4r_1 job4r_2 job4r_3 job4r_4 job4r_5 job4r_6 job4r_7 job4r_8 job4r_9 job4r_10 job4r_11 job4r_12 job4r_13
	global guess guess_baseline_1 guess_baseline_2 guess_baseline_3 guess_baseline_4 guess_baseline_5
	global round round_6 round_7 round_8
	global pref pref_*

	//2 Propensity Score Matching PSM
*****CAUTION******************************************************************
*The PSM algorithm for selecting variables is time consuming and requires a high-performance computer.
*When you use synthetic data, results are usually different including variable selections.
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
	
	
	**********************************		
	//Following Imbens (2015)
	**********************************	
	
	**********************************	
	*A. PSM Estimation R6-R8
	**********************************		
	
	//1. Preparation for trimming: selecting variables
	
		//To save your time, skip psestimate
		psestimate win, totry(age gender $marital2 $job $guess $jobind njoin_member round_*)
		
		//First
		/*
		Result: 
		Selected first order covariates are: njoin_member round_6 job4r_9 guess_baseline_5 job4r_5 guess_baseline_4 job4r_1 job4r_3 job4r_7 job4r_8 age student married2 havechild2 divorce2 part job4r_12 job4r_13 self

		Selected second order covariates are: c.njoin_member#c.njoin_member c.self#c.job4r_8 c.divorce2#c.job4r_3 c.married2#c.job4r_1 c.divorce2#c.job4r_8 c.married2#c.job4r_5 c.married2#c.round_6 c.job4r_7#c.round_6 c.job4r_5#c.round_6 c.havechild2#c.married2 c.married2#c.job4r_9 c.divorce2#c.job4r_1 c.job4r_13#c.part c.job4r_5#c.guess_baseline_5 c.guess_baseline_4#c.job4r_5 c.havechild2#c.job4r_7 c.havechild2#c.job4r_3 c.student#c.age c.job4r_12#c.part c.job4r_12#c.married2 c.job4r_12#c.havechild2
		*/		
		
		gen interaction1 = c.njoin_member#c.njoin_member
		gen interaction2 = c.self#c.job4r_8 
		gen interaction3 = c.divorce2#c.job4r_3 
		gen interaction4 = c.married2#c.job4r_1 
		gen interaction5 = c.divorce2#c.job4r_8 
		gen interaction6 = c.married2#c.job4r_5 
		gen interaction7 = c.married2#c.round_6 
		gen interaction8 = c.job4r_7#c.round_6 
		gen interaction9 = c.job4r_5#c.round_6 
		gen interaction10 = c.havechild2#c.married2 
		gen interaction11 = c.married2#c.job4r_9 
		gen interaction12 = c.divorce2#c.job4r_1 
		gen interaction13 = c.job4r_13#c.part 
		gen interaction14 = c.job4r_5#c.guess_baseline_5 
		gen interaction15 = c.guess_baseline_4#c.job4r_5 
		gen interaction16 = c.havechild2#c.job4r_7 
		gen interaction17 = c.havechild2#c.job4r_3 
		gen interaction18 = c.student#c.age 
		gen interaction19 = c.job4r_12#c.part 
		gen interaction20 = c.job4r_12#c.married2 
		gen interaction21 = c.job4r_12#c.havechild2		
		
		global first njoin_member round_6 job4r_9 guess_baseline_5 job4r_5 guess_baseline_4 job4r_1 job4r_3 job4r_7 job4r_8 age student married2 havechild2 divorce2 part job4r_12 job4r_13 self
		global imbens $first interaction*
		
		psmatch2 win $imbens, out(k6 happiness averageplaytime1 averageplaytime3) common noreplacement descending logit	//Hiro added averageplaytime1 2026 Mar 4, not meaningful though
		
	//2. Trimming
		drop if !inrange(_pscore,0.1,0.9) & !mi(_pscore)		

	//3. Running PSM to estimate causal effects: begin with selecting variables
	
		//To save your time, skip psestimate	
		psestimate win, totry(age gender $marital2 $job $guess $jobind njoin_member round_*)	

		//Second
		/*
		Result: 
		Selected first order covariates are: njoin_member round_6 job4r_9 guess_baseline_5 guess_baseline_4 job4r_1 job4r_5 job4r_3 job4r_7 job4r_8
		Selected second order covariates are: c.njoin_member#c.njoin_member c.job4r_7#c.round_6 c.job4r_5#c.guess_baseline_5 c.job4r_9#c.round_6	
		*/
		drop interaction*
		gen interaction1 = c.njoin_member#c.njoin_member 
		gen interaction2 = c.job4r_7#c.round_6 
		gen interaction3 = c.job4r_5#c.guess_baseline_5 
		gen interaction4 = c.job4r_9#c.round_6	

		
		global first njoin_member round_6 job4r_9 guess_baseline_5 guess_baseline_4 job4r_1 job4r_5 job4r_3 job4r_7 job4r_8		
				
		global imbens $first interaction*
		
	//4. Running PSM to estimate causal effects	
		local excel psmR6_R8
		
		//psmatch2 #1 *Basic specfication
		set seed 1
		psmatch2 win $imbens, out(k6 happiness averageplaytime1 averageplaytime3) ate ties logit ai(2) neighbor(2)
		
			scalar att_k6 = r(att_k6)
			scalar att_happiness = r(att_happiness)
			scalar att_averageplaytime1 = r(att_averageplaytime1)
			scalar att_averageplaytime3 = r(att_averageplaytime3)			
			scalar seatt_k6 = r(seatt_k6)
			scalar seatt_happiness = r(seatt_happiness)
			scalar seatt_averageplaytime1 = r(seatt_averageplaytime1)
			scalar seatt_averageplaytime3 = r(seatt_averageplaytime3)			
			
			scalar ate_k6 = r(ate_k6)
			scalar ate_happiness = r(ate_happiness)
			scalar ate_averageplaytime1 = r(ate_averageplaytime1)
			scalar ate_averageplaytime3 = r(ate_averageplaytime3)			
			scalar seate_k6 = r(seate_k6)
			scalar seate_happiness = r(seate_happiness)
			scalar seate_averageplaytime1 = r(seate_averageplaytime1)
			scalar seate_averageplaytime3 = r(seate_averageplaytime3)			
			
			sum k6 if e(sample) == 1
			scalar mean1 = r(mean)
			scalar sd1 = r(sd)
			sum happiness if e(sample) == 1
			scalar mean2 = r(mean)
			scalar sd2 = r(sd)
			sum averageplaytime1 if e(sample) == 1
			scalar mean3 = r(mean)
			scalar sd3 = r(sd)
			sum averageplaytime3 if e(sample) == 1
			scalar mean4 = r(mean)
			scalar sd4 = r(sd)			
			
			//matrix M = r(table)
			putexcel set "$work/figures/`excel'", replace
			putexcel A2 = "ATT"
			putexcel A3 = "SE"
			putexcel A4 = "Mean"
			putexcel A5 = "SD"
			putexcel A6 = "Standardized ATT"
			putexcel A7 = "Standardized SE"
			
			putexcel A8 = "ATE"
			putexcel A9 = "SE of ATE"
			putexcel A10 = "Standardized ATE"
			putexcel A11 = "Standardized SE"
			
			putexcel B1 = "k6"
			putexcel C1 = "happiness"
			putexcel D1 = "averageplaytime1"
			putexcel E1 = "averageplaytime3"			
			
			putexcel F1 = "Option of psmatch2"
			putexcel F2 = "ate ties logit ai(2) neighbor(2)"
			
			scalar stand_att1 = att_k6 / sd1
			scalar stand_att2 = att_happiness / sd2
			scalar stand_att3 = att_averageplaytime1 / sd3
			scalar stand_att4 = att_averageplaytime3 / sd4			
			scalar stand_seatt1 = seatt_k6 / sd1
			scalar stand_seatt2 = seatt_happiness / sd2
			scalar stand_seatt3 = seatt_averageplaytime1 / sd3
			scalar stand_seatt4 = seatt_averageplaytime3 / sd4			
			scalar stand_ate1 = ate_k6 / sd1
			scalar stand_ate2 = ate_happiness / sd2
			scalar stand_ate3 = ate_averageplaytime1 / sd3
			scalar stand_ate4 = ate_averageplaytime3 / sd4			
			scalar stand_seate1 = seate_k6 / sd1
			scalar stand_seate2 = seate_happiness / sd2			
			scalar stand_seate3 = seate_averageplaytime1 / sd3	
			scalar stand_seate4 = seate_averageplaytime3 / sd4				
			
			matrix result = (att_k6,att_happiness,att_averageplaytime1,att_averageplaytime3\seatt_k6,seatt_happiness,seatt_averageplaytime1,seatt_averageplaytime3\mean1,mean2,mean3,mean4\sd1,sd2,sd3,sd4\stand_att1,stand_att2,stand_att3,stand_att4\stand_seatt1,stand_seatt2,stand_seatt3,stand_seatt4\ate_k6,ate_happiness,ate_averageplaytime1,ate_averageplaytime3\seate_k6,seate_happiness,seate_averageplaytime1,seate_averageplaytime3\stand_ate1,stand_ate2,stand_ate3,stand_ate4\stand_seate1,stand_seate2,stand_seate3,stand_seate4)
			matrix list result
			putexcel B2 = matrix(result)
		
		psgraph, graphregion(color(white)) ytitle(Density)
		graph save "Graph" "$work\figures\overlap_`excel'_neighbor2.gph", replace
		graph export "$work\figures\overlap_`excel'_neighbor2.png", as(png) name("Graph") replace	width(2000)	
		pstest $imbens, graph both label ylabel(,labsize(vsmall)) graphregion(color(white))
		gr_edit .grpaxis.style.editstyle majorstyle(tickstyle(show_labels(yes))) editcopy 
		gr_edit .grpaxis.style.editstyle majorstyle(tickstyle(textstyle(size(vsmall)))) editcopy
		
		graph save "Graph" "$work\figures\balance_`excel'_neighbor2.gph", replace
		graph export "$work\figures\balance_`excel'_neighbor2.png", as(png) name("Graph") replace	width(2000)