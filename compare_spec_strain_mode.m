function [] = compare_spec_strain_mode(reshaped_proc_data, reshaped_proc_data_np)
% Plot all the sensitivity values for  

%Sensitivity_to_plot = [1 1 1 1 1 1 1 1 1 1];
%Sensitivity_to_plot = [1 0 0 1 1 1 1 1 1 1];
%Sensitivity_to_plot = [1 0 0 1 0 0 0 0 0 0 ];
%Sensitivity_to_plot = [0 0 0 0 1 1 1 0 0 0];
Sensitivity_to_plot = [0 0 0 0 0 0 0 1 1 1];

%Sensitivity_to_plot = [1 0 0 1 0 0 0 0 0 0];
%Sensitivity_to_plot = [0 0 0 0 0 0 0 0 0 0];

all_params = {'Real WN Propagating','Imag WN Propagating','Real WN Non-Prop','Imag WN Non-Prop','PND X Propagating','PND Y Propagating','PND Z Propagating','PND X Non-Prop','PND Y Non-Prop','PND Z Non-Prop'};
no_to_plot = sum(Sensitivity_to_plot);
%xlim_max = 200;
plot_wavenumber = 0;

modes_to_plot = [1 2];   % make this an input to the function
number_freq_points = 3000;
%selected_node  =  185 ; % middle of web
selected_node  =  106;
%selected_node  =  258 ; % top of rail   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% need to interpolate the values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interpol_vals    = interpolate_values(reshaped_proc_data,modes_to_plot,number_freq_points,selected_node);
interpol_vals_np = interpolate_values(reshaped_proc_data_np,modes_to_plot,number_freq_points,selected_node);

%interpol_vals.freq_vals   = freq_vals  ;
%interpol_vals.WN_vals     = WN_vals    ;
%interpol_vals.ms_x_vals   = ms_x_vals  ;
%interpol_vals.ms_y_vals   = ms_y_vals  ;
%interpol_vals.ms_z_vals   = ms_z_vals  ;

%interpol_vals_np.freq_vals   = freq_vals  ;
%interpol_vals_np.WN_vals     = WN_vals    ;
%interpol_vals_np.ms_x_vals   = ms_x_vals  ;
%interpol_vals_np.ms_y_vals   = ms_y_vals  ;
%interpol_vals_np.ms_z_vals   = ms_z_vals  ;

% Go through mode 1 and 2 and plot
cc = hsv(length(reshaped_proc_data));
cc2 = hsv(no_to_plot);
% 'color',cc(strain_index,:))    

if plot_wavenumber == 1 
for mode_index = 1:2

fig_A(mode_index) = figure;  
% set the figure title
title(['Mode ', num2str(mode_index)])
hold on


sub_A1(mode_index) = subplot(4,1,1); 
hold on
title('Real WN Propagating')

sub_A2(mode_index) = subplot(4,1,2);
hold on
title('Imag WN Propagating')

sub_A3(mode_index) = subplot(4,1,3);
hold on
title('Real WN Non-Prop')

sub_A4(mode_index) = subplot(4,1,4);
hold on
title('Imag WN Non-Prop')


fig_B(mode_index) = figure;
title(['Mode ', num2str(mode_index)])
hold on

sub_B1(mode_index) = subplot(2,3,1); 
semilogy(0,0)
hold on 
title('Direction X')
xlabel('Freq')

sub_B2(mode_index) = subplot(2,3,2); 
semilogy(0,0)
hold on 
title('Direction Y')
xlabel('Freq')

sub_B3(mode_index) = subplot(2,3,3); 
semilogy(0,0)
hold on 
title('Direction Z')
xlabel('Freq')

sub_B4(mode_index) = subplot(2,3,4); 
semilogy(0,0)
hold on 
title('Direction X')
xlabel('Freq')

sub_B5(mode_index) = subplot(2,3,5); 
semilogy(0,0)
hold on 
title('Direction Y')
xlabel('Freq')

sub_B6(mode_index) = subplot(2,3,6); 
semilogy(0,0)
hold on 
title('Direction Z')
xlabel('Freq')

end %for mode_index = 1:2

end %if plot_wavenumber == 1


for mode_index = 1:2

