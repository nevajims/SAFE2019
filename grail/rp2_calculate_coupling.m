%calculate, but don'r compensate for coupling

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

if ~exist('coupling_fig','var')
   coupling_fig=figure;
end;

figure(coupling_fig);
clf;

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
