%Provisional rail experimental data processing

%Version 1

%Coded by Paul.

%DON'T CHANGE anything below the line that says END OF USEFUL INPUT unless you know what you're doing

%Useful output matrices are:
%out_dist_data - matrix of distance traces - complex numbers - real is RF, abs is envelope, each column is a distance trace
%out_dist - vector of distances, for plotting against columns from out_dist_data
%out_time_data and out_time, as above but w.r.t. time.

%if you want to do keep trying different processing on the SAME file, set new file to 0
%this keeps the data in memory and doesn't reload it, which in theory saves time
new_file=1;
if new_file;
    clear;
    new_file=1;
end;
close all;

pdw_test=0; %set to zero if you ain't me

%Full path and name of the experimental file go here.
%Program uses the last one if you have more than one exp_fname='...' line
%exp_path='n:\grail\matlab\exp-data\gauge-corner\';
exp_path='n:\grail\exp-results\polmont\26m+\';
exp_path='N:\grail\admin\data-for-coupling-review\Data-from-10row-rig\Weld-with-toe-defect\'
%exp_path='n:\grail\exp-results\ic-rails\';
%exp_path='n:\grail\exp-results\thermit-broxbourne\';
%exp_path='n:\grail\matlab\exp-data\internal-defect\';
%exp_fname='new-rail-with-slot-downstairs-at-ic-row10data-missing-test5.rla';
%exp_fname='new-rail-with-slot-downstairs-at-ic-row10data-missing-test7.rla';
%exp_fname='old-rail-with-possible-crack-downstairs-at-ic-row10data-missing-test8.rla';
%exp_fname='short_rail_in_office.rla';
%exp_fname='new-rail-with-slot-downstairs-at-ic-row10data-missing-test6.rla';
%exp_fname='rail--676CH-15kHz-5cyc-new rail 4 averages.rla';
%exp_fname='n:\grail\matlab\exp-data\slottedrail-after-realigning.rla';
%exp_fname='asymmetric-head-30mm-40db-1ave-15khp--676CH-15kHz-5cyc.rla';
%exp_fname='gauge-corner-0mm-40db-1ave-15khp--676CH-15kHz-5cyc.rla';
%exp_fname='gauge-corner-14mm-40db-1average-15khp--676CH-15kHz-5cyc.rla';
%exp_fname='10mm-trans-head-crack-40db-1avs--676CH-15kHz-5cyc-test01.rla';
%exp_fname='20mm-trans-head-crack-35db-4avs--676CH-15kHz-5cyc-test01.rla';
%exp_fname='30mm-trans-head-crack-35db-4avs--676CH-15kHz-5cyc-test01.rla';
exp_fname='WR140-10#00081=20020221.rla';
%exp_fname='rail-rx-test.rla';
%exp_fname='asymmetric-head-30mm-40db-1ave-15khp--676CH-15kHz-5cyc.rla';
%exp_fname='newrail-40db-1avs--676CH-15kHz-5cyc-test01.rla';
%exp_fname='brox-good-rail-10m-from-joint-16CH-15kHz-5cyc-test01.rla';
%exp_fname='bros-20m-old-rail-5000pts-676CH-15kHz-5cyc-test01.rla';
%exp_fname='thermit-rail2-batt-4avs-3-43m-from-end--676CH-15kHz-5cyc-test01.rla';
%exp_fname='thermit-rail1-batt-3-43m-from-end--676CH-15kHz-5cyc-test01.rla';
%exp_fname='internalrail--676CH-15kHz-10cyc-test01.rla';
%exp_fname='35mm-trans-head-crack-35db-4avs--676CH-15kHz-5cyc-test01.rla';
%exp_fname='new-rail-with-slot-downstairs-at-ic-row10data-missing-test5.rla';
%exp_fname='internal bead off 15khp rail--676CH-15kHz-10cyc-test01.rla';
%exp_fname='internal bead on rail--676CH-15kHz-10cyc-test01.rla';

