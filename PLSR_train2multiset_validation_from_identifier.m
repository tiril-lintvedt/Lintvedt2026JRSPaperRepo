function [Regcoeff, Performance, Residuals] = PLSR_train2multiset_validation_from_identifier(X, Y, target, idpos,id_cal, maxcomp,reps_idpos, varargin)
% --------------------- Multiple test set validation ----------------------
% A version of PLSR validation where one calibration set defined by the saisir 
% id string positions idpos exact match to cal_id, and employ it on one or 
% multiple test sets defined by remaining unique id variations in the idpos. 
% 
% The number of LVs is selected based on CV on the calibration set.
%
% NB! Works only for one target reference value at a time.
% -------------------------------------------------------------------------
%
%   INPUT:
%               X           -   Saisir data structure
%               Y           -   Saisir data structure of reference values 
%               target      -   Column number in block Y to establish models 
%                               for (only one!)
%               idpos       -   Id position (indices) in strings used to 
%                               define validation segments     
%               reps_idpos  -   Id position (indices) in strings used to 
%                               define what measurements belong to same sample.
%               aopt        -   Predefined number of PLS components to use
% 
%   OUTPUT:
%               FIG         - Figure handle for predicted vs target plot
%               Regcoeff    - Regression coefficients per segment
%               Performance - Struct, summarry of performance metrics
%               Residuals   - Prediction residuals
% -------------------------------------------------------------------------
% EXAMPLE CALL
% -------------------------------------------------------------------------
%
% [FIG, Regcoeff, Performance] = PLSR_validate_from_identifier2(X, Y, target, ...
%                                                               idpos, ncomp,'aoptAlg', 'WM')
%  
% * ncomp is an optional parameter, but must be present if 'aoptAlg' is set
%   to 'STATIC' 
% * aoptAlg : 'STATIC' / 'WM' (default) / 'ALT2'
% * reps_idpos is an optional parameter but must be present if 'aoptMode'
%   is set to 'calCV'
% -------------------------------------------------------------------------
% SETTINGS 
% -------------------------------------------------------------------------

% Main plot colors
plot_colors =[0.1 0.1 0.5 ; 
              0.5 0.5 0.5 ;
              0.9 0.5 0   ; 
              0.2 0.7 0.7 ;
              0.6 0.2 0.9 ;
              0.3 0.8 0.3 ;
              0.9 0.3 0.6 ; 
              0   0   0   ;
              0 0.5 0.9   ; 
              0.2 0.5 0.2 ; 
              0.7 0.7 0.2 ; 
              0.9 0.3 0.1 ;
              0.1 0.1 0.5 ; 
              0.5 0.5 0.5 ;
              0.9 0.5 0   ; 
              0.2 0.7 0.7 ;
              0.6 0.2 0.9 ;
              0.3 0.8 0.3 ;
              0.9 0.3 0.6 ; 
              0   0   0   ;
              0 0.5 0.9   ; 
              0.2 0.5 0.2 ; 
              0.7 0.7 0.2 ; 
              0.9 0.3 0.1 ;
              0.1 0.1 0.5 ; 
              0.5 0.5 0.5 ;
              0.9 0.5 0   ; 
              0.2 0.7 0.7 ;
              0.6 0.2 0.9 ;
              0.3 0.8 0.3 ;
              0.9 0.3 0.6 ; 
              0   0   0   ;
              0 0.5 0.9   ; 
              0.2 0.5 0.2 ; 
              0.7 0.7 0.2 ; 
              0.9 0.3 0.1 ;
              0.1 0.1 0.5 ; 
              0.5 0.5 0.5 ;
              0.9 0.5 0   ; 
              0.2 0.7 0.7 ;
              0.6 0.2 0.9 ;
              0.3 0.8 0.3 ;
              0.9 0.3 0.6 ; 
              0   0   0   ;
              0 0.5 0.9   ; 
              0.2 0.5 0.2 ; 
              0.7 0.7 0.2 ; 
              0.9 0.3 0.1 ;
];

% plot_colors = ones(12,3)-linspecer(12,'qualitative') + 0.3*ones(12,3);

plot_markers  = {'^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.'
                 };

set(0,'defaultfigurecolor',[1 1 1])

