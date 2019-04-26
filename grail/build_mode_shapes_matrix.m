%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%START OF INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%frequency to use
freq = 15e3;

%2D FE model data
%fe_fname='C:\Paul\matlab\rail\fe-data\5mm_tap';
fe_fname='N:\grail\matlab\fe-data\2D-models\5mm_tap';

%hardware filename
%hardware_fname='C:\Paul\matlab\rail\new_prototype';
hardware_fname='N:\grail\matlab\new_prototype';

%output filename
mode_shapes_fname = 'D:\development\rail\test.txt';

%which modes (and in what order) to include in matrix calc
tx_modes_to_use=      [3,5,7,8,10,  3,3,3,3,   5,5,5,5,   7,7,7,7,   8,8,8,8,   10,10,10,10];
rx_modes_to_use=      [3,5,7,8,10,  5,7,8,10,  3,7,8,10,  3,5,8,10,  3,5,7,10,  3,5,7,8];
the_different_modes = [3,5,7,8,10];

%various options
ignore_pulse_echo = 1; %doesn't use pulse-echo data if 1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%END OF INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load hardware layout file
run(hardware_fname);%loads it immediately
%load FE data
tic;
load(fe_fname);
disp(['Loading FE data: ',num2str(toc)]);

%this is the sign flipper to sort the mode shape sign irregularities out
tic;
for mi=1:length(data_mode_start_indices)-1;
	[start_index,end_index]=get_good_mode_indices(mi,data_freq,data_mode_start_indices);
	for ii=start_index:end_index-1'
   	if (data_ms_z(trans_node_list,ii)' * data_ms_z(trans_node_list,ii+1))<0
      	data_ms_z(:,ii+1:end_index) = -data_ms_z(:,ii+1:end_index);
	   end;
   end;
end;
disp(['Correcting mode shapes: ',num2str(toc)]);


%create tx and rx row and position lookup vectors
tic;
temp_tx_indices = 1:sum(sum(trans_pos(find(transmitter_rows),:)));
temp_rx_indices = 1:sum(sum(trans_pos(find(receiver_rows),:)));
temp_tx_indices2 = (ones(size(temp_rx_indices')) * temp_tx_indices)';
temp_rx_indices2 = ones(size(temp_tx_indices')) * temp_rx_indices;
[temp_tx_row,temp_tx_pos]=find(trans_pos(find(transmitter_rows),:));
[temp_rx_row,temp_rx_pos]=find(trans_pos(find(receiver_rows),:));
tx_row = temp_tx_row(temp_tx_indices2(:));
tx_pos = temp_tx_pos(temp_tx_indices2(:));
rx_row = temp_rx_row(temp_rx_indices2(:));
rx_pos = temp_rx_pos(temp_rx_indices2(:));
if ignore_pulse_echo;
   temp_none_pulse_echo = find(~((tx_row==rx_row) & (tx_pos==rx_pos)));
   tx_row = tx_row(temp_none_pulse_echo);
   rx_row = rx_row(temp_none_pulse_echo);
   tx_pos = tx_pos(temp_none_pulse_echo);
   rx_pos = rx_pos(temp_none_pulse_echo);
end;
no_time_traces = length(tx_row);
clear('temp_*');
disp(['Building transducer look up vectors: ',num2str(toc)]);

%create mode and direction lookup vectors
tic;
direction = [ones(1,length(tx_modes_to_use)),-ones(1,length(tx_modes_to_use))];
tx_modes = [tx_modes_to_use,tx_modes_to_use];
rx_modes = [rx_modes_to_use,rx_modes_to_use];
no_mode_combinations = length(tx_modes);
disp(['Building mode look up vectors: ',num2str(toc)]);

%build the mode shapes matrix
tic;
mode_shapes = zeros(no_time_traces,no_mode_combinations);
temp_mode_shapes = zeros(max(the_different_modes),length(trans_node_list));
temp_wavenos = zeros(max(the_different_modes),1);
for jj=1:length(the_different_modes);
	[i1,i2]=get_good_mode_indices(the_different_modes(jj),data_freq,data_mode_start_indices);
	temp_mode_shapes(the_different_modes(jj),:) = interp1(data_freq(i1:i2),data_ms_z(trans_node_list,i1:i2)',freq,'cubic');
   temp_wavenos(the_different_modes(jj)) = interp1(data_freq(i1:i2),data_freq(i1:i2) ./ data_ph_vel(i1:i2),freq,'cubic');
end;
%build the mode shape matrix at this frequency
for jj=1:no_mode_combinations;
	mode_shapes(:,jj) = (...
		temp_mode_shapes(tx_modes(jj),tx_pos) .* ...
		temp_mode_shapes(rx_modes(jj),rx_pos) .* ...
   	exp(2*pi*i*temp_wavenos(tx_modes(jj))*trans_row_pos(tx_row)*direction(jj)).* ...
      exp(2*pi*i*temp_wavenos(rx_modes(jj))*trans_row_pos(rx_row)*direction(jj)) ...
      ).';
end;
mode_shapes(find(isnan(mode_shapes)))=0;
mode_shapes(find(isinf(mode_shapes)))=0;
disp(['Building mode shapes matrix: ',num2str(toc)]);

%invert it to get the answer
tic;
inv_mode_shapes = pinv(mode_shapes);
disp(['Inverting mode shapes matrix: ',num2str(toc)]);

%NB  If you want to obtain modified inv_mode_shapes for transducer down
%    just zero the appropriate rows in mode_shapes before doing inverse

%export file
tic;
temp=[tx_row';tx_pos';rx_row';rx_pos';real(inv_mode_shapes);imag(inv_mode_shapes)];
temp=[[zeros(4,1);tx_modes';tx_modes'],[zeros(4,1);rx_modes';rx_modes'],[zeros(4,1);direction';direction'],temp];
save(mode_shapes_fname,'temp','-ascii','-double','-tabs');
disp(['Mode shape file exported: ',num2str(toc)]);