%filtering/processing
norm_option=0;%how transducer coupling is compensated for 0=it ain't, 1=it is but badly, 2=it is a little better
filt_freq=15e3;%filter centre frequency
bandwidth=4.5e3;%filter half bandwidth to -40 dB points

%normalisation of processed results
abs_plot=0;%0 will normalise to max value in current processed results set,1 will normalise to data value
datum=3.0065e+005;%normalising datum if abs-plot is set to 1

%feature extraction
feature_extraction_on=1;
feat_thresh=-25;%any feature breaking this level gets analysed
feat_length=1.5;%distance that is analysed around each feature
feat_max_range=[-0 20];%distance past which features are ignored in metres, these should be the known ends of the rail
feat_resolution=3.0;%minimum distance from rig that features will be looked for
max_feats=3;%max number of features toget analysed (working away from rig location)(use to prevent cross talk being analysed as features, and make graphs look pretty)
dead_time=0.25e-3;%length in seconds of zeroed portion of processed data vs. time graph at rig location
calibration=0;%turns on or off the scaling of defect echoes based on predicted reflection coefficients
calibration_feat_type=1;%this uses the known reflection coefficient data to normalize for plotting. 1- end, 2- thermit weld (not implemented yet)
calibration_feat_data=[1.0097 0.9774 0.6232 0.9924 0.9187;0 0 0 0 0];%these are the reflection coefficients calculated for the above feature types for the first 5 reflection coefficients ie 3-3 5-5 7-7 8-8 and 10-10