if plot_wavenumber == 1    
for strain_index = 1 : length(reshaped_proc_data)
figure(fig_A(mode_index))
subplot(sub_A1(mode_index))
% subfig 1 wavenumber real  (prop)
plot(interpol_vals.freq_vals(mode_index,:), real(squeeze(interpol_vals.WN_vals(mode_index,strain_index,:  ))),'-x','color',cc(strain_index,:))    
subplot(sub_A2(mode_index))
plot(interpol_vals.freq_vals(mode_index,:), imag(squeeze(interpol_vals.WN_vals(mode_index,strain_index,:  ))),'-x','color',cc(strain_index,:))    
% subfig 2 wavenumber imag  (prop)
subplot(sub_A3(mode_index))
plot(interpol_vals_np.freq_vals(mode_index,:), real(squeeze(interpol_vals_np.WN_vals(mode_index,strain_index,:  ))),'-x','color',cc(strain_index,:))    
% subfig 3 wavenumber real and imaginary (non prop)
subplot(sub_A4(mode_index))
plot(interpol_vals_np.freq_vals(mode_index,:), imag(squeeze(interpol_vals_np.WN_vals(mode_index,strain_index,:  ))),'-x','color',cc(strain_index,:))    

% subfig 4 wavenumber imag  (non prop)    

figure(fig_B(mode_index));

subplot(sub_B1(mode_index)); 
semilogy(interpol_vals.freq_vals(mode_index,:), abs(squeeze(interpol_vals.ms_x_vals (mode_index,strain_index,:))) ,'-x','color',cc(strain_index,:))    

subplot(sub_B2(mode_index)); 
semilogy(interpol_vals.freq_vals(mode_index,:), abs(squeeze(interpol_vals.ms_y_vals (mode_index,strain_index,:))) ,'-x','color',cc(strain_index,:))    

subplot(sub_B3(mode_index)); 
semilogy(interpol_vals.freq_vals(mode_index,:), abs(squeeze(interpol_vals.ms_z_vals (mode_index,strain_index,:))) ,'-x','color',cc(strain_index,:))    

subplot(sub_B4(mode_index)) ; 
semilogy(interpol_vals_np.freq_vals(mode_index,:), abs(squeeze(interpol_vals_np.ms_x_vals (mode_index,strain_index,:))) ,'-x','color',cc(strain_index,:))    

subplot(sub_B5(mode_index)); 
semilogy(interpol_vals_np.freq_vals(mode_index,:), abs(squeeze(interpol_vals_np.ms_y_vals (mode_index,strain_index,:))) ,'-x','color',cc(strain_index,:))    

subplot(sub_B6(mode_index)); 
semilogy(interpol_vals_np.freq_vals(mode_index,:), abs(squeeze(interpol_vals_np.ms_z_vals (mode_index,strain_index,:))) ,'-x','color',cc(strain_index,:))    
end  % for strain_index = 1 : length(reshaped_proc_data)

end %if plot_wavenumber == 1

% sensitivity plot for the second strain condition oveer the zero strain condition
fig_C{mode_index} = figure ; 
hold on
title(['Mode ',num2str(mode_index)])
xlabel('Freq (Hz)')
ylabel('Sensitivity (%)')
line_number = 0;
%build up the legend for an eval statement
%leg_text = '';
%if strain_index == size(all_strain_per  ,2)
%comma_insert = '';
%else
%comma_insert = ',';
%end
%leg_text            = [leg_text,'''','Strain = ',num2str(all_strain_per(strain_index)),'''', comma_insert]; 
%eval(['legend(',leg_text,')'])   

leg_text ='';

% P1--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(1)==1
line_number = line_number+1;
nz_val = real(squeeze(interpol_vals.WN_vals(mode_index,2,:)));
zer_val = real(squeeze(interpol_vals.WN_vals(mode_index,1,:)));
plot(interpol_vals.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))

if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{1},'''', comma_insert]; 
end
% P2--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(2)==1
line_number = line_number+1;
nz_val = imag(squeeze(interpol_vals.WN_vals(mode_index,2,:)));
zer_val = imag(squeeze(interpol_vals.WN_vals(mode_index,1,:)));
plot(interpol_vals.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val),'-x','color',cc2(line_number,:))    

if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{2},'''', comma_insert]; 
end


