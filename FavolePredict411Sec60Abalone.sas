%let ME=johannafavole2013;
%let PATH=/home/&ME./my_courses/donald.wedding/c_8888/PRED411/UNIT03/DB;
%let NAME=DB;
%let LIB=&NAME..;

libname &NAME "&PATH.";

%let INFILE = DB.zip_abalone;

*proc means data = &INFILE. n nmiss mean var;
*run;

*proc univariate data = &INFILE. plots;
*var LENGTH DIAMETER SHELLWEIGHT;
*run;

*proc freq data=&INFILE.;
*table Sex*Target_Rings;
*run;

*proc corr data=&INFILE.;
*run;

data FIXEDFILE;
set &INFILE.;

if (SEX = "M") then SexM = 1; else SexM = 0;
if (SEX = "F") then SexF = 1; else SexF = 0;
if (SEX = "I") then SexI = 1; else SexI = 0;
drop SEX;

F_LENGTH = LENGTH;
if F_LENGTH < 0.2025 then F_LENGTH = 0.2025;
drop LENGTH;

F_DIAMETER = DIAMETER;
if F_DIAMETER < 0.1425 then F_DIAMETER = 0.1425;
drop DIAMETER;

F_HEIGHT = HEIGHT;
if F_HEIGHT < 0.04 then F_HEIGHT = 0.04;
if F_HEIGHT > 0.24 then F_HEIGHT = 0.24;
drop HEIGHT;

F_WHOLE = WHOLEWEIGHT;
if F_WHOLE > 0.2215 then F_WHOLE = 0.2215;
drop WHOLEWEIGHT;

F_SHUCKED = SHUCKEDWEIGHT;
if F_SHUCKED > 0.979 then F_SHUCKED = 0.979;
drop SHUCKEDWEIGHT;

F_VISCERA = VISCERAWEIGHT;
if F_VISCERA > 0.4915 then F_VISCERA = 0.4915;
drop VISCERAWEIGHT;

F_SHELL = SHELLWEIGHT;
if F_SHELL > 0.633 then F_SHELL = 0.633;
drop SHELLWEIGHT;

run;

proc means data=FIXEDFILE n nmiss;
run;

proc genmod data=FIXEDFILE;
model TARGET_RINGS = SexM SexF SexI F_LENGTH F_DIAMETER F_SHELL / dist=ZINB link=log;
zeromodel SexM SexF SexI F_LENGTH F_DIAMETER F_SHELL / link=logit;
output OUT=TEMPFILE pred=P_TARGET_RINGS pzero=P_ZERO_ZINB;
run;

data SCOREFILE;
set DB.zip_abalone_test;

if (SEX = "M") then SexM = 1; else SexM = 0;
if (SEX = "F") then SexF = 1; else SexF = 0;
if (SEX = "I") then SexI = 1; else SexI = 0;
drop SEX;

F_LENGTH = LENGTH;
if F_LENGTH < 0.2025 then F_LENGTH = 0.2025;
drop LENGTH;

F_DIAMETER = DIAMETER;
if F_DIAMETER < 0.1425 then F_DIAMETER = 0.1425;
drop DIAMETER;

F_SHELL = SHELLWEIGHT;
if F_SHELL > 0.633 then F_SHELL = 0.633;
drop SHELLWEIGHT;

TEMP = 2.1759
+ 0.0938*SEXM
+ 0.1128*SEXF
- 1.3183*F_LENGTH
+ 0.9995*F_DIAMETER
+ 1.4132*F_SHELL;
P_SCORE_ZINB_ALL = exp(TEMP);

TEMP = -7.8547
- 0.6879*SEXM
- 0.9543*SEXF
+ 123.5725*F_LENGTH
- 99.1702*F_DIAMETER
- 136.457*F_SHELL;
P_SCORE_ZERO = exp(TEMP)/(1 + exp(TEMP));

P_TARGET_RINGS = P_SCORE_ZINB_ALL*(1-P_SCORE_ZERO);
P_TARGET_RINGS = round(P_TARGET_RINGS, 1);

keep INDEX;
keep P_TARGET_RINGS;

run;



proc print data=SCOREFILE(obs=10);
run;

libname favole "/home/&ME.";

data favole.FavolePRED411SEC60ABALONE;
set SCOREFILE;
run;

























