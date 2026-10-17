* Weighted Average Least Squares
*! Version 1.0
* Date: 06/05/2011
* Authors: De Luca Giuseppe, Jan Magnus

*-------------------------------------------------------------------------------------------------
* wals
*-------------------------------------------------------------------------------------------------
program define wals, eclass 
	syntax [anything] [if] [in], [*]
	if !replay() {
		local cmdline : copy local 0
	}

	version 11.1, missing
	if replay() {
		if "`e(cmd)'" != "wals" {
			error 301
		}
		Di_wals `0' 
		exit
	}
	version 11.1: Estimate `0'
	version 11.1: ereturn local cmdline `"wals `0'"'
end
*-------------------------------------------------------------------------------------------------



*-------------------------------------------------------------------------------------------------
* Estimate
*-------------------------------------------------------------------------------------------------
program define Estimate, eclass
qui {
	version 11.1

* Identify dependent variable 
	gettoken depvar 0 : 0 , parse(" =,[")
	gettoken equals rest : 0 , parse(" =")
	if "`equals'" == "=" local 0 `"`rest'"'
	local depvarn : subinstr local depvar "." "_"
	
* Syntax
	syntax [varlist(default=none)] [if] [in] , 					///
		AUXiliary(varlist numeric min=1) 						///
		[q(real 1) INTPoints(integer 10000) eps(real 1e-8) 		///
		iterate(integer 16000) noCONstant]

* Options
	local nc `constant'
	if "`auxiliary'"!=	""  local aux "`auxiliary'"

* Estimation sample 
	marksample touse
	markout `touse' `depvar' `varlist' `aux' 

* Check estimation sample 
	count if `touse' 
	if r(N)==0 error 2000 
	else local N=r(N)	
	tempname Nl
	matrix `Nl'=(`N')

* Constant term (if any)
	if "`nc'"~="noconstant" {
		tempvar const
		gen byte `const'=1
	}
	
* Check for collinearity
	_rmcollright (`const') (`varlist') (`aux') if `touse', noconstant 
	local dropped `r(dropped)'
	local rb2 `r(block2)'
	local rb3 `r(block3)'
	if "`dropped'"!="" {
		noi di in gr "note: `dropped' omitted because of collinearity" 
		local varlist_rc ""
		local x=1
		foreach xx of local varlist {
			local yy: word `x' of `rb2' 
			if "`yy'"!="o.`xx'" local varlist_rc `varlist_rc' `xx'
			local x=`x'+1
		}
		local auxlist_rc ""
		local x=1
		foreach xx of local aux {
			local yy: word `x' of `rb3' 
			if "`yy'"!="o.`xx'" local auxlist_rc `auxlist_rc' `xx'
			local x=`x'+1
		}
	}
	else {
		local varlist_rc `varlist'
		local auxlist_rc `aux'
	}
	
* Number of focus and auxiliary regressors
	tempname Kl
	local k1: word count `varlist_rc' 
	if "`nc'"~="noconstant" local k1=`k1'+1
	local k2: word count `auxlist_rc' 
	matrix `Kl'=(`k1',`k2')

* Check condition on number of obs 
	if `N'<`k1'+`k2' {
		noi di as err "Number of obs must be greater than (k1+k2)"
		error 2000
	}
	
* Load Gauss-Laguerre abcissas and weights
	tempname GLPointsl
	GaussLaguerre
	matrix `GLPointsl'=r(Points)
	
* Parameters of the Laplace or Subbotin density 
	tempname subpar
	if `q'>1 |`q'<=0 {
		noi di _n as err "q must be a real in the interval (0,1]" 
		error 198
	}
	if `q'==.5|`q'==1 {
		tempname c
		if `q' == 0.5 scalar `c' = 1.67834699001666
		if `q' == 1.0 scalar `c' = log(2)
	}
	else {
		* Preserve data 
			preserve 

		* Define dependent variable for nl estimation
			drop _all
			set obs 2
			generate 	y=1		in 1
			replace 	y=0 	in 2
		
		* Starting value 
			tempname c_s
			if `q'> 0 & `q' <= .1 	scalar `c_s' = 9.66871461471413
			if `q'>.1 & `q' <= .2 	scalar `c_s' = 4.67090888279598
			if `q'>.2 & `q' <= 0.3 	scalar `c_s' = 3.00658197401172
			if `q'>.3 & `q' <= 0.4 	scalar `c_s' = 2.17573009527741
			if `q'>.4 & `q' <= 0.5 	scalar `c_s' = 1.67834699001666
			if `q'>.5 & `q' <= 0.6 	scalar `c_s' = 1.34775791172323
			if `q'>.6 & `q' <= 0.7 	scalar `c_s' = 1.11252498116257
			if `q'>.7 & `q' <= 0.8 	scalar `c_s' = 0.93692388388995
			if `q'>.8 & `q' <= 0.9 	scalar `c_s' = 0.80110299776595
			if `q'> .9 				scalar `c_s' = log(2)
			nl subbot @ y, parameters(c t) initial(c `c_s' t 1) q(`q') points(`intpoints') eps(`eps')
			tempname c
			scalar `c'= _b[/c]

		* Restore data 
			restore 	
			if `c'==. {
				noi di as err _n "Parameter c of the subbotin density is invalid"
				error 198
			}
	}
	matrix `subpar'=(`q',`c')
	
* Estimation
	noi mata: walsmata("`touse'","`depvar'","`varlist_rc' `const'","`auxlist_rc'"	/*
		*/ ,"`Nl'","`Kl'","`GLPointsl'","`subpar'") 

		
* Check eighenvalues of Z=(X2'*M1*X2) 
	tempname Eigencheck Eigenfun CondNum
	matrix `Eigencheck'=r(eigencheck)
	matrix `Eigenfun'  =r(eigenfun)
	if `Eigencheck'[1,1]==1 {
		noi di as err "Eigenvalues of the positive definite matrix (X2'*M1*X2) are not positive"
		error 411
	}
	if `Eigenfun'[1,1]==1 local eigenfun "symeigensystem"
	if `Eigenfun'[1,1]==2 local eigenfun "eigensystem"
	matrix `CondNum'=r(condnum)
	
* Combine estimation results 
	tempname b_aux V_aux  
	matrix `b_aux' 	= r(b_aux)
	matrix `V_aux' 	= r(V_aux)
	matrix coln `b_aux' = `auxlist_rc' 
	matrix coln `V_aux' = `auxlist_rc' 
	matrix rown `V_aux' = `auxlist_rc' 
	if `k1'>0 {
		tempname b_foc V_foc C_foc_aux
		matrix `b_foc' 		= r(b_foc)
		matrix `V_foc' 		= r(V_foc)
		matrix `C_foc_aux' 	= r(C_focaux)
		if "`nc'"~="noconstant" local k1s=`k1'-1
		else 					local k1s=`k1'
	}
	else local k1s=0
	if "`nc'"~="noconstant" {
		tempname b_cc V_cc C_aux_cc   
		matrix `b_cc'=`b_foc'[1,`k1']
		matrix coln `b_cc' = _cons 

		matrix `V_cc'=`V_foc'[`k1',`k1']
		matrix coln `V_cc' = _cons
		matrix rown `V_cc' = _cons

		matrix `C_aux_cc'=`C_foc_aux'[`k1'..`k1',1..`k2']
		matrix coln `C_aux_cc' = `auxlist_rc' 
		matrix rown `C_aux_cc' = _cons 
		
		if `k1s'>0 {
			tempname C_foc_cc
			matrix `C_foc_cc'=`V_foc'[`k1'..`k1',1..`k1s']
			matrix coln `C_foc_cc' = `varlist_rc' 
			matrix rown `C_foc_cc' = _cons 
			matrix `b_foc'=`b_foc'[1,1..`k1s']
			matrix `V_foc'=`V_foc'[1..`k1s',1..`k1s']
			matrix `C_foc_aux'=`C_foc_aux'[1..`k1s',1..`k2']
		}
	}
	if `k1s'>0 {
		matrix coln `b_foc' = `varlist_rc' 
		matrix coln `V_foc' = `varlist_rc' 
		matrix rown `V_foc' = `varlist_rc' 
		matrix coln `C_foc_aux' = `auxlist_rc' 
		matrix rown `C_foc_aux' = `varlist_rc' 
	}
	if "`nc'"~="noconstant" {
		tempname b V
		if `k1s'==0 {
			matrix `b'=(`b_cc',`b_aux')
			matrix `V'=`V_cc' , `C_aux_cc' \ `C_aux_cc'' , `V_aux'
		}
		else {
			matrix `b'=(`b_cc',`b_foc',`b_aux')
			matrix `V'		= `V_cc'       , `C_foc_cc' , `C_aux_cc'  	/*
						*/ 	\ `C_foc_cc''  , `V_foc'    , `C_foc_aux' 	/*
						*/  \ `C_aux_cc'' , `C_foc_aux'' , `V_aux'
		}
	}
	else {
		tempname b V
		if `k1s'==0 {
			matrix `b'=`b_aux'
			matrix `V'=`V_aux'
		}
		else {
			matrix `b'=(`b_foc',`b_aux')
			matrix `V'=`V_foc', `C_foc_aux' \ `C_foc_aux'' , `V_aux'
		}
	}
	if "`nc'"~="noconstant" local df_m=colsof(`b')-1
	else 					local df_m=colsof(`b')
	local df_r=`N'-colsof(`b')
	
* Estimate Return
	ereturn post `b' `V', dep(`depvar') obs(`N') esample(`touse')		
	ereturn scalar k1 		=`k1'
	ereturn scalar k2 		=`k2'
	ereturn scalar df_m 	=`df_m'
	ereturn scalar df_r 	=`df_r'
	ereturn scalar q 		=`q'
	ereturn scalar c 		=`c'
	ereturn scalar kappa	=`CondNum'[1,1]

	ereturn local eigenf 	"`eigenfun'"
	if e(q)==1 				ereturn local prior "Laplace prior"
	else 					ereturn local prior "Subbotin prior" 
	ereturn local auxiliary "`auxlist_rc'"
	if "`nc'"~="noconstant" ereturn local focus 	"_cons `varlist_rc'"
	else 					ereturn local focus 	"`varlist_rc'"
	ereturn local title "WALS estimates - `e(prior)'"
	ereturn local cmd "wals"
	
* Estimate Display
	noi Di_wals, nc(`nc')  
	
}
end



*-------------------------------------------------------------------------------------------------
* walsmata
*-------------------------------------------------------------------------------------------------
version 11.1
mata:
mata clear
void walsmata(touse,depvar,varlist,aux,Nl,Kl,GLPointsl,subpar)
{
// Declarations
	real colvector 	y, K, subc, D, res_y_Xs, res_y_X1, b2s_hat, eta_hat, 		/*
		*/			signx, x, g0, g1, g2, psi0, psi1, psi2, hratio, mu_tmp, 	/*
		*/			sigma_sqr_tmp, lambda, mu, sigma_sqr, b2, b1 
	real matrix 	X1, X2, GLP, V1r, res_X2_X1, Z, P, X2s, Xs, V, G, varb2,	/*
		*/			Q, varb1, covb1b2
	real scalar 	n, k1, k2, k, q, c, s_sqr, s, phi, condnum  

// Loading data from stata into mata
	y  = st_data(., (st_varindex(tokens(depvar))), touse)
	X1 = st_data(., (st_varindex(tokens(varlist))), touse)
	X2 = st_data(., (st_varindex(tokens(aux))), touse)
	n = st_matrix(Nl)
	K = st_matrix(Kl)
	GLP = st_matrix(GLPointsl)
	subc = st_matrix(subpar)

// Define number of observations and regressors 
	k1=K[1]
	k2=K[2]
	k=k1+k2

// Define parameters of the subbotin density 
	q=subc[1]
	c=subc[2]
	
// Transformation (set-up and diagonalize)
	if (k1 > 0) {
		// Scaling X1
			D_X1=diag(X1'*X1)
			XB1=J(n,k1,0)
			for (j=1; j<=k1; j++) {
				XB1[.,j]=1/sqrt(D_X1[j,j]) * X1[.,j]
			}

		// Compute Z
			V1r = invsym(XB1'*XB1)
			res_X2_XB1 = X2 - (XB1*V1r)*(XB1'*X2)	
			Z = res_X2_XB1' * res_X2_XB1	
	}
	else {
		// Compute Z
			Z=X2'*X2
	}

// Scaling X2
	D_X2=diag(Z)
	XB2=J(n,k2,0)
	for (j=1; j<=k2; j++) {
		XB2[.,j]=1/sqrt(D_X2[j,j]) * X2[.,j]
		
	}

// Compute ZB
	res_XB2_XB1 = XB2 - (XB1*V1r)*(XB1'*XB2)	
	ZB = res_XB2_XB1' * res_XB2_XB1		
	condnum=sqrt(cond(ZB))
	st_matrix("r(condnum)", condnum)	
	
// Orthogonal transformation 
	// Default function for eigenvalues and eigenvectors 
		P=.
		D=.
		symeigensystem(ZB, P, D) 
		//ZB
		//diag(D)

	// Check that eighenvalues are positive  
		col_D=cols(D)
		tol=epsilon(1)
		rank=colsum((D:>tol)')
		if (rank!=col_D) {
			// Alternative function for eigenvalues and eigenvectors 
				P=.
				D=.
				eigensystem(ZB, P, D)
				D=Re(D)
				P=Re(P)
				
			// Check that eighenvalues are positive  
				col_D=cols(D)
				rank=colsum((D:>tol)')		
				if (rank!=col_D) {
					st_matrix("r(eigencheck)", 1)	
					exit(0)
				}
				else {
					st_matrix("r(eigencheck)", 0)	
					st_matrix("r(eigenfun)", 2)	
				}
		}
		else {
			st_matrix("r(eigencheck)", 0)	
			st_matrix("r(eigenfun)", 1)	
		}
		
// OLS estimates of the unrestricted model
	XB2s=XB2 * P * matpowersym(diag(D),-.5)
	XBs = XB1 , XB2s
	VBs = invsym(XBs'*XBs)
	res_y_XBs = y - (XBs*VBs)*(XBs'*y)
	s_sqr = res_y_XBs' * res_y_XBs / (n-k)
	s = s_sqr^.5
	res_y_XB1 = y - (XB1*V1r)*(XB1'*y)	
	B2s_hat=XB2s'*res_y_XB1
	Eta_hat=B2s_hat / s

// Moments of the Laplace or Subbotin density
	if (q==1) {
		signx=sign(Eta_hat)
		x=abs(Eta_hat)
		g0 = normal(-x:-c)
		g1 = normal(x:-c)
		g2 = normalden(x:-c)
		psi0 = g0 :/ g1
		psi1 = g2 :/ g1
		psi2 = exp(2*c:*x) :* psi0
		hratio = (1 :- psi2) :/ (1 :+ psi2)
		mu_tmp = signx :* (x - c * hratio)
		sigma_sqr_tmp = 1 :+ c^2* (1 :- hratio:^ 2) - (c * psi1) :* (1 :+ hratio) 
	}
	else {
		mu_tmp=J(k2,1,0)
		sigma_sqr_tmp=J(k2,1,0)
		for (i=1; i<=k2; i++) {
			phi=Eta_hat[i]
			G=J(100,3,0)
			G[.,1]=(				 		normalden(phi:-GLP[.,1])+						normalden(phi:+GLP[.,1])):*exp(-c:*(GLP[.,1]:^q)):*exp(GLP[.,1])
			G[.,2]=((phi:-GLP[.,1]) 	:* 	normalden(phi:-GLP[.,1])+ (phi:+GLP[.,1])	 :* normalden(phi:+GLP[.,1])):*exp(-c:*(GLP[.,1]:^q)):*exp(GLP[.,1])
			G[.,3]=((phi:-GLP[.,1]):^2  :* 	normalden(phi:-GLP[.,1])+ (phi:+GLP[.,1]):^2 :* normalden(phi:+GLP[.,1])):*exp(-c:*(GLP[.,1]:^q)):*exp(GLP[.,1])
			G=quadcolsum(G:*GLP[.,2])
			psi1=G[2]/G[1]
			psi2=G[3]/G[1]
			mu_tmp[i,1]=phi-psi1
			sigma_sqr_tmp[i,1]=psi2-psi1^2
		}
	}
	
// Normalize moments
	lambda=D'
	mu = mu_tmp :/ (lambda:^.5)
	sigma_sqr= sigma_sqr_tmp :/ lambda

// Estimated coefficients and thier variances 
	b2 = matpowersym(D_X2,-.5) * s * P * mu
	varb2 = s^2 * matpowersym(D_X2,-.5) * (P * diag(sigma_sqr) * P') *  matpowersym(D_X2,-.5)
	if (k1 > 0) {
		b1 = matpowersym(D_X1,-.5) * V1r * XB1' * (y - X2*b2)
		Q = matpowersym(D_X1,-.5) * V1r * XB1' * X2
		varb1 = s^2 * matpowersym(D_X1,-.5) * V1r * matpowersym(D_X1,-.5) + Q * varb2 * Q' 
		covb1b2 = - Q * varb2
	}

// Return estimates auxiliary 
	st_matrix("r(b_aux)", b2')	
	st_matrix("r(V_aux)", varb2)	
	if (k1 > 0) {
		st_matrix("r(b_foc)", b1')	
		st_matrix("r(V_foc)", varb1)	
		st_matrix("r(C_focaux)", covb1b2)	
	}

}
end
*-------------------------------------------------------------------------------------------------



*-------------------------------------------------------------------------------------------------
program GaussLaguerre, rclass
// Source: http://keisan.casio.com/has10/SpecExec.cgi
	preserve 
	clear
	set obs 100

	gen double x=.
	gen double w=.
	replace x=.01438615          in 1
	replace w=.03639261          in 1
	replace x=.07580361          in 2
	replace w=.07967675          in 2
	replace x=.1863141           in 3
	replace w=.1121151           in 3
	replace x=.34596918          in 4
	replace w=.13035661          in 4
	replace x=.55481094          in 5
	replace w=.13404334          in 5
	replace x=.81289128          in 6
	replace w=.12540709          in 6
	replace x=1.1202738          in 7
	replace w=.10831411          in 7
	replace x=1.4770343          in 8
	replace w=.08709664          in 8
	replace x=1.8832608          in 9
	replace w=.06555101          in 9
	replace x=2.3390538          in 10
	replace w=.04634013          in 10
	replace x=2.8445265          in 11
	replace w=.03084631          in 11
	replace x=3.3998048          in 12
	replace w=.01936783          in 12
	replace x=4.0050276          in 13
	replace w=.01148544          in 13
	replace x=4.6603468          in 14
	replace w=.00643895          in 14
	replace x=5.365928           in 15
	replace w=.00341498          in 15
	replace x=6.12195            in 16
	replace w=.00171432          in 16
	replace x=6.9286058          in 17
	replace w=.00081487          in 17
	replace x=7.7861024          in 18
	replace w=.00036685          in 18
	replace x=8.6946611          in 19
	replace w=.00015645          in 19
	replace x=9.6545182          in 20
	replace w=.00006321          in 20
	replace x=10.665925          in 21
	replace w=.0000242           in 21
	replace x=11.729148          in 22
	replace w=8.774e-06          in 22
	replace x=12.844471          in 23
	replace w=3.014e-06          in 23
	replace x=14.012192          in 24
	replace w=9.808e-07          in 24
	replace x=15.232628          in 25
	replace w=3.023e-07          in 25
	replace x=16.50611           in 26
	replace w=8.820e-08          in 26
	replace x=17.832992          in 27
	replace w=2.436e-08          in 27
	replace x=19.213642          in 28
	replace w=6.370e-09          in 28
	replace x=20.648448          in 29
	replace w=1.576e-09          in 29
	replace x=22.137819          in 30
	replace w=3.686e-10          in 30
	replace x=23.682185          in 31
	replace w=8.155e-11          in 31
	replace x=25.281994          in 32
	replace w=1.705e-11          in 32
	replace x=26.937719          in 33
	replace w=3.368e-12          in 33
	replace x=28.649854          in 34
	replace w=6.284e-13          in 34
	replace x=30.418919          in 35
	replace w=1.106e-13          in 35
	replace x=32.245456          in 36
	replace w=1.838e-14          in 36
	replace x=34.130035          in 37
	replace w=2.880e-15          in 37
	replace x=36.073252          in 38
	replace w=4.253e-16          in 38
	replace x=38.075732          in 39
	replace w=5.914e-17          in 39
	replace x=40.138129          in 40
	replace w=7.743e-18          in 40
	replace x=42.261127          in 41
	replace w=9.536e-19          in 41
	replace x=44.445445          in 42
	replace w=1.104e-19          in 42
	replace x=46.691834          in 43
	replace w=1.201e-20          in 43
	replace x=49.00108           in 44
	replace w=1.226e-21          in 44
	replace x=51.37401           in 45
	replace w=1.174e-22          in 45
	replace x=53.811489          in 46
	replace w=1.054e-23          in 46
	replace x=56.314423          in 47
	replace w=8.853e-25          in 47
	replace x=58.883764          in 48
	replace w=6.959e-26          in 48
	replace x=61.52051           in 49
	replace w=5.112e-27          in 49
	replace x=64.22571           in 50
	replace w=3.506e-28          in 50
	replace x=67.000465          in 51
	replace w=2.243e-29          in 51
	replace x=69.845931          in 52
	replace w=1.336e-30          in 52
	replace x=72.763325          in 53
	replace w=7.407e-32          in 53
	replace x=75.753929          in 54
	replace w=3.816e-33          in 54
	replace x=78.819091          in 55
	replace w=1.824e-34          in 55
	replace x=81.960232          in 56
	replace w=8.082e-36          in 56
	replace x=85.178851          in 57
	replace w=3.313e-37          in 57
	replace x=88.476531          in 58
	replace w=1.255e-38          in 58
	replace x=91.854943          in 59
	replace w=4.384e-40          in 59
	replace x=95.315857          in 60
	replace w=1.410e-41          in 60
	replace x=98.861146          in 61
	replace w=4.169e-43          in 61
	replace x=102.49279          in 62
	replace w=1.130e-44          in 62
	replace x=106.21291          in 63
	replace w=2.806e-46          in 63
	replace x=110.02374          in 64
	replace w=6.361e-48          in 64
	replace x=113.92765          in 65
	replace w=1.314e-49          in 65
	replace x=117.9272           in 66
	replace w=2.467e-51          in 66
	replace x=122.02509          in 67
	replace w=4.198e-53          in 67
	replace x=126.22423          in 68
	replace w=6.456e-55          in 68
	replace x=130.52772          in 69
	replace w=8.947e-57          in 69
	replace x=134.93891          in 70
	replace w=1.114e-58          in 70
	replace x=139.46136          in 71
	replace w=1.240e-60          in 71
	replace x=144.09897          in 72
	replace w=1.231e-62          in 72
	replace x=148.8559           in 73
	replace w=1.085e-64          in 73
	replace x=153.73669          in 74
	replace w=8.455e-67          in 74
	replace x=158.74625          in 75
	replace w=5.793e-69          in 75
	replace x=163.88995          in 76
	replace w=3.472e-71          in 76
	replace x=169.17364          in 77
	replace w=1.810e-73          in 77
	replace x=174.60376          in 78
	replace w=8.154e-76          in 78
	replace x=180.18739          in 79
	replace w=3.152e-78          in 79
	replace x=185.93236          in 80
	replace w=1.038e-80          in 80
	replace x=191.84737          in 81
	replace w=2.885e-83          in 81
	replace x=197.94213          in 82
	replace w=6.705e-86          in 82
	replace x=204.22756          in 83
	replace w=1.289e-88          in 83
	replace x=210.71597          in 84
	replace w=2.025e-91          in 84
	replace x=217.42139          in 85
	replace w=2.563e-94          in 85
	replace x=224.35989          in 86
	replace w=2.574e-97          in 86
	replace x=231.55007          in 87
	replace w=2.01e-100          in 87
	replace x=239.01363          in 88
	replace w=1.20e-103          in 88
	replace x=246.77624          in 89
	replace w=5.31e-107          in 89
	replace x=254.86863          in 90
	replace w=1.70e-110          in 90
	replace x=263.32817          in 91
	replace w=3.76e-114          in 91
	replace x=272.20117          in 92
	replace w=5.54e-118          in 92
	replace x=281.54633          in 93
	replace w=5.11e-122          in 93
	replace x=291.44013          in 94
	replace w=2.74e-126          in 94
	replace x=301.98586          in 95
	replace w=7.71e-131          in 95
	replace x=313.32953          in 96
	replace w=9.88e-136          in 96
	replace x=325.69126          in 97
	replace w=4.65e-141          in 97
	replace x=339.4351           in 98
	replace w=5.63e-147          in 98
	replace x=355.26131          in 99
	replace w=8.91e-154          in 99
	replace x=374.98411          in 100
	replace w=3.25e-162          in 100
	
	tempname GLPoints
	mkmat x w, matrix(`GLPoints')
	restore
	return matrix Points=`GLPoints'
end
*-------------------------------------------------------------------------------------------------



*-------------------------------------------------------------------------------------------------
* Di_wals
*-------------------------------------------------------------------------------------------------
program Di_wals
	syntax [, nc(string)]

	local y=abbrev(`"`e(depvar)'"',12)
	local focus "`e(focus)'"
	local aux "`e(auxiliary)'"
	
	di as text _n `"`e(title)'"'						///
		_col(46) "Number of obs =" as res %8.0f e(N)	///
		_n as text _col(46) "k1 " _col(60) "=" 			///
		as res %8.0f e(k1) 								///
		_n as text _col(46) "k2 " _col(60) "=" 			///
		as res %8.0f e(k2) 								///		
		_n as text _col(46) "q " _col(60) "=" 			///
		as res %8.4f e(q) 								///
		_n as text _col(46) "c " _col(60) "=" 			///
		as res %8.4f e(c) 								///
		_n as text _col(46) "kappa" _col(60) "=" 		///
		as res %8.1f e(kappa) 
		
	di as text "{hline 13}{c TT}{hline 54}"								///
		_n "{ralign 12:`y'} {c |}"										///
		"      Coef.   Std. Err.      t     [1-Std. Err. Bands]"		/// 
		_n "{hline 13}{c +}{hline 54}"	
	if "`nc'"~="noconstant" {
		di as text "{ralign 12:_cons} {c |}  "				///
				as res %9.0g  _b[_cons] "  "				///
				as res %9.0g  _se[_cons]	"    "			///
				as res %5.2f  _b[_cons]/_se[_cons]	"    "	///
				as res %9.0g _b[_cons]-_se[_cons] " "		///
				as res %9.0g _b[_cons]+_se[_cons] "   "	
	}
	foreach jj of local focus {
		if "`jj'"=="_cons" continue
		local name =abbrev(`"`jj'"',12)
		di as text "{ralign 12:`name'} {c |}  "			///
			as res %9.0g _b[`jj'] "  "					///
			as res %9.0g _se[`jj']	"    "				///
			as res %5.2f _b[`jj']/_se[`jj']	"    "		///
			as res %9.0g _b[`jj']-_se[`jj'] " "			///
			as res %9.0g _b[`jj']+_se[`jj'] "   "	
	}
	noi di as text "{hline 13}{c +}{hline 54}"	
	foreach jj of local aux {
		local name =abbrev(`"`jj'"',15)
		di as text "{ralign 12:`name'} {c |}  "			///
			as res %9.0g _b[`jj'] "  "					///
			as res %9.0g _se[`jj']	"    "				///
			as res %5.2f _b[`jj']/_se[`jj']	"    "		///	
			as res %9.0g _b[`jj']-_se[`jj'] " "			///
			as res %9.0g _b[`jj']+_se[`jj'] "   "	
	}
	noi di as text "{hline 13}{c BT}{hline 54}"	
end
*-------------------------------------------------------------------------------------------------
