function [reshaped_proc_data , sorted_lookup , data_wn_matrix] =  proc_data_into_modes_safe(data,no_modes)
% calculate the group velocity once all the other calculations are done 
% --------------------------------------------------------------
% need to check that the first dps is the same for both routines-  
% use the old procedure to check the new one
% check that every mode shape is correct in the reshaped data
% check the mode shape--   check the single val is the same and the array is
% the same-  if not then sort this
% how to check convergence of the dispersion curves?
% how to plot the mode shapes?
% mix activities so I dont get stuck on a single problem
% --------------------------------------------------------------
% fields of proc_data:
% mode_start_indices: [20x1 double]
% no_modes: 20
% freq: [7960x1 double]
% ph_vel: [7960x1 double]
% ms_x: [463x7960 double]
% ms_y: [463x7960 double]
% ms_z: [463x7960 double]
% gr_vel: [7960x1 double]load daa
% calculate group velocity using my method to make sure it is the same
% --------------------------------------------------------------
do_order_by_wn_plot          = 0;
do_modes_plots               = 0;
no_points                    = size(data.ms_x,2);
no_nodes                     = size(data.ms_x,1);
%no_mode_shapes               = round(no_points/data.no_files);

no_mode_shapes = no_modes;

%no_mode_shapes               = 200;
no_points_per_mode           = data.no_files;
%no_points_per_mode = 10;0

[~, data_wn_matrix]    =  order_by_wavenumber(data , do_order_by_wn_plot);

%valid_pts                                 =  ones(size(data_wn_matrix.freq))           ;  % initially all points are valid
%sorted_lookup                             =  zeros(size(data_wn_matrix.freq))          ;  % initially none are sorted       
valid_pts                                  =  ones(no_mode_shapes,no_points_per_mode)   ;  % initially all points are valid
sorted_lookup                              =  zeros(no_mode_shapes,no_points_per_mode)  ;  % initially none are sorted       
search_win_tol                             =  2                                         ;  % if -1 then turned off

for mode_index = 1 : no_mode_shapes  
% Trace down  the mode shape through the wave numbers, starting from the

for point_index = 1:no_points_per_mode-1;
   
if point_index == 1
valid_pts(mode_index,point_index)      =           0 ;
sorted_lookup(mode_index,point_index)  =  mode_index ; 
mode_index_in_current_point = mode_index ;  % this is for the dot product comparison will be updated as the mode is traced
% make the first column the label of the mode number

else
end %if point_index == 1
%if mode_index == 1
%disp(num2str(sorted_lookup(mode_index,point_index)))
%end %if mode_index == 1

search_window = create_search_window(no_mode_shapes, sorted_lookup(mode_index,point_index), search_win_tol);  % should this be set for each point

for search_index = 1 : no_mode_shapes
% for each wn search for the closest ms to the 

dps(search_index,1) = abs(...
                       dot(data_wn_matrix.ms_x(:,mode_index_in_current_point,point_index), data_wn_matrix.ms_x(:,search_index,point_index+1))+...
                       dot(data_wn_matrix.ms_y(:,mode_index_in_current_point,point_index), data_wn_matrix.ms_y(:,search_index,point_index+1))+...
                       dot(data_wn_matrix.ms_z(:,mode_index_in_current_point,point_index), data_wn_matrix.ms_z(:,search_index,point_index+1)));
end  % for search_index = 1 : no_mode_shapes

%sorted_lookup(mode_index,point_index)  =  mode_index ; 

dps = dps .* valid_pts(:,point_index+1) ; % eliminate any points already used
dps = dps .*search_window;

if mode_index ==1 && point_index == 1
n_dps = 100 * dps/max(dps);
%n_dps(:,point_index)  = norm_dps;
%end %if mode_index ==1
end  %if mode_index ==1 && point_index == 1

[~,mode_index_in_current_point]  =  max(dps) ;     % increment index 

valid_pts(mode_index_in_current_point,point_index+1) = 0 ;
sorted_lookup(mode_index,point_index+1) = mode_index_in_current_point ;

end %for point_index = 1:no_points_per_mode-1;
end % for mode_index = 1 : no_mode_shapes

for point_index = 1:no_points_per_mode;
freq__   (:,point_index)                =   data_wn_matrix.freq  (sorted_lookup(:,point_index) ,point_index ); 
ph_vel__ (:,point_index)                =   data_wn_matrix.ph_vel(sorted_lookup(:,point_index) ,point_index ); 
waveno   (:,point_index)                =   data_wn_matrix.waveno(sorted_lookup(:,point_index) ,point_index );  
end

