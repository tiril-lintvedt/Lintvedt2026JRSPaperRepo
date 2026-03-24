function plot_SapphVsLP(X_Saisir, sample_inds, lp_inds,wd_inds)

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
    
    wd_names = unique(cellstr(X_s.i(:,wd_inds)));
    nwd = height(wd_names);

    for j = 1:nwd
        X_s_wd = select_from_identifier(X_s,wd_inds(1),wd_names{j});
        %[~,SapphInt] = saisir_getSapphIntensity(X_s_wd,750,'Mode','derivative','plotit',0); 
        [~,SapphInt] = saisir_getSignalIntensity(X_s_wd,750,'Mode','derivative','plotit',0); 
        plot(str2num(X_s_wd.i(:,lp_inds)), SapphInt,'.-','Color',plot_colors(j,:),'MarkerSize',11) ; %plot(str2num(X_lp_all.i(:,11:12)), N2int,'-o')
    
    end
end


xlabel('LP / mW','Fontsize', 12, 'Units','points')
ylabel('Sapphire signal / 750 cm^{-1}','Fontsize', 12, 'Units','points')
leg = legend(wd_names,'Location','southeast','Fontsize', 8, 'Units','points');
title(leg,'WD / cm','Fontsize', 8)
box off, grid on


end