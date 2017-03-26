* memristor_DC_AC_TRAN.sp
* ---------------------------------------------------------------------
* HSPICE netlist to test the memristor compact model (memristor.va)
*
* Version: 1.0.0
* Tested on: Synopsys HSPICE Version J-2014.09 64-BIT
*
* Author: Tianshi Wang [tianshi@berkeley.edu]
* Last Modified: Mar 25, 2017

.OPTION POST
.OPTION RUNLVL=5

.hdl ../models/memristor.va

Vin in 0 DC -1 pulse(-1 1 1u 4m 4m 1u 8m) AC 1
X1 in 0 memristor

* DC analysis
.dc Vin -1 1 0.01

* AC analysis
.ac dec 20 100 1G

* transient simulation
.tran 1u 8m

.end