reshaped_proc_data.freq      =  freq__'   ;
reshaped_proc_data.ph_vel    =  ph_vel__' ;
reshaped_proc_data.waveno    =  waveno';



for node_index = 1:no_nodes
for point_index = 1:no_points_per_mode;
temp_x(:,point_index)                  = data_wn_matrix.ms_x(node_index,sorted_lookup(:,point_index),point_index);
temp_y(:,point_index)                  = data_wn_matrix.ms_y(node_index,sorted_lookup(:,point_index),point_index);
temp_z(:,point_index)                  = data_wn_matrix.ms_z(node_index,sorted_lookup(:,point_index),point_index);
end %for point_index = 1:no_points_per_mode;

reshaped_proc_data.ms_x (node_index,:,:)   = temp_x';
reshaped_proc_data.ms_y (node_index,:,:)   = temp_y';
reshaped_proc_data.ms_z (node_index,:,:)   = temp_z';

end  %for node_index = 1:no_nodes

% go through every mode and calculate the group velocity for each one here:::::::::::::::::
% size(reshaped_proc_data.freq,2) -  this should be the number of mode shapes
% group_velocity = zeros(size(reshaped_proc_data.waveno));
% for mode_index = 1 : no_mode_shapes  
% freq_temp =  reshaped_proc_data.freq (:,mode_index) ;
% wn_temp   =  reshaped_proc_data.waveno(:,mode_index);
% [group_velocity_temp] = calc_group_velocity(freq_temp , wn_temp , 0.000001);  
% group_velocity(:,mode_index) = group_velocity_temp;
% end % for mode_index = 1 : no_mode_shapes      
% reshaped_proc_data.group_velocity = group_velocity;

%----------------------------------------------------------------------------------------------------------
%save reshaped_proc_data reshaped_proc_data
%----------------------------------------------------------------------------------------------------------

if do_modes_plots == 1;
    
figure(2)
subplot(2,1,1)
plot(reshaped_proc_data.freq,reshaped_proc_data.ph_vel,'-.')
xlim([0 50E3])
ylim([0 1E4])
xlabel('Freq')
ylabel('Vph')
title('modes found using maximum of dot product of mode shapes') 
subplot(2,1,2)

%plot the modes by simply reordering the matrix
plot( data_wn_matrix.freq', data_wn_matrix.ph_vel','-')
xlabel('Freq')
ylabel('Vph')
xlim([0 50E3])
ylim([0 1E4])
title('modes assumed through simply reshaping the matrix') 

%figure(3)
%plot(reshaped_proc_data.freq,reshaped_proc_data.group_velocity,'-.')
%xlabel('Freq')
%ylabel('Vgr')
%title('modes found using maximum of dot product of mode shapes') 

figure(4)
plot(reshaped_proc_data.freq,reshaped_proc_data.waveno,'-.')
xlabel('Freq')
ylabel('K')
title('modes found using maximum of dot product of mode shapes') 
end %if do_modes_plots == 1;


end
%------------------------------------------------------------------------------------------------------------

function [group_velocity_] = calc_group_velocity(freq_,wn_,gap)

% df_dk is the group velocity
% ------------------------------------------------------------------------------------
% calc_dcirc_dwavenumber  ------------ this is the group velocity ------------
% ----------------------------
% first get the path length as a variable (s_)
% gap is h in the numerical diff
% y = freq
% x = wn
% ------------------------------------------------------------------------------------
s_(1) = 0;
for index = 1: size(freq_,1)-1
s_(index + 1) = s_(index) + sqrt((freq_(index)-freq_(index+1))^2  + (wn_(index)-wn_(index+1))^2);       
end %for index = 1: size(freq_,1)

s_ = s_' ;

for index = 1: size(freq_,1)
df_ds(index)     =  (spline(s_,freq_ , s_(index) + gap/2) - spline(s_,freq_ , s_(index) - gap/2))/gap  ;
dwn_ds(index)    =  (spline(s_,wn_ , s_(index) + gap/2) - spline(s_,wn_ , s_(index) - gap/2))/gap      ;
% freq_even(index) =  spline(s_,freq_ , s_(index));
end
df_dwn           =   df_ds./dwn_ds ;   % this is the chain rule or s. l. t.
df_dk  = df_dwn'                   ;   %  this is what disperse gives (units check)
group_velocity_ = df_dk            ;

% dxds     =    dwn/ds
% dy/dx    =    dy/ds
%               -----
%               dx/ds
end %function


