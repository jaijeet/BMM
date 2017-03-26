* hys_template_DC_AC_TRAN.sp
* ---------------------------------------------------------------------
* HSPICE netlist to test the hys_template compact model (hys_template.va)
*
* Version: 1.0.0
* Tested on: Synopsys HSPICE Version J-2014.09 64-BIT
*
* Author: Tianshi Wang [tianshi@berkeley.edu]
* Last Modified: Mar 25, 2017

.OPTION POST
.OPTION RUNLVL=5

.hdl ../models/hys_template.va

V1 1 0 1 sin(0 0.7 1k) AC 1
X1 1 0 hys_template

* DC analysis
.dc V1 -1 +1 0.01

* AC analysis
.ac dec 20 10 10k

* transient simulation
.tran 1u 2m

.end
