function [ x, tether_locations,binding_record,hopCount,hopOverageCount, onOverage] = NumericalHoppingTetherNoBind( params, plot_flag )
try
% This code runs the simulation with a continuous model, taking in only
% non-dimensional parameters.  It binds after the first step and never
% allows unbinding!
disp('Running no-binding version of simulation.');
% Import parameters.
L = params.L;
D = params.D;
deltaT = params.deltaT;
timesteps = params.timesteps;

k = params.k;
c = params.c;
kHop = params.kHop;  
Ef = params.Ef; 

% Make a tether vector with randomly-spaced tethers from a continuous
% uniform distribution.

% Set number of tethers:
M = round(L*c)-1;
% Make a sorted list of random tethers:
%tether_locations = [L/2];
tether_locations = L*sort([rand(M,1)' 1/2]);

% x(i,1) = position, x(i,2) is well number (0 if unbound).
x = zeros(params.numrec,2);
x(1,:) = [L/2 0]; % start at the center, start bound to tether.
jrec = 1; % record index (first step gets recorded if t = 0)
recsteps = params.recsteps;

% initialize logical array for binding record
binding_record = false(params.timesteps,1);

% intializing arrays for some diagnostic variables
hopCount = 0;
hopOverageCount = 0;
onOverage = 0;

% get current position and binding for first step (t = 0)
nextPos = x(1,1);
nextBind = x(1,2);
%fprintf('Starting time loop\n')
for i=0:timesteps-1  
    % update positions and binding
    currPos = nextPos;
    currBind = nextBind;
    nextBind = 0;
    
    % Define Gaussian distribution from which to pick step sizes.
    % sigma corresponds to Gaussian solution to diffusion equation.
    sigma = sqrt(2*D*deltaT);
    step = normrnd(0,sigma);
    
    nextPos = currPos + step;

    % recording
    if mod(i, recsteps) == 0 
      x(jrec,1) = currPos;
      x(jrec,2) = currBind;
      jrec = jrec+1;
    end
end

% update last time
i = i + 1;
currPos = nextPos;
currBind = nextBind;
% recording
if mod(i, recsteps) == 0 
  x(jrec,1) = currPos;
  x(jrec,2) = currBind;
end

if plot_flag
    close all
    subplot(2,2,1)
    %plot_time = timesteps;
    histogram(nonzeros(x(:,2)))
    title('tether locations')
    subplot(2,2,2)
    plot(x(:,1))
    title('position vs time')
    subplot(2,2,4)
    plot(nonzeros(x(:,2)))
    title('tether locations vs time')
    subplot(2,2,3)
    histfit(x(:,1), 100)
    title('histogram of locations')
end
catch err
  fprintf('%s',err.getReport('extended') );
  keyboard
end



