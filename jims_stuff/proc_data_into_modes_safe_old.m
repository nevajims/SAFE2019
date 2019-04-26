function [reshaped_proc_data , proc_data] =  proc_data_into_modes_safe_old(data);


%old ---------preserved to take the fennel form takes the form


%------------------ to do
% calculate group velocity using my method to make sure it is the same
%
%
%
%------------------ to do


do_order_by_wn_plot = 0;
do_modes_plots = 1;
no_points = size(data.ms_x,2);
no_nodes  = size(data.ms_x,1);
no_mode_shapes  = round(no_points/data.no_files);
data_wn  =  order_by_wavenumber(data , do_order_by_wn_plot );

%get ready for the mode tracing part
valid_pts                                 =  ones(no_points,1)      ;    % initially all points are valid
sorted_lookup                             =  zeros(no_points,1)     ;   % initially none are sorted       
proc_data.mode_start_indices              =  zeros(no_mode_shapes,1);
mode_start_index_in_initial_lookup        =  1                      ; % this is incremented through all the points inside loop
mode_start_index_in_sorted_lookup         =  1                      ;
index_in_sorted_lookup                    =  1                      ;
mode_count                                =  1                      ;

counter_1 = 0;

while mode_start_index_in_initial_lookup <= no_points;

   if valid_pts(mode_start_index_in_initial_lookup,1);
   %disp([num2str(mode_start_index_in_initial_lookup),'--------']) 
   %disp(num2str(length(find(valid_pts==1))))
   %found first point of mode
   
      old_max_dps = -1 ; %to turn off mode shape comparison
      proc_data.mode_start_indices(mode_count)      =   mode_start_index_in_sorted_lookup  ;   % where the mode starts in the sorted lookup
      current_index_in_initial_lookup               =   mode_start_index_in_initial_lookup ;   % this is initial value for the current point
      first_block = floor((current_index_in_initial_lookup-1)/no_mode_shapes) + 2 ;            % the block after where the current point is
      last_block  = data.no_files;                                                             % the last block in the look up table
      
 %disp(num2str(last_block))      
 %disp(num2str(first_block))     
 
      % add point to mode in sorted lookup
      sorted_lookup(index_in_sorted_lookup)=current_index_in_initial_lookup;
      valid_pts(current_index_in_initial_lookup)=0; %so that the point can't be used as either a starting point or another point on another mode
      index_in_sorted_lookup = index_in_sorted_lookup + 1;
      %work through the subsequent blocks to trace the mode
      
      if first_block <= last_block; % catch, in case a stray point is found in last block, and there are no further blocks to trace in
          
          for block = first_block : last_block ;

           %find the best match in the block
      	   dps = zeros(no_points,1);
           % disp(num2str(length(dps)))
           first_index=(block-1)*no_mode_shapes+1;
           last_index=block*no_mode_shapes;
                     
   	      %compare each point in block with current point
           for index = first_index:last_index;
                  dps(index,1)=abs(...
                  dot(data_wn.ms_x(:,current_index_in_initial_lookup), data_wn.ms_x(:,index))+...
                  dot(data_wn.ms_y(:,current_index_in_initial_lookup), data_wn.ms_y(:,index))+...
               	  dot(data_wn.ms_z(:,current_index_in_initial_lookup), data_wn.ms_z(:,index)));
           end %for index=first_index:last_index;
                      
            dps(first_index:last_index,1) = dps(first_index:last_index,1) .* valid_pts(first_index:last_index,1);%eliminate any points already used
            
             % if block == first_block
             % disp(num2str(length(find(dps~=0))))
             % disp([num2str(max(dps)),',',num2str(min(dps))])
             % end %if block == first_block
             
            [new_max_dps,current_index_in_initial_lookup]  =  max(dps);%increment index 
            
            %look for mode shape mismatch if not first point 

            %---  This hasnt happened yet
            if old_max_dps > 1;
            counter_1  = counter_1 + 1;
            disp(['old_max_dps > 1 ' num2str(counter_1)])
            if new_max_dps/old_max_dps*100 < run_variables.min_percent_change_in_ms;
               %end of mode due to mode shape mismatch
                  break;
               end %if new_max_dps/old_max_dps*100<run_variables.min_percent_change_in_ms;
           end %if old_max_dps > 1;
           %---  This hasnt happened yet
           old_max_dps = new_max_dps;
           
           % add point to sorted lookup
           sorted_lookup(index_in_sorted_lookup) = current_index_in_initial_lookup;
           valid_pts(current_index_in_initial_lookup)=0;
           index_in_sorted_lookup = index_in_sorted_lookup+1;                  
           
                                
          end %for block=first_block:last_block;
          %disp(num2str(index_in_sorted_lookup))
    
      else
       disp('there was a stray point')
      end %if first_block<=last_block
      
      mode_count = mode_count+1;                                               %------------------------------ mode_count = mode_count+1;
      mode_start_index_in_sorted_lookup = index_in_sorted_lookup;
      
   end  %if valid_pts(mode_start_index_in_initial_lookup,1);
  
   mode_start_index_in_initial_lookup = mode_start_index_in_initial_lookup+1; 