%graph options
log_plot=1;%1 for dB graphs of envelopes, 0 for time/distance traces
dbrange=40;%db range for dB graphs
direction=-1;%change sign to flip all graphs left for right
max_time=10e-3;%max time shown on time traces
max_dist=10;%max(abs(feat_max_range));%max distance shown on distance traces
max_dist=max(abs(feat_max_range));%max distance shown on distance traces
dist_step=0.01;%distance step on distance traces (can be coarser if looking at envelope (log) plots
one_feature_graph=0;%0 gives each feature it's own graph, 1 gives all on one graph **warning, if more that 3 interp surfaces are plotted on one graph the shading is wrong****
secret_option=0;%turns off the useful graph axes 
export_mode_shapes_file=1;

%Use following line to enable or disable complete rows of transducers
row_enable=[1,1,1,1,1,1,1,1,1,1];
%Use following line to enable or disable a transducer position in all rows
pos_enable=[1,1,1,1,1,1,1,1,1,1,1,1];
%Use this following line to disable specific transducers by setting
%corresponding element in trans_enable matix to zero - row = transducer row, col = transducer position
trans_enable=ones(10,12);
%trans_enable(6:8,6:7)=zeros(3,2);
%trans_enable(9,3)=0;
%trans_enable(3,7)=0;
%trans_enable(4,6)=0;
%trans_enable(1,3)=0;
%e.g. trans_enable(3,4)=0;
%use following to disable specific time-traces
%time_trace_disable_tx_row=[3,3,3,3,3,3,3,3,3,3,3];
%time_trace_disable_tx_pos=[7,7,7,7,7,9,9,9,9,9,9];
%time_trace_disable_rx_row=[9,9,8,8,6,6,6,9,9,9,9];
%time_trace_disable_rx_pos=[5,8,9,4,4,6,11,10,3,5,8];
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
modes_to_plot= [0,1,0,0,0,   0,0,0,0,   1,1,1,1,   0,0,0,0,   0,0,0,0,   0,0,0,0];
%tx_modes=      [3,5,9,7,8,10,8,10  3,3,3,3,   5,5,5,5,   7,7,7,7,   8,8,8,8,   10,10,10,10];
%rx_modes=      [3,5,9,7,8,10,9,9  5,7,8,10,  3,7,8,10,  3,5,8,10,  3,5,7,10,  3,5,7,8];
%modes_to_plot= [1,1,1,1,1,1,1,1   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0];
feat_find_modes=[0,0,0,1,1,   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0];%these are the modes that features are detected in

dispersion_compensation=0;

%END OF USEFUL INPUT
proc_option=3;%as good as any

if pdw_test==1;
	%exp_path='n:\grail\exp-results\thermit-broxbourne\';
   %exp_fname='thermit-rail2-batt-4avs-3-43m-from-end--676CH-15kHz-5cyc-test01.rla';
   export_mode_shapes_file=1;
    feat_max_range=[-20 2];   
	max_time=20e-3;%max time shown on time traces
   max_dist=20;%max(abs(feat_max_range));%max distance shown on distance traces
   feature_extraction_on=0;
   dispersion_compensation=0;
	modes_to_plot= [1,1,1,1,1,   1,1,1,1,   1,1,1,1,   1,1,1,1,   1,1,1,1,   1,1,1,1];
   modes_to_plot= [1,1,1,1,1,   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0,   0,0,0,0];
   proc_option=1;
end;


%Name of FE file to get mode shapes from - DONT CHANGE
fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';

%Phasings of transducer positions (i.e. orientations of transducers) - DON'T CHANGE
trans_pos_phasings=[0,1,1,-1,1,1,-1,-1,1,-1,-1,0];
%Node positions in FEfile corresponding to transducer positions - DON'T CHANGE
trans_node_list=[63 53 306 72 107 139 251 279 241 409 151 197];

use_pulse_echo26=1;
%Axial position of rows is set here - DON'T CHANGE
%temp=0.0413;%inter-row spacing of transducers on either side of same plate (with rubber pads)
temp=0.038;%inter-row spacing of transducers on either side of same plate (normal)
if use_pulse_echo26;
    tmpOffset = 0.090+temp/2-0.007;
    trans_row_pos=[tmpOffset-(0.076+0.090)-temp/2,tmpOffset-(0.076+0.090)+temp/2,tmpOffset-0.090-temp/2,tmpOffset-0.090+temp/2,tmpOffset-temp/2,tmpOffset-temp/2,tmpOffset-0.090+temp/2,tmpOffset-0.090-temp/2,tmpOffset-(0.076+0.090)+temp/2,tmpOffset-(0.076+0.090)-temp/2];
else
    trans_row_pos=[-(0.076+0.090)-temp/2,-(0.076+0.090)+temp/2,-0.090-temp/2,-0.090+temp/2,-temp/2];
    trans_row_pos=[trans_row_pos,-fliplr(trans_row_pos)];  % For 52 channel Pitch-Catch
end;

%Processing option:
%1=wilcox all in one, centre freq only
%2=wilcox all in one, freq tracking for inter row phasings
%3=wilcox all in one, freq tracking for inter row phasings and mode shapes
max_save_cond_number=10;%only applicable for processing options 2 and 3

%END OF INPUT

tic;
fname=[exp_path,exp_fname];
load_exp_data;
in_time_data=in_time_data/2;
if new_file;
    load(fe_fname);
    disp(['Loading time: ',num2str(toc)]);
end;

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

%conversion to frequency domain and compensate for transmission delay in wavemaker
tic;
time_pts=size(in_time_data,1);
fft_pts=2^nextpow2(time_pts);
in_freq_data=fft(in_time_data,fft_pts);
in_freq_data=in_freq_data(1:fft_pts/2+1,:);
time_step=in_time(2)-in_time(1);
freq_step=1/(fft_pts*time_step);
freq=[0:fft_pts/2]*freq_step;
freq_start_count=floor((filt_freq-bandwidth)/freq_step);
freq_end_count=ceil((filt_freq+bandwidth)/freq_step);
freq_cent_count=round(filt_freq/freq_step);
delay=in_cycles/in_freq/2 *1.5;%1.5 is a fiddle cos I don't know what wavemaker delay is
for tt_count=1:in_no_time_traces;
    in_freq_data(:,tt_count)=in_freq_data(:,tt_count) .* exp(-2*pi*i*freq*delay)';
end;

disp(['Converting to frequency domain: ',num2str(toc)]);

%transducer coupling graph
tic;
trans_pos=[1:12];
trans_row=[1:10];
trans_amp=zeros(length(trans_pos),length(trans_row));
trans_amp2=zeros(size(trans_row_lookup));
for count=1:size(in_freq_data,2);
   trans_amp(trans_pos(tx_pos(count)),trans_row(tx_row(count)))=trans_amp(trans_pos(tx_pos(count)),trans_row(tx_row(count)))+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));
   trans_amp(trans_pos(rx_pos(count)),trans_row(rx_row(count)))=trans_amp(trans_pos(rx_pos(count)),trans_row(rx_row(count)))+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));   
   ii=find((trans_row_lookup==tx_row(count))&(trans_pos_lookup==tx_pos(count)));
   trans_amp2(ii)=trans_amp2(ii)+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));
   ii=find((trans_row_lookup==rx_row(count))&(trans_pos_lookup==rx_pos(count)));
   trans_amp2(ii)=trans_amp2(ii)+sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));
