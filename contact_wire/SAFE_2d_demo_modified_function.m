% made small changes for first commit
% new files created :  Euler_Bern_verify.m
%demo of how to use SAFE method to calculate dispersion curves for a 2D
%waveguide - a 1mm diameter aluminium rod as an example

clear all ; close all;
do_plot = 1;
n_v_points = 800;



%-------------------------------
% demo of how to use SAFE method to calculate dispersion curves for a 2D
% waveguide - a 1mm diameter aluminium rod as an example
%-------------------------------
% addpath('.\Mesh2d v24');
%-------------------------------
% define material(s)
% matl_name = 'aluminium';
% youngs_modulus = 70e9;
% poissons_ratio = 1/3;
% density = 2700;
%-------------------------------
% define material(s)
%------------------------------
%   
%
%  Put in a strain_per value and have the model solve for this value-  then
%
%
%  from the results write a function that plots phase velocity vs frequency
%  for a chosen mode 
%  extract the first  

matl_name = 'steel';
% default disperse vaules--------------------------------------------
%steel
% youngs_modulus       = 216.9e9;
% poissons_ratio       = 0.2865;
% density              = 7932;

%copper
youngs_modulus       = 117e9;
poissons_ratio       = 0.35; 
density              = 8960; %kg/m3

% default disperse vaules--------------------------------------------
% solver parameters
indep_var            = 'waveno';
pts                  = 300;
max_freq             = 0.5e6;

%max_freq            = 0.5e5;
safe_opts.use_sparse = 1;
% mesh - see mesh2d or meshfaces functions for how meshing works
% rad = 0.5e-3;
%rad = 1e-3;
%-----------------------------
%no_per_mm = 2;
%nom_el_size = rad/2; 
%nom_el_size = rad/0.2; 
%nom_el_size = 0.015625E-3; 

%-----------------------------
% [nodes_,edge_] = create_Rectangular_x_section(15.6,1.6,2,no_per_mm) ;
% [nodes_,edge_] = create_arb_pipe(203.2 , 8 , 30)            ;
%%%%%%%%%%%%%%%%%
%no_per_side = 160;
%nom_el_size = (175E-3)/no_per_side;
%[nodes_,edge_] = create_n_sided_polygon(424.8 ,16.24 ,8 , no_per_side);
%nodes_        = nodes_* 1e-3;
%%%%%%%%%%%%%%%%%[nodes_,edge_] = create_n_sided_polygon(416.18 ,20.56 , 8 , 10);
%[nodes_,edge_]  =  create_arb_pipe(438.5 , 9.525 , 150);
% nom_el_size = 12E-3;

triangular_element_type = 2;

%a = linspace(0, 2 * pi, ceil(2 * pi * rad / nom_el_size));
%a = a(1:end - 1)';
%nd_ = [cos(a), sin(a)] * rad ;
%--------------------------------------------------------------------------
load('AC-80_W10_6_H10_6.mat')

%load('5-01-0A IM RAIL MODEL 60 E 1 (H 172 W 150).mat')
%[equispaced_points_mm, nom_el_size_mm]    =  get_outside_edge( data , 172 , 150 , 100 , 1);

%[equispaced_points_mm, nom_el_size_mm]     =  get_outside_edge( data , 10.6 , 10.6 , 250 , 1); 
[variable_points_mm , nom_el_size_mm ]  = get_outside_edge_variable( data , 10.6 , 10.6 , n_v_points, 1); 


disp([num2str(length(variable_points_mm)) , 'Points' ])

nom_el_size = nom_el_size_mm * 1E-3;

nd_ = [real(variable_points_mm)'*1E-3,imag(variable_points_mm)'*1E-3];

%nd_ = [real(equispaced_points_mm )'*1E-3,imag(equispaced_points_mm )'*1E-3];
%--------------------------------------------------------------------------
mesh.matl{1}.name              =   matl_name;
mesh.matl{1}.stiffness_matrix  =   fn_iso_stiffness_matrix(youngs_modulus, poissons_ratio);
mesh.matl{1}.density           =   density;
[long_vel, shear_vel]          =   fn_velocities_from_stiffness_and_density(youngs_modulus, poissons_ratio, density);
hdata.hmax                     =   nom_el_size;
ops.output                     =   false;

[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nd_, [], hdata, ops);
%[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nodes_, edge_,hdata, ops);
%[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nodes_, edge_);

mesh.el.matl  = ones(size(mesh.el.nds, 1), 1)                            ;
mesh.el.type  = ones(size(mesh.el.nds, 1), 1) * triangular_element_type  ;
mesh.nd.dof   = ones(size(mesh.nd.pos, 1), 3)                            ;

%[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nd_, [], hdata, ops)    ;
%[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nd_, [], [], ops)    ;



%display mesh
%SAFE solver
switch indep_var
    case 'waveno'
        var = linspace(0, 2 * pi * max_freq / shear_vel, pts);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
        
    case 'freq'
        var = linspace(0, max_freq, pts);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);

end

%save unsorted_results unsorted_results
[data_wn] = create_fenel_format_data (unsorted_results);
%save data_wn data_wn
[reshaped_proc_data,sorted_lookup,data_wn_matrix] =  proc_data_into_modes_safe(data_wn);
reshaped_proc_data.mesh = mesh ;


%save sorted_lookup sorted_lookup
%save data_wn_matrix data_wn_matrix
%save reshaped_proc_data reshaped_proc_data
%save reshaped_proc_data reshaped_proc_data -v7.3
%[dispersion_region] = get_dispersion_region(reshaped_proc_data,0.5E5,10000) ;

if do_plot ==1
figure(3);
fv.Vertices = mesh.nd.pos;
fv.Faces = mesh.el.nds;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;

figure(4);
plot(unsorted_results.freq/1000 , 2 * pi * unsorted_results.freq ./ unsorted_results.waveno , 'r.');
xlabel('Frequency (kHz)')
ylabel('Vph')
axis([0, max_freq/1000, 0, 2*long_vel]);
%axis([0, 50E3, 0, 10E3]);
end %if do_plot ==1


save (['rpd_v_',num2str(length(variable_points_mm))],'reshaped_proc_data')


