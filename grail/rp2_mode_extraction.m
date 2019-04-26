%main processing
tic;

%build mode shape matrices for centre frequency methods
if (proc_option==1)|(proc_option==2);
    tx_mode_shapes=zeros(length(tx_modes),length(trans_node_list));
    tx_wavenos=zeros(length(tx_modes),1);
    tx_vels=zeros(length(tx_modes),1);
    rx_mode_shapes=zeros(length(tx_modes),length(trans_node_list));
    rx_wavenos=zeros(length(tx_modes),1);
    rx_vels=zeros(length(tx_modes),1);
    for count=1:length(tx_modes);
        [start_index,end_index]=get_good_mode_indices(tx_modes(count),data_freq,data_mode_start_indices);
        tx_mode_shapes(count,:)=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',filt_freq,'cubic');
        tx_waveno(count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), filt_freq,'cubic');
        tx_vels(count)=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index), filt_freq,'cubic');
        [start_index,end_index]=get_good_mode_indices(rx_modes(count),data_freq,data_mode_start_indices);
        rx_mode_shapes(count,:)=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',filt_freq,'cubic');
        rx_waveno(count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), filt_freq,'cubic');
        rx_vels(count)=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index), filt_freq,'cubic');
    end;
end;

%WILCOX ALL IN ONE SPECIAL CENTRE FREQUENCY ONLY%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if proc_option==1;
    %build full mode shape matrix including axial position and invert it
    full_mode_shapes=zeros(in_no_time_traces,2*length(tx_modes));
    for m_count=1:length(tx_modes);
        for tt_count=1:in_no_time_traces;
            ms_prod=tx_mode_shapes(m_count,tx_pos(tt_count))*rx_mode_shapes(m_count,rx_pos(tt_count));
            ph_prod=exp(2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
            full_mode_shapes(tt_count,m_count*2-1)=ms_prod*ph_prod;
            ph_prod=exp(-2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(-2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
            full_mode_shapes(tt_count,m_count*2)=ms_prod*ph_prod;        
        end;
    end;
    inv_full_mode_shapes=pinv(full_mode_shapes);

    %do the multiplication
    out_freq_data=zeros(fft_pts/2+1,2*length(tx_modes));
    for f_count=freq_start_count:freq_end_count;
        out_freq_data(f_count,:)=filt_freq_data(f_count,:) * inv_full_mode_shapes';
    end;
 end;
 
if ~exist('proc_vs_time_fig','var')
   proc_vs_time_fig=figure;
end;

figure(proc_vs_time_fig);
clf;

%plot time domain results
out_time_data=ifft(out_freq_data,fft_pts);
out_time_data=out_time_data(1:in_no_time_pts,:);
bkwd_indices=[2:2:size(out_time_data,2)];
fwd_indices=[1:2:size(out_time_data,2)-1];
out_time_data=[flipud(out_time_data(:,bkwd_indices));out_time_data(2:size(out_time_data,1),fwd_indices)];
out_time=[-flipud(in_time);in_time(2:length(in_time))];
for count=1:size(out_time_data,2);
   out_time_data(:,count)=out_time_data(:,count) .* (abs(out_time)>(dead_time/2));
end;
norm_val=max(max(abs(out_time_data)));
out_time_data=out_time_data/norm_val;
out_time_data(find(out_time_data==0))=norm_val/1e10;
temp=20*log10(abs(out_time_data));
temp=temp+dbrange;
temp=temp .* (temp>0);
temp=temp-dbrange;
ymin=-dbrange;
ymax=0;
plot_mode_indices=find(modes_to_plot);
for count=1:length(plot_mode_indices);
    subplot(length(plot_mode_indices),1,count);
    hold on;
    if count==1
        title(exp_fname);
    end;
    x=out_time/10^-3;
    y=temp(:,plot_mode_indices(count));
    plot(x,y,'r');
    axis([-max_time/10^-3,max_time/10^-3,ymin,ymax]);
    text(max_time*1.01/10^-3,0.5*(ymin+ymax),[Int2Str(tx_modes(plot_mode_indices(count))),' to ',Int2Str(rx_modes(plot_mode_indices(count)))]);   
    if count==length(plot_mode_indices)
        xlabel('Time(us)');
    end;
end;

%last lines - turn off features figure too
set(filter_button,'enable','on');
set(convert_to_dist_button,'enable','on');
set(feat_extr_button,'enable','off');
