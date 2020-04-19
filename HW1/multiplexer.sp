* multiplexer.sp

*------------------------------------------------
* Parameters and models
*------------------------------------------------
.param SUPPLY=5.0
.param CYCLE=2ns
.param EPSILON=1fs
.include './mosistsmc180.sp'
.temp 70
.option post
.option scale=100n

*------------------------------------------------
* Subcircuits
*------------------------------------------------
.global vdd, gnd
.include './nand2.sp'

*------------------------------------------------
* Simulation netlist
*------------------------------------------------
* D = NAND(NAND(D1, S), NAND(D_0,  NAND(S, S)))
Vdd     vdd   gnd  'SUPPLY'
Vd0     d0    gnd  PULSE 0        'SUPPLY' '2*CYCLE'   'EPSILON' 'EPSILON' '2*CYCLE'   '4*CYCLE'
Vd1     d1    gnd  PULSE 0        'SUPPLY' 'CYCLE'     'EPSILON' 'EPSILON' 'CYCLE'     '2*CYCLE'
Vs      s     gnd  PULSE 0        'SUPPLY' '0.5*CYCLE' 'EPSILON' 'EPSILON' '0.5*CYCLE' 'CYCLE'
Vs_bar  s_bar gnd  PULSE 'SUPPLY' 0        '0.5*CYCLE' 'EPSILON' 'EPSILON' '0.5*CYCLE' 'CYCLE'
X1  d     d1_s d0_ns nand2
X2  d1_s  d1   s     nand2
X3  d0_ns d0   s_bar nand2

*------------------------------------------------
* Stimulus
*------------------------------------------------
.tran 0.1ps '5*CYCLE'
.end