% P3--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(3)==1
line_number = line_number+1;
nz_val = real(squeeze(interpol_vals_np.WN_vals(mode_index,2,:)));
zer_val = real(squeeze(interpol_vals_np.WN_vals(mode_index,1,:)));
plot(interpol_vals_np.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))    
if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{3},'''', comma_insert]; 
end


% P4--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(4)==1
line_number = line_number+1;
nz_val = imag(squeeze(interpol_vals_np.WN_vals(mode_index,2,:)));
zer_val = imag(squeeze(interpol_vals_np.WN_vals(mode_index,1,:)));
plot(interpol_vals_np.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))    
if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{4},'''', comma_insert]; 
end

% P5--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(5)==1
line_number = line_number+1;
nz_val = abs(squeeze(interpol_vals.ms_x_vals (mode_index,2,:)));
zer_val = abs(squeeze(interpol_vals.ms_x_vals (mode_index,1,:))); 
plot(interpol_vals.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:)) 

if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{5},'''', comma_insert]; 
end


% P6--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(6)==1
line_number = line_number+1;
nz_val = abs(squeeze(interpol_vals.ms_y_vals (mode_index,2,:)));
zer_val = abs(squeeze(interpol_vals.ms_y_vals (mode_index,1,:))); 
plot(interpol_vals.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))    

if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{6},'''', comma_insert]; 
end

% P7--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(7)==1
line_number = line_number+1;
nz_val = abs(squeeze(interpol_vals.ms_z_vals (mode_index,2,:)));
zer_val = abs(squeeze(interpol_vals.ms_z_vals (mode_index,1,:))); 
plot(interpol_vals.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))    

if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{7},'''', comma_insert]; 
end


% P8--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(8)==1
line_number = line_number+1;
nz_val = abs(squeeze(interpol_vals_np.ms_x_vals (mode_index,2,:)));
zer_val = abs(squeeze(interpol_vals_np.ms_x_vals (mode_index,1,:))); 
plot(interpol_vals_np.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))    

if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{8},'''', comma_insert]; 
end


