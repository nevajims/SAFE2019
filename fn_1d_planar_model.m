function [nd, el] = fn_1d_planar_model(layer_data, matl, max_freq, model_options);
default_options.els_per_wavelength = 50;
default_options.trace_lamb = 1;
default_options.trace_sh = 0;
model_options = fn_set_default_fields(model_options, default_options);
el_type = 1;%always for 1d planar model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%should start off by converting materials to stiffness matrices

%initialise mesh variables
el.type = [];
el.matl = [];
el.nds = [];
nd.pos = [0, 0, 0];

%loop through layers
for ii = 1:length(layer_data)
    %calc min bulk wave vel in layer material
    min_vel = 3000;
    %calc number of elements in layer
    min_wavelength = min_vel / max_freq;
    no_els = ceil(layer_data{ii}.thickness / min_wavelength * model_options.els_per_wavelength);
    %set up nodes
    first_node_of_layer = size(nd.pos, 1);
    pos = linspace(nd.pos(first_node_of_layer, 1), nd.pos(first_node_of_layer, 1) + layer_data{ii}.thickness, no_els + 1)';
    pos = pos(2:end);
    nd.pos = [nd.pos; [pos, zeros(length(pos), 2)]];
    last_node_of_layer = size(nd.pos, 1);
    %set up els
    el.type = [el.type; ones(no_els, 1) * el_type];
    el.matl = [el.matl; ones(no_els, 1) * layer_data{ii}.matl];
    el.nds = [el.nds; [[first_node_of_layer : last_node_of_layer - 1]', [first_node_of_layer + 1 : last_node_of_layer]']];
end;

nd.dof = zeros(size(nd.pos, 1), 3);
nd.dof(:, [1,3]) = model_options.trace_lamb;
nd.dof(:, 2) = model_options.trace_sh;
return;