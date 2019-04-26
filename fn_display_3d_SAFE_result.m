function fn_display_3d_SAFE_result(mesh, result, options)
%SUMMARY
%   Displays 3D SAFE result. By default elements are plotted as gray patches
%   (with the gray level proportional to their material index) and the
%   edges of the mesh are drawn in black (useful for seeing zero volume
%   defects such as cracks).
%INPUTS
%   mesh - structured variable describing mesh with fields as follows
%   mesh.nd.x/y(/z) - vectors of node x/y(/z)-coordinates
%   mesh.el.nds - matrix of element nodes (each row is an element)
%   mesh.el.type - vector of element type indices (indices refer to element
%   types defined in mesh.el_type)
%   mesh.el.matl - vector of element material indices (indices refer to
%   materials defined in mesh.matl)
%   mesh.monitor_nodes - vector of nodes if displacements are only required at
%   limited number of nodes. If empty, default is to return displacements
%   at all nodes
%   mesh.matl - vector of structured variables describing different
%   materials in model; fields are density, youngs_modulus, poissons_ratio,
%   name and damping. ** In future, complete stiffness matrices will be
%   added as an alternative way of specifying stiffnes**
%   mesh.el_type - cell array of element types (e.g. 'CPE4')
%
%   options - structured variable allowing optional plotting properties to
%   be set. See below for defaults. In particular:
%   default_options.node_sets_to_plot - allows specific nodes to be plotted
%   in a particular color. It is a vector of structured variables with
%   fields nd and col. nd is a vector of node indices and col is the color
%   (e.g. 'r') in which nodes in that set will be plotted.
%OUTPUTS
%   none
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global plot_data
default_options.mesh_color_min = [1, 1, 1];
default_options.mesh_color_max = [1, 1, 1] * 0.5;
default_options.section_color_min = [1, 1, 1];
default_options.section_color_max = [1, 1, 1] * 0.5;
default_options.draw_elements = 1;
default_options.element_edge_color = 'k';
default_options.mesh_edge_color = 'r';
default_options.draw_mesh_edges = 1;
default_options.node_sets_to_plot = [];
default_options.axial_length = 0;%will make axial length equal to largest in plane dimension
default_options.el_size_z = 0;%will make axial element size approx same as existing elements
default_options.max_els_z = 20; %caps number of elements
default_options.plot_axis_to_coord_axis_map = [1, 3, 2];
default_options.interactive = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = fn_set_default_fields(options, default_options);

%reshape results into a 3 column displacement matrix for nodes
disp_sect = zeros(size(mesh.nd.pos, 1), 3);
for ii = 1:length(result.disp)
    disp_sect(result.nd(ii), result.dof(ii)) = result.disp(ii);
end;

%create z-coordinates of mesh cross section if not already present
if size(mesh.nd.pos,2) < 3
    mesh.nd.pos = [mesh.nd.pos, zeros(size(mesh.nd.pos,1), 3 - size(mesh.nd.pos, 2))];
end;

%get sorted matrix of all element edges
ed = fn_get_edges(mesh.el.nds);
%find edges that only occur once (i.e. they are the free edges)
free_ed = fn_find_free_edges(ed);

%add the new elements representing the axial dimension
if ~options.el_size_z
    el_size_z = sqrt(mean(polyarea(reshape(mesh.nd.pos(mesh.el.nds, 1), size(mesh.el.nds))', reshape(mesh.nd.pos(mesh.el.nds, 2), size(mesh.el.nds))')));
else
    el_size_z = options.el_size_z;
end;

%set axial length of model if not specified
if ~options.axial_length
    axial_length = sqrt((max(mesh.nd.pos(:,1)) - min(mesh.nd.pos(:,1))) .^ 2 + (max(mesh.nd.pos(:,2)) - min(mesh.nd.pos(:,2))) .^ 2);
else
    axial_length = options.axial_length;
end;

%number of elements axially and axial positions of node planes
n_els_z = ceil(axial_length / el_size_z);
n_els_z = min([options.max_els_z, n_els_z]);
z_planes = linspace(0, axial_length, n_els_z + 1);

