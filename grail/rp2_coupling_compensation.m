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
    for count=1:size(in_freq_data,2);
        it=find((trans_row_lookup==tx_row(count))&(trans_pos_lookup==tx_pos(count)));
        ir=find((trans_row_lookup==rx_row(count))&(trans_pos_lookup==rx_pos(count)));
        in_freq_data(:,count)=in_freq_data(:,count)*trans_weight(it)*trans_weight(ir);
    end;
end;
disp(['Coupling compensation: ',num2str(toc)]);
rp2_calculate_coupling;

%last line- turn off figures too
set(comp_coup_button,'enable','off');
set(mode_extract_button,'enable','off');
set(filter_button,'enable','on');
set(convert_to_dist_button,'enable','off');
set(feat_extr_button,'enable','off');
