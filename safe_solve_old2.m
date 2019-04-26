%  create a program that takes a mesh and solves 
%  find a mesh and conditions that solve reasonably quickly - 
%  both for rail and 
%  Things unsure about
%  ----------  why does the solver not work for this mode when i put a low frequency value in ??????
%  ----------  why the descrepency in frequency (20x high in the FE gives  the same results as analytical
%  now put in the tension as a variable  and allow the plotting af the same
%  region for each tesnion selected -  simply by wavenumber at the moment

% The 20 factor in the frequency my be a 2(pi) ^2 
% Find the 


%   Do a three d plot of dispersion curves for various strains in order to identify the modes that are most sensitive to strain-  then look at the mode shapes of these.


%   Look at the excitability of the vertical mode at the top of the rail and the horizontal mode on the side of the rail - look at the effect of tension on this.
%   do a comparison of the propogating and non propogating waves



% ***  DONE Verify the 'Freq as independent variable' curves by looking at the progating modes and comparing with equivalent WN as independent variable curves.
% ***  DONE  Plot all the DC in different colours here
% ***  DONE give the option to do the 3d plot-  different for WN or FREQ options

clear
do_plot_mesh = 0;
do_plot_DC = 1;
do_plot_Specific_modes = 1;
show_complex = 1; 

% --------------------------------------------------------------------------------
% Mesh file to load
% --------------------------------------------------------------------------------

cd('meshes')
%load('MESH_ROD_D1_mm_1.mat')
load('MESH_RAIL_56_1.mat')
cd('..')
element_details = get_element_details(mesh);

% --------------------------------------------------------------------------------
% Material Properties
% -------------------------------------------------------------------------------

%matl_name      = 'aluminium';
%youngs_modulus = 70e9;     % kg m-1 s-2    
%poissons_ratio = 1/3;
%density        = 2700;     % kg/m3
matl_name      = 'steel';
youngs_modulus = 216.9e9;
poissons_ratio = 0.2865;
density        = 7932;

% --------------------------------------------------------------------------------
% Solver parameters
% --------------------------------------------------------------------------------
%indep_var               = 'waveno';
indep_var               = 'freq';
%pts                     = 150      ;
max_freq                = 300  ;    % rail freq
pts                     = 250      ;
%max_freq                = 1500;  % rail wn

safe_opts.use_sparse    = 1       ;
triangular_element_type = 2       ;
% Two options
%(1):
nom_el_size      =  mesh_input_settings.nom_el_size(mesh_input_settings.shape_type) ;  % size used to set the mesh
%(2):
%nom_el_size     =   element_details.mean_edge_length;

% -------------------------------
% Loading and boundary conditions
% -------------------------------
% start with a single value function should work with a single value
% pass strain/stress and load to the solver
% if no strain selected then assume strain is 0
% Then do 
% Tension
% Put strain in as a percentage
%all_strain_per              =     [0 0.1]               ;  % strain sets to solve for
%all_strain_per              =     [0 0.02 0.04 0.06 0.08 0.1 ]  % strain sets to solve for (circular bar)
%all_strain_per              =     [0 0.05 0.1];   

%all_strain_per              =     [0 0.25 0.5 0.75 1];   
 all_strain_per              =     [0 0.1];   

%all_strain_per              =     [0 ] ;
 all_strain_abs              =     all_strain_per/100                       ;  % no units
 all_stress                  =     all_strain_abs * youngs_modulus          ;

% then calculate the stress  = strain * youngs modulus
% Tension =   stress * CSA?
% solver should calculate for single tension values
% should output a chosen mode 
% Foundation conditions
% --------------------------------
% Pre prosessing setup parameters
% --------------------------------

mesh.matl{1}.name              =   matl_name;
mesh.matl{1}.stiffness_matrix  =   fn_iso_stiffness_matrix(youngs_modulus, poissons_ratio);
mesh.matl{1}.youngs_modulus    =   youngs_modulus;
mesh.matl{1}.density           =   density;
[long_vel, shear_vel]          =   fn_velocities_from_stiffness_and_density(youngs_modulus, poissons_ratio, density);
hdata.hmax                     =   nom_el_size;
mesh.el.matl                   =   ones(size(mesh.el.nds, 1), 1)                           ;
mesh.el.type                   =   ones(size(mesh.el.nds, 1), 1) * triangular_element_type ;
mesh.nd.dof                    =   ones(size(mesh.nd.pos, 1), 3)                           ;

% ---------------------------
% Post prosessing parameters
% ---------------------------
% specific mode to display in the final plot
% ---------------------------

specific_output_mode_number = 1;

%  just output entire mode details for that mode and save in the condition stack
% ------------------------------------------------------------------------------
% solver
% ------------------------------------------------------------------------------
% size(all_stress,2)
% ------
for index = 1 :  size(all_stress,2)
    
safe_opts.axial_stress = all_stress(index);

switch indep_var
    
    case 'waveno'
        var = linspace(0, 2 * pi * max_freq / shear_vel, pts);
        unsorted_results{index} = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
                 
    case 'freq'
        var = linspace(0, max_freq, pts);
        unsorted_results{index} = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);

        