%current max node number in cross section
max_nd = size(mesh.nd.pos, 1);

%find the nodes describing the perimeter of the cross section
[un, ii, jj] = unique(free_ed);

%copy displacements of perimeter nodes
disp_perim = disp_sect(un, :);
disp_all = [disp_sect; zeros(size(disp_perim, 1) * n_els_z, 3)];

%get list of node numbers for first plane in z (i.e. to define first layer
%of axial elements)
nds_per_z_plane = length(un);
els_per_z_plane = size(free_ed, 1);
new_first_nds = [1:nds_per_z_plane] + max_nd;
first_layer_els = [free_ed, fliplr(reshape(new_first_nds(jj), size(free_ed)))];
second_layer_els = [reshape(new_first_nds(jj), size(free_ed)), fliplr(reshape(new_first_nds(jj), size(free_ed))) + nds_per_z_plane];
%append new node positions same x,y coords, just increasing z
mesh.nd.pos = [mesh.nd.pos; [repmat(mesh.nd.pos(un, 1:2), n_els_z, 1), reshape(ones(length(un), 1) * z_planes(2: end), [], 1)]];
for ii = 2:length(z_planes)
    disp_all(size(disp_sect, 1) + (ii - 2) * size(disp_perim, 1) + 1: size(disp_sect, 1) + (ii - 1) * size(disp_perim, 1), :) = disp_perim * exp(i * result.waveno * z_planes(ii));
end;
if size(mesh.el.nds, 2) < 4
    mesh.el.nds = [mesh.el.nds, NaN(size(mesh.el.nds, 1), 4 - size(mesh.el.nds, 2))];
end;
existing_els = size(mesh.el.nds, 1);
mesh.el.nds = [mesh.el.nds; zeros(els_per_z_plane * n_els_z, 4)];
ii = 1;
mesh.el.nds(existing_els + 1: existing_els + els_per_z_plane, :) = first_layer_els;
for ii = 2:n_els_z
    mesh.el.nds(existing_els + (ii - 1) * els_per_z_plane + 1: existing_els + ii * els_per_z_plane, :) = second_layer_els + (ii - 2) * nds_per_z_plane;
end;
mesh.el.matl = [mesh.el.matl; ones(els_per_z_plane * n_els_z, 1)];


disp_all = disp_all / max(max(abs(disp_all))) * el_size_z * 2;

plot_data.nd_pos = mesh.nd.pos;
plot_data.disp = disp_all;
plot_data.el_nds = mesh.el.nds; 
plot_data.el_matl = mesh.el.matl; 
plot_data.free_ed = free_ed;
plot_data.scale_factor = 1;
plot_data.options = options;

if options.interactive
    fn_draw_mesh_int;
else
    fn_draw_mesh(plot_data.nd_pos + real(plot_data.disp), plot_data.el_nds, plot_data.el_matl, plot_data.free_ed, plot_data.options);
end;

return;


function fn_draw_mesh(nd_pos, el_nds, el_matl, ed_nds, options)
[az, el] = view;
ax = axis;
cla;
if options.draw_elements
    col = el_matl / max(el_matl);
    col = col * (options.mesh_color_max - options.mesh_color_min) + ones(size(col)) * options.mesh_color_min;
    hold on;
    fv.Faces = el_nds;
    fv.Vertices = nd_pos(:, options.plot_axis_to_coord_axis_map);
    fv.FaceVertexCData = col;
    patch(fv, 'EdgeColor', options.element_edge_color, 'FaceColor', 'flat');
end;

if options.draw_mesh_edges
    hold on;
    x = reshape(nd_pos(ed_nds, options.plot_axis_to_coord_axis_map(1)), size(ed_nds))';
    y = reshape(nd_pos(ed_nds, options.plot_axis_to_coord_axis_map(2)), size(ed_nds))';
    z = reshape(nd_pos(ed_nds, options.plot_axis_to_coord_axis_map(3)), size(ed_nds))';
    plot3(x, y, z, options.mesh_edge_color);
end;