end;
figure;
hold on;
trans_amp=trans_amp/max(max(abs(trans_amp(:,1:10))))/2;
temp=zeros(1,5);
for r_count=1:length(trans_pos);
   for c_count=1:10;
      amp=trans_amp(trans_pos(r_count),trans_row(c_count));
      temp(1)=r_count+amp+i*c_count;
      temp(2)=r_count+i*(c_count+amp);
      temp(3)=r_count-amp+i*c_count;
      temp(4)=r_count+i*(c_count-amp);
      temp(5)=temp(1);
      plot(temp);
   end;
end;
disp(['Computing coupling graph: ',num2str(toc)]);
%normalisation
tic;
if norm_option==1;
%   Stupid one - normalise each time trace by sum of spectral amps
    for count=1:in_no_time_traces;
        in_freq_data(:,count)=in_freq_data(:,count)/sum(abs(in_freq_data(freq_start_count:freq_end_count,count)));
    end;
end;
if norm_option==2;
%   use mean spectral amp to work back to find individual transducer coupling
    ideal_amplitude=ones(size(trans_row_lookup));%change this later to suit energy distribution in all modes of interest
    trans_weight=ones(size(trans_row_lookup));
    amplitude=sum(abs(in_freq_data(freq_start_count:freq_end_count,:)));
    amplitude=amplitude/mean(amplitude);
    for i_count=1:10;
        trans_amp=zeros(size(trans_row_lookup));
        for count=1:size(in_freq_data,2);
            it=find((trans_row_lookup==tx_row(count))&(trans_pos_lookup==tx_pos(count)));
            ir=find((trans_row_lookup==rx_row(count))&(trans_pos_lookup==rx_pos(count)));
            trans_amp(it)=trans_amp(it)+amplitude(count)*trans_weight(it)*trans_weight(ir);
            trans_amp(ir)=trans_amp(ir)+amplitude(count)*trans_weight(it)*trans_weight(ir);
        end;
        good_index=trans_amp>0;%mean(trans_amp/100));%ignore any transducers with less than 100th of mean amplitude
        trans_amp(find(not(good_index)))=1;
        trans_weight=trans_weight .* (ideal_amplitude ./ trans_amp) .^ 0.5 .* good_index;
     end;
     temp=ones(676,1);
    for count=1:size(in_freq_data,2);
        it=find((trans_row_lookup==tx_row(count))&(trans_pos_lookup==tx_pos(count)));
        ir=find((trans_row_lookup==rx_row(count))&(trans_pos_lookup==rx_pos(count)));
        in_freq_data(:,count)=in_freq_data(:,count)*trans_weight(it)*trans_weight(ir);
        temp(count)=temp(count)*trans_weight(it)*trans_weight(ir);
    end;
end;
disp(['Normalisation: ',num2str(toc)]);

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

