function mode_lookup =  read_mode_lookup(file_name)

% csv format 
fid = fopen([file_name,'.csv']);

new_line = 1;
linecount = 0;

while new_line == 1
current_line  = fgetl(fid); 

if length(current_line) == 1
new_line =0;
else
    
linecount = linecount + 1;
current_commas = find(current_line == ',');

for index = 2 : length(current_commas)
    
temp_start_index = current_commas(index)+1;

if index == length(current_commas)
temp_end_index = length(current_line);
else
temp_end_index = current_commas(index+1)-1;    
end %if index = length(current_commas) + 1    

if linecount == 1
names_{index-1} = current_line(temp_start_index:temp_end_index);
else
    
if index ==2
mesh_name{linecount-1} =  current_line(current_commas(1)+1 : current_commas(2)-1);
end
    
look_vals(linecount-1,index-1)  =  str2num(current_line(temp_start_index:temp_end_index));

end    
end %for index = 1: length(current_commas)
end %if length(current_line) == 1
end %while new_line == 1

[~ , unique_name_indices_unsorted]  =  unique(names_)                     ; 
unique_name_indices                 =  sort(unique_name_indices_unsorted) ;

for index              =    1 : length(unique_name_indices)
    
mode_name{index}       =    names_{unique_name_indices(index)};

all_instances_of_mode  = find(strcmp(names_,mode_name{index})); % there will either be 1 or 2 instances
if length(all_instances_of_mode) == 1
% add a columns of NaN's
mode_indices{index} =  [look_vals(:,all_instances_of_mode),NaN(size(look_vals(:,all_instances_of_mode)))];
elseif length(all_instances_of_mode) == 2
mode_indices{index} =  [look_vals(:,all_instances_of_mode(1)),look_vals(:,all_instances_of_mode(2))];
else
disp('error there should be 1 or 2 instances of the mode')
end %if length (all_instances_of_mode) == 1
end %for index = 1 length(unique_name_indices)

mode_lookup.mode_name    = mode_name     ;
mode_lookup.mode_indices = mode_indices  ;
mode_lookup.mesh_name    = mesh_name     ;

save mode_lookup mode_lookup
