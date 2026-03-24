function plot_SignalSampVsWD(X_Saisir, sample_inds, lp_inds,wd_inds)

sample_names = unique(cellstr(X_Saisir.i(:,sample_inds)));
nsamp = height(sample_names);

plot_colors = [0 0.5 0.9;
                0.9	0.5	0;
                0.2	0.5	0.2;
                0.9	0.3	0.1;
                0.7	0.7	0.2;
                0	0	0;
                0.5	0.5	0.5;
                0.2	0.7	0.7];

rs_signal = 1657;

f = figure('Position',[ 50 50 500 400]);
f.PaperUnits = 'centimeters';
set(f,'PaperPosition',[0 0 6.7 5.7]);  
hold on
for i = 1:nsamp
    sampName = sample_names{i,:} ;
    X_s = select_from_identifier(X_Saisir,sample_inds(1),sampName);
    
    lp_names = unique(cellstr(X_s.i(:,lp_inds)));
    nlp = height(lp_names);

    for j = 1:nlp
        X_s_lp = select_from_identifier(X_s,lp_inds(1),lp_names{j});
        X_s_optcond = select_from_identifier(X_s,lp_inds(1),'450mW_10cm');

        [~,SInt] = saisir_getSignalIntensity(X_s_lp,rs_signal,'Mode', 'derivative'); 

        [~,SIntOpt] = saisir_getSignalIntensity(X_s_optcond,rs_signal,'Mode', 'derivative'); 
      
        plot(str2num(X_s_lp.i(:,wd_inds)), SInt./SIntOpt,'.-','Color',plot_colors(j,:),'MarkerSize',11);
    
    end
end


xlabel('Working distance / cm','Fontsize', 12, 'Units','points')
ylabel('Sample signal / 1656 cm^{-1}','Fontsize', 12, 'Units','points')
leg = legend(lp_names,'Location','southwest','Fontsize', 8, 'Units','points');
title(leg,'LP / mW','Fontsize', 8)
box off, grid on




end