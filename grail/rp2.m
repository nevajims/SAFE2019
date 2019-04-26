%Provisional rail experimental data processing

%Version 2

%Coded by Paul.

%DON'T CHANGE anything below the line that says END OF USEFUL INPUT unless you know what you're doing

%Useful output matrices are:
%out_dist_data - matrix of distance traces - complex numbers - real is RF, abs is envelope, each column is a distance trace
%out_dist - vector of distances, for plotting against columns from out_dist_data
%out_time_data and out_time, as above but w.r.t. time.

clear;
close all;

%Full path and name of the experimental file go here.
%Program uses the last one if you have more than one exp_fname='...' line
%exp_fname='C:\Paul\matlab\rail\rp2-simulated-15kHz.rla';
%exp_fname='n:\grail\exp-results\polmont\26m+\00130.rla';
exp_fname='D:\grail\Exp-Results\6-row-prototype\Crewe-6m-plain-sample\Export-2681-14kHz-edited.rla';
%exp_fname='D:\grail\Exp-Results\6-row-prototype\Crewe-6m-plain-sample\00130.rla';
%exp_fname='N:\grail\admin\data-for-coupling-review\Data-from-10row-rig\Weld-with-toe-defect\WR140-10#00081=20020221.rla'

%hardware filename
hardware_fname='D:\Grail\matlab\old_prototype';
%hardware_fname='D:\Grail\matlab\six_row_prototype';
run(hardware_fname);%loads it immediately

%compensation algorithm
norm_option=0;%how transducer coupling is compensated for 0=it ain't, 1=it is but badly, 2=it is a little better

%filtering (a Gaussian filter will be applied in the frequency points, after
%the experimental input signal has been compensated for
filter_freq=14e3;%filter centre frequency
filter_bandwidth=2.5e3;%filter half bandwidth to -40 dB points

%normalisation of processed results
abs_plot=0;%0 will normalise to max value in current processed results set, 1 will normalise to data value
datum=1;%normalising datum if abs-plot is set to 1

%graph options
log_plot=1;%1 for dB graphs of envelopes, 0 for time/distance traces
dbrange=40;%db range for dB graphs
max_time=10e-3;%max time shown on time traces
max_dist=10;%max(abs(feat_max_range));%max distance shown on distance traces
dist_step=0.01;%distance step on distance traces (can be coarser if looking at envelope (log) plots
direction=-1;%change sign to flip all graphs left for right
show_coupling_graphs=1;

%special mode shape export function
export_mode_shapes_file=1;%if set to one, the inverted mode shapes file 
%AT THE FILTER FREQUENCY is exported and no processing is performed,
%but an experimental data file is still loaded, as 
%the transducer indices are needed for the formulation of the mode shapes matrix

%Use following line to enable or disable complete rows of transducers
row_enable=ones(size(trans_pos,1));
%Use following line to enable or disable a transducer position in all rows
pos_enable=ones(size(trans_pos,2));
%Use this following line to disable specific transducers by setting
%corresponding element in trans_enable matix to zero - row = transducer row, col = transducer position
trans_enable=ones(size(trans_pos));
%use following to disable specific time-traces - each of following must have same length (=number of time-traces to disable)
time_trace_disable_tx_row=[];
time_trace_disable_tx_pos=[];
time_trace_disable_rx_row=[];
time_trace_disable_rx_pos=[];

%The following vectors (tx-modes, rx_modes, modes_to_plot and feat_find_modes)
%specify which modes are used in the calculation, which are plotted and which are
%used for feature extraction. Al vectors must have same number of elements
%tx_modes = modes used in transmission for calculation
%rx_modes = modes used in reception for calculation
%modes_to_plot = result is plotted if one, not if zero
%feat_find_modes = sets whether or not feature extraction routine looks for peaks
%a particular signal or not

tx_modes=      [3,5,7,8,10,  3,3,3,3,   5,5,5,5,   7,7,7,7,   8,8,8,8,   10,10,10,10];
rx_modes=      [3,5,7,8,10,  5,7,8,10,  3,7,8,10,  3,5,8,10,  3,5,7,10,  3,5,7,8];
modes_to_plot= [1,1,1,1,1   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0];
%modes_to_plot = ones(1,length(tx_modes));

dispersion_compensation=0;%????????????????
dead_time=0;

%END OF USEFUL INPUT

%Name of FE file to get mode shapes from - DONT CHANGE
fe_fname='D:\grail\matlab\fe-data\2D-models\5mm_tap';

%END OF INPUT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load FE data
tic;
load(fe_fname);
disp(['Loading FE data: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load experimental data file
tic;
load_exp_data2;
disp(['Loading experimental data: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%build mode shape matrices
tic;
tx_mode_shapes=zeros(length(tx_modes),length(trans_node_list));
tx_wavenos=zeros(length(tx_modes),1);
tx_vels=zeros(length(tx_modes),1);
rx_mode_shapes=zeros(length(tx_modes),length(trans_node_list));
rx_wavenos=zeros(length(tx_modes),1);
rx_vels=zeros(length(tx_modes),1);
for count=1:length(tx_modes);
	[start_index,end_index]=get_good_mode_indices(tx_modes(count),data_freq,data_mode_start_indices);
   tx_mode_shapes(count,:)=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',filter_freq,'cubic');
   tx_waveno(count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), filter_freq,'cubic');
   tx_vels(count)=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index), filter_freq,'cubic');
   [start_index,end_index]=get_good_mode_indices(rx_modes(count),data_freq,data_mode_start_indices);
   rx_mode_shapes(count,:)=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',filter_freq,'cubic');
   rx_waveno(count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), filter_freq,'cubic');
   rx_vels(count)=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index), filter_freq,'cubic');
