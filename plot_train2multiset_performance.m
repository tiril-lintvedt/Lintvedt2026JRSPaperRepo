function [FIG, axeshandles] = plot_train2multiset_performance(Performance, varargin)
% Plots main results from PLSR_train2multiset_validation_from_identifier.

% -------------------------------------------------------------------------
% SETTINGS 
% -------------------------------------------------------------------------

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
];

plot_markers  = {'^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.',...
                 '^','o','square','diamond','*','x','hexagram','.', ...
                 '^','o','square','diamond','*','x','hexagram','.'};

set(0,'defaultfigurecolor',[1 1 1])

% -------------------------------------------------------------------------
% INPUT PARSING
% -------------------------------------------------------------------------

defaultMetric = {'rmsepcorr','bias','slope','r2p','rmsep',}; 
defaultRmsepLim = [];
defaultBiasLim = [];
defaultSlopeLim = [];

p = inputParser;
   expectedMetrics = {'rmsep','rmsepcorr','bias','slope','r2p','rmsep'};
   
   addRequired(p,'Performance'); % positional arg
   addParameter(p,'Metric',defaultMetric); % Name Value pair
   addParameter(p,'RmsepcorrLim',defaultRmsepLim); % Name Value pair
   addParameter(p,'BiasLim',defaultBiasLim); % Name Value pair
   addParameter(p,'SlopeLim',defaultSlopeLim); % Name Value pair
 
   parse(p,Performance, varargin{:});
   
Metric = p.Results.Metric;
% -------------------------------------------------------------------------
% MAIN
% -------------------------------------------------------------------------

scrsz = get(0,'ScreenSize');
FIG = figure('Position',[50 50 scrsz(3)/2.5 scrsz(4)/1.9]);
nmetrics = length(Metric);
axeshandles = {};

tiledlayout(nmetrics,1,'TileSpacing','Compact');

% Only for Normalization study;
plotlims = [0 2; -2 8; 0 1.3; -5 1; -5 5];

for m = 1:length(Metric)
    metric = Metric{m};
    nexttile
    grid on
    hold on 
    ci = 1; 

    for j = 1:(size(Performance.(metric),2))
        %descr = [Performance.i(i,1:end-15) Performance.v(j,1:end-12)];
        descr = [char(strrep(cellstr(Performance.i(1,:)),'->','')) Performance.v(j,:)];
        descr = char(replace(cellstr(descr),'_',''));
        b = bar(categorical(cellstr(descr)), Performance.(metric)(j),'facecolor', plot_colors(ci,:),'EdgeColor', plot_colors(ci,:));            
        xtips2 = b(1).XEndPoints;
        labels2 = string(round(b(1).YData,2));
        text(xtips2,Performance.(metric)(j)/1.9,labels2,'HorizontalAlignment','center','VerticalAlignment','middle','Color',[0.95 0.95 0.95],'FontSize',9)
        if strcmp(metric,'rmsepcorr')   
            text(xtips2,Performance.(metric)(j)+0.3,['LV=',num2str(Performance.lv(j))],'HorizontalAlignment','center','VerticalAlignment','top','Color',[0 0 0],'FontSize',8)
            plot(xtips2,Performance.(metric)(j)+0.4, 'color',plot_colors(ci,:),'Marker',plot_markers{ci})
        end

        if strcmp(metric,'slope')
            yline(1,'--')
        end
        
        

        ci = ci +1;

    end        
    
    ylabel(metric)
    ylim(plotlims(m,:))
     
    if m ~= nmetrics
        set(gca, 'XTickLabel',{''})
    end
    
    axeshandles{end+1} = gca;

end


end