% P9--------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(9)==1
line_number = line_number+1;
nz_val = abs(squeeze(interpol_vals_np.ms_y_vals (mode_index,2,:)));
zer_val = abs(squeeze(interpol_vals_np.ms_y_vals (mode_index,1,:))); 
plot(interpol_vals_np.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))    
if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{9},'''', comma_insert]; 
end



% P10-------------------------------------------------------------------------------------------------------------------------
if Sensitivity_to_plot(10)==1
line_number = line_number+1;    
nz_val = abs(squeeze(interpol_vals_np.ms_z_vals (mode_index,2,:)));
zer_val = abs(squeeze(interpol_vals_np.ms_z_vals (mode_index,1,:))); 
plot(interpol_vals_np.freq_vals(mode_index,:),abs(100*(nz_val-zer_val)./zer_val) ,'-x','color',cc2(line_number,:))  
if line_number == no_to_plot
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''',all_params{10},'''', comma_insert]; 
end
disp(num2str(line_number))
xlim([0 150])
ylim([0 40])
disp(['legend(',leg_text,')'])
eval(['legend(',leg_text,')'])
end
%-------------------------------------------------------------------------------------------------------------------------


%eval(['legend(',leg_text,')'])   
% Build up the % plot the  parameters of interest here
% set the figure title
% choose the parameters  to plot here

% do one plot for each Mode with the following parameters in each   
% for 0.1% strain sensitivity 
%------------------
% six parameters :::
%------------------
% mode 1
% 3 figures for each mode  
% fig 1  Mode x wavenumber values
%------------------
% subfig 1 wavenumber real  (prop)
% subfig 2 wavenumber imag  (prop)
% subfig 3 wavenumber real and imaginary (non prop)
% subfig 4 wavenumber imag  (non prop)
%------------------
% fig 2  Mode x power normalised displacement
%------------------
% subfig 1  power normalised displacement x  (prop)
% subfig 2  power normalised displacement y  (prop)
% subfig 3  power normalised displacement z  (prop)
% subfig 4   power normalised displacement x (non prop)
% subfig 5   power normalised displacement y (non prop)
% subfig 6   power normalised displacement z (non prop)
%------------------
% fig 3  Mode 1 sensitivity all 8 paramenters 
%------------------



%------------------
% sensitivity for all 6 parameters above
%------------------
%------------------
% Propagating
%------------------
% real       wavenumber 
% imaginary  wavenumber
% power normalised displacement - X
% power normalised displacement - y
% power normalised displacement - Z

%------------------
% Non- Propagating
%------------------
% real       wavenumber 
% imaginary  wavenumber
% power normalised displacement - X
% power normalised displacement - y
% power normalised displacement - Z
%------------------
%------------------
% mode 2
%------------------
% Propagating
%------------------
% real       wavenumber 
% imaginary  wavenumber
% power normalised displacement - X
% power normalised displacement - y
% power normalised displacement - Z

%------------------
% Non- Propagating
%------------------
% real       wavenumber 
% imaginary  wavenumber
% power normalised displacement - X
% power normalised displacement - y
% power normalised displacement - Z
%------------------


end  % function [] = compare_spec_strain_mode(reshaped_proc_data, reshaped_proc_data_np)


function interpol_vals =   interpolate_values(reshaped_proc_data,modes_to_plot,number_freq_points,selected_node)
all_strain_per = reshaped_proc_data(1).data.all_strain_per;
freq_min =zeros(1,length(modes_to_plot));
for index_mode = 1:length(modes_to_plot)
    
freq_min(index_mode) = max(reshaped_proc_data(1).data.freq(:,modes_to_plot(index_mode))) ;
for index_strain = 2:length(all_strain_per)

if freq_min(index_mode) > max(reshaped_proc_data(index_strain).data.freq(:,modes_to_plot(index_mode)))
freq_min(index_mode) = max(reshaped_proc_data(index_strain).data.freq(:,modes_to_plot(index_mode)));
end %if freq_min(index_mode)> max(reshaped_proc_data(index_strain).data.freq(:,modes_to_plot(index_mode)))          

end %for index_1 = 1:length(all_strain_per)  
end % for index_mode = 1:length(modes_to_plot)


for mode_index = 1:length(modes_to_plot)
freq_vals(mode_index,:) = [0:freq_min(mode_index)/(number_freq_points-1):freq_min(mode_index)];
for strain_index  = 1:length(all_strain_per)
% here  is the interpolation part
ph_vel_vals(mode_index,strain_index,:) = interp1(reshaped_proc_data(strain_index).data.freq(:,modes_to_plot(mode_index) ),reshaped_proc_data(strain_index).data.ph_vel(:,modes_to_plot(mode_index) ),freq_vals(mode_index,:));                                
WN_vals    (mode_index,strain_index,:) = interp1(reshaped_proc_data(strain_index).data.freq(:,modes_to_plot(mode_index) ),reshaped_proc_data(strain_index).data.waveno(:,modes_to_plot(mode_index) ),freq_vals(mode_index,:));
ms_x_vals  (mode_index,strain_index,:) = interp1(reshaped_proc_data(strain_index).data.freq(:,modes_to_plot(mode_index) ),abs(reshaped_proc_data(strain_index).data.ms_x(selected_node,:,modes_to_plot(mode_index) )),freq_vals(mode_index,:));
ms_y_vals (mode_index,strain_index,:)  = interp1(reshaped_proc_data(strain_index).data.freq(:,modes_to_plot(mode_index) ),abs(reshaped_proc_data(strain_index).data.ms_y(selected_node,:,modes_to_plot(mode_index) )),freq_vals(mode_index,:));
ms_z_vals (mode_index,strain_index,:)  = interp1(reshaped_proc_data(strain_index).data.freq(:,modes_to_plot(mode_index) ),abs(reshaped_proc_data(strain_index).data.ms_z(selected_node,:,modes_to_plot(mode_index) )),freq_vals(mode_index,:));

end %for strain_index  = 1:length(all_strain_per) 
end %for mode_idex = 1:length(modes_to_plot)

interpol_vals.freq_vals   = freq_vals  ;
interpol_vals.ph_vel_vals = ph_vel_vals;
interpol_vals.WN_vals     = WN_vals    ;
interpol_vals.ms_x_vals   = ms_x_vals  ;
interpol_vals.ms_y_vals   = ms_y_vals  ;
interpol_vals.ms_z_vals   = ms_z_vals  ;

end %function interpol_vals =   interpolate_values(reshaped_proc_data, reshaped_proc_data_np);