end;
 
%build full mode shape matrix including axial position and invert it for centre frequency only
full_mode_shapes=zeros(in_no_time_traces,2*length(tx_modes));
temp_dir=zeros(2*length(tx_modes),1);
temp_tx_modes=zeros(2*length(tx_modes),1);
temp_rx_modes=zeros(2*length(tx_modes),1);
for m_count=1:length(tx_modes);
	for tt_count=1:in_no_time_traces;
   	ms_prod=tx_mode_shapes(m_count,tx_pos(tt_count))*rx_mode_shapes(m_count,rx_pos(tt_count));
      ph_prod=exp(2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
      full_mode_shapes(tt_count,m_count*2-1)=ms_prod*ph_prod;
      temp_dir(m_count*2-1)=-direction;
      temp_tx_modes(m_count*2-1)=tx_modes(m_count);
      temp_rx_modes(m_count*2-1)=rx_modes(m_count);
      ph_prod=exp(-2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(-2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
      full_mode_shapes(tt_count,m_count*2)=ms_prod*ph_prod;        
      temp_dir(m_count*2)=direction;
      temp_tx_modes(m_count*2)=tx_modes(m_count);
      temp_rx_modes(m_count*2)=rx_modes(m_count);
   end;
end;
inv_full_mode_shapes=pinv(full_mode_shapes);
disp(['Mode shape matrices built: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%export mode shapes file if desired
if export_mode_shapes_file;
	tic;
   temp=[tx_row';tx_pos';rx_row';rx_pos';real(inv_full_mode_shapes);imag(inv_full_mode_shapes)];
   temp=[[zeros(4,1);temp_tx_modes;temp_tx_modes],[zeros(4,1);temp_rx_modes;temp_rx_modes],[zeros(4,1);temp_dir;temp_dir],temp];
   save c:\temp\rail_mode_shapes.txt temp -ascii -double -tabs
   disp(['Mode shape file exported: ',num2str(toc)]);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%remove data from any disbaled rows/positions/transducers and multiply out to remove transducer phasing
c=1;
temp_data=zeros(size(in_time_data));
temp_tx_pos=zeros(size(tx_pos));
temp_rx_pos=zeros(size(rx_pos));
temp_tx_row=zeros(size(tx_row));
temp_rx_row=zeros(size(rx_row));
for count=1:in_no_time_traces;
    if pos_enable(tx_pos(count))& ...
            pos_enable(rx_pos(count))& ...
            row_enable(tx_row(count))& ...
            row_enable(rx_row(count))& ...
            trans_enable(tx_row(count),tx_pos(count))& ...
            trans_enable(rx_row(count),rx_pos(count));
        %check if specifi tt is disabled
        enabled=1;
        for ii=1:length(time_trace_disable_tx_row);
            if (time_trace_disable_tx_row(ii)==tx_row(count))& ...
                    (time_trace_disable_tx_pos(ii)==tx_pos(count))& ...
                    (time_trace_disable_rx_row(ii)==rx_row(count))& ...
                    (time_trace_disable_rx_pos(ii)==rx_pos(count));
                enabled=0;
            end;
        end;
        if enabled;
            temp_data(:,c)=in_time_data(:,count)*trans_pos_phasings(tx_pos(count))*trans_pos_phasings(rx_pos(count));
            temp_tx_pos(c)=tx_pos(count);
            temp_rx_pos(c)=rx_pos(count);
            temp_tx_row(c)=tx_row(count);
            temp_rx_row(c)=rx_row(count);
            c=c+1;
        end;
    end;
end;
c=c-1;
in_no_time_traces=c;
in_time_data=temp_data(:,1:c);
tx_pos=temp_tx_pos(1:c);
rx_pos=temp_rx_pos(1:c);
tx_row=temp_tx_row(1:c);
rx_row=temp_rx_row(1:c);
clear temp_*;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conversion to frequency domain, compensate for input signal spectrum
%and compensate for transmission delay in wavemaker
tic;
time_pts=size(in_time_data,1);
fft_pts=2^nextpow2(time_pts);
in_freq_data=fft(in_time_data,fft_pts);
in_freq_data=in_freq_data(1:fft_pts/2+1,:);
time_step=in_time(2)-in_time(1);

in_time = ([1:fft_pts]-1) * time_step;
in_signal=0.5 * sin(2 * pi * in_freq * in_time) .* (1 - cos(2 * pi * in_freq * in_time / in_cycles)) .* (in_time<in_cycles/in_freq);;
in_spec=fft(in_signal,fft_pts);
in_spec=abs(in_spec(1:fft_pts/2+1))';
in_valid = in_spec>0;
in_spec(~in_valid) = 1;

freq_step=1/(fft_pts*time_step);
freq=[0:fft_pts/2]*freq_step;
freq_start_count=floor((filter_freq-filter_bandwidth)/freq_step);
freq_end_count=ceil((filter_freq+filter_bandwidth)/freq_step);
freq_cent_count=round(filter_freq/freq_step);
delay=in_cycles / in_freq * wavemaker_delay_factor;
for tt_count=1:in_no_time_traces;
    in_freq_data(:,tt_count)=in_freq_data(:,tt_count) .* exp(-2*pi*i*freq*delay)' ./ in_spec .* in_valid;
end;
disp(['Converting to frequency domain: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%do the transducer coupling graph (before any coupling compensation)
if show_coupling_graphs;
	tic;
	trans_amp=zeros(size(trans_pos));
	for count=1:size(in_freq_data,2);
   	trans_amp(tx_row(count),tx_pos(count))=trans_amp(tx_row(count),tx_pos(count))+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));
	   trans_amp(rx_row(count),rx_pos(count))=trans_amp(rx_row(count),rx_pos(count))+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));   
	end;
	figure;
	hold on;
	trans_amp=trans_amp/max(max(abs(trans_amp)));
	temp=zeros(1,5);
	for r_count=1:size(trans_pos,1);
   	for c_count=1:size(trans_pos,2);
      	amp=trans_amp(r_count,c_count)/2;
	      temp(1)=c_count+amp+i*r_count;
   	   temp(2)=c_count+i*(r_count+amp);
      	temp(3)=c_count-amp+i*r_count;
	      temp(4)=c_count+i*(r_count-amp);
   	   temp(5)=temp(1);
      	plot(temp);
	   end;
	end;
	xlabel('Position');
	ylabel('Row');
	title('Transducer signal amplitude before compensation');
	disp(['Computing coupling graph before compensation: ',num2str(toc)]);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%coupling compensation
tic;
if norm_option==1;
%   Stupid one - normalise each time trace by sum of spectral amps
    for count=1:in_no_time_traces;
        in_freq_data(:,count)=in_freq_data(:,count)/sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));
    end;
end;
if norm_option==2;
%   use mean spectral amp to work back to find individual transducer coupling
    ideal_amplitude=ones(size(trans_pos));%change this later to suit energy distribution in all modes of interest
    trans_weight=ones(size(trans_pos));
    amplitude=sum(abs(in_freq_data(freq_start_count:freq_end_count,:)));
    amplitude=amplitude/mean(amplitude);
    for i_count=1:10;
        trans_amp=zeros(size(trans_pos));
        for count=1:in_no_time_traces;
           trans_amp(tx_row(count),tx_pos(count))=trans_amp(tx_row(count),tx_pos(count)) + ...
              amplitude(count)*trans_weight(tx_row(count),tx_pos(count))*trans_weight(rx_row(count),rx_pos(count));
           trans_amp(rx_row(count),rx_pos(count))=trans_amp(rx_row(count),rx_pos(count)) + ...
              amplitude(count)*trans_weight(tx_row(count),tx_pos(count))*trans_weight(rx_row(count),rx_pos(count));
        end;
        trans_amp(find(trans_pos==0)) = 1; %avoid divide by zero errors
        trans_weight=trans_weight .* (ideal_amplitude ./ trans_amp) .^ 0.5;
    end;
    for count=1:in_no_time_traces;
    	in_freq_data(:,count)=in_freq_data(:,count)*trans_weight(tx_row(count),tx_pos(count))*trans_weight(rx_row(count),rx_pos(count));
    end;
    
end;
disp(['Coupling compensation: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%do the transducer coupling graph (after any coupling compensation)
if show_coupling_graphs;
	tic;
	trans_amp=zeros(size(trans_pos));
	for count=1:size(in_freq_data,2);
   	trans_amp(tx_row(count),tx_pos(count))=trans_amp(tx_row(count),tx_pos(count))+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));
	   trans_amp(rx_row(count),rx_pos(count))=trans_amp(rx_row(count),rx_pos(count))+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));   
	end;
	figure;
	hold on;
	trans_amp=trans_amp/max(max(abs(trans_amp)));
	temp=zeros(1,5);
	for r_count=1:size(trans_pos,1);
   	for c_count=1:size(trans_pos,2);
      	amp=trans_amp(r_count,c_count)/2;
	      temp(1)=c_count+amp+i*r_count;
   	   temp(2)=c_count+i*(r_count+amp);
      	temp(3)=c_count-amp+i*r_count;
	      temp(4)=c_count+i*(r_count-amp);
   	   temp(5)=temp(1);
      	plot(temp);
	   end;
	end;
	xlabel('Position');
	ylabel('Row');
	title('Transducer signal amplitude after compensation');
	disp(['Computing coupling graph after compensation: ',num2str(toc)]);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main mode extraction
