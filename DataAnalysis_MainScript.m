% =========================================================================
% PAPER III - Working distance and sapphire signal
% =========================================================================
% Contains all relevant data analysis for paper V.
% ------------------------------------------------------------------------
%
% Author: Tiril Lintvedt
% Nofima, Raw materials and process optimisation
% email address: tiril.lintvedt@nofima.no
% Website: 
% March 2026
% MATLAB version: R2025a
% OS: Windows 11 Home
% Other packages required: GSTools, My_toolbox, Saisir, Open EMSC toolbox

% -------------------------------------------------------------------------

%% SETTINGS 
% -------------------------------------------------------------------------

% Main plot colors
plot_colors =[0 0.5 0.9   ; 
              0.9 0.5 0   ; 
              0.2 0.5 0.2 ; 
              0.9 0.3 0.1 ;
              0.7 0.7 0.2 ; 
              0   0   0   ;
              0.5 0.5 0.5 ;
              0.2 0.7 0.7  ];

set(0,'defaultfigurecolor',[1 1 1])
addpath(genpath('DATA'))
addpath(genpath('Saisir'))
addpath(genpath('Open EMSC toolbox\Methods\Achim'))
addpath(genpath('GSTools'))
addpath(genpath('My_toolbox'))

%% DATA IMPORT
% -------------------------------------------------------------------------

% Main set data -----------------------------------------------------------
spec = GSImportspec('DATA/Spectra',0);
[X, Xmeta] = extractSPC(spec); % Spectra and Meta data


% Supplemmentary data -----------------------------------------------------
spec = GSImportspec('DATA\Supplementary\Exosure time series',0);
[Xsupl, Xmeta_supl] = extractSPC(spec); % Spectra and Meta data

spec = GSImportspec('DATA\Supplementary\Background spectra',0);
[Xbg, Xmeta_bg] = extractSPC(spec); % Spectra and Meta data


% Reference data ----------------------------------------------------------
Y = readcell('DATA\Reference analyses.xls','Sheet', 'Result report');

sample_names = Y(7:31,5);
nsamp = size(sample_names,1);
id = char(sample_names(:,1));
individ_id = id(:,1:3);

References.d = cell2mat(Y(7:31,[6:10,13:16,18:26,29,31:41]));
References.v = char(Y(1,[6:10,13:16,18:26,29,31:41]));
References.i = char(Y(7:31,5));

