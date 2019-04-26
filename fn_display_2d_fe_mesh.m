function fn_display_2d_fe_mesh(mesh, options)
%SUMMARY
%   Displays 2D FE mesh. By default elements are plotted as gray patches
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

default_options.mesh_color_min = [1, 1, 1];
default_options.mesh_color_max = [1, 1, 1] * 0.5;
default_options.draw_elements = 1;
default_options.element_edge_color = 'k';
default_options.mesh_edge_color = 'r';
default_options.draw_mesh_edges = 1;
default_options.node_sets_to_plot = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = fn_set_default_fields(options, default_options);

if options.draw_elements
    px = reshape(mesh.nd.pos(mesh.el.nds, 1), size(mesh.el.nds)) .';
    py = reshape(mesh.nd.pos(mesh.el.nds, 2), size(mesh.el.nds)) .';
    col = mesh.el.matl / max(mesh.el.matl);
    col = col(:) * (options.mesh_color_max - options.mesh_color_min) + ones(size(col(:))) * options.mesh_color_min;
%     col(find(mesh.el.matl == 2), :) = 0;
%     col(find(mesh.el.matl == 2), 3) = 1;
    col = reshape(col, 1, size(col, 1), size(col, 2));
    
    hold on;
    patch(px, py, col, 'EdgeColor', options.element_edge_color);
end;

if options.draw_mesh_edges
    %get sorted matrix of all element edges
    ed = fn_get_edges(mesh.el.nds);
    %find edges that only occur once (i.e. they are the free edges)
    free_ed = fn_find_free_edges(ed);
    %plot them
    hold on;
    plot(reshape(mesh.nd.pos(free_ed, 1), size(free_ed))', reshape(mesh.nd.pos(free_ed, 2), size(free_ed))', options.mesh_edge_color);
end;

if ~isempty(options.node_sets_to_plot)
    hold on;
    for ii = 1:length(options.node_sets_to_plot)
        plot(mesh.nd.pos(options.node_sets_to_plot(ii).nd, 1), mesh.nd.pos(options.node_sets_to_plot(ii).nd, 2), options.node_sets_to_plot(ii).col);
    end;
end;

axis equal;
axis off;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function free_ed = fn_find_free_edges(ed)
%add dummy edges at start and end so subsequent logic is general
ed = [[0, 0]; ed; [0, 0]];
ind = find((ed(2:end-1, 1) ~= ed(1:end-2, 1) | ed(2:end-1, 2) ~= ed(1:end-2, 2)) & (ed(2:end-1, 1) ~= ed(3:end, 1) | ed(2:end-1, 2) ~= ed(3:end, 2)));
free_ed = ed(ind + 1, :);
return;