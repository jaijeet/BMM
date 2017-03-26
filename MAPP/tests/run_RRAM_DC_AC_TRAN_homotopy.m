% ======================================================================
% run_RRAM_DC_AC_TRAN_homotopy.m
% ======================================================================
% MAPP script to test the RRAM compact model (RRAM_ModSpec.m).
% The script first creates a circuit by connecting a RRAM_ModSpec device
% in series with a voltage source, then runs DC operating point analysis, DC
% sweep, AC analysis, transient analysis and homotopy analysis on the circuit.
%
% Version: 1.0.0
% Tested on: MAPP-2017-02-15-release
%
% Author: Tianshi Wang [tianshi@berkeley.edu]
% Last Modified: Mar 25, 2017

if ~exist('RRAM_MOD')
    RRAM_MOD = RRAM_ModSpec();
end

do_dc = 1;
do_ac = 1;
do_tran = 1;
do_hom = 1;

% set up ckt
clear ckt; 
ckt.cktname = 'RRAM test bench';
ckt.nodenames = {'1'};
ckt.groundnodename = '0';
tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t+args.phi, 0.5);
tranargs.offset = 0; tranargs.A = 2; tranargs.T = 8e-3; tranargs.phi=0;
ckt = add_element(ckt, vsrcModSpec(), 'V1', ...
   {'1', '0'}, {}, {{'DC', 1}, {'AC', 1}, {'TRAN', tranfunc, tranargs}});
ckt = add_element(ckt, RRAM_MOD, 'R1', {'1', '0'});

% set up DAE
DAE = MNA_EqnEngine(ckt);

% DC OP analysis
dcop = dot_op(DAE);
dcop.print(dcop);
dcSol = dcop.getSolution(dcop);
uDC = dcop.getDCinputs(dcop);

if do_dc
    % DC sweep
    swp = dcsweep(DAE, dcSol, 'V1:::E', +1:-0.01:-1);
    swp.plot(swp);
end

if do_ac
    % small-signal AC analysis
    sweeptype = 'DEC'; fstart = 1e2; fstop = 1e9; nsteps = 20;
    acObj = ac(DAE, dcSol, uDC, fstart, fstop, nsteps, sweeptype);
    feval(acObj.plot, acObj);
end

if do_tran
    % transient simulation, sweep Vin
    tstart = 0; tstep = 1e-5; tstop = 8e-3;
    xinit = [0; 0; 1.7];
    LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
    LMSobj.plot(LMSobj);

    % get transient data, plot current in log scale
    [tpts, sols] = LMSobj.getSolution(LMSobj);
    figure; semilogy(sols(1,:), abs(sols(2,:)));
    xlabel('V1 (V)'); ylabel('log(current) (A)'); grid on;
end

if do_hom
    % homotopy analysis
    startLambda = 1; stopLambda = -1; lambdaStep = -1e-1;
    hom = homotopy(DAE, 'V1:::E', 'input', dcSol, startLambda, lambdaStep, stopLambda);
    hom.plot(hom);
end
