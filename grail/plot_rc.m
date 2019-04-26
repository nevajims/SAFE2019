function plot_rc(input_modes_to_plot,rc,tc,notch_depths,defect_dimension,defect_file_name,input_modes,modes_to_plot);
mode_symmetry=[-1,1,-1,1,-1,-1,1,1,-1,1];
legend_text={'1','2','3','4','5','6','7','8','9','10'};
col='brgcmy';
secret_option=0;
plot_axes=2;
notch_depths=notch_depths(plot_axes,:);
defect_dimension=char(defect_dimension(plot_axes));
notch_depths_to_plot=[1:length(notch_depths)];
db_range=-40;
clf;
reflection_coefficient=zeros(length(notch_depths),1);
transmission_coefficient=zeros(length(notch_depths),1);
x=notch_depths(notch_depths_to_plot);
[x,ii]=sort(x);
for mode_index=1:length(input_modes_to_plot)
    mode=input_modes_to_plot(mode_index);
    mi=find(input_modes==mode);
    primary_mode_count=1;
    secondary_mode_count=1;
    h=figure(mode_index);
    set(h,'Position',[400 300 540 400]);
    if size(tc,1)>1
        rc_fig=subplot(2,1,1);
    else
        rc_fig=subplot(1,1,1);
    end
    hold on;
    for modes_to_plot_count=1:length(modes_to_plot);
        for notch_count=1:length(notch_depths_to_plot);
            reflection_coefficient(notch_count)=rc(modes_to_plot(modes_to_plot_count),mi,notch_depths_to_plot(notch_count));
        end;
        if find(input_modes==modes_to_plot(modes_to_plot_count))
            if mode_symmetry(modes_to_plot(modes_to_plot_count))==1
                plot(x,reflection_coefficient(ii),strcat(col(primary_mode_count),'o-'));
            else
                plot(x,reflection_coefficient(ii),strcat(col(primary_mode_count),'<-'));
            end
            primary_mode_count=primary_mode_count+1;
        else
            
            plot(x,reflection_coefficient(ii),strcat(col(secondary_mode_count),'.-'));
            secondary_mode_count=secondary_mode_count+1;
        end    
    end;
    legend(legend_text(modes_to_plot),-1);
    ylabel('Reflection coefficient');
    title([defect_file_name,':  Mode ',int2str(mode),' incident'],'interpreter','none');
    if plot_axes==1
        if min(notch_depths(notch_depths_to_plot))==max(notch_depths(notch_depths_to_plot))
            axis([min(notch_depths(notch_depths_to_plot))-0.1*min(notch_depths(notch_depths_to_plot)),min(notch_depths(notch_depths_to_plot))+0.1*min(notch_depths(notch_depths_to_plot)),0,1]);
        else
            axis([min(notch_depths(notch_depths_to_plot)),max(notch_depths(notch_depths_to_plot)),0,1]);
        end
    elseif plot_axes==2
        axis([0,max(notch_depths(notch_depths_to_plot)),0,1])
    end
    set(rc_fig,'ygrid','on');
    set(rc_fig,'ytick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])    
    %set(rc_fig,'xtick',sort(notch_depths))
    primary_mode_count=1;
    secondary_mode_count=1;
    if size(tc,1)>1
        tc_fig=subplot(2,1,2);
        hold on;
        for modes_to_plot_count=1:length(modes_to_plot);
            for notch_count=1:length(notch_depths_to_plot);
                transmission_coefficient(notch_count)=tc(modes_to_plot(modes_to_plot_count),mi,notch_depths_to_plot(notch_count));
            end;
            if find(input_modes==modes_to_plot(modes_to_plot_count))
                if mode_symmetry(modes_to_plot(modes_to_plot_count))==1
                    plot(x,transmission_coefficient(ii),strcat(col(primary_mode_count),'o-'));
                else
                    plot(x,transmission_coefficient(ii),strcat(col(primary_mode_count),'<-'));
                end
                primary_mode_count=primary_mode_count+1;
            else
                plot(x,transmission_coefficient(ii),strcat(col(secondary_mode_count),'.-'));
                secondary_mode_count=secondary_mode_count+1;
            end    
        end;
        legend(legend_text(modes_to_plot),-1);
        ylabel('Transmission coefficient');
    if plot_axes==1
        if min(notch_depths(notch_depths_to_plot))==max(notch_depths(notch_depths_to_plot))
            axis([min(notch_depths(notch_depths_to_plot))-0.1*min(notch_depths(notch_depths_to_plot)),min(notch_depths(notch_depths_to_plot))+0.1*min(notch_depths(notch_depths_to_plot)),0,1]);
        else
            axis([min(notch_depths(notch_depths_to_plot)),max(notch_depths(notch_depths_to_plot)),0,1]);
        end
    elseif plot_axes==2
        axis([0,max(notch_depths(notch_depths_to_plot)),0,1])
    end
    set(tc_fig,'ygrid','on')
    set(tc_fig,'ytick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]) 
    %set(tc_fig,'xtick',sort(notch_depths))
    end
    if length(defect_dimension)==0
        defect_dimension=input('What is the dimension of the defect, eg crack length (mm)','s');
    end
    xlabel(defect_dimension);
end
h=figure;
set(h,'Position',[400 300 540 400]);
[temp,sorted]=sort(notch_depths);
if length(notch_depths_to_plot)>1
    disp(strcat('The defects are    ',num2str(notch_depths(sorted)),'   ',defect_dimension));
    notch_depths_to_plot=input('Specify up to three defects to plot, eg. [a b c]:  ');
end
for defect_count=1:length(notch_depths_to_plot)
    defect_index=notch_depths_to_plot(defect_count);
    subplot(ceil(sqrt(length(notch_depths_to_plot))),ceil(length(notch_depths_to_plot)/ceil(sqrt(length(notch_depths_to_plot)))),defect_count);
    %figure;
    surf(20*log10(rc(input_modes(:),:,sorted(defect_index))));
    axis tight;
    axis off;
    view(2);
    shading interp
    if ~secret_option
        caxis([db_range 0]);
        colorbar
        %title(strcat(defect_dimension(1:findstr('(',defect_dimension)-1),' ',int2str(notch_depths(sorted(defect_index))),' ',defect_dimension(findstr('(',defect_dimension):length(defect_dimension))));
        h=text(3,5.2,strcat(defect_dimension(1:findstr('(',defect_dimension)-1),' ',int2str(notch_depths(sorted(defect_index))),' ',defect_dimension(findstr('(',defect_dimension):length(defect_dimension))));
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','middle');
        h=text([1:5],ones(1,5)*0.7,int2str(input_modes'));
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','middle');
        set(h,'Color','blue')
        h=text(ones(1,5)*0.7,[1:5],int2str(input_modes'));
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','middle');
        set(h,'Color','red')
    else
        h=text(3,0.8,'Output Mode');
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','middle');
        set(h,'Color','blue')
        h=text(0.8,3,'Input Mode');
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','middle');
        set(h,'Rotation',90);
        set(h,'Color','red')
    end

end
