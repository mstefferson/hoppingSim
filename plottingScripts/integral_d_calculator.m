function [] = makeDBFromHoppingOutput()
% This scripts generates DB data using the outputs of the hopping
% simulation.  Several parameters need to be set by hand at the top of the
% script.  Navigate to the folder in which the output files are located
% before running.  Folder should contain output files in ascending order of
% kHop (rHop).
%% User inputs
SetFigureDefaults(18,2); % first argument is default font size; second argument is default line width.
f = 0.9; % fraction of data to use.  f = 0.9 uses first 90% of data.
lc = 500; % tether contour length in nm.
rhopList = [0, 0.001];%,0.01,0.1]; % list of rHop values from simulations
koffList = logspace(-3,-1,30); % list of koff values you want to use

%% Load output files
r = LoadResults();

%% Set up arrays for msd and error; define a time axis
msdList = zeros(length(r.filename),f*1e5);
errList = zeros(length(r.filename),f*1e5);
for i=1:length(r.filename)
    %s = smooth(r.msd{i},1e2);
    s= r.msd{i};
    serr = r.errMean{i};
    msdList(i,:) = s(1:f*end);
    errList(i,:) = serr(1:f*end);
end
dtime = r.dtime{i}(1:f*end);
clear i

%% Set up array for lifetime distribution
distList = zeros(length(koffList),length(dtime));
for koffIndex=1:length(koffList)
    for tt=1:length(dtime)
        % rho = koff*e^(-koff*t)
        distList(koffIndex,tt) = koffList(koffIndex)*exp(-koffList(koffIndex)*dtime(tt));
    end
end
clear koff tt

%% Define the integrands
% The integrand is msd(rhop,t)*rho(koff,t).
% The lifetime integral goes in the denominator of the final expression and
% its integrand is rho(koff,t)*t.
% The error integrand is for calculating error in DB.

% Initialize arrays
integrand = zeros(length(rhopList),length(koffList),length(dtime));
ltintegrand = zeros(length(koffList),length(dtime));
errintegrand = zeros(length(rhopList),length(koffList),length(dtime));
% Loop over all koff, rhop, and t
for koffIndex = 1:length(koffList)
    for tt = 1:length(dtime)
        ltintegrand(koffIndex,tt) = dtime(tt)*distList(koffIndex,tt);
        for khopIndex =1:length(rhopList)
            integrand(khopIndex,koffIndex,tt) = ...
                msdList(khopIndex,tt)*distList(koffIndex,tt);
            errintegrand(khopIndex,koffIndex,tt) = ...
                errList(khopIndex,tt)*distList(koffIndex,tt);
        end
    end
end

clear khopIndex koffIndex tt

%% Numerically integrate all integrands over time
integral = sum(integrand,3);
lifetime = sum(ltintegrand,2);
err = sum(errintegrand,3);

%% Calculate bound diffusion coefficient and error
% In 1D, DB = integral / (2*lifetime).

% Initialize arrays
d = zeros(length(rhopList),length(koffList));
derr = zeros(length(rhopList),length(koffList));
% Loop over all values of koff
for koffIndex = 1:length(koffList)
    d(:,koffIndex) = integral(:,koffIndex)./(2*lifetime(koffIndex));
    derr(:,koffIndex) = err(:,koffIndex)./(2*lifetime(koffIndex));
end
%% Plot results

% Calculate expected results for rhop = 0:
y = (1.*koffList.*1.*lc)./(3.*1+koffList.*1.*lc);

figure
set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')

% Convert x-axis from koff to KD (kon = 1e-3, diffusion-limited)
semilogx(koffList/1e-3,y,'k-');
hold all
for i=1:length(rhopList)
    errorbar(koffList/1e-3,d(i,:)',derr(i,:)','o')
    %loglog(koffList,d(i,:)','o');
end
h = legend({'Tether Model','0','0.004', '0.04', '0.4'});
ht = get(h,'Title');
set(ht,'String','$k_\mathrm{hop}$ ($\mu$s$^{-1}$)')
clear i
hold off
xlabel('Dissociation constant $K_D$ ($\mu$ M)');
ylabel('Bound diffusion ratio $D_B/D_F$');

end