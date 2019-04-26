% compare_with_disperse
% compare freq vs Vph for disperse and SAFE
%

SAFE_file = 'reshaped_proc_data.mat';
%load(disperse_file)
load(SAFE_file)
% first disperse
figure(1)

%mode_cols = {'g','b','c','r','m','y'};

%for index = 1 : size(mode_data_str.data,2)
%h_temp =plot(mode_data_str.data{index}(:,1),mode_data_str.data{index}(:,3),[mode_cols{index},'-']);      
%set(h_temp,'linewidth',6)

%end %for index = 1 : size(mode_data_str.data,2)

% plot the disperse as solid lines and the SAFE as discrete points

plot( reshaped_proc_data.freq/1E6 ,reshaped_proc_data.ph_vel/1E3, '+-' )

xlabel('Frequency (MHz)')
ylabel('Vph (m/ms)')
%legend(mode_data_str.mode_name,'location','EastOutside')
xlim([0 0.5])
ylim([0 5])


