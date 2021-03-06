function reshaped_proc_data =  SAFE_batch_solve(mat_index , indep_var , points_in_sol , max_freq , no_modes, do_save, do_plot)

% INPUT DATA------------------------------------------------------------------------
% INPUT DATA------------------------------------------------------------------------ 
% no_modes -  number of modes to solve for 
% SAFE_batch_solve(2,'waveno',300,0.5e6,1)    -  example of this function being used
% points_in_sol = 300;  points on dispersion curve
% mat_index   1 - Steel   //    2 - Copper
% max_freq      =  0.5e6;  maximum frequency in Hz
% indep_var   'freq' or 'waveno'  (usually 'waveno')
% do_save  -  save the data on the NAS 
% do_plot  -  show the mesh and results
% INPUT DATA------------------------------------------------------------------------
% INPUT DATA------------------------------------------------------------------------
solve_details.mat_index     = mat_index       ; 
solve_details.indep_var     = indep_var       ; 
solve_details.points_in_sol = points_in_sol   ; 
solve_details.max_freq      = max_freq        ; 
solve_details.no_modes      = no_modes        ;

[mat_properties, OK_]      =  get_mat_properties(mat_index) ;
triangular_element_type    =  2                             ;
safe_opts.max_sparse_modes =  no_modes                      ;

if OK_ ==1
safe_opts.use_sparse = 1;
cd('meshes')
temp_a                =       dir('*.mat')            ;
all_file_names        =      {temp_a.name}            ;

choice = listdlg('PromptString' , 'Select the meshes to solve' , 'SelectionMode' , 'multiple'  , 'ListString' , all_file_names);
% file_name = temp_b{choice};

for index = 1: length (choice)
load(all_file_names{choice(index)})  ;

mesh.matl{1}.name              =    mat_properties.matl_name;
mesh.matl{1}.stiffness_matrix  =    fn_iso_stiffness_matrix( mat_properties.youngs_modulus,  mat_properties.poissons_ratio);
mesh.matl{1}.density           =    mat_properties.density;

[long_vel, shear_vel]          =   fn_velocities_from_stiffness_and_density( mat_properties.youngs_modulus,  mat_properties.poissons_ratio,  mat_properties.density);

mesh.el.matl  = ones(size(mesh.el.nds, 1), 1)                            ;
mesh.el.type  = ones(size(mesh.el.nds, 1), 1) * triangular_element_type  ;
mesh.nd.dof   = ones(size(mesh.nd.pos, 1), 3)                            ;      

switch indep_var
    case 'waveno'
        var = linspace(0, 2 * pi * max_freq / shear_vel, points_in_sol);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
        
    case 'freq'
        var = linspace(0, max_freq, points_in_sol);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
end

[data_wn] = create_fenel_format_data (unsorted_results);



[reshaped_proc_data , ~ , ~] =  proc_data_into_modes_safe(data_wn,no_modes);

reshaped_proc_data.mesh = mesh                      ;
reshaped_proc_data.solve_details  = solve_details   ;

%keyboard

plot_data (reshaped_proc_data , max_freq , long_vel , all_file_names{choice(index)} , do_plot  )


save_data (reshaped_proc_data , all_file_names{choice(index)}, do_save)


end % for index = 1: length (choice)
cd('..')
else
   
    
    
end% if OK_ ==1

% solver parameters
% indep_var            = 'waveno' , 'freq'   %
% pts                  = 300;                %
% max_freq             = 0.5e6;              % 
% default disperse vaules--------------------------------------------

end %function SAFE_batch_solve(mat_index, indep_var, points_in_sol, max_freq )

%----------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------

function [mat_properties  , OK_ ] = get_mat_properties(mat_index)  

OK_ = 1;

switch(mat_index)

    case (1) 
% steel
mat_properties.youngs_modulus       = 216.9e9;%Pa
mat_properties.poissons_ratio       = 0.2865;
mat_properties.density              = 7932;%kg/m3
mat_properties.matl_name            = 'steel';

    case (2)
% copper
mat_properties.youngs_modulus       = 117e9;%Pa
mat_properties.poissons_ratio       = 0.35; 
mat_properties.density              = 8960;%kg/m3
mat_properties.matl_name            = 'copper';

    otherwise
      
OK_ = 0;
disp('No material property for this index')

end %switch(mat_index)
end %function mat_properties = get_mat_properties( )  

function plot_data (reshaped_proc_data,max_freq ,long_vel,file_name, do_plot)
if do_plot == 1

% colormap= hsv(100); cmap = [colormap(20:end,:);colormap(1:20-1,:)];
% Plot_color = cmap(round( (count/ tot_els)  * length(cmap)),:);      % range 

mode_nos =  [1:size(reshaped_proc_data.freq,2)];

leg_text = ''; 
for index = 1:length(mode_nos)
if index == length(mode_nos); comma_insert=''; else comma_insert=','; end
leg_text = [leg_text,'''','Mode ', num2str(mode_nos(index)),'''', comma_insert ];   
end %for index = 1:length(mode_nos)

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(1,3,1)
fv.Vertices  = reshaped_proc_data.mesh.nd.pos;
fv.Faces     = reshaped_proc_data.mesh.el.nds;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;
subplot(1,3,2)
plot(reshaped_proc_data.freq/1000 , 2 * pi * reshaped_proc_data.freq ./ reshaped_proc_data.waveno , '.');

xlabel('Frequency (kHz)')
ylabel('Vph')
axis([0, max_freq/1000, 0, 2*long_vel]);

file_name_r =  file_name;
file_name_r(find(file_name=='_')) =' ';


suptitle(['file name: ',file_name_r])
subplot(1,3,3)
plot(reshaped_proc_data.freq/1000 , reshaped_proc_data.waveno , '.');
xlabel('Frequency (kHz)')
ylabel('WN (1/m)')
eval(['leg_hand = legend(',leg_text,');']    )
set(leg_hand,'location','EastOutside' )

end %if do_plot ==1
end %function plot_data (reshaped_proc_data , do_plot)

function save_data (reshaped_proc_data,mesh_file_name,do_save)

if do_save ==1

P_W_D = pwd;
cd('m:\SAFE_solutions')
mesh_pos_start =  strfind(mesh_file_name,'MESH');
solution_file_name = [mesh_file_name(1:(mesh_pos_start-1)),'SOLVED' ,mesh_file_name((mesh_pos_start+4):end)];
save(solution_file_name,'reshaped_proc_data')
disp([solution_file_name,'.... Saved'])
cd(P_W_D)

end  %if do_save ==1

end %function save_data (reshaped_proc_data,mesh_file_name )
