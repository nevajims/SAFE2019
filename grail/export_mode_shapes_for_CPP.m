%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START OF INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%frequency range and step to use
min_freq = 10e3;
max_freq = 20e3;
freq_step = 0.5e3;
%2D FE model data
%fe_fname='C:\Paul\matlab\rail\fe-data\5mm_tap';
%fe_fname='N:\grail\matlab\fe-data\2D-models\5mm_tap';
%fe_fname='C:\Users\Mark\Desktop\Rail Working Copy\Matlab\fe-data\2D-models\NP46\NP46_5mm';
%fe_fname='C:\Users\Mark\Desktop\Rail Working Copy\Matlab\fe-data\2D-models\50E2\50E2_5mm_TAP_V';
%fe_fname='C:\Users\Mark\Desktop\Rail Working Copy\Matlab\fe-data\2D-models\54E1\54E1_5mm_TAP_V';
%fe_fname='C:\Users\Mark\Desktop\Rail Working Copy\Matlab\fe-data\2D-models\56E1\56E1_5mm_TAP_V';
%fe_fname='C:\Users\Mark\Desktop\Rail Working Copy\Matlab\fe-data\2D-models\60E1\60E1_5mm_TAP_V';
fe_fname='G:\10-MAIN PROJECTS\grail\matlab\fe-data\2D-models\50E2T1\50E2T1';

%which transducers are to be used
%trans_node_list=[153, 319, 329, 193, 216, 238];%, 118, 96, 73, 273, 258, 33];% for BS80 5mm tapered
%trans_node_list=[302, 312, 171, 194, 215, 106, 85, 62, 252, 237];% for NP46 5mm tapered
%trans_node_list=[461, 471, 291, 327, 368, 182, 141, 105, 408, 393];% for 50E2 5mm tapered
%trans_node_list=[467, 479, 291, 327, 368, 182, 141, 105, 411, 393];% for 54E1 5mm tapered
%trans_node_list=[467, 479, 291, 327, 368, 182, 141, 105, 411, 393];% for 56E1 5mm tapered
trans_node_list=[80, 476, 141, 182, 212, 430, 400, 359, 535, 298];% for 50E2T2

no_trans_nodes = length(trans_node_list);

%output filename


%export_fname='n:\grail\matlab\mode_shapes_for_CPP.txt'; %default file and directory for brian
export_fname='c:\tmp\50E2T1_mode_shapes_for_CPP.txt'; %test file

%which modes (and in what order) to include in exported file
%export_modes = [3 5 7 8 10 6 9 4 13 11 12 2 1];
%export_modes = [1 2 3 4 5 6 7 8 9 10 11 12 13];
export_modes_labels = [1 2 3 4 5 6 7 8 9 10]; %the mode numbers which will appear in the output file
%export_modes = [1 2 3 7 5 6 4 8 10 9];  %reordering for BS80 raw mode orders
%export_modes = [1	2	3	7	5	6	4	8	9	10];  %reordering for 46E1 raw mode orders
%export_modes = [1	2	3	7	5	6	4	8	9	10];  %reordering for 50E2 raw mode orders
%export_modes = [1	2	3	7	5	6	4	8	9	10];  %reordering for 54E1 raw mode orders
%export_modes = [1	2	3	7	5	6	4	8	9	10];  %reordering for 56E1 raw mode orders
%export_modes = [1	2	3	7	5	6	4	8	9	10];  %reordering for 60E1 raw mode orders
export_modes = [1	2	3	7	5	6	4	8	10	9];  %reordering for 60E1 raw mode orders

no_export_modes = length(export_modes);
value_to_export = 1;     %can choose what to export in the file 1 = z displacements, 2 =  z excitability
export_values = {'axial displacements','axial excitability'};

%summary
disp(strcat('Exporting:_',export_values(value_to_export),'_for_frequencies_',num2str(min_freq),'kHz_to_',num2str(max_freq),'kHz'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%END OF INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load FE data
tic;
load(fe_fname);
disp(['Loading FE data: ',num2str(toc)]);

% check that the trans node list contains only perimeter nodes
temp=sum(ismember(trans_node_list,data_perimeter_node_list));
if temp~=no_trans_nodes
    disp('Fatal error, the transducer node list does not match the FE data file. Not all the transducer nodes are perimeter nodes');
    return
end

%this is the sign flipper to sort the mode shape sign irregularities out
tic;
if 0
for mi=1:length(data_mode_start_indices)-1;
	[start_index,end_index]=get_good_mode_indices(mi,data_freq,data_mode_start_indices);
	for ii=start_index:end_index-1
   	if (data_ms_z(trans_node_list,ii)' * data_ms_z(trans_node_list,ii+1))<0
      	data_ms_z(:,ii+1:end_index) = -data_ms_z(:,ii+1:end_index);
 	   end;
   end;
end;
end;

disp(['Correcting mode shapes: ',num2str(toc)]);

%Open the export file and write a header
out_file_id = fopen(export_fname,'w+');
fprintf(out_file_id,'//Exporting %s from %s\n',char(export_values(value_to_export)),fe_fname);
fprintf(out_file_id,'//Transmitter node numbers\t');
for i = 1:no_trans_nodes
    fprintf(out_file_id,'%u\t' ,trans_node_list(i));
end
fprintf(out_file_id,'\r\n');
fprintf(out_file_id,'//Modes\t');
for i = 1:no_export_modes
    fprintf(out_file_id,'%u\t' ,export_modes_labels(i));
end
fprintf(out_file_id,'\r\n\r\n');

%calculate the modeshapes and write to the file
mode_shapes = zeros(no_trans_nodes,no_export_modes);
for current_freq = min_freq:freq_step:max_freq;
    phase_velocity=zeros(no_export_modes,1);
    group_velocity=zeros(no_export_modes,1);
    fprintf(out_file_id,'{%E /*Hz*/, {\r\n',current_freq);
    for mode_index = 1:no_export_modes
        current_mode = export_modes(mode_index);
        [i1,i2]=get_good_mode_indices(current_mode,data_freq,data_mode_start_indices);
        if current_freq < data_freq(i1) | current_freq > data_freq(i2)
            disp(strcat('Warning: Frequency_',num2str(current_freq/1000),'kHz_is_out_of_range_for_mode_',num2str(current_mode)));
            mode_shapes(:,mode_index) = 0;
            attenuation=0;
        else
            mode_shapes(:,mode_index) = interp1(data_freq(i1:i2),data_ms_z(trans_node_list,i1:i2)',current_freq,'cubic')';
            phase_velocity(mode_index) = interp1(data_freq(i1:i2),data_ph_vel(i1:i2)',current_freq,'cubic')';
            group_velocity(mode_index) = interp1(data_freq(i1:i2),data_gr_vel(i1:i2)',current_freq,'cubic')';
            attenuation=0;
        end
    end
    for mode_index = 1:no_export_modes
        fprintf(out_file_id,'{%u /*Mode*/,\t',export_modes_labels(mode_index));
        fprintf(out_file_id,'%E /*Vph m/s*/,\t',phase_velocity(mode_index));
        fprintf(out_file_id,'%E /*Att*/,\t',attenuation);
        fprintf(out_file_id,'%E /*Vgr m/s*/,\t{',group_velocity(mode_index));
        for trans_node_index =1:no_trans_nodes
            fprintf(out_file_id,'%f,\t',mode_shapes(trans_node_index,mode_index)*1E6);
        end
        fprintf(out_file_id,'}},\r\n');
    end
    
    fprintf(out_file_id,'}},\r\n');
end
fclose(out_file_id);
disp(['Mode shape file exported: ',num2str(toc)]);
