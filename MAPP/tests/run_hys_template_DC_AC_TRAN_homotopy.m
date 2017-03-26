% ======================================================================
% run_hys_template_DC_AC_TRAN_homotopy.m
% ======================================================================
% MAPP script to test the hys_template compact model (hys_template_ModSpec.m).
% The script first creates a circuit by connecting a hys_template_ModSpec device
% in series with a voltage source, then runs DC operating point analysis, DC
% sweep, AC analysis, transient analysis and homotopy analysis on the circuit.
%
% Version: 1.0.0
% Tested on: MAPP-2017-02-15-release
%
% Author: Tianshi Wang [tianshi@berkeley.edu]
% Last Modified: Mar 25, 2017

if ~exist('hys_MOD')
    hys_MOD = hys_template_ModSpec();
end

do_dc1 = 1;
do_dc2 = 1;
do_ac = 1;
do_tran = 1;
do_hom = 1;

% set up ckt
clear ckt; 
ckt.cktname = 'hys_template test bench';
ckt.nodenames = {'1'};
ckt.groundnodename = '0';
tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t+args.phi, 0.5);
tranargs.offset = 0; tranargs.A = 2; tranargs.T = 8e-3; tranargs.phi=0;
ckt = add_element(ckt, vsrcModSpec(), 'V1', ...
   {'1', '0'}, {}, {{'DC', 1}, {'AC', 1}, {'TRAN', tranfunc, tranargs}});
ckt = add_element(ckt, hys_MOD, 'H1', {'1', '0'});

% set up DAE
DAE = MNA_EqnEngine(ckt);

% DC OP analysis
dcop = dot_op(DAE);
dcop.print(dcop);
dcSol = dcop.getSolution(dcop);
uDC = dcop.getDCinputs(dcop);

if do_dc1
    % DC sweep
    swp1 = dcsweep(DAE, [0;0;-1], 'V1:::E', -2:+0.1:+2);
    swp1.plot(swp1);
end

if do_dc2
    % DC sweep
    swp2 = dcsweep(DAE, [0;0;+1], 'V1:::E', +2:-0.1:-2);
    swp2.plot(swp2);
end

if do_dc1 && do_dc2
    % plot forward and backward DC sweep results
    [pt1, sol1] = swp1.getSolution(swp1);
    [pt2, sol2] = swp2.getSolution(swp2);

    sidx = DAE.unkidx('H1:::s', DAE);
    figure;
    plot(pt1, sol1(3, :), '.-r');
    hold on;
    plot(pt2, sol2(3, :), '.-b');
    grid on; box on;
    xlabel('V (V)');
    ylabel('s');
    legend('forward DC sweep', 'backward DC sweep');

    Iidx = DAE.unkidx('V1:::ipn', DAE);
    figure;
    plot(pt1, -sol1(Iidx,:), '.-r');
    hold on;
    plot(pt2, -sol2(Iidx,:), '.-b');
    grid on; box on;
    xlabel('V (V)');
    ylabel('I (A)');
    legend('forward DC sweep', 'backward DC sweep');
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
    xinit = [0; 0; -1];
    LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
    LMSobj.plot(LMSobj);
end

if do_hom
    % homotopy analysis
    startLambda = 1; stopLambda = -1; lambdaStep = -1e-1;
    hom = homotopy(DAE, 'V1:::E', 'input', dcSol, startLambda, lambdaStep, stopLambda);
    hom.plot(hom);
end
