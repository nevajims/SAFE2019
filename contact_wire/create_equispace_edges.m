% Create Eqispace edges
% name format =   **fn** eq_POINTS.MAT
% POINTS = number of outside points

function  create_equispace_edges(no_points)

files_to_process  = {'AC-80.mat','AC-100.mat','AC-107.mat','AC-120.mat','AC-150.mat','BC-100.mat','BC-107.mat','BC-120.mat','BC-150.mat'}   ;

diameters_         = [10.6, 12.0, 12.3, 13.2, 14.8, 12.0, 12.24, 12.85, 14.5]                                                               ;

for index = 1: length(files_to_process)
load(files_to_process{index})
filename = [files_to_process{index}(1:end-4),'eq_',num2str(no_points),'.mat'];


[dummy1 , dummy2]    =   get_outside_edge( data , diameters_(index) , diameters_(index) , no_points , 1)  ; 

clear data
data.equispaced_points_mm  = dummy1;
data.path_distance         = dummy2; 

save (filename, 'data')
end %for index = 1: length(files_to_process)

end %function create_eqispace_edges (no_points)