if ~isempty(options.node_sets_to_plot)
    hold on;
    for ii = 1:length(options.node_sets_to_plot)
        plot3(mesh.nd.pos(options.node_sets_to_plot(ii).nd, 1), mesh.nd.pos(options.node_sets_to_plot(ii).nd, 2), mesh.nd.pos(options.node_sets_to_plot(ii).nd, 3), options.node_sets_to_plot(ii).col);
    end   ;
end       ;

axis equal;
axis off;
view(az, el);
% axis(ax);
pause(0.2);
return;

function ed = fn_get_edges(nds)
ed = zeros(prod(size(nds)), 2);
kk = 1;
for ii = 1:size(nds, 1)
    tmp = nds(ii, :);
    tmp = tmp(find(tmp));
    tmp = [tmp, tmp(1)];
    tmp_ed = [tmp(1:end-1); tmp(2:end)]';
    ed(kk: kk + size(tmp_ed,1) - 1, :) = tmp_ed;
    kk = kk + size(tmp_ed,1);
end;
ed = ed(1:kk-1 , :);
ed = sortrows(sort(ed, 2));
return;

function free_ed = fn_find_free_edges(ed)
%add dummy edges at start and end so subsequent logic is general
ed = [[0, 0]; ed; [0, 0]];
ind = find((ed(2:end-1, 1) ~= ed(1:end-2, 1) | ed(2:end-1, 2) ~= ed(1:end-2, 2)) & (ed(2:end-1, 1) ~= ed(3:end, 1) | ed(2:end-1, 2) ~= ed(3:end, 2)));
free_ed = ed(ind + 1, :);
return;

function fn_draw_mesh_int;
global plot_data
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Position',[360,500,450,285]);

%  Construct the components.
hanimate = uicontrol('Style','pushbutton','String','Animate',...
    'Position',[315,220,70,25],...
    'Callback',{@animatebutton_Callback});
hsfinc = uicontrol('Style','pushbutton','String','Bigger',...
    'Position',[315,180,70,25],...
    'Callback',{@incbutton_Callback});
hsfdec = uicontrol('Style','pushbutton',...
    'String','Smaller',...
    'Position',[315,135,70,25],...
    'Callback',{@decbutton_Callback});
% htext = uicontrol('Style','text','String','Select Data',...
%     'Position',[325,90,60,15]);
% hpopup = uicontrol('Style','popupmenu',...
%     'String',{'Peaks','Membrane','Sinc'},...
%     'Position',[300,50,100,25],...
%     'Callback',{@popup_menu_Callback});
ha = axes('Units','Pixels','Position',[50,60,200,185]);
set([f,hanimate,ha, hsfdec, hsfinc],...
    'Units','normalized');

fn_draw_mesh(plot_data.nd_pos + real(plot_data.disp), plot_data.el_nds, plot_data.el_matl, plot_data.free_ed, plot_data.options);
view(3);
% align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None');

% Initialize the GUI.
% Change units to normalized so components resize
% automatically.
%Create a plot in the axes.

set(f,'Name','SAFE display control')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');

return;

function animatebutton_Callback(source, eventdata)
global plot_data
a = linspace(0, 2*pi, 13);
a = a(2:end);
for ii = 1:5
    for jj = 1:length(a)
        fn_draw_mesh(plot_data.nd_pos +real(plot_data.disp * exp(-i*a(jj))) * plot_data.scale_factor, plot_data.el_nds, plot_data.el_matl, plot_data.free_ed, plot_data.options);
    end;
end;
return;

function decbutton_Callback(source, eventdata)
global plot_data
plot_data.scale_factor = plot_data.scale_factor / 2;
fn_draw_mesh(plot_data.nd_pos +real(plot_data.disp) * plot_data.scale_factor, plot_data.el_nds, plot_data.el_matl, plot_data.free_ed, plot_data.options);
return;

function incbutton_Callback(source, eventdata)
global plot_data
plot_data.scale_factor = plot_data.scale_factor * 2;
fn_draw_mesh(plot_data.nd_pos +real(plot_data.disp) * plot_data.scale_factor, plot_data.el_nds, plot_data.el_matl, plot_data.free_ed, plot_data.options);
return;