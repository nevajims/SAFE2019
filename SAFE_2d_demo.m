clear; close all;

addpath('.\Mesh2d v24');

%define material(s)
matl_name = 'aluminium';
youngs_modulus = 70e9;
poissons_ratio = 1/3;
density = 2700;

%solver parameters
indep_var = 'waveno';
pts = 40;
max_freq = 2e6;
safe_opts.use_sparse = 1;

%mesh - see mesh2d or meshfaces functions for how meshing works
rad = 0.5e-3;
nom_el_size = rad/8;

triangular_element_type = 2;

a = linspace(0, 2 * pi, ceil(2 * pi * rad / nom_el_size));
a = a(1:end - 1)';
nd = [cos(a), sin(a)] * rad;

%--------------------------------------------------------------------------

mesh.matl{1}.name = matl_name;
mesh.matl{1}.stiffness_matrix = fn_iso_stiffness_matrix(youngs_modulus, poissons_ratio);
mesh.matl{1}.density = density;
[long_vel, shear_vel] = fn_velocities_from_stiffness_and_density(youngs_modulus, poissons_ratio, density);

hdata.hmax = nom_el_size;
ops.output = false;

[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nd, [], hdata, ops);
mesh.el.matl = ones(size(mesh.el.nds, 1), 1);
mesh.el.type = ones(size(mesh.el.nds, 1), 1) * triangular_element_type;
mesh.nd.dof = ones(size(mesh.nd.pos, 1), 3);

%display mesh
figure;
fv.Vertices = mesh.nd.pos;
fv.Faces = mesh.el.nds;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;

%SAFE solver
switch indep_var
    case 'waveno'
        var = linspace(0, 2 * pi * max_freq / shear_vel, pts);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
    case 'freq'
        var = linspace(0, max_freq, pts);
        unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, safe_opts);
end;

%display results
figure;
plot(unsorted_results.freq, 2 * pi * unsorted_results.freq ./ unsorted_results.waveno, 'r.');
axis([0, max_freq, 0, 2*long_vel]);