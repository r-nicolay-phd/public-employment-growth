{smcl}
{* 20May2011}{...}
{cmd:help wals} {right: ({browse "http://www.stata-journal.com/article.html?article=st0239":SJ11-4: st0239})}
{hline}

{title:Title}

{p2colset 5 13 15 2}{...}
{p2col :{hi:wals} {hline 2}}Weighted-average least squares{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}{cmd:wals} {it:depvar} [{varlist}] 
{ifin}{cmd:,}
{cmdab:aux:iliary}{cmd:(}{varlist}{cmd:)} 
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt auxiliary(varlist)}}auxiliary covariates{p_end}
{synopt :{opt q(#)}}specify the parameter 0 < q <= 1 of a Subbotin prior{p_end}
{synopt :{opt intp:oints(#)}}define the number of data points to approximate the constrained parameter of a Subbotin prior{p_end}
{synopt :{opt eps(#)}}specify the convergence criterion for solving the nonlinear equation of the constrained parameter of a Subbotin prior{p_end}
{synopt :{opt iterate(#)}}specify the maximum number of iterations for solving the nonlinear equation of the constrained parameter of a Subbotin prior{p_end}
{synopt :{opt nocon:stant}}exclude the constant term from the model{p_end}
{synoptline}
{p 4 6 2}* {opt auxiliary(varlist)} is required.{p_end}
{p 4 6 2}{it:depvar} is the dependent variable and {varlist} is the list of focus regressors.{p_end}
{p 4 6 2}Factor variables, time-series operators, and weights are not allowed.{p_end}


{title:Description}

{pstd}
{cmd:wals} uses the weighted-average least-squares estimator introduced
by Magnus, Powell, and Pr{c u:}fer (2010) to fit a classical linear
regression model with uncertainty about the choice of the explanatory
variables.

{pstd}
The statistical framework is a classical linear regression model with
two subsets of explanatory variables.  The focus regressors contain
explanatory variables that we want in the model because of theoretical
reasons or other considerations about the phenomenon under
investigation.  The auxiliary regressors contain additional
explanatory variables of which we are less certain.

{pstd}
The problem of model uncertainty arises because different subsets of
auxiliary regressors could be excluded from the model to improve, in the
mean squared error sense, the unrestricted ordinary least-squares
estimator of the focus parameters.  When there are k2 auxiliary
regressors, the number of possible models to be considered is I=2^k2.

{pstd}
This model-averaging technique provides a coherent method of inference
on the regression parameters of interest by taking explicit account of
the uncertainty due to both the estimation and the model selection
steps.  Weighted-average least squares relies on preliminary orthogonal
transformations of the auxiliary regressors and their parameters, which
greatly reduce the computational burden of this model-averaging
estimator and allow for exploiting prior distributions corresponding to a
more transparent concept of ignorance about the role of the auxiliary
regressors.

{pstd}
This Bayesian estimator uses conventional noninformative priors on the
focus parameters and the error variance, and a distribution with zero
mean for the independent and identically distributed elements of the t
ratios associated with linear combinations of the auxiliary parameters.
The prior distribution of the t ratios can be either a neutral Laplace
distribution (Magnus, Powell, and Pr{c u:}fer 2010) or a neutral
Subbotin distribution (Einmahl, Kumar, and Magnus 2011).


{title:Options}

{phang} {opt auxiliary(varlist)} is the required list of auxiliary
regressors of which we are less certain.

{phang}
{opt q(#)} specifies the free parameter q of a Subbotin prior distribution
under neutrality.  The default is {cmd:q(1)}, which corresponds to a neutral
Laplace prior.  Any real value of q in the interval (0,1) corresponds 
to a neutral Subbotin prior.

{phang}
{opt intpoints(#)} defines the number of data points used by the
built-in Stata command {cmd:integ} when approximating numerically the
integral involved in the nonlinear equation for the constrained
parameter c of a Subbotin density under neutrality.  The default uses
10,000 data points.  When q=1 or q=0.5, this option is
ineffective because the solution of the constrained parameter c is
determined analytically.  

{phang}
{opt eps(#)} specifies the convergence criterion used by the built-in
Stata command {cmd:nl} when solving the nonlinear equation for the
constrained parameter c of a Subbotin density under neutrality.  The
default is {cmd:eps(1e-8)}.  When q=1 or q=0.5, this option is
ineffective because the solution of the constrained parameter c is
determined analytically.  

{phang}
{opt iterate(#)} specifies the maximum number of iterations used by the
built-in Stata command {cmd:nl} when solving the nonlinear equation for
the constrained parameter c of a Subbotin density under neutrality.  The
default is {cmd:iterate(16000)}.  When q=1 or q=0.5, this
option is ineffective because the solution of the constrained parameter
c is determined analytically.

{phang}
{opt noconstant} specifies that the constant term be excluded from the model.
By default, the constant term is included and the corresponding vector of ones
is treated as a focus regressor.


{title:Examples}

{phang}{cmd:. use data_mpp_small}

{phang}{cmd:. wals growth gdp60 equipinv confuc school60 life60 law tropics avelf, auxiliary(mining dpop pright malaria)}

{phang}{cmd:. wals growth, auxiliary(gdp60 equipinv confuc school60 life60 law tropics avelf mining dpop pright malaria)}

{phang}{cmd:. wals growth, auxiliary(gdp60 equipinv confuc school60 life60 law tropics avelf mining dpop pright malaria) q(.5)}

{phang}{cmd:. wals growth, auxiliary(gdp60 equipinv confuc school60 life60 law tropics avelf mining dpop pright malaria) q(.2) intpoints(50000)}


{title:References}

{p 4 8 2}
Einmahl, J. H. J., K. Kumar, and J. R. Magnus.  2011.
On the choice of prior in Bayesian model averaging.  Discussion Paper No.
2011-003, Tilburg University.
http://ideas.repec.org/p/dgr/kubcen/2011003.html.

{p 4 8 2}
Magnus, J. R., O. Powell, and P. Pr{c u:}fer.  2010.
A comparison of two model averaging techniques with an application to growth
empirics.  {it:Journal of Econometrics} 154: 139-153.
  

{title:Authors}

{pstd}Giuseppe De Luca{p_end}
{pstd}ISFOL{p_end}
{pstd}Rome, Italy{p_end}

{pstd}Jan R. Magnus {p_end}
{pstd}Tilburg University{p_end}
{pstd}Tilburg, The Netherlands{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 11, number 4: {browse "http://www.stata-journal.com/article.html?article=st0239":st0239}

{p 4 14 2}{space 1}Manual:  {manlink R regress}, {manlink R stepwise}

{p 4 14 2}{space 3}Help:  {helpb regress}, {helpb stepwise}, {helpb vselect},
{helpb bma}, {helpb gmi} (if installed)
{p_end}
