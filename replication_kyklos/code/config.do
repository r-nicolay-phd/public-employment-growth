* config.do -- the only file to edit before running the package.
* Set ROOT to the full path of the replication package (the folder that contains README.md), for example
*     global ROOT "C:/Users/me/replication_kyklos"
* If ROOT is left empty, the current working directory is used: run the package from its root folder.
global ROOT ""
if "$ROOT" == "" global ROOT "`c(pwd)'"
* community-contributed packages shipped with the package (versions in README.md)
sysdir set PLUS "$ROOT/code/ado/plus"
adopath ++ "$ROOT/code/ado/plus"
