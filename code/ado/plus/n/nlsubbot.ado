program nlsubbot
	syntax varlist (min=1 max=1) [if], at(name) [q(real .5) points(integer 10000)]
	tempname c t
	scalar `c' = `at'[1, 1]
	scalar `t' = `at'[1, 2]
	
	preserve
	drop _all
	tempvar theta y
	range `theta' 0 1 `points'
	gen double `y'=exp(-`c'*`theta'^`q')
	integ `y' `theta'
	tempname integr 
	scalar `integr'=r(integral)
	restore
	
	tempname alpha
	scalar `alpha'=(`q'*`c'^(1/`q'))/(2*exp(lngamma(1/`q')))
	replace `varlist' = `alpha' * `integr'+.75+(`t'-`t') 			in 1
	replace `varlist'=(`c'-`c')+(`t'-`t')							in 2
end
