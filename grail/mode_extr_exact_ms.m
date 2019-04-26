clear;
close all;
default_extract_dir='n:\grail\matlab\fe-data';
default_excite_prefix='mode10';
excite_prefixes={'~' '~' 'mode3' '~' 'mode5' '~' 'mode7' 'mode8' '~' 'mode10'}';
default_extract_fname='fe77loop.mat';
if exist(strcat(matlabroot,'\finel_defaults.mat'))
    load(strcat(matlabroot,'\finel_defaults.mat'))
end;
if ~exist(default_extract_dir,'dir')
    default_extract_dir='n:\grail\matlab\fe-data';
end
%get directory
disp(' ');
fe77_dir=input(strcat('Extract file directory [',strrep(default_extract_dir,'\','\\'),']: '),'s');
if size(fe77_dir,2)==0
    fe77_dir=default_extract_dir;
end;
default_extract_dir=fe77_dir;
%append backslash if nesc
if default_extract_dir(size(default_extract_dir,2))~='\'
    default_extract_dir=strcat(default_extract_dir,'\');
end;
%list files in directory
data_extract_files=dir(strcat(default_extract_dir,'*.mat'));
disp(' ');
data_no_files=size(data_extract_files,1);
for count=1:data_no_files;
    disp(strcat('    ',data_extract_files(count).name));
end;
disp(' ');
option=input(strcat('1. Specify file prefix 2. All file prefixes [',num2str(1),']: '));
data_no_files=0;
excite_mode=0;
if option==1|~size(option)
    while ~data_no_files
        excite_prefix=input(strcat('File prefix [',strrep(default_excite_prefix,'\','\\'),']: '),'s')
        if size(excite_prefix)==0
            excite_prefix=default_excite_prefix;
        else
            default_excite_prefix=excite_prefix;
        end
        data_extract_files=dir(strcat(default_extract_dir,default_excite_prefix,'*.mat'));
        disp(' ');
        data_no_files=size(data_extract_files,1);
        excite_modes=find(ismember(excite_prefixes,default_excite_prefix));
        if ~data_no_files
            disp('No matching files found, try again');
        elseif ~size(excite_mode,1)
            data_no_files=0;
            disp('This is not a valid prefix for extraction');
        else
            for count=1:data_no_files;
                disp(strcat('    ',data_extract_files(count).name));
            end;
        end
    end
else
    excite_modes=[3 5 7 8 10];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
disp(' ');
save(strcat(matlabroot,'\finel_defaults'),'default_*');
plot_extracted_data=0;
directionality=0;
exact_modeshape_extraction=1;
%load the 2DFE file
load('n:\grail\matlab\fe-data\3d-models\10mm_tap');
radius_of_2d_model=min(data_nodes(:,1));
data_nodes(:,1)=data_nodes(:,1)-radius_of_2d_model;
%load the 3D FE file
no_excite_modes=length(excite_modes);
rc_modes=[1 2 3 4 5 6 7 8 9 10];
notch_depths=  [5 7 10 12 15; 100 200 400 600 800];
defect_dimension={'Crack length (mm)','Crack Area (mm^2)'};
rc=zeros(length(rc_modes),no_excite_modes,15);
tc=zeros(length(rc_modes),no_excite_modes,15);
for excite_mode_index=1:no_excite_modes
    excite_mode=excite_modes(excite_mode_index);
    excite_prefix=char(excite_prefixes(excite_mode));
    data_extract_files=dir(strcat(default_extract_dir,excite_prefix,'*.mat'));
    if ~exist('energy_balance')
        energy_balance=zeros(no_excite_modes,size(data_extract_files,1));
    end
    for file_number=1:size(data_extract_files,1);
		notch_depth=notch_depths(file_number);
        load(strcat(default_extract_dir,data_extract_files(file_number).name));
        disp(strcat('Loading:   ',data_extract_files(file_number).name));
        perimeter_monitoring_only=1;
        if perimeter_monitoring_only
            nodes_per_row=size(data_perimeter_node_list,1);
            no_rows=floor(size(dispout_nodes,1)/nodes_per_row);
        end
        if no_rows==4
            row_locations=[2.49 2.52 5.49 5.52];
        elseif no_rows==2
            row_locations=[2.49 2.52];
        else
            disp('Incorrect number of rows');
            return
        end
        defect_location=4.995;
        cent_freq=15e3;
        desired_cent_freq=cent_freq;
        desired_cycles=16;
        no_cycles=4;
        extract_modes=[1,2,3,4,5,6,7,8,9,10]; %may need to include all modes
        %FFT and filter
        fft_pts=2^nextpow2(dispout_no_pts);
        freq_step=1.0/(dispout_timestep*fft_pts);
        
        %set up desired input signal
        t=[0:fft_pts-1]*dispout_timestep;
        freq=[0:fft_pts/2]*freq_step;
        cent_freq_index=round(cent_freq/freq_step)+1;
        t0=max(t)/2;
        f1=sin(2*pi*desired_cent_freq*(t'-t0)) .* gaussian(fft_pts,0.5,(desired_cycles/desired_cent_freq/2)/max(t))';
        f_f1=fft(f1,fft_pts);
        f_f1=f_f1(1:fft_pts/2+1);
        f0=dispout_data(:,size(dispout_data,2));
        f_f0=fft(f0,fft_pts);
        f_f0=f_f0(1:fft_pts/2+1);
        
        %find centre of f0 with Hilbert transform
        f0=ifft(f_f0,fft_pts);
        [temp,ii]=max(abs(f0));
        t0=(ii-1)*dispout_timestep;
        %make vector which does time shift and filtering
        filter=exp(-2*pi*i*freq*t0)'.* abs(f_f1 ./ f_f0);
        f_f0=f_f0.*filter;
        f_f0(find(isinf(f_f0)|isnan(f_f0)))=0;
        f_f0=f_f0/max(f_f0);
        test=abs(ifft(f_f0,fft_pts));
        test=test/max(test);
        [temp,t0]=max(test);
        t1=min(find(test<0.001));
        %find the bandwidth of the filtered input signal
        min_bw_index=min(find(real(f_f0)>0.01));
        max_bw_index=max(find(real(f_f0)>0.01));
        %filter all the monitored signals
        dispout_filtered_data=zeros(fft_pts/2+1,dispout_no_nodes);
        dispout_specs=zeros(fft_pts/2+1,dispout_no_nodes);
        for count=1:dispout_no_nodes;
            temp=fft(dispout_data(:,count),fft_pts);
            dispout_specs(:,count)=temp(1:fft_pts/2+1);
            %filtering in here
            dispout_specs(:,count)=dispout_specs(:,count) .* filter;
            temp=ifft(dispout_specs(:,count),fft_pts);
            dispout_filtered_data(:,count)=temp(1:fft_pts/2+1);
        end;
        %mode extraction bit
        if exact_modeshape_extraction
            min_freq_index=min_bw_index;
            max_freq_index=max_bw_index;
        else
            min_freq_index=cent_freq_index;
            max_freq_index=cent_freq_index;
        end
            
        for current_freq_index=min_freq_index:max_freq_index
            %get mode shapes of modes from 2d finel data rows=no of pts, cols=no of modes
            current_freq=(current_freq_index-1)*freq_step
            mode_shapes=ones(data_no_perimeter_nodes,length(extract_modes));
            for count=1:length(extract_modes);
                [start_index,end_index]=get_good_mode_indices(extract_modes(count),data_freq,data_mode_start_indices);
                mode_shapes(:,count)=interp1(data_freq(start_index:end_index),data_ms_z(data_perimeter_node_list,start_index:end_index)',current_freq,'cubic')';
            end;
            mode_shapes(find(isnan(mode_shapes)))=0;
            inv_mode_shapes=pinv(mode_shapes);
            inv_mode_shapes(find(isnan(inv_mode_shapes)))=0;
            %Now use this mode shape matrix to extract the modes in the frequency domain
            for row_count=1:no_rows
                start_node_index=nodes_per_row*(row_count-1)+1;
                end_node_index=start_node_index+nodes_per_row-1;
                if exact_modeshape_extraction
                    mode_specs(:,current_freq_index,row_count)=inv_mode_shapes*dispout_specs(current_freq_index,start_node_index:end_node_index)';
                else
                    mode_specs(:,:,row_count)=inv_mode_shapes*dispout_specs(:,start_node_index:end_node_index)';
                end
            end
        end
        %Now inverse fft the mode specs to produce the extracted time domain data
        for row_count=1:no_rows
            start_node_index=nodes_per_row*(row_count-1)+1;
            end_node_index=start_node_index+nodes_per_row-1;
            mode_data(:,:,row_count)=ifft(mode_specs(:,:,row_count)',fft_pts);
        end
        %process the mode extracted data to give forwards and backwards propagating components
        if directionality
            ring(1,:)=[1 2];
            ring(2,:)=[3 4];
            no_rings=size(ring,1);
            forward_specs=zeros(length(extract_modes),fft_pts/2+1,no_rings);
            backward_specs=zeros(length(extract_modes),fft_pts/2+1,no_rings);
            for ring_count=1:no_rings;
                x1=row_locations(ring(ring_count,1));
                x2=row_locations(ring(ring_count,2));
                for mode_index=1:length(extract_modes);
                    mode_count=extract_modes(mode_index);
                    [start_index,end_index]=get_good_mode_indices(mode_count,data_freq,data_mode_start_indices);
                    for freq_index=min_bw_index:max_bw_index
                        current_frequency=freq(freq_index);
                        if current_frequency>=data_freq(start_index)&current_frequency<=data_freq(end_index)
                            k=current_frequency/interp1(data_freq(start_index:end_index),data_ph_vel(start_index:end_index),current_frequency);
                            %set up the matrix for the directionality part
                            m(1,:)=[exp(2*pi*i*k*x1) exp(-2*pi*i*k*x1)];
                            m(2,:)=[exp(2*pi*i*k*x2) exp(-2*pi*i*k*x2)];
                            im=inv(m);
                            u_vector=[mode_specs(mode_index,freq_index,ring(ring_count,1)) mode_specs(mode_index,freq_index,ring(ring_count,2))]';
                            temp=im*u_vector;
                            backward_specs(mode_index,freq_index,ring_count)=temp(1) * exp(2*pi*i*k*(x1+x2)/2);
                            forward_specs(mode_index,freq_index,ring_count)=temp(2) * exp(-2*pi*i*k*(x1+x2)/2);
                        end
                    end
                end
                forward_data(:,:,ring_count)=ifft(forward_specs(:,:,ring_count)',fft_pts);
                backward_data(:,:,ring_count)=ifft(backward_specs(:,:,ring_count)',fft_pts);
            end
        end
        %Calculate the expected time of arrival for each mode and the windowing limits%%%%%%%%%%%%%%%%%%%%%%%
        %Assuming that the excitation is at 0m first calculate the time for the outgoing signal to reach the moitoring point
        min_freq_index=find_nearest_point(data_mode_start_indices,data_freq,excite_mode,freq(min_bw_index));
        max_freq_index=find_nearest_point(data_mode_start_indices,data_freq,excite_mode,freq(max_bw_index));
        freq_index=find_nearest_point(data_mode_start_indices,data_freq,excite_mode,cent_freq);
        fastest_first_arrival=mean(row_locations(1:2))/max(data_gr_vel(min_freq_index:max_freq_index))-(t1*dispout_timestep/1.2);
        slowest_first_arrival=mean(row_locations(1:2))/mean(data_gr_vel(min_freq_index:max_freq_index))+(t1*dispout_timestep/1.2);
        fastest_outgoing=defect_location/max(data_gr_vel(min_freq_index:max_freq_index))-(t1*dispout_timestep/1.2);
        slowest_outgoing=defect_location/mean(data_gr_vel(min_freq_index:max_freq_index))+(t1*dispout_timestep/1.5);
        mean_outgoing=defect_location/data_gr_vel(freq_index);
        for row_count=1:no_rows
            for mode_count=1:size(mode_data,2)
                min_freq_index=find_nearest_point(data_mode_start_indices,data_freq,mode_count,freq(min_bw_index));
                max_freq_index=find_nearest_point(data_mode_start_indices,data_freq,mode_count,freq(max_bw_index));
                freq_index=find_nearest_point(data_mode_start_indices,data_freq,mode_count,cent_freq);
                fastest_arrival(mode_count,row_count)=fastest_outgoing+abs((row_locations(row_count)-defect_location)/max(data_gr_vel(min_freq_index:max_freq_index)));
                slowest_arrival(mode_count,row_count)=slowest_outgoing+abs((row_locations(row_count)-defect_location)/mean(data_gr_vel(min_freq_index:max_freq_index)));
            end
        end
        %Plot the extracted mode data for each row%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if plot_extracted_data
            max_time=5E-3;
            pts_2_plot=round(max_time/(dispout_timestep));
            if pts_2_plot>size(mode_data,1)
                pts_2_plot=size(mode_data,1);
                max_time= pts_2_plot*dispout_timestep;
            end
            modes_2_plot=[1 2 3 4 5 6 7 8 9 10];
            time_scale=[0:dispout_timestep:max_time];
            max_val=max(max(max(abs(mode_data(:,:,:)))));
            for row_count=1:2:no_rows
                figure;
                for mode_count=1:length(modes_2_plot);
                    h=subplot(length(modes_2_plot),1,mode_count);
                    plot(time_scale.*1E3,real(mode_data(1:pts_2_plot+1,modes_2_plot(mode_count),row_count))/max_val);
                    axis([0,max_time*1E3,-1,1]);
                    if mode_count==5
                        t=text(-0.5,0,'Mode Number');
                        set(t,'rotation',90);
                        set(t,'HorizontalAlignment','center');
                    end
                    hold on;
                    if modes_2_plot(mode_count)==excite_mode&ismember(row_count,[1 2])
                        plot([fastest_first_arrival fastest_first_arrival]*1e3,[-1 1],'r');
                        plot([slowest_first_arrival slowest_first_arrival]*1e3,[-1 1],'r');
                    end 
                    plot([fastest_arrival(modes_2_plot(mode_count),row_count) fastest_arrival(modes_2_plot(mode_count),row_count)]*1e3,[-1 1],'g');
                    plot([slowest_arrival(modes_2_plot(mode_count),row_count) slowest_arrival(modes_2_plot(mode_count),row_count)]*1e3,[-1 1],'g');
                    ylabel(num2str(modes_2_plot(mode_count)));
                    set(h,'ytick',-2);
                    set(h,'xtick',-1);
                end;
                xlabel('Time(linear scale)');
                subplot(length(modes_2_plot),1,1);
                title(strcat('File:	',data_extract_files(file_number).name,'Row: ',num2str(row_count)),'interpreter','none');
            end
        end
        %find reflection coefficients by gating the data from the first 2 rows, ffting and looking for the amplitude at centre frequency
        input_row=1;
        rc_row=1;
        tc_row=3;
        %first find amplitude of the input signal at the centre frequency
        input_signal_data=zeros(fft_pts,1);
        reflect_signal_data=zeros(fft_pts,1);
        trans_signal_data=zeros(fft_pts,1);
        fastest_first_arrival_index=round(fastest_first_arrival/dispout_timestep);
        slowest_first_arrival_index=round(slowest_first_arrival/dispout_timestep);
        input_signal_data(fastest_first_arrival_index:slowest_first_arrival_index)=mode_data(fastest_first_arrival_index:slowest_first_arrival_index,excite_mode,input_row);
        temp=ifft(input_signal_data',fft_pts);
        input_amplitude=abs(temp(cent_freq_index));
        %calculate the reflection coefficients
        for mode_index=1:length(rc_modes);
            mode_count=rc_modes(mode_index);
            reflect_signal_data=zeros(fft_pts,1);
            trans_signal_data=zeros(fft_pts,1);
            fastest_arrival_index=round(fastest_arrival(mode_count,rc_row)/dispout_timestep);
            slowest_arrival_index=round(slowest_arrival(mode_count,rc_row)/dispout_timestep);
            reflect_signal_data(fastest_arrival_index:slowest_arrival_index)=mode_data(fastest_arrival_index:slowest_arrival_index,mode_count,rc_row);
            temp=ifft(reflect_signal_data',fft_pts);
            rc(mode_index,excite_mode_index,file_number)=abs(temp(cent_freq_index))/input_amplitude;
            fastest_arrival_index=round(fastest_arrival(mode_count,tc_row)/dispout_timestep);
            slowest_arrival_index=round(slowest_arrival(mode_count,tc_row)/dispout_timestep);
            trans_signal_data(fastest_arrival_index:slowest_arrival_index)=mode_data(fastest_arrival_index:slowest_arrival_index,mode_count,tc_row);
            temp=ifft(trans_signal_data',fft_pts);
            tc(mode_index,excite_mode_index,file_number)=abs(temp(cent_freq_index))/input_amplitude;
        end
        energy_balance(excite_mode_index,file_number)=sum(tc(:,excite_mode_index,file_number) .^ 2)+sum(rc(:,excite_mode_index,file_number) .^ 2);
        disp(strcat('Energy Balance:   ',num2str(energy_balance(excite_mode_index,file_number))));
    end
end
energy_balance_errors=mean(abs(1-energy_balance')*100);
if max(energy_balance_errors)>10
    input('WARNING: Max error is greater than 10% press return to continue');
end
%save the results in a single file with the correct name
output_fname=input('Specify the prefix of the output file:  ','s');
save(strcat(default_extract_dir,output_fname,'_ref_coef'),'rc','tc','output_fname','notch_depths','excite_modes','rc_modes','defect_dimension','energy_balance');
plot_rc(excite_modes,rc,tc,notch_depths,defect_dimension,output_fname,excite_modes,rc_modes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