if export_mode_shapes_file;
   temp=[tx_row';tx_pos';rx_row';rx_pos';real(inv_full_mode_shapes);imag(inv_full_mode_shapes)];
   temp=[[zeros(4,1);temp_tx_modes;temp_tx_modes],[zeros(4,1);temp_rx_modes;temp_rx_modes],[zeros(4,1);temp_dir;temp_dir],temp];
   save c:\temp\rail_mode_shapes.txt temp -ascii -double -tabs
   end;
 
 %do the multiplication
    out_freq_data=zeros(fft_pts/2+1,2*length(tx_modes));
    for f_count=freq_start_count:freq_end_count;
        out_freq_data(f_count,:)=in_freq_data(f_count,:) * inv_full_mode_shapes';
    end;
end;

%WILCOX ALL IN ONE SPECIAL WITH FREQUENCY TRACKING FOR PHASINGS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if proc_option==2;
    cond_number=zeros(size(freq));
    %build full mode shape matrix without axial position and invert it
    out_freq_data=zeros(fft_pts/2+1,2*length(tx_modes));
    full_mode_shapes=zeros(in_no_time_traces,2*length(tx_modes));
    full_mode_shapes_no_phase=zeros(in_no_time_traces,2*length(tx_modes));
    full_mode_shapes_only_phase=zeros(in_no_time_traces,2*length(tx_modes));
    for tt_count=1:in_no_time_traces;
        for m_count=1:length(tx_modes);
            ms_prod=tx_mode_shapes(m_count,tx_pos(tt_count))*rx_mode_shapes(m_count,rx_pos(tt_count));
            full_mode_shapes_no_phase(tt_count,m_count*2-1)=ms_prod;
            full_mode_shapes_no_phase(tt_count,m_count*2)=ms_prod;        
        end;
    end;
    
    f_count_index=[freq_cent_count:freq_end_count,freq_cent_count-1:-1:freq_start_count];
    %work up from centre frequency
    for ff_count=1:length(f_count_index);
        f_count=f_count_index(ff_count);
        for m_count=1:length(tx_modes);
            %get wavenumbers
            [start_index,end_index]=get_good_mode_indices(tx_modes(m_count),data_freq,data_mode_start_indices);
            tx_waveno(m_count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), freq(f_count),'cubic');
            [start_index,end_index]=get_good_mode_indices(rx_modes(m_count),data_freq,data_mode_start_indices);
            rx_waveno(m_count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), freq(f_count),'cubic');
            for tt_count=1:in_no_time_traces;
                ph_prod=exp(2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
                full_mode_shapes_only_phase(tt_count,m_count*2-1)=ph_prod;
                ph_prod=exp(-2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(-2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
                full_mode_shapes_only_phase(tt_count,m_count*2)=ph_prod;        
            end;
        end;
        full_mode_shapes=full_mode_shapes_only_phase .* full_mode_shapes_no_phase;
        inv_full_mode_shapes=pinv(full_mode_shapes);
        %check condition number and revert to last safe one if it fails
        cond_number(f_count)=cond(inv_full_mode_shapes);
        if ff_count==1;
            last_safe_inv_full_mode_shapes=inv_full_mode_shapes;
        else
            if cond_number(f_count)>max_save_cond_number;
                inv_full_mode_shapes=last_safe_inv_full_mode_shapes;
                cond_number(f_count)=cond(inv_full_mode_shapes);
            else
                last_safe_inv_full_mode_shapes=inv_full_mode_shapes;
            end;
        end;
        %do the multiplication for all spectral components at current frequency
        out_freq_data(f_count,:)=in_freq_data(f_count,:) * inv_full_mode_shapes';
    end;
end;
    
%WILCOX ALL IN ONE SPECIAL WITH FREQUENCY TRACKING FOR PHASINGS AND MODE SHAPES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if proc_option==3;
    cond_number=zeros(size(freq));
    %build full mode shape matrix without axial position and invert it
    freq_start_count=floor((in_freq-bandwidth)/freq_step);
    freq_end_count=ceil((in_freq+bandwidth)/freq_step);
    out_freq_data=zeros(fft_pts/2+1,2*length(tx_modes));
    full_mode_shapes=zeros(in_no_time_traces,2*length(tx_modes));
    
    %work out from centre frequency
    f_count_index=[freq_cent_count:freq_end_count,freq_cent_count-1:-1:freq_start_count];
    for ff_count=1:length(f_count_index);
        f_count=f_count_index(ff_count);
        for m_count=1:length(tx_modes);
            %get wavenumbers
            [start_index,end_index]=get_good_mode_indices(tx_modes(m_count),data_freq,data_mode_start_indices);
            tx_waveno(m_count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), freq(f_count),'cubic');
            tx_mode_shapes(m_count,:)=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',freq(f_count),'cubic');
            if ff_count==1;
                tx_vels(m_count)=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index), filt_freq,'cubic');
            end;
            [start_index,end_index]=get_good_mode_indices(rx_modes(m_count),data_freq,data_mode_start_indices);
            rx_waveno(m_count)=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index), freq(f_count),'cubic');
            rx_mode_shapes(m_count,:)=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',freq(f_count),'cubic');
            if ff_count==1;
                rx_vels(m_count)=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index), filt_freq,'cubic');
            end;
            for tt_count=1:in_no_time_traces;
                ms_prod=tx_mode_shapes(m_count,tx_pos(tt_count))*rx_mode_shapes(m_count,rx_pos(tt_count));
                ph_prod=exp(2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
                full_mode_shapes(tt_count,m_count*2-1)=ph_prod*ms_prod;
                ph_prod=exp(-2*pi*i*tx_waveno(m_count)*trans_row_pos(tx_row(tt_count))*direction)*exp(-2*pi*i*rx_waveno(m_count)*trans_row_pos(rx_row(tt_count))*direction);
                full_mode_shapes(tt_count,m_count*2)=ph_prod*ms_prod;
            end;
        end;
        inv_full_mode_shapes=pinv(full_mode_shapes);
        %check condition number and revert to last safe one if it fails
        cond_number(f_count)=cond(inv_full_mode_shapes);
        if ff_count==1;
            last_safe_inv_full_mode_shapes=inv_full_mode_shapes;
        else
            if cond_number(f_count)>max_save_cond_number;
                inv_full_mode_shapes=last_safe_inv_full_mode_shapes;
                cond_number(f_count)=cond(inv_full_mode_shapes);
            else
                last_safe_inv_full_mode_shapes=inv_full_mode_shapes;
            end;
        end;
        %do the multiplication for all spectral components at current frequency
        out_freq_data(f_count,:)=in_freq_data(f_count,:) * inv_full_mode_shapes';
    end;
end;

disp(['Main mode extraction: ',num2str(toc)]);

%filtering and return to time domain
tic;
filter=gaussian(fft_pts/2+1,filt_freq/max(freq),bandwidth/max(freq));
for count=1:size(out_freq_data,2);
    out_freq_data(:,count)=out_freq_data(:,count) .* filter';
end;
out_time_data=ifft(out_freq_data,fft_pts);
out_time_data=out_time_data(1:in_no_time_pts,:);
bkwd_indices=[2:2:size(out_time_data,2)];
fwd_indices=[1:2:size(out_time_data,2)-1];
out_time_data=[flipud(out_time_data(:,bkwd_indices));out_time_data(2:size(out_time_data,1),fwd_indices)];
out_time=[-flipud(in_time);in_time(2:length(in_time))];
for count=1:size(out_time_data,2);
   out_time_data(:,count)=out_time_data(:,count) .* (abs(out_time)>(dead_time/2));
end;
disp(['Filtering and returning to time domain: ',num2str(toc)]);

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
%    out_dist_data(:,count)=out_dist_data(:,count) .* (abs(out_dist)>(dead_dist/2));
end;
disp(['Conversion to distance: ',num2str(toc)]);
%normalise
if abs_plot;
    norm_val=datum;
else
    norm_val=max(max(abs(out_time_data)));
end;
out_time_data=out_time_data/norm_val;
out_dist_data=out_dist_data/norm_val;
out_time_data(find(out_time_data==0))=norm_val/1e10;
out_dist_data(find(out_dist_data==0))=norm_val/1e10;


%feature extraction
tic;
%find the feature positions
%take the mean envelope of the selected traces
if feature_extraction_on;
	if sum(feat_find_modes')>1;
   	feat_trace=sum(20*log10(abs(out_dist_data(:,find(feat_find_modes)))'))/sum(feat_find_modes');
	else
   	feat_trace=20*log10(abs(out_dist_data(:,find(feat_find_modes)))');
	end;   
	n=floor(feat_length/dist_step/2);
	pks=zeros(1,length(out_dist)-2*n);
	for count=n+1:length(pks)+n;
   	if feat_trace(count)>max(feat_trace([count-n:count-1,count+1,count+n]));
	      pks(count-n)=1;
   	end;
	end;
	pks=[zeros(1,n),pks,zeros(1,n)];
	pks=pks .* (feat_trace>feat_thresh);
	feat_dist=out_dist(find(pks));
	feat_dist=feat_dist.*(feat_dist>=feat_max_range(1)&feat_dist<=feat_max_range(2));
	feat_dist=feat_dist.*(feat_dist<=-feat_resolution|feat_dist>=feat_resolution);
	last_real_feat=1;
	for count=1:length(feat_dist)
   	if abs(feat_dist(count)-feat_dist(last_real_feat))<=feat_length;
      	feat_dist(count)=0;
   	else
      	last_real_feat=count;
	   end
   	feat_dist';
	end
	feat_dist=feat_dist(find(feat_dist));
	temp=sort(abs(feat_dist));
	if length(temp)>max_feats;
		max_feat_dist=temp(max_feats);
	   feat_dist=feat_dist(min(find(abs(feat_dist)<=max_feat_dist)):max(find(abs(feat_dist)<=max_feat_dist)));
	end;
	features=zeros(length(feat_dist),length(tx_modes));
	for count=1:length(feat_dist);
   	    d1=feat_dist(count)-feat_length/2;
    	d2=feat_dist(count)+feat_length/2;
    	i1=min(find((out_dist>d1)&(out_dist<d2)));
    	i2=max(find((out_dist>d1)&(out_dist<d2)));
    	for m_count=1:length(tx_modes);
      	    features(count,m_count)=max(abs(out_dist_data(i1:i2,m_count)));        
    	end;
   end;
    
disp(['Feature extraction: ',num2str(toc)]);
end;


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
    
    if feature_extraction_on;
        for f_count=1:length(feat_dist);
            plot(ones(1,2)*(feat_dist(f_count)-feat_length/2),[ymin,ymax],'g');        
            plot(ones(1,2)*(feat_dist(f_count)+feat_length/2),[ymin,ymax],'g');        
            plot(ones(1,2)*(feat_dist(f_count)),[ymin,ymax],'b');        
            if count==1;
                h=text(feat_dist(f_count),ymax,['F',int2str(f_count)]);
                set(h,'HorizontalAlignment','center');
                set(h,'VerticalAlignment','bottom');
                set(h,'Color','blue')
                set(h,'FontSize',7)
            end;
        end;
    end;
end;

if feature_extraction_on;
    f=figure;%vs distance
    set(f,'Position',[400 300 540 400])
    subplot(length(feat_dist)+1,1,1);
    hold on;
    plot(out_dist,feat_trace,'r');
    axis([-max_dist max_dist,-dbrange,0]);
    plot([-max_dist max_dist],[-30 -30],'m-.');
    ylabel('dB');
    xlabel('Distance(m)');

    
    for f_count=1:length(feat_dist);
        plot(ones(1,2)*(feat_dist(f_count)),[-dbrange,0],'b');        
        h=text(feat_dist(f_count),0,['F',int2str(f_count)]);
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','bottom');
        set(h,'Color','blue')
        set(h,'FontSize',7)
    end;
    
    for f_count=1:length(feat_dist);
        subplot(length(feat_dist)+1,1,f_count+1);
        bar(features(f_count,:)/max(max(features)));
        axis([0,length(tx_modes)+1,0,1]);
        axis off;
        h=text([1:length(tx_modes)],zeros(1,length(tx_modes)),int2str(tx_modes'));
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','top');
        set(h,'Color','red')
        set(h,'FontSize',7)
        h=text([1:length(tx_modes)],-ones(1,length(tx_modes))*0.2,int2str(rx_modes'));
        set(h,'HorizontalAlignment','center');
        set(h,'VerticalAlignment','top');
        set(h,'Color','green')
        set(h,'FontSize',7)
        h=text(-length(tx_modes)/10,0.5,['F',int2str(f_count)]);
        set(h,'HorizontalAlignment','right');
        set(h,'VerticalAlignment','middle');
        set(h,'Color','blue')
    end;
    
    %features as surfaces maybe
    feat_dbrange=30;
    forward_mode_lookup=[3,5,7,8,10];
    reverse_mode_lookup=zeros(15,1);
    reverse_mode_lookup(3)=1;
    reverse_mode_lookup(5)=2;
    reverse_mode_lookup(7)=3;
    reverse_mode_lookup(8)=4;
    reverse_mode_lookup(10)=5;
    temp=zeros(5,5);
    %find the biggest feature and assume that it is an end, then normalise accordingly
    biggest_feat_rc=max(max(features(:,1:5)));
    [big_feat_index,rc_column]=find(features==biggest_feat_rc);
    norm_feat=features(big_feat_index,[1:5])./calibration_feat_data(calibration_feat_type,[1:5]);
    graphing_output=zeros(length(feat_dist),size(features,2));
    for f_count=1:length(feat_dist);
        if one_feature_graph==1
            if f_count==1
                f=figure;%features
                set(f,'Position',[400 300 540 400])
            end
            set(f,'Position',[400 300 540 400])
            subplot(ceil(sqrt(length(feat_dist))),ceil(sqrt(length(feat_dist))),f_count);
        else
            f=figure;%features
            set(f,'Position',[400 300 540 400])
        end
        for count=1:size(features,2);
            if calibration==0
                temp(reverse_mode_lookup(tx_modes(count)),reverse_mode_lookup(rx_modes(count)))=features(f_count,count)/max(max(features));
            elseif calibration==1
                temp(reverse_mode_lookup(tx_modes(count)),reverse_mode_lookup(rx_modes(count)))=features(f_count,count)/norm_feat(reverse_mode_lookup(tx_modes(count)));
                %temp(reverse_mode_lookup(tx_modes(count)),reverse_mode_lookup(rx_modes(count)))=features(f_count,count)./max(norm_feat(reverse_mode_lookup(tx_modes(count))));
                graphing_output(f_count,count)=features(f_count,count)/norm_feat(reverse_mode_lookup(tx_modes(count)));
            end
        end;
        if calibration==0
            temp=20*log10(abs(temp)/max(max(abs(temp))));
        elseif calibration==1
            temp=20*log10(abs(temp));
        end
        temp=temp .* (temp<=feat_dbrange);
        surf(temp);
        axis tight;
        axis off;
        caxis([-feat_dbrange 0]);
        shading interp;
        view(2);
        if ~secret_option
            colorbar;
            h=text([1:5],ones(1,5)*0.7,int2str(forward_mode_lookup'));
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            set(h,'Color','blue')
            h=text(ones(1,5)*0.7,[1:5],int2str(forward_mode_lookup'));
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            set(h,'Color','red')
            h=text(3,5,['F',int2str(f_count)]);
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','bottom');
            set(h,'Color','blue')
        else;
            h=text(3,0.8,'Output Mode');
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            set(h,'Color','blue')
            h=text(0.8,3,'Input Mode');
            set(h,'HorizontalAlignment','center');
            set(h,'VerticalAlignment','middle');
            set(h,'Rotation',90);
            set(h,'Color','red');
        end
    end
end;


