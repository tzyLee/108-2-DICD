* nand2.sp

.subckt nand2 out a b N=8 P=8
M1 out a vdd vdd PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
M2 out b vdd vdd PMOS W='P' L=2 AS='P*5' PS='2*P+10' AD='P*5' PD='2*P+10'
M3 out a c   gnd NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10'
M4 c   b gnd gnd NMOS W='N' L=2 AS='N*5' PS='2*N+10' AD='N*5' PD='2*N+10'
.ends