tic;

%actually do the multiplication to convert the raw freq domain data
%to mode extracted freq domain data
out_freq_data=zeros(fft_pts/2+1,2*length(tx_modes));
out_freq_data(freq_start_count:freq_end_count,:)=in_freq_data(freq_start_count:freq_end_count,:) * inv_full_mode_shapes';
disp(['Main mode extraction: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filtering and return to time domain
tic;
filter=gaussian(fft_pts/2+1,filter_freq/max(freq),filter_bandwidth/max(freq));
for count=1:size(out_freq_data,2);
    out_freq_data(:,count)=out_freq_data(:,count) .* filter';
end;
out_time_data=ifft(out_freq_data,fft_pts);
out_time_data=out_time_data(1:in_no_time_pts,:);
bkwd_indices=[2:2:size(out_time_data,2)];
fwd_indices=[1:2:size(out_time_data,2)-1];
out_time_data=[flipud(out_time_data(:,bkwd_indices));out_time_data(2:size(out_time_data,1),fwd_indices)];
out_time=[-fliplr(in_time(1:in_no_time_pts)),in_time(2:in_no_time_pts)];
disp(['Filtering and returning to time domain: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%convert to distance
tic;
out_dist=[0:round(max_dist/dist_step)]'*dist_step;
out_dist=[-flipud(out_dist);out_dist(2:length(out_dist))];
out_dist_data=zeros(length(out_dist),size(out_time_data,2));
for count=1:size(out_time_data,2);
   if dispersion_compensation;
      for dir_count=1:2;
			if dir_count==1;         
            sig=flipud(out_time_data(1:floor(size(out_time_data,1)/2),count));
         else
            sig=out_time_data(floor(size(out_time_data,1)/2)+1:floor(size(out_time_data,1)),count);
         end;
         over_sampling=8;
         sig_spec=fft(sig,fft_pts*over_sampling);
         sig_spec=sig_spec(1:fft_pts*over_sampling/2+1);
         freq_step=1/(time_step*fft_pts*over_sampling);
         freq=[0:fft_pts*over_sampling/2]*freq_step;
         
         [i1_tx,i2_tx]=get_good_mode_indices(tx_modes(count),data_freq,data_mode_start_indices);
         [i1_rx,i2_rx]=get_good_mode_indices(rx_modes(count),data_freq,data_mode_start_indices);
         
         disp_waveno_tx=data_freq(i1_tx:i2_tx) ./ data_ph_vel(i1_tx:i2_tx);
         disp_freq_tx=data_freq(i1_tx:i2_tx);
         disp_waveno_tx_interp=interp1(disp_freq_tx,disp_waveno_tx,freq);
         
         disp_waveno_rx=data_freq(i1_rx:i2_rx) ./ data_ph_vel(i1_rx:i2_rx);
         disp_freq_rx=data_freq(i1_rx:i2_rx);
         disp_waveno_rx_interp=interp1(disp_freq_rx,disp_waveno_rx,freq);
         
         disp_waveno_interp=(disp_waveno_tx_interp+disp_waveno_rx_interp)/2;
         disp_waveno_interp(find(isnan(disp_waveno_interp)))=0;
         disp_waveno_interp(find(isinf(disp_waveno_interp)))=0;
         
         [i1,i2,inc]=smart_monotonic_range(disp_waveno_interp);
         
         spat_fft_pts=2^nextpow2(ceil(size(out_dist,1)/2));
         waveno_step=1/(spat_fft_pts*dist_step);
         waveno=[0:spat_fft_pts/2]*waveno_step;
         
         freq_at_waveno=interp1(disp_waveno_interp(i1:i2),freq(i1:i2),waveno);         
         freq_at_waveno(find(isnan(freq_at_waveno)))=0;
         freq_at_waveno(find(isinf(freq_at_waveno)))=0;
         
         sig_spat_spec=interp1(freq,sig_spec,freq_at_waveno);
         sig_spat=ifft(sig_spat_spec,spat_fft_pts);
			if dir_count==1;         
            out_dist_data(1:floor(size(out_dist_data,1)/2),count)=flipud(sig_spat(1:floor(size(out_dist_data,1)/2)).');
         else
            out_dist_data(floor(size(out_dist_data,1)/2)+1:size(out_dist_data,1),count)=sig_spat(1:size(out_dist_data,1)-(floor(size(out_dist_data,1)/2+1))+1).';
         end;
      end;
    else
        vel=1/(1/tx_vels(ceil(count))+1/rx_vels(ceil(count)));
        d=out_time*vel;
        out_dist_data(:,count)=interp1(d,out_time_data(:,count),out_dist,'cubic');
    end;
end;
disp(['Conversion to distance: ',num2str(toc)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%END OF PROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%normalisation if required
if abs_plot;
    norm_val=datum;
else
    norm_val=max(max(abs(out_time_data)));
end;
out_time_data=out_time_data/norm_val;
out_dist_data=out_dist_data/norm_val;
out_time_data(find(out_time_data==0))=norm_val/1e10;
out_dist_data(find(out_dist_data==0))=norm_val/1e10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%graphing
if log_plot;
    out_time_data(find(out_time_data==0))=norm_val/1e10;
    temp=20*log10(abs(out_time_data));
    temp=temp+dbrange;
    temp=temp .* (temp>0);
    temp=temp-dbrange;
    ymin=-dbrange;
    ymax=0;
else
    temp=real(out_time_data);
    ymin=-1;
    ymax=1;
end;

%plot time domain results
f=figure;%vs time
set(f,'Position',[400 300 540 400])
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

if log_plot;
    out_dist_data(find(out_dist_data==0))=norm_val/1e10;
    temp=20*log10(abs(out_dist_data));
    temp=temp+dbrange;
    temp=temp .* (temp>0);
    temp=temp-dbrange;
    ymin=-dbrange;
    ymax=0;
else
    temp=real(out_dist_data);
    ymin=-1;
    ymax=1;
end;

f=figure;%vs distance
set(f,'Position',[400 300 540 400])
for count=1:length(plot_mode_indices);
    distplot=subplot(length(plot_mode_indices),1,count);
    hold on;
    if count==1
        title(exp_fname);
    end;
    x=out_dist;
    y=temp(:,plot_mode_indices(count));
    plot(x,y,'k');
    axis([-max_dist,max_dist,ymin,ymax]);
    plot([-max_dist max_dist],[-30 -30],'m-.');
    ylabel('dB');
    text(max_dist*1.02,0.5*(ymin+ymax),[Int2Str(tx_modes(plot_mode_indices(count))),' to ',Int2Str(rx_modes(plot_mode_indices(count)))]);  
    if count==length(plot_mode_indices)
        xlabel('Distance(m)');
    end;
end;