end

proc_data.no_modes = size(proc_data.mode_start_indices,1);

%proc_data.mode_start_indices=[ proc_data.mode_start_indices ; no_points];%last index is last point in array - useful in other functions
% sort original data into order specified by sorted look-up

proc_data.freq            =  data_wn.freq(sorted_lookup(:))   ;      
proc_data.ph_vel          =  data_wn.ph_vel(sorted_lookup(:)) ;
proc_data.ms_x            =  data_wn.ms_x(:,sorted_lookup(:)) ;
proc_data.ms_y            =  data_wn.ms_y(:,sorted_lookup(:)) ;
proc_data.ms_z            =  data_wn.ms_z(:,sorted_lookup(:)) ;
proc_data.gr_vel          =  calculate_group_velocity(proc_data.mode_start_indices,proc_data.freq,proc_data.ph_vel);   

reshaped_proc_data.freq   = reshape(proc_data.freq   , data.no_files , proc_data.no_modes);
reshaped_proc_data.ph_vel = reshape(proc_data.ph_vel , data.no_files , proc_data.no_modes);
% node number ,  point number on mode curve , mode number
reshaped_proc_data.ms_x   =  reshape(proc_data.ms_x,  no_nodes , data.no_files , proc_data.no_modes);
reshaped_proc_data.ms_y   =  reshape(proc_data.ms_y,  no_nodes , data.no_files , proc_data.no_modes);
reshaped_proc_data.ms_z   =  reshape(proc_data.ms_z,  no_nodes , data.no_files , proc_data.no_modes);

if do_modes_plots == 1;
figure(2)
%plot the modes as calculated by the dot product
subplot(2,1,1)


plot(reshaped_proc_data.freq,reshaped_proc_data.ph_vel,'.')
xlim([0 1E4])
ylim([0 2E4])
xlabel('Freq')
ylabel('Vph')
title('modes found using maximum of dot product of mode shapes') 

subplot(2,1,2)

%plot the modes by simply reordering the matrix
reshap_freq2   = reshape(data_wn.freq,20,398);
reshap_ph_vel2 = reshape(data_wn.ph_vel,20,398);
plot(reshap_freq2',reshap_ph_vel2','.')
xlabel('Freq')
ylabel('Vph')
xlim([0 1E4])
ylim([0 2E4])
title('modes assumed through simply reshaping the matrix') 
end %if do_modes_plots == 0;


end

%------------------------------------------------------------------------------------------------------------
function data_wn  =  order_by_wavenumber(data,do_plot);

% legacy from 'Fenel' processing --  beacuse of file ordering in directory  -----  not necessary for 'SAFE' data

no_points = size(data.ms_x,2);
no_mode_shapes  = round(no_points/data.no_files);

lambda = data.ph_vel(1:no_mode_shapes:no_points,1) ./ data.freq(1:no_mode_shapes:no_points,1);
[ordered_lambda , block_lookup] = sort(lambda);

block_lookup   =  flipud(block_lookup)    ; %reverse it   because k = 2pi/lambda
for count=1 : data.no_files
initial_lookup((count-1)*no_mode_shapes + 1 : count*no_mode_shapes)    =   (block_lookup(count)-1) * no_mode_shapes + 1  :   block_lookup(count)*no_mode_shapes;
end;

data_wn.freq   = data.freq(initial_lookup(:)); 
data_wn.ph_vel = data.ph_vel(initial_lookup(:));
data_wn.ms_x   = data.ms_x(:,initial_lookup(:));
data_wn.ms_y   = data.ms_y(:,initial_lookup(:));
data_wn.ms_z   = data.ms_z(:,initial_lookup(:));

if do_plot ==1
    figure(1)
subplot (2,1,1)    
plot(2*pi*data.freq./data.ph_vel,'.')
 
subplot (2,1,2)    
plot(2*pi*data_wn.freq./data_wn.ph_vel,'.')

end %if do_plot ==1
end % function


%------------------------------------------------------------------------------------------------------------