function [data_wn,data_wn_mat] = order_by_wavenumber(data,do_plot);
% need to reshape so that
node_ = 1 ;
mode_ = 1 ;
% legacy from 'Fenel' processing --  beacuse of file ordering in directory  -----  not necessary for 'SAFE' data

no_points       = size(data.ms_x,2);
no_nodes        = size(data.ms_x,1);
points_per_mode = data.no_files;
no_mode_shapes  = round(no_points/points_per_mode);

lambda = data.ph_vel(1:no_mode_shapes:no_points,1) ./ data.freq(1:no_mode_shapes:no_points,1);
[ordered_lambda , block_lookup] = sort(lambda);

block_lookup   =  flipud(block_lookup)    ; %reverse it   because k = 2pi/lambda

for count=1 : points_per_mode
initial_lookup((count-1)*no_mode_shapes + 1 : count*no_mode_shapes)    =   (block_lookup(count)-1) * no_mode_shapes + 1  :   block_lookup(count)*no_mode_shapes;
end;

% find the first mode shape and compare it to the original mode shape
data_wn.no_files = data.no_files;  
data_wn.freq     = data.freq(initial_lookup(:)); 
data_wn.ph_vel   = data.ph_vel(initial_lookup(:));
data_wn.waveno   = data.waveno(initial_lookup(:));


data_wn.ms_x     = data.ms_x(:,initial_lookup(:));
data_wn.ms_y     = data.ms_y(:,initial_lookup(:));
data_wn.ms_z     = data.ms_z(:,initial_lookup(:));


data_wn_mat.freq       =  reshape(data_wn.freq,no_mode_shapes,points_per_mode)  ;
data_wn_mat.ph_vel     =  reshape(data_wn.ph_vel,no_mode_shapes,points_per_mode);
data_wn_mat.waveno     =  reshape(data_wn.waveno,no_mode_shapes,points_per_mode);


for index = 1:no_nodes 
temp_x = data_wn.ms_x(index,:);
temp_y = data_wn.ms_y(index,:);
temp_z = data_wn.ms_z(index,:);

reshape_temp_x  = reshape(temp_x, no_mode_shapes,points_per_mode);   
reshape_temp_y  = reshape(temp_y, no_mode_shapes,points_per_mode);   
reshape_temp_z  = reshape(temp_z, no_mode_shapes,points_per_mode);   

data_wn_mat.ms_x(index,:,:) = reshape_temp_x;      
data_wn_mat.ms_y(index,:,:) = reshape_temp_y;            
data_wn_mat.ms_z(index,:,:) = reshape_temp_z;            

end %for index = 1:no_points


% plot the first mode from vector and reshaped to make sure the are the same

if do_plot ==1
figure(1)
subplot (2,1,1)    
plot(2*pi*data.freq./data.ph_vel,'.')
subplot (2,1,2)    
plot(2*pi*data_wn.freq./data_wn.ph_vel,'.')
figure(2)
subplot (3,1,1)    
temp__ = squeeze(data_wn_mat.ms_x(node_,mode_,:));
plot(real(temp__) , 'rx')
hold on
plot( real(data_wn.ms_x(node_,(mode_-1)*points_per_mode+1  : mode_*points_per_mode) ),'bo')
subplot (3,1,2)
temp__ = squeeze(data_wn_mat.ms_y(node_,mode_,:));
plot(real(temp__) , 'rx')
hold on
plot( real(data_wn.ms_y(node_,(mode_-1)*points_per_mode+1  : mode_*points_per_mode) ),'bo')
subplot (3,1,3)
temp__ = squeeze(data_wn_mat.ms_z(node_,mode_,:));
plot(real(temp__) , 'rx')
hold on
plot( real(data_wn.ms_z(node_,(mode_-1)*points_per_mode+1  : mode_*points_per_mode) ),'bo')
end %if do_plot == 1

end % function

function search_window = create_search_window(no_mode_shapes,mode_index,search_win_tol)

if search_win_tol ==-1
search_window = ones(no_mode_shapes,1);    
else
search_window = zeros(no_mode_shapes,1);
if mode_index - search_win_tol <= 1
search_window_start = 1;    
else
search_window_start = mode_index - search_win_tol;
end
if mode_index + search_win_tol >= no_mode_shapes
search_window_end = no_mode_shapes;    
else
search_window_end =  mode_index + search_win_tol;    
end
search_window(search_window_start:search_window_end) = ones(size(search_window(search_window_start:search_window_end),1),1);
end

end %function
%------------------------------------------------------------------------------------------------------------















