%create_mesh

%select the file
load ('AC-107eq_75.mat')
do_plot = 1 ; 

matl_name = 'steel';
% default disperse vaules--------------------------------------------
youngs_modulus       = 216.9e9;
poissons_ratio       = 0.2865;
density              = 7932;

% default disperse vaules--------------------------------------------
% solver parameters
indep_var            = 'waveno';
pts                  = 200;
%max_freq             = 5e4;
%max_freq            = 0.5e5;

max_freq = 0.8e6;
safe_opts.use_sparse = 1;
triangular_element_type = 2;

ep_mm    = data.equispaced_points_mm;
nes_mm   = data.path_distance;

nom_el_size = 0.5*nes_mm * 1E-3;
nd_ = [real(ep_mm)'*1E-3,imag(ep_mm)'*1E-3];

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

mesh.el.matl  = ones(size(mesh.el.nds, 1), 1)                           ;
mesh.el.type  = ones(size(mesh.el.nds, 1), 1) * triangular_element_type ;
mesh.nd.dof   = ones(size(mesh.nd.pos, 1), 3)                           ;


%SAFE solver

switch indep_var
    case 'waveno'
        var = linspace(0, 2 * pi * max_freq / shear_vel, pts);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
    case 'freq'
        var = linspace(0, max_freq, pts);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
end;

[data_wn] = create_fenel_format_data (unsorted_results);
save data_wn data_wn


[reshaped_proc_data,sorted_lookup,data_wn_matrix] =  proc_data_into_modes_safe(data_wn);
reshaped_proc_data.mesh = mesh ;

save reshaped_proc_data reshaped_proc_data


if do_plot ==1
figure;
fv.Vertices = mesh.nd.pos;
fv.Faces = mesh.el.nds;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;

end