% Meta data - Laser power measurements ------------------------------------
Ylaser = readcell('DATA\Experiment meta data.xlsx','Sheet', 'Laser power monitoring');
clear LP
LP.d = Ylaser([20:49,56:66],4:9);
LP.i = char(Ylaser([20:49,56:66],3));
LP.v = char(Ylaser(18, 4:9)');




%% MEASUREMENT DESIGN ILLUSTRATION
% -------------------------------------------------------------------------

WDs =  [5 10 10 10 10 15 20 20 20 25 30 30 30];
LPs  = [450 450 400 300 200 450 450 400 300 450 450 400 300];

figure('Position',[ 50 50 500 400]);
plot(WDs,LPs, '.','MarkerSize',40,'MarkerFaceColor',[plot_colors(2,:)],'MarkerEdgeColor',[plot_colors(2,:)])
grid on; box off
xlabel('Working distance / cm ', 'Fontsize', 18)
ylabel('Laser power / mW', 'Fontsize', 18)
xlim([3 32])
ylim([190 460])

%% MEASURED LASER POWER AS A FUNCTION OF WORKING DISTANCE (WD)
% -------------------------------------------------------------------------

% Remove unmeasured samples:
LP.d([35:36,39:41],:) = [];
LP.i([35:36,39:41],:) = [];

% Clean the laser power data, separate column info
WD2MeasuredLP_5cm = [mean([LP.d{:,1}]','omitnan');  std([LP.d{:,1}]','omitnan')];
WD2MeasuredLP_10cm = [mean(str2double(split(LP.d(:,2),',')),1); std(str2double(split(LP.d(:,2),',')),1)];
WD2MeasuredLP_15cm = [mean([LP.d{:,3}]','omitnan');  std([LP.d{:,3}]','omitnan')];
WD2MeasuredLP_20cm = [mean(str2double(split(LP.d(:,4),',')),1); std(str2double(split(LP.d(:,4),',')),1)];
WD2MeasuredLP_25cm = [mean([LP.d{:,5}]','omitnan');  std([LP.d{:,5}]','omitnan')];
WD2MeasuredLP_30cm = [mean(str2double(split(LP.d(:,6),',')),1); std(str2double(split(LP.d(:,6),',')),1)];

lp_out = [450, 400, 300, 200];
wd = [5,10,15,20,25,30];

LPout.i = num2str(wd');
LPout.v = num2str(lp_out');
LPout.mean = [];
LPout.mean(1,1) = WD2MeasuredLP_5cm(1,:);
LPout.mean(2,1:4) = WD2MeasuredLP_10cm(1,:);
LPout.mean(3,1) = WD2MeasuredLP_15cm(1,:);
LPout.mean(4,1:3) = WD2MeasuredLP_20cm(1,:);
LPout.mean(5,1) = WD2MeasuredLP_25cm(1,:);
LPout.mean(6,1:3) = WD2MeasuredLP_30cm(1,:);

LPout.std = [];
LPout.std(1,1) = WD2MeasuredLP_5cm(2,:);
LPout.std(2,1:4) = WD2MeasuredLP_10cm(2,:);
LPout.std(3,1) = WD2MeasuredLP_15cm(2,:);
LPout.std(4,1:3) = WD2MeasuredLP_20cm(2,:);
LPout.std(5,1) = WD2MeasuredLP_25cm(2,:);
LPout.std(6,1:3) = WD2MeasuredLP_30cm(2,:);

% Plot output laser power as a function of WD (for each LP setting separately)
figure('Position',[ 50 50 500 400]);
hold on
plot(wd,LPout.mean(:,1)./LPout.mean(2,1),'-o')
plot([10 20, 30],LPout.mean([2,4,6],2)./LPout.mean(2,2),'-o')
plot([10 20, 30],LPout.mean([2,4,6],3)./LPout.mean(2,3),'-o')
xlabel('Working distance / cm ','FontSize',18)
ylabel('Laser power ratio rel. to 10 cm','FontSize',18)
box off; grid on
l=legend('450 mW','400 mW', '300 mW'); 
title(l, 'Laser power', 'FontSize',14)
ylim([0.97 1.01])

% At 10 cm, LP setting vs LP measured
figure('Position',[ 50 50 500 400]);
hold on
plot(lp_out,LPout.mean(2,:),'-o')
xlabel('Laser power setting / mW','FontSize',18)
ylabel('Measured laser power / mW','FontSize',18)
box off; grid on


%% EXPLORE REFERENCE VALUES
% -------------------------------------------------------------------------

% Reduce the subset of reference values to consider:
ReferencesReduced = selectcol(References, [1,3,4,6 7:9,23]);
saisir_explore_reference_data(ReferencesReduced,1,1:3) 

% Removing four outliers wrt 18:1 variation:
ReferencesReduced2 = deleterow(ReferencesReduced, [1,2,6,10]);
saisir_explore_reference_data(ReferencesReduced2,1,1:3) 


%% PREPROCESSING - PART I
% -------------------------------------------------------------------------

% Reference standard 
[X_cyclo,~] = select_from_identifier(X,1,'C');

% Background signals (10 s exposure)
[X_bg,~] = select_from_identifier(Xbg,1,'Steel_WD10cm_Exp14x40000ms');

% Main samples
[X,~] = select_from_identifier(X,1,'M');
[Xmeta,~] = select_from_identifier(Xmeta,1,'M');
[X,~] = select_from_identifier(X,16,'1X40s'); 
[Xmeta,~] = select_from_identifier(Xmeta,16,'1X40s');

% Exclude spectrum end regions
[~,i1] = min(abs(str2num(X.v)-550));  
[~,i2] = min(abs(str2num(X.v)-2400));
X = selectcol(X,i1:i2);
X_bg = selectcol(X_bg,i1:i2); 
Xsupl = selectcol(Xsupl,i1:i2);

% Remove spectra of samples without reference analyses
remove_names = { 'M06';'M10';'M11';'M13';'M14';'M17';'M19';'M20';'M26';
                 'M30';'M31';'M34';'M36';'M39';'M40';'M41'};

for i = 1:length(remove_names)
    X = delete_from_identifier(X,1,remove_names{i,:});
end


%% PLOT RAW SPECTRA 
% -------------------------------------------------------------------------

plot_Raman(str2num(X.v), X.d);


%% SPIKE REMOVAL 
%  ------------------------------------------------------------------------

th = 13; % threshold for spike detection % originally 13, 12 ok.

[X, ~] = spikefix_whitaker_multi(X,2,1,th,1,'ignoreWN',[550 590; 1540 1565; 2315 2350]); % Ignore bands that would otherwise be wrongly detected as spikes due to their naturally steep bands.


% Remove recurring spikes (not cosmic rays, likely detector flaw)
X = fix_recspikes(X,[1201 1230; 1477 1480; 2020 2025; 2096 2100; 2036 2042;...
                    2058 2061; 2271 2274; 2380 2383; 1993 1999; 2162 2172;...
                    1836 1848; 1396 1405; 2373 2376]);

% Supplemenatry data
th = 13; % threshold for spike detection

[Xsupl, ~] = spikefix_whitaker_multi(Xsupl,2,1,th,1); 


% Background spectrum, ensure correspondence in wn between X and Xbg 
th = 50;

[X_bg, ~] = spikefix_whitaker_multi(X_bg,2,1,th,1); 



% Remove recurring spikes (not cosmic rays, likely detector flaw)
X_bg = fix_recspikes(X_bg,[1201 1230; 1477 1480; 2020 2025; 2096 2100; 2036 2042;...
                    2058 2061; 2271 2274; 2380 2383; 1993 1999; 2162 2172;...
                    1836 1848; 1396 1405; 2373 2376]);


%% PLOT SPIKE FREE SPECTRA 
% -------------------------------------------------------------------------

plot_Raman(str2num(X.v), X.d);



%% SMOOTHING SPECTRA 
% Savitzky-Golay
% -------------------------------------------------------------------------
wd = 5; % window size
polorder = 2; % polynomial order
derorder =  0; % derivative order 0 = smoothing

X_smooth = X;
for i = 1
    X_smooth = saisir_derivative(X_smooth,polorder,wd,derorder);% Savitsky-Golay smoothing
    nvar = length(X_smooth.v);
    X_smooth = selectcol(X_smooth,5:(nvar-4));% Remove edge effects (the edge points on each side)
end

% Control plot
plot_Raman(str2num(X.v), X.d(1:3,:));
hold on; 
plot(str2num(X_smooth.v),X_smooth.d(1:3,:),'r');
title('Smoothed')


X = X_smooth;

% Background spectrum
X_bg_smooth = saisir_derivative(X_bg,polorder,5,derorder);% Savitsky-Golay smoothing, 2nd degree polynomial, wd size 9.
nvar = length(X_bg_smooth.v);
X_bg_smooth = selectcol(X_bg_smooth,5:(nvar-4));% Remove edge effects (the edge points on each side

% Control plot
plot_Raman(str2num(X_bg.v), X_bg.d);
hold on;
plot(str2num(X_bg_smooth.v),X_bg_smooth.d,'r');
title('Smoothed')

X_bg = X_bg_smooth;

% Supplementary
Xsupl = saisir_derivative(Xsupl,polorder,wd,derorder);% Savitsky-Golay smoothing, 2nd degree polynomial, wd size 9.
nvar = length(Xsupl.v);
Xsupl = selectcol(Xsupl,5:(nvar-4));% Remove edge effects (the edge points on each side

% % Control plot
ph1 = plot_Raman(str2num(Xsupl.v), Xsupl.d);title('Smoothed')


%% GATHER IN SUBSETS
% -------------------------------------------------------------------------

% Input
X_region_subsets = {X};    
Xmeta_region_subsets = {Xmeta};

% Output, regions by subset types
X_subsets = {};
Xmeta_subsets = {};

n_subsets = {};

for i = 1:size(X_region_subsets,2)

    X = X_region_subsets{i};
    M = Xmeta_region_subsets{i};

    % Separate by working distance
    [X_WD5, ~] = select_from_identifier(X,11,'05');
    [X_WD10, ~] = select_from_identifier(X,11,'10'); 
    [X_WD15, ~] = select_from_identifier(X,11,'15');
    [X_WD20, ~] = select_from_identifier(X,11,'20'); 
    [X_WD25, ~] = select_from_identifier(X,11,'25'); 
    [X_WD30, ~] = select_from_identifier(X,11,'30'); 
   
    
    % Separate by laser power output
    [X_LP200, ~] = select_from_identifier(X,5,'200');
    [X_LP300, ~] = select_from_identifier(X,5,'300'); 
    [X_LP400, ~] = select_from_identifier(X,5,'400');
    [X_LP450, ~] = select_from_identifier(X,5,'450');

    % Meta data -----------------------------------------------------------

    % Separate by working distance
    [M_WD5, ~] = select_from_identifier(M,11,'05');
    [M_WD10, ~] = select_from_identifier(M,11,'10'); 
    [M_WD15, ~] = select_from_identifier(M,11,'15');
    [M_WD20, ~] = select_from_identifier(M,11,'20'); 
    [M_WD25, ~] = select_from_identifier(M,11,'25'); 
    [M_WD30, ~] = select_from_identifier(M,11,'30'); 
    
    % Separate by laser power output
    [M_LP200, ~] = select_from_identifier(M,5,'200');
    [M_LP300, ~] = select_from_identifier(M,5,'300'); 
    [M_LP400, ~] = select_from_identifier(M,5,'400');
    [M_LP450, ~] = select_from_identifier(M,5,'450');


    % Gather all data subsets -------------------------------------------------
    nsets = 11;
    X_subsets(end+1:end+nsets) = {X_WD5, X_WD10, X_WD15, X_WD20,X_WD25,X_WD30,X_LP200,X_LP300,X_LP400,X_LP450, X};
    Xmeta_subsets(end+1:end+nsets) = {M_WD5, M_WD10, M_WD15, M_WD20,M_WD25,M_WD30,M_LP200,M_LP300,M_LP400,M_LP450, M};
    n_subsets(end+1 : end+nsets , 1) = {'WD5';'WD10';'WD15';'WD20';'WD25';'WD30';'LP200';'LP300';'LP400';'LP450';'ALL' };

end

%% CONNECT REFERENCE DATA WITH RAMAN SPECTRA
% -------------------------------------------------------------------------

ref_idpos = 1:3; % string position in reference id tags
x_idpos = 1:3; %string position in spectral/data blocks 

Y_subsets = connect2ref(X_subsets, References, x_idpos, ref_idpos);


%% PREPROCESSING - PART II - BASELINE CORRECTION (ALS) and SNV 
% -------------------------------------------------------------------------

X_prep_alssnv_subsets = {};
p = 0.001;
lambda = 5;

for i = 1:11
    Subset = X_subsets{i};
    [X_corr,baseline,wgts] = saisir_als(Subset,lambda, p); % correct baseline 5.5, 0.01

    X_corr = selectwn(X_corr,785:1725); % Remove regions with the most apparent peaks in background from the spectra, otherwise SNV will be influenced by background instead of sample signals
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD

    [Subset_prep] = saisir_snv(X_corr); % SNV correction
    
    X_prep_alssnv_subsets{i} = Subset_prep;

end

plot_Raman(str2num(X_prep_alssnv_subsets{11}.v), X_prep_alssnv_subsets{11}.d);

%% PREPROCESSING - PART II - BASELINE CORRECTION ONLY W/ALS 
% -------------------------------------------------------------------------

X_prep_als_subsets = {};
lambda = 5 ; 
p = 0.001;

for i = 1:11
    Subset = X_subsets{i};
    [Subset_prep,baseline,wgts] = saisir_als(Subset,lambda,p); % correct baseline
    %X_corr = selectwn(Subset_prep,785:1782);
    X_prep_als_subsets{i} = Subset_prep;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

% Supplementary
lambda = 5 ; 
p = 0.001;

X_supl_subsets = {Xsupl};
X_prep_als_supl = {};
for i = 1
    Subset = X_supl_subsets{i};
    %Subset = selectwn(Subset,500:1850);
    [Subset_prep,baseline,wgts] = saisir_als(Subset,lambda,p); % correct baseline
    %X_corr = selectwn(Subset_prep,785:1782);
    X_prep_als_supl{i} = Subset_prep;
    
    % Control plot
    plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

% Background spectrum
lambda = 4 ; 
p = 0.001;

X_bg_subsets = {X_bg};
X_prep_als_bg = {};
for i = 1
    Subset = X_bg_subsets{i};
    %Subset = selectwn(Subset,500:1850);
    Subset = saisir_replace_by_line(Subset,[1740 1755]); % The detector dip issue
    [Subset_prep,baseline,wgts] = saisir_als(Subset,lambda,p); % correct baseline
    %X_corr = selectwn(Subset_prep,785:1782);
    X_prep_als_bg{i} = Subset_prep;
    
    % Control plot
    plot_Raman(str2num(Subset_prep.v), Subset_prep.d); hold on
    plot(str2num(Subset.v),Subset.d)
    plot(str2num(Subset.v),baseline)
end

%% PLOTTING BACKGROUND SPECTRUM AFTER BASELINE CORRECTION
% -------------------------------------------------------------------------
X_bg_bslc = X_prep_als_bg{1};
X_bg_bslc = selectwn(X_bg_bslc,590:2500);

f = figure;
f.PaperUnits = 'centimeters';
set(f,'PaperPosition',[0 0 9.2 5])

% Create 2-parted background spectrum
Xbg = X_prep_als_bg{1};
Xbg = selectwn(Xbg,590:2500);
Xbg.i = 'Background spec ';
Xbg_optics = Xbg;
Xbg_optics = saisir_replace_by_line(Xbg_optics,[1530 1570; 2300 2350]);
Xbg_optics. i = 'Background optic';
Xbg_air = Xbg;
Xbg_air.d = Xbg_air.d - Xbg_optics.d;
Xbg_air. i = 'Background air  ';

ph2 = plot(str2num(Xbg_optics.v), Xbg_optics.d,'Color',plot_colors(1,:),'LineWidth',1.5); 
box off
grid on
ylabel('Raman Intensity / Arbitr. Units','FontSize',12,'Units','points')
hold on

plot(str2num(Xbg_air.v), Xbg_air.d,'Color',plot_colors(2,:),'LineWidth',1.5)
box off
grid on
xlim([570, max(str2num(X_bg_bslc.v))])
ylim([-500, max(X_bg_bslc.d)])

xline(750,'k','S');
xline(2329.2,'k','N');
xline(1555,'k','O');
xline([630;1074;1366],'k', {'630';'1074';'1366'});

xlabel('Wavenumber / cm^{-1}','FontSize',12,'Units','points');
set(gcf,'Color',[1 1 1])



%% PREPROCESSING - PART II - BASELINE CORRECTION ONLY - REDUCED REG W/ALS 
% -------------------------------------------------------------------------

X_prep_als_subsets_reducedreg_benchmark = {};
lambda = 5 ; 
p = 0.001;

for i = 1:11
    Subset = X_subsets{i};
    %Subset = selectwn(Subset,500:1850);
    [Subset_prep,baseline,wgts] = saisir_als(Subset,lambda,p); % correct baseline
    X_corr = selectwn(Subset_prep,785:1725);
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD
    X_prep_als_subsets_reducedreg_benchmark{i} = X_corr;
    
     % Control plot
     %plot_Raman(str2num(X_corr.v), X_corr.d);

end

% Supplementary
lambda = 5 ; 
p = 0.001;

X_supl_subsets = {Xsupl};
X_prep_als_reducedreg_supl = {};
for i = 1
    Subset = X_supl_subsets{i};
    %Subset = selectwn(Subset,500:1850);
    [Subset_prep,baseline,wgts] = saisir_als(Subset,lambda,p); % correct baseline
    X_corr = selectwn(Subset_prep,767:1530);
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD
    X_prep_als_reducedreg_supl{i} = X_corr;
    
    % Control plot
    %plot_Raman(str2num(X_corr.v), X_corr.d);

end



%% EXPLORE SPECTRA - AsLS ONLY
% -------------------------------------------------------------------------

% Laser power 450 mW
i = 10;
plot_from_identifier(X_prep_als_subsets{i},11:12);

% Check average spectra:
XavgWDLP = average_from_identifier(X_prep_als_subsets{i},5:14) ;
plot_from_identifier(XavgWDLP,7:8);
xlabel('Wavenumber / cm^{-1}','FontSize',18)
ylabel('Relative intensity','FontSize',18)

% Working distance 10 cm 
i = 2;
XavgWDLP = average_from_identifier(X_prep_als_subsets{i},5:14) ;
plot_from_identifier(XavgWDLP,1:3);
xlabel('Wavenumber / cm^{-1}','FontSize',18)
ylabel('Relative intensity','FontSize',18)


%% PREPROCESSING - PART II - BASELINE CORRECTION (AsLS) and MSC 
% -------------------------------------------------------------------------

X_prep_alsmsc_subsets = {};
lambda = 5;
p = 0.001;
for i = 11
    Subset = X_subsets{i};
    %Subset = selectwn(Subset,500:1850);
    [X_corr,baseline,wgts] = saisir_als(Subset,lambda, p); % correct baseline 5.5, 0.01

    emsc_mod = make_emsc_modfunc(X_corr, 3); % Option 7: EMSC w/up to 6th order polynomial, 3: MSC only (multiplicative + constant)
    
    % Update ref spec to optimal measurement setting, to avoid too much
    % working distance variation.    
    XsaisirOptimal = select_from_identifier(X_corr,5,'450mW_10cm');
    XsaisirOptimalAvg = average_from_identifier(XsaisirOptimal,5:14);
    emsc_mod.Model(:,emsc_mod.NModelFunc) = XsaisirOptimalAvg.d;

    [Subset_prep,a,b] = cal_emsc(X_corr, emsc_mod); % Calculate EMSC parameters

    X_corr = selectwn(Subset_prep,785:1725); % Remove regions with the most apparent peaks in background from the spectra, otherwise SNV will be influenced by background instead of sample signals
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD

    X_prep_alsmsc_subsets{i} = X_corr;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

plot_Raman(str2num(X_prep_alsmsc_subsets{11}.v), X_prep_alsmsc_subsets{11}.d);



%% PREPROCESSING - PART II - MSC FOR MULT. EFFECT + (2-part) BACKGROUND SPEC
% -------------------------------------------------------------------------

X_prep_alsmsc_2pbg_subsets = {};

% Construct 2-parted background spectrum
Xbg = X_prep_als_bg{1};
Xbg.i = 'Background spec ';

% Plot original background spectrum
plot_Raman(str2num(Xbg.v),Xbg.d); 

Xbg_optics = Xbg;
Xbg_optics = saisir_replace_by_line(Xbg_optics,[1530 1570; 2300 2350]);
Xbg_optics. i = 'Background optic';

Xbg_air = Xbg;
Xbg_air.d = Xbg_air.d - Xbg_optics.d;
Xbg_air. i = 'Background air  ';

% Plot separated background spectrum
plot_Raman(str2num(Xbg_air.v),Xbg_air.d); hold on
plot(str2num(Xbg_optics.v),Xbg_optics.d)
legend('Air background spectrum (10 cm)','Instrumental background spectrum')

for i = 11
    Subset = X_prep_als_subsets{i};
    [X_corr,emsc_mod, Parameters] = msc4RamBadBg2part(Subset,Xbg, Xbg_optics,Xbg_air);  
    X_corr = selectwn(X_corr,785:1725); % Remove regions with the most apparent peaks in background from the spectra, otherwise SNV will be influenced by background instead of sample signals
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD

    X_prep_alsmsc_2pbg_subsets{i} = X_corr;

end

plot_Raman(str2num(X_prep_alsmsc_2pbg_subsets{11}.v), X_prep_alsmsc_2pbg_subsets{11}.d);
color_by(Y_subsets{11}.d(:,7))



%% EXPLORE SPECTRA - ALS + SNV
% -------------------------------------------------------------------------

% Laser power 450 mW
i = 10;
plot_from_identifier(X_prep_alssnv_subsets{i},11:12);

% Check average spectra:
XavgWDLP = average_from_identifier(X_prep_alssnv_subsets{i},5:14) ;
plot_from_identifier(XavgWDLP,7:8);
xlabel('Wavenumber / cm^{-1}','FontSize',18)
ylabel('Relative intensity','FontSize',18)

% Working distance 10 cm 
i = 2;
XavgWDLP = average_from_identifier(X_prep_alssnv_subsets{i},5:14) ;
plot_from_identifier(XavgWDLP,1:3);
xlabel('Wavenumber / cm^{-1}','FontSize',18)
ylabel('Relative intensity','FontSize',18)




%% SUPPLEMENTARY - SAMPLE SIGNAL EFFFECT OF EXPOSURE TIME
% WD constant 10 cm, salmon
% -------------------------------------------------------------------------

X_expseries = X_prep_als_supl{1};

AccTime = str2num(X_expseries.i(:,9:14));
[~, S] = saisir_getSignalIntensity(X_expseries,1656, 'Mode','derivative','peakWidth',40);
    
figure('Position',[50 50 500 400])
plot(AccTime, S,'-o')
xlabel('Exposure time / ms','FontSize',18)
ylabel('Sample signal / 1656 cm^{-1}','FontSize',18)
box off;grid on


% 750
X_expseries = X_prep_als_supl{1};
[~, S] = saisir_getSignalIntensity(X_expseries,750, 'Mode','derivative','peakWidth',30);

figure('Position',[50 50 500 400])
plot(AccTime, S,'-o')
xlabel('Exposure time / ms','FontSize',18)
ylabel('Sapphire signal / 750 cm^{-1}','FontSize',18)
box off;grid on


%% PREPROCESSING - PART II - ALS AND NORMALIZATION BY PEAK AT 750 CM^-1
% -------------------------------------------------------------------------

X_prep_alsnormpeakSapph_subsets = {};
peak = 750;
lambda = 5 ; 
p = 0.001;

for i = 1:11
    Subset = X_subsets{i};
    [X_corr,baseline,wgts] = saisir_als(Subset, lambda, p); % correct baseline

    [Subset_prep] = saisir_normsapph(X_corr, peak,'Mode','derivative'); % normalization by safire peak // saisir_normpeak
    X_prep_alsnormpeakSapph_subsets{i} = Subset_prep;

    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

plot_Raman(str2num(X_prep_alsnormpeakSapph_subsets{2}.v), X_prep_alsnormpeakSapph_subsets{2}.d);


X_prep_alsnormpeakSapph_supl = {};
peak = 750;
lambda = 5 ; 
p = 0.001;

for i = 1
    Subset = X_supl_subsets{i};
    [X_corr,baseline,wgts] = saisir_als(Subset, lambda, p); % correct baseline

    %X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD

    [Subset_prep] = saisir_normsapph(X_corr, peak,'Mode','derivative'); % normalization by safire peak // saisir_normpeak
    %X_corr = selectwn(Subset_prep,785:1782);

    X_prep_alsnormpeakSapph_supl{i} = Subset_prep;

    % % Control plot
    % plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end


%% PREPROCESSING - PART II - ALS AND NORMALIZATION BY PEAK AT 750 CM^-1
% -------------------------------------------------------------------------

X_prep_alsnormpeakSapph_subsets_reducedreg = {};
peak = 750;
lambda = 5 ; 
p = 0.001;

for i = 1:11
    Subset = X_subsets{i};
    [X_corr,baseline,wgts] = saisir_als(Subset, lambda, p); % correct baseline

    [X_corr,pv] = saisir_normsapph(X_corr, peak,'Mode','derivative'); % normalization by safire peak // saisir_normpeak
    X_corr = selectwn(X_corr,785:1725); 
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD
    
    X_prep_alsnormpeakSapph_subsets_reducedreg{i} = X_corr;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

plot_Raman(str2num(X_prep_alsnormpeakSapph_subsets_reducedreg{11}.v), X_prep_alsnormpeakSapph_subsets_reducedreg{11}.d);

%% EXPLORE SPECTRA - ALS + SAPPHIRE NORMALIZATION
% -------------------------------------------------------------------------

% Laser power 450 mW
i = 10;
plot_from_identifier(X_prep_alsnormpeakSapph_subsets_reducedreg{i},11:12);

% Check average spectra:
XavgWDLP = average_from_identifier(X_prep_alsnormpeakSapph_subsets_reducedreg{i},5:14) ;
plot_from_identifier(XavgWDLP,7:8);
xlabel('Wavenumber / cm^{-1}','FontSize',18)
ylabel('Intensity','FontSize',18)

% Working distance 10 cm 
i = 2;
XavgWDLP = average_from_identifier(X_prep_alsnormpeakSapph_subsets_reducedreg{i},5:14) ;
plot_from_identifier(XavgWDLP,1:3);
xlabel('Wavenumber / cm^{-1}','FontSize',18)
ylabel('Intensity','FontSize',18)

%% CHARACTERIZE NITROGEN, SAPPHIRE AND SAMPLE SIGNAL RELATION TO WD / LASER POWER 
% -------------------------------------------------------------------------

% Nitrogen ----------------------------------------------------------------

% WD

X_all = X_prep_als_subsets{11};
X_all = average_from_identifier(X_all,1:20); % First, average the replicates
plot_N2VsWD(X_all,1:3, 5:7, 11:12)


% Sapphire ----------------------------------------------------------------
% WD
X_all = X_prep_als_subsets{11};
X_all = average_from_identifier(X_all,1:20); % First, average the replicates
plot_SapphVsLP(X_all, 1:3, 5:7, 11:12)


% Sample signal ----------------------------------------------------------------
% WD
X_all = X_prep_als_subsets{11};
X_all = average_from_identifier(X_all,1:20); % First, average the replicates
plot_SignalSampVsWD(X_all,1:3, 5:7, 11:12)


%% CORRECTION FACTORS
% -------------------------------------------------------------------------

% N2 TO WD CORRECTION FACTORS  --------------------------------------------

X_all = X_prep_alsnormpeakSapph_subsets{11}; 
X_3samp = selectrow(X_all, 1:123); %  Take all lp and wd variations into account, 3 first samples (the ones with most extreme chemical variations)
X_3samp = select_from_identifier(X_3samp,5,'450');
X3samp_wdavg = average_from_identifier(X_3samp,11:12); 

[~, N2int] = saisir_getSignalIntensity(X3samp_wdavg,2329, 'Mode','derivative');

WD_cf_table = [];
WD_cf_table(:,1) = N2int;
WD_cf_table(:,2) = str2num(X3samp_wdavg.i);


% WD TO SAMPLE SIGNAL CORRECTION FACTORS ----------------------------------

% Signal to use:
rs_signal = 1657;
[~, SampleInt] = saisir_getSignalIntensity(X3samp_wdavg,rs_signal, 'Mode','derivative','peakWidth',40);
WD_cf_table(:,3) = SampleInt(2)./SampleInt(:) ; % Sample signal intensity relative to optimal WD


% Make interpolated table that can handle interpolate values of working 
% distances, i.e. N2 signals and correction factors (N2-> WD-> CF) --------
clear WD_cf_table_interp
clear WD_cf_table_final
WD_cf_table_interp = interp1(WD_cf_table(:,1),WD_cf_table(:,2:3),0.2:0.001:1.4,'linear','extrap');

WD_cf_table_final(:,1) = 0.2:0.001:1.4;
WD_cf_table_final(:,2:3) = WD_cf_table_interp;

% N2-> WD
figure('Position',[ 50 50 500 400])
plot(WD_cf_table_final(:,1), WD_cf_table_final(:,2))
ylabel('WD / cm','FontSize',18);
xlabel('N_{2}','FontSize',18);
grid on;box off;

% WD-> S
figure('Position',[ 50 50 500 400])
plot(WD_cf_table_final(:,2), WD_cf_table_final(:,3))
xlabel('WD / cm','FontSize',18);
ylabel('Correction factor','FontSize',18);
grid on;box off;


WD_cf_table = WD_cf_table_final;
save('WD_cf_table',"WD_cf_table")


%% INTENSITY CORRECTION - BASED ON NITROGEN BAND 
% -------------------------------------------------------------------------

X_prep_alsnormpeakSapphN2WDCF_subsets = {};
peak = 748.5;
lambda = 5 ; 
p = 0.001;

for i = 1:11
    Subset = X_subsets{i};
    [X_corr,baseline,wgts] = saisir_als(Subset, lambda, p); % correct baseline
    [Subset_prep] = saisir_normsapph(X_corr, peak,'Mode', 'derivative'); % normalization by safire peak
    
    Subset_prep = WD_CF_N2(Subset_prep);   
    X_corr = selectwn(Subset_prep,785:1725);
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD
   
    X_prep_alsnormpeakSapphN2WDCF_subsets{i} = X_corr;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

i = 11;
plot_Raman(str2num(X_prep_alsnormpeakSapphN2WDCF_subsets{i}.v),X_prep_alsnormpeakSapphN2WDCF_subsets{i}.d);
cbh = color_by(Y_subsets{i}.d(:,1));
title(cbh,'%Fat')

plot_Raman(str2num(X_prep_alsnormpeakSapph_subsets{i}.v),X_prep_alsnormpeakSapph_subsets{i}.d);
cbh = color_by(Y_subsets{i}.d(:,1));
title(cbh,'%Fat')

%% PLOTTING ONE SAMPLE SPECTRUM IN DIFFERENT LP/ WD VARIATIONS
% -------------------------------------------------------------------------

X = X_prep_als_subsets_reducedreg_benchmark{11}; 
Xsamp = select_from_identifier(X,1,'M01');
Xsamp = average_from_identifier(Xsamp,1:14);
XsampWDvar = select_from_identifier(Xsamp,5,'450');
XsampLPvar = select_from_identifier(Xsamp,11,'10');

X = X_prep_alsnormpeakSapphN2WDCF_subsets{11}; 
Xsampcorr = select_from_identifier(X,1,'M01');
Xsampcorr = average_from_identifier(Xsampcorr,1:14);
XsampcorrWDvar = select_from_identifier(Xsampcorr,5,'450');
XsampcorrLPvar = select_from_identifier(Xsampcorr,11,'10');

f = figure;
f.PaperUnits = 'centimeters';
set(f,'PaperPosition',[0 0 23 7])

tiledlayout(2,2,'TileSpacing','Compact')

nexttile
plot(str2num(XsampWDvar.v), XsampWDvar.d);
wd = str2num(XsampWDvar.i(:,11:12));
cbh = color_by(wd);
title(cbh,'WD','FontSize',10,'Units','points')
grid on; box off
text(0.02,0.80,'LP = 450 mW','Units','normalized','FontSize',10)
xlim([min(str2num(XsampWDvar.v)) max(str2num(XsampWDvar.v))])

nexttile
plot(str2num(XsampcorrWDvar.v), XsampcorrWDvar.d);
wd = str2num(XsampcorrWDvar.i(:,11:12));
cbh = color_by(wd);
title(cbh,'WD','FontSize',10,'Units','points')
grid on; box off
text(0.02,0.80,'LP = 450 mW','Units','normalized','FontSize',10)
xlim([min(str2num(XsampWDvar.v)) max(str2num(XsampWDvar.v))])

nexttile
plot(str2num(XsampLPvar.v), XsampLPvar.d);
lp = str2num(XsampLPvar.i(:,5:7));
cbh2 = color_by(lp);
title(cbh2,'LP','FontSize',10,'Units','points')
grid on; box off
text(0.02,0.80,'WD = 10 cm','Units','normalized','FontSize',10)
xlim([min(str2num(XsampWDvar.v)) max(str2num(XsampWDvar.v))])

xlabel('Wavenumber / cm^{-1}','FontSize',12,'Units','points')
ylabel('Raman Intensity / Arbitr. Units','FontSize',12,'Units','points')

nexttile
plot(str2num(XsampcorrLPvar.v), XsampcorrLPvar.d);
lp = str2num(XsampcorrLPvar.i(:,5:7));
cbh2 = color_by(lp);
title(cbh2,'LP','FontSize',10,'Units','points')
grid on; box off
text(0.02,0.80,'WD = 10 cm','Units','normalized','FontSize',10)
xlim([min(str2num(XsampWDvar.v)) max(str2num(XsampWDvar.v))])
xlabel('Wavenumber / cm^{-1}','FontSize',12,'Units','points')


%% INTENSITY CORRECTION - BASED ON KNOWN WORKING DISTANCE 
% -------------------------------------------------------------------------
% Representing a hardware update with laser distance measurer.

% Here, we should rather start with the mapping function based on WD to
% signal S

X_prep_alsNormsapph_WDCF_subsets_reducedreg = {};
peak = 750;
lambda = 5 ; 
p = 0.001;

for i = 1:11
    Subset = X_subsets{i};
    [X_corr,baseline,wgts] = saisir_als(Subset, lambda, p); % correct baseline
    [Subset_prep] = saisir_normsapph(X_corr, peak,'Mode', 'derivative'); % normalization by safire peak
    
    wd_known = str2num(Subset_prep.i(:,11:12)) ;
    Subset_prep = WD_CF(Subset_prep,wd_known);
    X_corr = selectwn(Subset_prep,785:1725);
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD
    X_prep_alsNormsapph_WDCF_subsets_reducedreg{i} = X_corr;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

plot_Raman(str2num(Subset_prep.v), Subset_prep.d);


i = 11;
plot_Raman(str2num(X_prep_alsNormsapph_WDCF_subsets_reducedreg{i}.v),X_prep_alsNormsapph_WDCF_subsets_reducedreg{i}.d);
cbh = color_by(Y_subsets{i}.d(:,1));
title(cbh,'%Fat')


%% PREPROCESSING - PART II -  SNV + 1ST DERIVATIVE
% -------------------------------------------------------------------------
% Additional test to reduce any remaining variations in baseline

X_prep_alssnvDeriv1_subsets_reducedreg = {};
peak = 750;
lambda = 5 ; 
p = 0.001;

for i = 1:11

    Subset = X_subsets{i};
    [X_corr,baseline,wgts] = saisir_als(Subset, lambda, p); % correct baseline
    
    X_corr = selectwn(X_corr,785:1782);
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD

    X_corr =  saisir_snv(X_corr);
    [Subset_prep] = saisir_derivative(X_corr,2,9,1); % normalization by sapphire peak
    
    X_prep_alssnvDeriv1_subsets_reducedreg{i} = Subset_prep;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

i = 11;%2; %10;
plot_Raman(str2num(X_prep_alssnvDeriv1_subsets_reducedreg{i}.v),X_prep_alssnvDeriv1_subsets_reducedreg{i}.d);
cbh = color_by(Y_subsets{i}.d(:,7));
title(cbh,'18:1 (% of fat)')


%% PREPROCESSING - PART II - EMSC + 1ST DERIVATIVE 
% -------------------------------------------------------------------------

X_prep_alsemscDeriv1_subsets_reducedreg = {};

% Construct 2-parted background spectrum
Xbg = X_prep_als_bg{1};
Xbg.i = 'Background spec ';

% Plot original background spectrum
%plot_Raman(str2num(Xbg.v),Xbg.d); 

Xbg_optics = Xbg;
Xbg_optics = saisir_replace_by_line(Xbg_optics,[1530 1570; 2300 2350]);
Xbg_optics. i = 'Background optic';

Xbg_air = Xbg;
Xbg_air.d = Xbg_air.d - Xbg_optics.d;
Xbg_air. i = 'Background air  ';

% Plot separated background spectrum
%plot_Raman(str2num(Xbg_air.v),Xbg_air.d); hold on
%plot(str2num(Xbg_optics.v),Xbg_optics.d)
%legend('Air background spectrum (10 cm)','Instrumental background spectrum')

for i = 11
    Subset = X_prep_als_subsets{i};
    [X_corr,emsc_mod, Parameters] = msc4RamBadBg2part(Subset,Xbg, Xbg_optics,Xbg_air);  
    [Subset_prep] = saisir_derivative(X_corr,2,9,1); % normalization by sapphire peak
    X_corr = selectwn(Subset_prep,785:1725); % Remove regions with the most apparent peaks in background from the spectra, otherwise SNV will be influenced by background instead of sample signals
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD

    X_prep_alsemscDeriv1_subsets_reducedreg{i} = X_corr;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end

plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

i = 11;%2; %10;
plot_Raman(str2num(X_prep_alsemscDeriv1_subsets_reducedreg{i}.v),X_prep_alsemscDeriv1_subsets_reducedreg{i}.d);
cbh = color_by(Y_subsets{i}.d(:,7));
title(cbh,'18:1 (% of fat)')

%% PREPROCESSING - PART II - N2-CF + 1ST DERIVATIVE 
% -------------------------------------------------------------------------

X_prep_alsN2WDCFDeriv1_subsets_reducedreg = {};

for i = 11
    Subset = X_prep_alsnormpeakSapphN2WDCF_subsets{i};
    [Subset_prep] = saisir_derivative(Subset,2,9,1); % normalization by sapphire peak
    X_corr = selectwn(Subset_prep,785:1725); % Remove regions with the most apparent peaks in background from the spectra, otherwise SNV will be influenced by background instead of sample signals
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD

    X_prep_alsN2WDCFDeriv1_subsets_reducedreg{i} = X_corr;
    
    % Control plot
    %plot_Raman(str2num(Subset_prep.v), Subset_prep.d);

end


i = 11;
plot_Raman(str2num(X_prep_alsN2WDCFDeriv1_subsets_reducedreg{i}.v),X_prep_alsN2WDCFDeriv1_subsets_reducedreg{i}.d);
cbh = color_by(Y_subsets{i}.d(:,1));
title(cbh,'% Fat')


%% REMOVE MEASUREMENTS WITHOUT REFERENCES BEFORE MODELLING
% -------------------------------------------------------------------------

% Remove spectra without reference values
for i = 1:length(Y_subsets)
    Y = Y_subsets{i};
    X = X_subsets{i};

   nanrows = find(all(isnan(Y.d),2)); 
   Y_subsets{i} = deleterow(Y, nanrows);
   X_subsets{i} = deleterow(X, nanrows);

end


%% MODEL TRANSFERABILITY ACROSS LP AND WD VARIATIONS 

%% TOTAL FAT ---------------------------------------------------------------

% Preserving intensity information - available prep versions
%X = X_prep_als_subsets_reducedreg_benchmark{11};
%X = X_prep_alsnormpeakSapph_subsets_reducedreg{11};
%X = X_prep_alsnormpeakSapphN2WDCF_subsets{11};
%X = X_prep_alsNormsapph_WDCF_subsets_reducedreg{11};
%X = X_prep_alsnormpeakSapphN2WDCF_bgsub_subsets{11};
%X = X_prep_alsN2WDCFDeriv1_subsets_reducedreg{11};


% Discarding intensity information - available prep versions
%X = X_prep_alssnv_subsets{11};
%X = X_prep_alsmsc_subsets{11};
%X = X_prep_alsmsc_2pbg_subsets{11};
%X = X_prep_alssnvDeriv1_subsets_reducedreg{11}; 
X = X_prep_alsemscDeriv1_subsets_reducedreg{11};

Y = Y_subsets{11};

% X = deletewn(X,1320:1400);
% 
% X = deletewn(X,1040:1090);

% Average the three replicates
X = average_from_identifier(X,1:14);
Y = average_from_identifier(Y,1:14);

% Remove the two outliers for 18:1
remove_names = {'M01';'M02';'M07';'M15'};
for i = 1:length(remove_names)
    X = delete_from_identifier(X,1,remove_names{i});
    Y = delete_from_identifier(Y,1,remove_names{i});
end

% Remove extra measurements (outside scope of measurement design)
X = delete_from_identifier(X,5,'300mW_25cm');
Y = delete_from_identifier(Y,5,'300mW_25cm');
X = delete_from_identifier(X,5,'400mW_15cm');
Y = delete_from_identifier(Y,5,'400mW_15cm');
X = delete_from_identifier(X,5,'400mW_25cm');
Y = delete_from_identifier(Y,5,'400mW_25cm');


% One cal set for optimal conditions, apply on rest
ncomp = 1;
[Regcoeff, Performance, ~] = PLSR_train2multiset_validation_from_identifier(X, Y, 1, 5:14, '450mW_10cm',10,1:14, 'plotLimits',[7 31],'AoptAlg','STATIC','ncomp', ncomp);
%[FIG, Regcoeff, Performance, ~] = PLSR_train2multiset_validation_from_identifier(X, Y, 1, 5:14, '450mW_10cm',10,1:14, 'plotLimits',[5 40]);

% Correlation between measurement settings and slope
r_wd = corrcoef(Performance.slope',str2num(Performance.v(:,9:10)));
r_lp = corrcoef(Performance.slope',str2num(Performance.v(:,3:5)));
disp('Correlation WD-PredSlope:');disp(r_wd)
disp('Correlation LP-PredSlope:');disp(r_lp)

% Correlation between measurement settings and bias errors
r_wd = corrcoef(Performance.bias',str2num(Performance.v(:,9:10)));
r_lp = corrcoef(Performance.bias',str2num(Performance.v(:,3:5)));
disp('Correlation WD-PredBias:');disp(r_wd)
disp('Correlation LP-PredBias:');disp(r_lp)

FIG = plot_regcoef(Regcoeff.v,Regcoeff.d(1,:),0.5, 'findpeaks','yes'); % Reg coeff applied on test sets.
FIG.PaperUnits = 'centimeters';
set(FIG,'PaperPosition',[0 0 9.2 3])

plot_train2multiset_performance(Performance); % v2



%% Plot outlier spectra at 450 mW, 10 cm:
X = X_prep_als_subsets_reducedreg_benchmark{11};
X = select_from_identifier(X,5,'450mW_10cm');
Y = Y_subsets{11};
Y = select_from_identifier(Y,5,'450mW_10cm');


% Remove the two outliers for 18:1
remove_names = {'M01';'M02';'M07';'M15'};
for i = 1:length(remove_names)
    X = delete_from_identifier(X,1,remove_names{i});
    Y = delete_from_identifier(Y,1,remove_names{i});
end

saisir_idplot(X)
set(gcf,'Position',[ 50 50 500 400])
h = color_by(Y.d(:,1));
title(h,'Fat(%)')
xlim([1640 1675])
ylabel('Intensity','FontSize',16)
xlabel('Raman Shift (cm^{-1})', 'FontSize',16)
set(gcf,'Color',[1 1 1])
yline(13000)
yline(11000)
box off
grid on


%% PLOT SPECTRA USED FOR CALIBRATION, DIFFERENT PREP STRATEGIES
% -------------------------------------------------------------------------
X1 = X_prep_als_subsets_reducedreg_benchmark{11};
X2 = X_prep_alsnormpeakSapphN2WDCF_subsets{11};
X3 = X_prep_alsmsc_subsets{11};
X4 = X_prep_alsmsc_2pbg_subsets{11};


Xprepspec = {X1,X2,X3,X4};

f = figure;
f.PaperUnits = 'centimeters';
set(f,'PaperPosition',[0 0 9.5 10]);  

tiledlayout(length(Xprepspec),1,'TileSpacing','Compact');

for j = 1:length(Xprepspec)
    
    X = Xprepspec{j};
    Y = Y_subsets{11};

    % Average the three replicates
    X = average_from_identifier(X,1:14);
    Y = average_from_identifier(Y,1:14);
    
    % Remove the two outliers for 18:1
    remove_names = {'M01';'M02';'M07';'M15'};
    for i = 1:length(remove_names)
        X = delete_from_identifier(X,1,remove_names{i});
        Y = delete_from_identifier(Y,1,remove_names{i});
    end
    
    % Remove extra measurements
    X = delete_from_identifier(X,5,'300mW_25cm');
    Y = delete_from_identifier(Y,5,'300mW_25cm');
    X = delete_from_identifier(X,5,'400mW_15cm');
    Y = delete_from_identifier(Y,5,'400mW_15cm');
    X = delete_from_identifier(X,5,'400mW_25cm');
    Y = delete_from_identifier(Y,5,'400mW_25cm');


    % Plot spectra
    nexttile
    wn = str2num(X.v);
    ph = plot(wn,X.d,'Linewidth',0.3);
    
    if j == 3
     ylabel('Raman Intensity / Arbitr. Units','FontSize',12,'Units','points')
    end

    set(gcf,'Color',[1 1 1])
    box off
    grid on
    xlim([min(wn), max(wn)])
    ylim([min(X.d,[],'all') max(X.d,[],'all')])
    h = color_by(Y.d(:,1));
    title(h,'Fat(%)')

    if j>2
        ax = gca;
        ax.YAxis.Exponent = 4;
    end

end

xlabel('Wavenumber / cm^{-1}','FontSize',12,'Units','points')


%% MODEL TRANSFER ACCROSS LP AND WD VARIATIONS 
% -------------------------------------------------------------------------

% FATTY ACID 18:1 ---------------------------------------------------------

% Preserving intensity information - available preprocessing versions
%X = X_prep_als_subsets_reducedreg_benchmark{11};
%X = X_prep_alsnormpeakSapph_subsets_reducedreg{11};
%X = X_prep_alsnormpeakSapphN2WDCF_subsets{11};
%X = X_prep_alsNormsapph_WDCF_subsets_reducedreg{11};
%X = X_prep_alsnormpeakSapphN2WDCF_bgsub_subsets{11};
%X = X_prep_alsN2WDCFDeriv1_subsets_reducedreg{11};

% Discarding intensity information  - available preprocessing versions
%X = X_prep_alssnv_subsets{11};
%X = X_prep_alsmsc_subsets{11};
%X = X_prep_alsmsc_2pbg_subsets{11};
%X = X_prep_alssnvDeriv1_subsets_reducedreg{11};  
X = X_prep_alsemscDeriv1_subsets_reducedreg{11};

Y = Y_subsets{11};

%X = selectwn(X,1150:1800);

% Average the three replicates
X = average_from_identifier(X,1:14);
Y = average_from_identifier(Y,1:14);

% Remove the two outliers for 18:1
remove_names = {'M01';'M02';'M07';'M15'};
for i = 1:length(remove_names)
    X = delete_from_identifier(X,1,remove_names{i});
    Y = delete_from_identifier(Y,1,remove_names{i});
end

% Remove extra measurements
X = delete_from_identifier(X,5,'300mW_25cm');
Y = delete_from_identifier(Y,5,'300mW_25cm');
X = delete_from_identifier(X,5,'400mW_15cm');
Y = delete_from_identifier(Y,5,'400mW_15cm');
X = delete_from_identifier(X,5,'400mW_25cm');
Y = delete_from_identifier(Y,5,'400mW_25cm');


% One cal set for optimal conditions, apply on rest
ncomp = 4;
[Regcoeff, Performance, Residuals] = PLSR_train2multiset_validation_from_identifier(X, Y, 7, 5:14, '450mW_10cm',10,1:14, 'plotLimits',[37 58],'AoptAlg','STATIC','ncomp', ncomp);
%[FIG, Regcoeff, Performance, Residuals] = PLSR_train2multiset_validation_from_identifier(X, Y, 7, 5:14, '450mW_10cm',10,1:14, 'plotLimits',[35 55]);


%  Correlation between measurement settings and slope
r_wd = corrcoef(Performance.slope',str2num(Performance.v(:,9:10)));
r_lp = corrcoef(Performance.slope',str2num(Performance.v(:,3:5)));
disp('Correlation WD-PredSlope:');disp(r_wd)
disp('Correlation LP-PredSlope:');disp(r_lp)

%  Correlation between measurement settings and bias errors
r_wd = corrcoef(Performance.bias',str2num(Performance.v(:,9:10)));
r_lp = corrcoef(Performance.bias',str2num(Performance.v(:,3:5)));
disp('Correlation WD-PredBias:');disp(r_wd)
disp('Correlation LP-PredBias:');disp(r_lp)


plot_regcoef(Regcoeff.v,Regcoeff.d(1,:),1.5, 'findpeaks','yes'); % Reg coeff applied on test sets.

plot_train2multiset_performance(Performance);


%% THE EFFECT OF BASELINE CORRECTION ON TRANSFER RESULTS - TOTAL FAT
% -------------------------------------------------------------------------
clear Summary
clear X_prep_alsnormpeakSapphWDCF_lambda_subsets

% Test a range of smoothing parameters
lambda_hyperpm = 4:0.2:6; % 5 is what was used originally

X_prep_alsnormpeakSapphWDCF_lambda_subsets = {}; % Storage for prep data set at each lambda
X_prep_N2CF_fullreg_lambda_subsets = {}; % Storage for prep data set at each lambda
Summary.lambdas = lambda_hyperpm;
for j = 1: length(lambda_hyperpm)
    lmd = lambda_hyperpm(j);

    % ALS + SAPPHIRE NORMALIZATION ----------------------------------------
    X_prep_alsnormpeakSapph_subsets = {};
    peak = 750;
    p = 0.001;
    
    for i = 10:11
        Subset = X_subsets{i};
        [X_corr,baseline,wgts] = saisir_als(Subset, lmd, p); % correct baseline
    
        [Subset_prep] = saisir_normsapph(X_corr, peak,'Mode','derivative'); % normalization by safire peak // saisir_normpeak
    
        X_prep_alsnormpeakSapph_subsets{i} = Subset_prep;
    
    end
    % Control plot
    %plot_Raman(str2num(X_corr.v), X_corr.d);

    % ESTABLISH CORRECTION FACTORS  ---------------------------------------

    % N2 TO WD CORRECTION FACTOR ------------------------------------------
    X_all = X_prep_alsnormpeakSapph_subsets{11}; 
    X_3samp = selectrow(X_all, 1:123); %  Take all lp and wd variations into account, 3 first samples (the ones wit most extreme chemical variations)
    X_3samp = select_from_identifier(X_3samp,5,'450');
    X3samp_wdavg = average_from_identifier(X_3samp,11:12); % AVERAGING ALL MEASUREMENTS AT WD 10 CM MIGHT NOT BE CORRECT. SINCE WE DON'T HAVE FULL COVERAGE IN LP AT ALL WDs.. CHECK..

    [~, N2int] = saisir_getSignalIntensity(X3samp_wdavg,2329, 'Mode','derivative');

    % figure; plot(str2num(X3samp_wdavg.i), N2int,'-o');xlabel('WD (cm)');ylabel('N_{2}');grid on;

    WD_cf_table = [];
    WD_cf_table(:,1) = N2int; %X3samp_wdavg.d(:,i1);
    WD_cf_table(:,2) = str2num(X3samp_wdavg.i);

    % WD TO SAMPLE CORRECTION FACTORS -----------------------------------------

    % Signal to use:
    rs_signal = 1657;
    
    X_lp450 = X_prep_alsnormpeakSapph_subsets{10}; 
    X_lp450_S1 = select_from_identifier(X_lp450,1,'M12'); 
    X_lp450_S1_wdavg = average_from_identifier(X_lp450_S1,11:12);

    % Make a correction factor table nitrogen intensity = WD = Corr factor
    % When employing this, check which nitr. intensity you are closest to, to obtain
    % correction factor.
    [~, SampleInt] = saisir_getSignalIntensity(X3samp_wdavg,rs_signal, 'Mode','derivative', 'peakWidth',40);
    WD_cf_table(:,3) = SampleInt(2)./SampleInt(:) ; % Sample signal intensity relative to optimal WD

    % Make an interpolated table, to handle WDs outside of the exact known WDs
    clear WD_cf_table_interp
    clear WD_cf_table_final
    WD_cf_table_interp = interp1(WD_cf_table(:,1),WD_cf_table(:,2:3),0.2:0.001:1.2,'linear','extrap'); % when not using derivative: 1:0.001:5
    WD_cf_table_final(:,1) = 0.2:0.001:1.2;
    WD_cf_table_final(:,2:3) = WD_cf_table_interp;

    WD_cf_table = WD_cf_table_final;
    save('WD_cf_table',"WD_cf_table")

    % DO THE N2->WD->S CORRECTION -----------------------------------------
    Subset_prep = X_prep_alsnormpeakSapph_subsets{11};
    
    % Check how much the Sapphire signal depends on WD for each baseline
    % param setting choice
    % Choose one sample to plot: 
    Example = select_from_identifier(Subset_prep,1,'M12_450mW');
    Example = average_from_identifier(Example,1:20);
    [~, SampleInt] = saisir_getSignalIntensity(Example,rs_signal, 'Mode','derivative','peakWidth',40);
    
    % Do the prep
    Subset_prep = WD_CF_N2(Subset_prep);    % For WD_CF : ,Subset_prep.i(:, 11:12)
    
    % Plot average spectrum after prep:

    X_prep_N2CF_fullreg_lambda_subsets{j} = Subset_prep;

    % REDUCE REGION TO AVOID END REGION OF BAD BASELINE FIT ---------------
    
    X_corr = selectwn(Subset_prep,785:1725);
    X_corr = deletewn(X_corr,1540:1570); % Remove oxygen band to avoid weighting a region we know will be dependent on WD
    
    X_prep_alsnormpeakSapphWDCF_lambda_subsets{j} = X_corr;
    
    %plot_Raman(str2num(X_corr.v), X_corr.d)

    % FAT TRANSFER MODELS -------------------------------------------------

    X = X_corr;
    Y = Y_subsets{11};
    
    %X = selectwn(X,1150:1800);
    
    % Average the three replicates
    X = average_from_identifier(X,1:14);
    Y = average_from_identifier(Y,1:14);
    
    % Remove the two outliers for 18:1
    remove_names = {'M01';'M02';'M07';'M15'};
    for i = 1:length(remove_names)
        X = delete_from_identifier(X,1,remove_names{i});
        Y = delete_from_identifier(Y,1,remove_names{i});
    end
    
    % Remove extra measurements
    X = delete_from_identifier(X,5,'300mW_25cm');
    Y = delete_from_identifier(Y,5,'300mW_25cm');
    X = delete_from_identifier(X,5,'400mW_15cm');
    Y = delete_from_identifier(Y,5,'400mW_15cm');
    X = delete_from_identifier(X,5,'400mW_25cm');
    Y = delete_from_identifier(Y,5,'400mW_25cm');
    
    
    % One cal set for optimal conditions, apply on rest
    %ncomp = 4;
    %[FIG, Regcoeff, Performance, Residuals] = PLSR_train2multiset_validation_from_identifier(X, Y, 1, 5:14, '450mW_10cm',6,1:14, 'plotLimits',[35 55],'AoptAlg','STATIC','ncomp', ncomp);
    [Regcoeff, Performance, Residuals] = PLSR_train2multiset_validation_from_identifier(X, Y, 1, 5:14, '450mW_10cm',6,1:14, 'plotLimits',[35 55],'PlotIt',0);


    % SAVE PERFORMANCE INDICATORS FOR EACH SMOOTHING PARAM LAMBDA ---------

    % Save the example of sample signals as a func of WD
    Summary.SampleSignalM12_WD10_LP450.wd = str2num(Example.i(:,11:12));
    Summary.SampleSignalM12_WD10_LP450.SInt1656(j,:) = SampleInt(2)./SampleInt;
    
    Summary.performance.v = Performance.v;
    Summary.performance.bias(j,:) = Performance.bias(1,:);
    Summary.performance.rmsepcorr(j,:) = Performance.rmsepcorr(1,:);
    Summary.performance.slope(j,:) = Performance.slope(1,:);
end


%% PLOT PERFORMANCE OVERVIEW OF SMOOTHING PARAMETER TEST
%---------------------------------------------------------------------------
% Check stability of calculated CF ----------------------------------------
figure('Position',[ 50 50 500 400]);
plot(Summary.SampleSignalM12_WD10_LP450.wd,Summary.SampleSignalM12_WD10_LP450.SInt1656)
leg = legend(replace(cellstr(num2str(Summary.lambdas')),'_',' '),'Location','Northwest');
title(leg,'Smoothing parameter')
box off
grid on
xlabel ('Working distance', 'FontSize',18)
ylabel ('Calculated CF', 'FontSize',18)


% Performance plots -------------------------------------------------------
% lambda increasing toward the right in each bar group ->

scrsz = get(0,'ScreenSize');
FIG = figure;
FIG.PaperUnits = 'centimeters';
set(FIG,'PaperPosition',[0 0 20 9])

tiledlayout(3,1,'TileSpacing','Compact')
nexttile

testsetcats = categorical(replace(cellstr(Summary.performance.v(:,3:end-5)),'_',' '));
bar(testsetcats, Summary.performance.rmsepcorr,'Edgecolor','none')
grid on
ylabel('RMSEP_{corr}','Fontsize',12,'Units','points')
set(gca, 'XTickLabel',{''})
nexttile

testsetcats = categorical(replace(cellstr(Summary.performance.v(:,3:end-5)),'_',' '));
bar(testsetcats, Summary.performance.bias,'Edgecolor','none')
grid on
ylabel('Bias','Fontsize',12,'Units','points')
set(gca, 'XTickLabel',{''})
nexttile

testsetcats = categorical(replace(cellstr(Summary.performance.v(:,3:end-5)),'_',' '));
bar(testsetcats,Summary.performance.slope,'Edgecolor','none')
grid on
ylabel('Slope','Fontsize',12,'Units','points')


% Plot average spectra at low, middle nad high lambda parameter values ----

Xlambdamin = X_prep_N2CF_fullreg_lambda_subsets{1};
Xlambdamin = average_from_identifier(Xlambdamin,1);

Xlambdamiddle = X_prep_N2CF_fullreg_lambda_subsets{6};
Xlambdamiddle = average_from_identifier(Xlambdamiddle,1);

Xlambdamax = X_prep_N2CF_fullreg_lambda_subsets{end};
Xlambdamax = average_from_identifier(Xlambdamax,1);

FIG = figure;
FIG.PaperUnits = 'centimeters';
set(FIG,'PaperPosition',[0 0 9.2 5])

plot(str2num(Xlambdamin.v),Xlambdamin.d,'Linewidth',1.2);hold on
plot(str2num(Xlambdamiddle.v),Xlambdamiddle.d,'Linewidth',1.2)
plot(str2num(Xlambdamax.v),Xlambdamax.d,'Linewidth',1.2)
xregion(785,1540)
xregion(1570,1725)
l = legend('4.0','5.2','6.0','Fontsize', 8, 'units','points');
title(l,'\lambda','Fontsize', 8)
ylabel('Raman Intensity / Arbitr. Units','FontSize',12, 'units','points')
xlabel('Wavenumber / cm^{-1}', 'FontSize',12, 'units','points')
set(gcf,'Color',[1 1 1])
box off
grid on
xlim([min(str2num(Xlambdamax.v)), max(str2num(Xlambdamax.v))])


%%