% -------------------------------------------------------------------------
% INPUT PARSING
% -------------------------------------------------------------------------

defaultNcomp = 10;
defaultAoptAlg = 'WM'; % // 'ALT2', 'STATIC'
defaultMetric = 'RMSEP'; 
defaultPlotLimit = [];
defaultAoptMode = 'calCV';
defaultRepIdPos = [];
defaultncomp = nan;
defaultPlotIt = 1;

p = inputParser;
   validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
   validNumLen2= @(x) isnumeric(x) && (length(x)==2) ;
   expectedModes = {'calCV','test'}; 
   expectedAlgs = {'STATIC', 'WM', 'ALT2'};
   expectedAlgMetrics = {'RMSEP','RMSEP_corr'};  
   addRequired(p,'X'); % positional arg
   addRequired(p,'Y'); % positional arg
   addRequired(p,'target',validScalarPosNum); % positional arg
   addRequired(p,'idpos'); % positional arg
   addRequired(p,'id_cal'); % positional arg
   addOptional(p,'maxcomp',defaultNcomp,validScalarPosNum);
   addOptional(p,'reps_idpos',defaultRepIdPos);
   addParameter(p,'ncomp', defaultncomp)
   addParameter(p,'plotLimits',defaultPlotLimit,validNumLen2);
   addParameter(p,'aoptAlg',defaultAoptAlg,  @(x) any(validatestring(x,expectedAlgs))); % Name Value pair
   addParameter(p,'aoptMode',defaultAoptMode,  @(x) any(validatestring(x,expectedModes)));
   addParameter(p,'aoptAlgMetric',defaultMetric,  @(x) any(validatestring(x,expectedAlgMetrics))); % Name Value pair
   addParameter(p,'plotIt',defaultPlotIt)
   parse(p,X, Y, target, idpos, id_cal, maxcomp, reps_idpos, varargin{:});
   
aoptstatic = p.Results.ncomp;
aoptmetric = p.Results.aoptAlgMetric;
aoptalg =  p.Results.aoptAlg;
aoptmode = p.Results.aoptMode;
plotlim = p.Results.plotLimits;
cal_id = p.Results.id_cal;
plotIt = p.Results.plotIt;

% -------------------------------------------------------------------------

% Model frames
[m,n] = size(X.d);
mc = maxcomp ; % NB! Hve you coded parsing for aopt input?

% Storage for predictions
Ypred.d = zeros([m length(target)]);
Ypred.i = Y.i;

% Determine number of segments from identifier and initialize 
unique_id = char(unique(cellstr(X.i(:,idpos)))); % Unique
% cv_seg = group_from_identifier(X, idpos); % Assign each spectrum to a CV segment by unique id tag position
% unique_group_num = unique(cv_seg); % Unique cv segment numbers
test_id = setdiff(unique_id, cal_id,'rows');
ntestsets = size(test_id,1);

% ncvseg = length(unique_group_num); 
Ypred.v = cell(m, ntestsets); % Might be a better way of storing this in the future

Regcoeff.d = zeros(1,n); 
Regcoeff.v = X.v;
Regcoeff.i = '                          ';

%Residuals.d = zeros(m, ncvseg); 
Residuals.v = '                          '; 

if plotIt
    % Initialize predicted versus target figure
    scrsz = get(0,'ScreenSize');
    FIG = figure('Position',[50 50 scrsz(3)/2.5 scrsz(4)/1.9]);
    FIG.PaperUnits = 'centimeters';
    set(FIG,'PaperPosition',[0 0 4.2 4.2]); 
    hold on
    phandles = {};  
end

group_names = {};
ci = 1; % plotnr/genral counter

% Calibrate and optimize model on cal set ---------------------------------

[~,indin]  = select_from_identifier2(X,idpos,cal_id); 

% PLS calibration
[b0,B,~,~,~,~] = pls_nipals(X.d(indin, :),Y.d(indin,target),mc); 


% Cross validation on calibration set, choose number of comp.
Xin = selectrow(X,indin);
Yin = selectrow(Y,indin);
[Predictions, ~, PerformanceMetrics] = PLSR_CV_from_identifier(Xin, Yin, target,reps_idpos, mc,'showPlot','no','aoptAlgMetric','RMSECV', 'aoptAlg',aoptalg,'ncomp',aoptstatic);
aopt = PerformanceMetrics.lv;