end % switch indep_var

[data_wn{index}] = create_fenel_format_data (unsorted_results{index});



switch indep_var
    
     case 'waveno'
    [reshaped_proc_data(index).data,sorted_lookup,data_wn_matrix] =  proc_data_into_modes_safe(data_wn{index});        
    reshaped_proc_data(index).data.mesh = mesh;
    
    if index ==  1
    reshaped_proc_data(index).data.all_strain_per = all_strain_per;
    reshaped_proc_data(index).data.stat = 0  ;
    end
     
    
end % switch indep_var

if index ==  1
    unsorted_results{index}.all_strain_per = all_strain_per;
end %if index ==  1
    


end %for index = 1:


%reshaped_proc_data.mesh                = mesh               ;
%reshaped_proc_data.all_strain_per      = all_strain_per     ;
%reshaped_proc_data.all_stress          = all_stress         ;
% --------------------------------------------------------------------------------
% plot
% --------------------------------------------------------------------------------
if do_plot_mesh == 1 
figure;
fv.Vertices = mesh.nd.pos;
fv.Faces = mesh.el.nds;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;
end
% just plot for the first case


if do_plot_DC == 1 

figure 
hold on
cc=hsv(size(all_strain_per  ,2));

for index = 1:size(all_strain_per  ,2)
  
switch indep_var
    
    case 'waveno'

plot(unsorted_results{index}.freq , 2 * pi * unsorted_results{index}.freq ./ unsorted_results{index}.waveno ,'.','color',cc(index,:));
xlabel('Frequency')
ylabel('Vph')
       
    case 'freq'
    disp(num2str(index))    
if show_complex == 1        
plot3(unsorted_results{index}.freq , real(unsorted_results{index}.waveno), imag(unsorted_results{index}.waveno)   ,'.','color',cc(index,:));
xlabel('Frequency')
ylabel('Real Wavenumber')
zlabel('Imaginary Wavenumber')

zlim([-10,10])
ylim([-20 20])
xlim([0,400])

else
    disp(num2str(index))
plot(unsorted_results{index}.freq , 2 * pi * unsorted_results{index}.freq ./ unsorted_results{index}.waveno ,'.','color',cc(index,:));
xlabel('Frequency')
ylabel('Vph')
end %if show_complex == 1        
        
end % switch indep_var

end %for index = 1:size(all_strain_per  ,2)
%axis([0, 2E4, 0,1E4 ])
%axis([0, 1000, 0,350 ]);
%axis([0, max_freq, 0, 2*long_vel]);
%axis([0, 20000, 0,500]);
%axis([0, 20000, 0,500 ]);
end %if do_plot_DC == 1 


if do_plot_Specific_modes == 1 
    
switch indep_var
    
     case 'waveno'

figure
hold on
leg_text = '';
cc=hsv(size(all_strain_per  ,2));

for index = 1:size(all_strain_per  ,2)
    
plot(reshaped_proc_data(index).data.freq(:,specific_output_mode_number),reshaped_proc_data(index).data.ph_vel(:,specific_output_mode_number),'-x','color',cc(index,:))    

if index == size(all_strain_per  ,2)
comma_insert = '';
else
comma_insert = ',';
end
leg_text            = [leg_text,'''','Strain = ',num2str(all_strain_per(index)),'''', comma_insert]; 
end
disp(['legend(',leg_text,')'])
eval(['legend(',leg_text,')'])

xlabel('Frequency (Hz)')
ylabel('Real Vph  (m/s)')
%axis([0, 20000, 0,500 ]);  % rod    
axis([0, 2000, 0,1200 ]);   %rail
     case 'freq'         
         
disp('cant plot like this yet')
     
    
end % switch indep_var    

end %if do_plot_Specific_modes == 1 




