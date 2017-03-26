% ======================================================================
% run_memristor_DC_AC_TRAN_homotopy.m
% ======================================================================
% MAPP script to test the memristor compact model (memristor_ModSpec.m).
% The script first creates a circuit by connecting a memristor_ModSpec device
% in series with a voltage source, then runs DC operating point analysis, DC
% sweep, AC analysis, transient analysis and homotopy analysis on the circuit.
%
% Version: 1.0.0
% Tested on: MAPP-2017-02-15-release
%
% Author: Tianshi Wang [tianshi@berkeley.edu]
% Last Modified: Mar 25, 2017

if ~exist('memristor_MOD')
    memristor_MOD = memristor_ModSpec();
end

do_ac = 1;
do_tran = 1;
do_hom = 1;

clear ckt; 
ckt.cktname = 'memristor test bench';
ckt.nodenames = {'1'};
ckt.groundnodename = '0';
tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t+args.phi, 0.5);
tranargs.offset = 0; tranargs.A = 1; tranargs.T = 1e-2; tranargs.phi=0;
ckt = add_element(ckt, vsrcModSpec(), 'V1', ...
   {'1', '0'}, {}, {{'DC', 1}, {'AC', 1}, {'TRAN', tranfunc, tranargs}});
ckt = add_element(ckt, memristor_MOD, 'R1', {'1', '0'}, {});

% set up DAE
DAE = MNA_EqnEngine(ckt);

% DC OP analysis
dcop = dot_op(DAE, [0;0;1]);
dcop.print(dcop);
dcSol = dcop.getSolution(dcop);
uDC = dcop.getDCinputs(dcop);

if do_ac
    % small-signal AC analysis
    sweeptype = 'DEC'; fstart = 1e2; fstop = 1e9; nsteps = 20;
    acObj = ac(DAE, dcSol, uDC, fstart, fstop, nsteps, sweeptype);
    feval(acObj.plot, acObj);
end

if do_tran
	% transient simulation, sweep Vin
	tstart = 0; tstep = 1e-4; tstop = 1e-2;
	xinit = [0; 0; 0];
	LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
	LMSobj.plot(LMSobj);

	% get transient data, plot current in log scale
	[tpts, sols] = LMSobj.getSolution(LMSobj);
	figure; semilogy(sols(1,:), abs(sols(2,:)));
	xlabel('Vin (V)'); ylabel('log(current) (A)'); grid on;
end

if do_hom
	% homotopy analysis
	startLambda = 1; stopLambda = -1; lambdaStep = -1e-2;
	hom = homotopy(DAE, 'V1:::E', 'input', dcSol, startLambda, lambdaStep, stopLambda);
	hom.plot(hom);
end
