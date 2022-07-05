%% Generating data snippet
    fS = 25e3;
    t = 0.08:1/fS:0.22-1/fS;
    signal = @(t) sqrt(2)*230*cos(2*pi*50*t-3.5*pi/3);
    zeroCross = ZeroX(t,signal(t));
    zeroCross1 = zeroCross(find(zeroCross<0.1,1,'last'));
    zeroCrossN = zeroCross(find(zeroCross<0.2,1,'last'));
    
%% Plotting
%     addpath('C:\Users\fg6202\bwSyncShare\publications\coordinate2normalized-master')
    axesXShift = -0.009;
    axesYShift = 0.03;
    axesWidthAddition = 0.09;
    axesHeightAddition = -0.03;
    FontSizeAll = 10;
    darkgreen = '#009900';
    figurewidth = 1.2*8.85553; % cm = columnwidth (textwidth = 18.13275 cm)
    LineWidthAll = 2;

    fig = figure();
    fig.Name = 'ScematicIntervals- 100ms vs zero-crossing interval';
    fig.Units = 'centimeter';
    fig.Position = [2, 2, figurewidth, figurewidth*350/560]; %[360,200,560,350]
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto','PaperUnits','centimeter','PaperSize',[pos(3), pos(4)])
    
    % generating the axes frame
    ax1 = axes();
        ax1.XAxisLocation = 'top';
        ax1.YAxisLocation = 'right';
        ax1.Box ='on';
        ax1.Color = 'w';
        ax1.TickLabelInterpreter = 'latex';
        ax1.FontSize = FontSizeAll;
        ax1.LabelFontSizeMultiplier = 1.0;
        pos1 = ax1.Position;
        ax1.Position = [pos1(1)+axesXShift, pos1(2)+axesYShift, pos1(3)+axesWidthAddition, pos1(4)+axesHeightAddition];
        ax1.XTick = [0.1 0.2]; ax1.YTick = [];
        ax1.XTickLabel = {'$t_\mathrm{r}=0.1\,s$','$t_\mathrm{r}=0.2\,s$'};
        
    ax2 = axes();
        ax2.XAxisLocation = 'bottom';
        ax2.YAxisLocation = 'left';
        ax2.Box ='off';
        ax2.Color = 'none';
        ax2.TickLabelInterpreter = 'latex';
        ax2.FontSize = FontSizeAll;
        ax2.LabelFontSizeMultiplier = 1.0;
%         pos1 = ax2.Position;
        ax2.Position = [pos1(1)+axesXShift, pos1(2)+axesYShift, pos1(3)+axesWidthAddition, pos1(4)+axesHeightAddition];
        ax2.XTick = zeroCross;
        ax2.XTickLabel = {'$t_\mathrm{zc}(0)$','$t_\mathrm{zc}(1)$','$t_\mathrm{zc}(2)$','$t_\mathrm{zc}(3)$','$t_\mathrm{zc}(4)$','$t_\mathrm{zc}(5)$','$t_\mathrm{zc}(6)$'};
    
    linkaxes([ax1,ax2],'x')
    xlim([0.08 0.22])
    ylim([-550 580])
   
    % axes labels
    alb = xlabel('Time');
        alb.Interpreter = 'latex';
        alb.FontSize = FontSizeAll;
    alb = ylabel('Voltage in V');
        alb.Interpreter = 'latex';
        alb.FontSize = FontSizeAll;

    hold on;
        % showing the zero crossing position and period numbers
        for n = 1:length(zeroCross)
            line([zeroCross(n) zeroCross(n)],[0 -580],'Color','k','LineStyle','-')
            if n<length(zeroCross)
                [normx, normy] = coord2norm(ax2, 0.007+[zeroCross(n) zeroCross(n+1)], -580*[1 1]);
                pos = [normx(1), normy(1), diff(normx), diff(normy)];
                anot = annotation('textbox',pos,'String',num2str(n),'EdgeColor','none');%0.312,0.112380952380952,0.058928571428571,0.087619047619048
                anot.FitBoxToText = 'on';
                anot.FontSize = FontSizeAll;
                anot.BackgroundColor = 'none';
                anot.Interpreter = 'latex';
                anot.Margin = 4;
                anot.VerticalAlignment = 'bottom';
            end
        end
        [normx, normy] = coord2norm(ax2, [zeroCross(3) zeroCross(5)], -460*[1 1]);
        pos = [normx(1), normy(1), diff(normx), diff(normy)];
        anot = annotation('textbox',pos,'String','period number $k$','FitBoxToText','on','EdgeColor','none');
        anot.FontSize = FontSizeAll;
        anot.BackgroundColor = 'white';
        anot.Interpreter = 'latex';
        anot.Margin = 1;
        anot.VerticalAlignment = 'bottom';

        plot(t,signal(t),'-k','LineWidth',LineWidthAll)
        plot(zeroCross,zeros(length(zeroCross),1),'o','Markersize',8,'MarkerFaceColor',darkgreen,'Color',darkgreen)

        % Marking the intervals
        xline([0.1,0.2],'b-','LineWidth',LineWidthAll) %,'100ms interval')
        xline([zeroCross1,zeroCrossN],'r--','LineWidth',LineWidthAll) %,'--','zero-crossing interval')
        [normx, normy] = coord2norm(ax2, [0.1 0.2]+0.001*[1 -1], 490*[1 1]);
        annotation('doublearrow',normx,normy,'Color','b','LineWidth',LineWidthAll);%[XFrom,XTo],[YFrom,YTo]
        [normx, normy] = coord2norm(ax2, [zeroCross(3) zeroCross(5)], 600*[1 1]);
        pos = [normx(1), normy(1), diff(normx), diff(normy)];
        anot = annotation('textbox',pos,'String','100ms interval',...;
            'FitBoxToText','on','EdgeColor','none','BackgroundColor','none',...
            'Color','b');
            anot.FontSize = FontSizeAll;
            anot.Interpreter = 'latex';
        [normx, normy] = coord2norm(ax2, [zeroCross(1) zeroCross(6)]+0.001*[1 -1], 380*[1 1]);
        annotation('doublearrow',normx,normy,'Color','r','LineWidth',LineWidthAll,'LineStyle','--');%[.175 .71],[.15 .15];
        [normx, normy] = coord2norm(ax2, [zeroCross(2) zeroCross(4)], 500*[1 1]);
        pos = [normx(1), normy(1), diff(normx), diff(normy)];
        anot = annotation('textbox',pos,'String','zero-crossing interval',...[.3 .01 .2 .2]
            'FitBoxToText','on','EdgeColor','none','BackgroundColor','none',...
            'Color','r');
            anot.FontSize = FontSizeAll;
            anot.Interpreter = 'latex';

        % Label to zero crossings
        [normx, normy] = coord2norm(ax2, [zeroCross(2)+0.01 zeroCross(2)+0.0015], [150 25]);
        anot = annotation('textarrow',normx,normy,'String',{'positive zero-crossing'},'LineWidth',LineWidthAll,'TextBackgroundColor','w','Color',darkgreen,'TextMargin',1);
            anot.FontSize = FontSizeAll;
            anot.Interpreter = 'latex';
    
    hold off
    
%% Saving figure
% 	savefig('Fig_SchematicIntervals.fig')
% 	print(fig,'Fig_SchematicIntervals.eps','-depsc')
% 	saveas(fig,'Fig_SchematicIntervals.png')
%     print(fig,'Fig_SchematicIntervals.pdf','-dpdf') % 