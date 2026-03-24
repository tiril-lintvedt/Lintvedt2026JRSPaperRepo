function plot_N2VsWD(X_Saisir, sample_inds, lp_inds,wd_inds)

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
        %[~,N2Int] = saisir_getN2intensity(X_s_lp,2329,'Mode','derivative','plotit',0);  
        [~,N2Int] = saisir_getSignalIntensity(X_s_lp,2329,'Mode','derivative','plotit',0);       

        plot(str2num(X_s_lp.i(:,wd_inds)), N2Int,'.-','Color',plot_colors(j,:),'MarkerSize',11) ; %plot(str2num(X_lp_all.i(:,11:12)), N2int,'-o')
    
    end
end


xlabel('Working distance / cm','Fontsize', 12, 'Units','points')
ylabel('N_{2} signal / 2329 cm^{-1}','Fontsize', 12, 'Units','points')
leg = legend(lp_names,'Location','southeast','Fontsize', 8, 'Units','points');
title(leg,'LP / mW','Fontsize', 8)
box off, grid on

end