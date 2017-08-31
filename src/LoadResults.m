function r = LoadResults(plotFlag)
% Loads all output .mat files from current folder.
% Input: plotFlag - if 1, plots showing how effective diffusion coefficient
% was calculated will remain after runnning.  If zeros, all plots will be
% closed after running.
% Output: a structure containing many results in an easy format for
% plotting.  Precise data contained in results structure may change as the
% simulation evolves.

d=dir('*.mat'); % list all .mat files in current folder
l = length(d); % count all files
r = struct(); % initialize results structure

r.d = cell(1,l); % cell array to hold Deff vectors
r.msd = cell(1,l); % cell array to hold msd vectors
r.dt = zeros(1,l); % for delta T parameter (size of timestep)
r.kon = zeros(1,l); % for kon calculated after running
r.koff = zeros(1,l); % for koff calculated after running
r.khop = zeros(1,l); % for hopping rate parameter
r.dPre = zeros(1,l); % for predicted Deff using koff and kon above
r.kd = zeros(1,l); % for calculated Kd (from koff and kon above)
r.dPost = zeros(1,l); % for Deff calculated from simulation
r.dErr = zeros(1,l); % for error in calculated Deff
r.db = zeros(1,l);
r.hopFreq = zeros(1,l);
r.hopOverageFreq = zeros(1,l); % for hopping overage frequency

r.params = cell(1,l); % for parameters needed for flux calculation
for k=1:l
    disp(['Loading file ' num2str(k) ' of ' num2str(l) '.']);
    fname=d(k).name;
    data=load(fname);
    r.d{k} = data.results.Deff;
    r.msd{k} = data.results.meanMSD;
    r.dt(k) = data.paramOut.deltaT;
    r.kon(k) = data.results.konCalc;
    r.koff(k) = data.results.koffCalc;
    r.khop(k) = data.paramOut.kHop;
    r.dPre(k) = data.DeffCalc;
    r.kd(k) = r.koff(k)/r.kon(k);
    [r.dPost(k), r.dErr(k)] = estimateDeff(r.dt(k)*1:length(r.d{k}),r.d{k});
    r.hopFreq(k) = data.results.hopFreq;
    if isfield(data.results,'hopOverageFreq')
        r.hopOverageFreq(k) = data.results.hopOverageFreq;
    else
        r.hopOverageFreq(k) = 0;
    end
    
    % Extract bound diffusion coefficient from dPost.
    r.dBound(k) = (r.dPost(k) - data.results.pfCalc*data.paramOut.D)/...
        (1-data.results.pfCalc);
    
    % Fill in params structure for subNum function.
    r.params{k} = struct();
    r.params{k}.DF = data.paramOut.D;
    r.params{k}.Nt = data.paramOut.Nt;
    r.params{k}.AB = 10; %shouldn't matter if I take ratios;
    r.params{k}.L = 100; % keep fixed
    r.params{k}.kon = r.kon(k);
    r.params{k}.koff = r.koff(k);
    r.params{k}.ll = data.paramOut.lc*data.paramOut.lp;
    r.params{k}.DB = r.dBound(k);

if plotFlag == 0
    close all
end

end