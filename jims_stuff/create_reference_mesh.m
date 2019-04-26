function [mode_data_str] = create_reference_mesh(rpdl_index)

load(['reshaped_proc_data_lite_',num2str(rpdl_index),'.mat'])
fid = fopen(['Reference Mode Names.csv']);

first_line  = fgetl(fid);
comma_indices =  find(first_line == ',');
reference_name = first_line(1:comma_indices(1)-1);

second_line    = fgetl(fid);
comma_indices  = find (second_line==',');

for index = 1:length(comma_indices)+1
    
if index ==    1    
temp_start_index = 1;   
temp_end_index = comma_indices(index) - 1;

elseif index == length(comma_indices) + 1;
temp_start_index = comma_indices(index-1) + 1;   
temp_end_index =  length(second_line);
else  
temp_start_index = comma_indices(index-1)+1;   
temp_end_index =  comma_indices(index)-1;
end %for index = 1:length(comma_indices)+1
names_{index} = second_line(temp_start_index:temp_end_index);
end %for index = 1: length(comma_indices)

data_ = cell(1,size(reshaped_proc_data_lite.freq,2));

for index = 1 : size(reshaped_proc_data_lite.freq,2)
data_{index}(:,1) = reshaped_proc_data_lite.freq(:,index)/1E6                        ;
data_{index}(:,2) = reshaped_proc_data_lite.waveno(:,index)/1000                     ;
data_{index}(:,3) = reshaped_proc_data_lite.ph_vel(:,index)/1000                     ;
data_{index}(:,4) = reshaped_proc_data_lite.group_velocity(:,index)/(1000*2*pi)      ;
end %for index = 1 : size(reshaped_proc_data_lite.freq,2)

mode_data_str.data               =  data_                                                             ;
mode_data_str.num_points         =  ones(1,size(reshaped_proc_data_lite.freq,2))*size(reshaped_proc_data_lite.freq,1);
mode_data_str.mode_name          =  names_                                                            ;
mode_data_str.units              =  {'MHz'  '1/mm'  'm/ms'  'm/ms'}                                   ;
mode_data_str.units_long_name    =  {'Frequency'  'Wavenumber'  'Phase velocity'  'Group velocity'}   ;
mode_data_str.units_short_name   =  {'f'  'k'  'Vph'  'Vgr'}                                          ;
mode_data_str.reference_name     =  reference_name                                                    ;

save mode_data_str mode_data_str

%---------------------------------------------------------------------------------------
% get the multiplication factor---------------------------------------------------------
%---------------------------------------------------------------------------------------
% data
% num_points
%     take rpd_lite file and create a file in the same format as the dispers       %
%     reference file 'mode data str'                                               %
%     (make sure the units are consistant)                                         %

%{
mode_data_str = 
                data: {1x19 cell}
          num_points: [47 36 60 57 39 35 63 58 46 31 63 53 33 59 45 48 171 170 162]
           mode_name: {1x19 cell}
               units: {'MHz'  '1/mm'  'm/ms'  'm/ms'}
     units_long_name: {'Frequency'  'Wavenumber'  'Phase velocity'  'Group velocity'}
    units_short_name: {'f'  'k'  'Vph'  'Vgr'}
%}

%{
mode_data_str.data = 
  Columns 1 through 8
    [47x4 double]    [36x4 double]    [60x4 double]    [57x4 double]    [39x4 double]    [35x4 double]    [63x4 double]    [58x4 double]
  Columns 9 through 16
    [46x4 double]    [31x4 double]    [63x4 double]    [53x4 double]    [33x4 double]    [59x4 double]    [45x4 double]    [48x4 double]
  Columns 17 through 19
    [171x4 double]    [170x4 double]    [162x4 double]
%}

end  % function [  ] = create_reference_mesh()