% Predict cal set from cal model (for all number of comps) and calculate 
YpredCal.d(indin,:) = b0 + X.d(indin,:)*B;
YpredCal.i(indin,:) = X.i(indin,:);
YpredCal.v = 'Number of components (1,2,3, ...)';
YRefCal = Y.d(indin,target); % Reference values for calibration set

% Performance metrics cal set 
RMSEC = cal_rmse(YRefCal, YpredCal.d(indin,:));  
R2C = cal_r2(YRefCal, YpredCal.d(indin,:));
RMSECV = PerformanceMetrics.rmsecv;

% Validate on multiple separate test sets ---------------------------------

% Keep control of what group was predicted from what other group.

for j = 1:ntestsets
    jname = test_id(j,:);
    [~,indout]  = select_from_identifier2(X,idpos,jname);
   
    % Prediction for all number of PLS comps in model   
    YpredTest.d(indout,:) = b0 + X.d(indout,:)*B;
    YpredTest.i(indout,:) = X.i(indout,:);
    YpredTest.v = 'Number of components (1,2,3, ...)';
    YRefTest = Y.d(indout,target); % Reference values for calibration

    % Calculate RMSE for all number of comps, incl zero comp
    RMSEP = cal_rmse(YRefTest, YpredTest.d(indout,:));          
    %RMSEP_corr = rmse_corr(YRefTest, YpredTest.d(indout,:));
    ypred_zerocomp = mean(YRefCal);
    rmse_zerocomp = cal_rmse(repelem(ypred_zerocomp,length(YRefTest))', YRefTest);
    
    % Find optimal number of components from given strategy
    if strcmp(aoptmode,'test')
        if  strcmp(aoptalg, 'WM')
            aopt = find_aopt(eval(aoptmetric)); % Based RMSEP/RMSEP_corr, Westad&Martens         
        elseif strcmp(aoptalg, 'ALT2')
            aopt = find_aopt([rmse_zerocomp RMSEP], 0.02, 2); % Optimal number of components, Unscr                     
        elseif strcmp(aoptalg, 'STATIC')
            aopt = p.Results.ncomp;
        end
    end

    % Optimal model ---------------------------------------------------
    b0_aopt = b0(aopt);
    b_aopt = B(:,aopt);
        
    % Store final regression coefficients (Now only assumes 1 per idtype)        
    descr = [char(unique(cellstr(X.i(indout,idpos))))]; % Description of segments used
    Regcoeff.d(1,:) = b_aopt;
    Regcoeff.i(1,1:length(descr)) = descr;  %[char(unique(cellstr(X.i(indin,idpos))))];

    % Store predictions and metrics for the OPTIMAL comp number
    Ypred.d(indout,j) = b0_aopt + X.d(indout,:)*b_aopt;
    Ypred.v(indout,j) = cellstr(repelem(descr,length(indout),1));
           
    if plotIt
        % Predicted versus target plot for the OPTIMAL comp number
        p_i = plot(Y.d(indout,target), Ypred.d(indout,j),'.', 'color',plot_colors(ci,:),'Marker',plot_markers{ci},'MarkerSize',3); 
        phandles{ci} = p_i;
        plot(-15:60, -15:60, 'color', 'r')
    end

    % Calculate performance metrics for OPTIMAL comp number 
    y_test = Y.d(indout,target); % Reference values for current testset
    y_pred = Ypred.d(indout,j); % Predicted values for current test set wit opt. num. comps.
    
    Residuals.d(indout,ci) = y_test - y_pred;
    Residuals.v(ci,1:length(descr)) = char(descr);
    Residuals.i(indout,:) = X.i(indout,:);

    % Residual variance, using zero components 
    ypred_zerocomp = mean(y_test);
    rmse_zerocomp = cal_rmse(repelem(ypred_zerocomp,length(y_test))', y_test);
    
    % Performance metrics 
    RMSEP = cal_rmse(y_test, y_pred); 
    R2P = cal_r2(y_test, y_pred);
    BIAS = cal_bias(y_test, y_pred);
    slope_intercept = cal_slope(y_test, y_pred) ;
    LV = aopt;

    % Performance after slope and bias correction
    RES_corr = residuals_corr(y_test, y_pred);
    RMSEP_corr = rmse_corr(y_test, y_pred);
    R2P_corr = R2_corr(y_test, y_pred);

    % Residuals when bias is corrected
    Residuals.dcor(indout,ci) = RES_corr;

    % Store all final metrics -----------------------------------------
    % INFO: Metrics are store row wise according to nested for-loop 
    Performance.rmsec(1,j) = RMSEC(aopt);
    Performance.r2c(1,j) = R2C(aopt);
    Performance.rmsecv(1,j) = RMSECV(aopt); % CV for calibration set
    Performance.rmsep(1,j) = RMSEP; 
    Performance.rmsepcorr(1,j) = RMSEP_corr; 
    Performance.r2p(1,j) = R2P;
    Performance.r2pcorr(1,j) = R2P_corr; 
    Performance.bias(1,j) = BIAS;
    Performance.slope(1,j) = slope_intercept(1); 
    Performance.lv(1,j) = LV;
    Performance.i(1,:) = [char(unique(cellstr(X.i(indin,idpos)))) '(Cal)' '->' ];
    Performance.v(j,:) = ['->' char(unique(cellstr(X.i(indout,idpos)))) '(Val)'];
    

    group_names{ci} = [replace(descr(1:end),'_',' ')];   
    ci = ci+1; 
end

if plotIt
    %title(['Calibration (CV) :', replace(cal_id,'_', ' ')],'FontSize',16)
    xlim(plotlim) 
    ylim(plotlim) 

    xlabel('Target','FontSize',12,'Units','points')
    ylabel('Predicted','FontSize',12,'Units','points')
    leg = legend([phandles{:}],group_names{:},'FontSize',7, 'Units','Points'); % , 'Location', 'Southeast');
    title(leg, 'Test set','FontSize',7)
    grid on
    text(0.03,0.83,['LV = ', num2str(aopt)],'units','normalized','FontSize',7)
    text(0.03,0.9,['RMSEP = ', num2str(round(RMSEP,2))],'units','normalized','FontSize',7)
    %set(leg,'visible','off')

  

% Plot CV results on calibration ------------------------------------------

    % RMSE as a function of number of comps, marking the OPTIMAL comp number
    f = figure('Position',[50 100 scrsz(3)/3 scrsz(4)/2.2])  ; 
    set(f,'PaperPosition',[0 0 4.2 4.2]);
    %title(['Calibration (CV) :', replace(cal_id,'_', ' ')],'FontSize',16)
    hold on
    plot(1:mc, PerformanceMetrics.rmsecv, '-o','color', plot_colors(3,:));
    plot(1:mc, PerformanceMetrics.rmsec, '-o','color', plot_colors(4,:)); 
    grid on
    box off
    ylabel('RMSE','FontSize', 18)
    xlabel('Num PLS components','FontSize', 18)
    xline(aopt)
    yline(rmse_zerocomp,'--')
    legend('CV', 'Cal')
 
    % Predicted versus target plot for the OPTIMAL comp number ------------
    f2 = figure('Position',[565 100 scrsz(3)/3 scrsz(4)/2.2])  ; 
    set(f2,'PaperPosition',[0 0 4.2 4.2]);
    %title(['Calibration (CV) :', replace(cal_id,'_', ' ')],'FontSize',16)
    hold on
    plot(Yin.d(:,target), Predictions.cvpred(:,aopt),'o', 'color',plot_colors(1,:),'Markersize',3);    
    
    %plot(0:ceil(max(Predictions.cvpred(:,aopt))), floor(0:ceil(max(Predictions.cvpred(:,aopt)))));
    plot(-10:60,-10:60);

    if ~isempty(plotlim); xlim(plotlim);ylim(plotlim);end

    text(0.03,0.83,['LV = ', num2str(aopt)],'units','normalized','FontSize',7)
    text(0.03,0.9,['RMSECV = ', num2str(round(PerformanceMetrics.rmsecv(:,aopt),2))],'units','normalized','FontSize',7)
    xlabel('Target (%)','Units','points','FontSize',12)
    ylabel('Predicted (%)','Units','points','FontSize',12)
    grid on
    box off

end
end