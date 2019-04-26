function [nodes_,edge_] = create_arb_pipe(inner_dia , thickness , no_points , do_plot)
%  make so the total number of nodes is 
% ***DONE  make this so that if inner dia is zero then no inner nodes are created 
% ***DONE  do the outer first, then the inner and then do the connectivity: edge_
% ***DONE  make it so the number of inner nodes is proportional to the circumference ratio 

if inner_dia ~=0  
internal_rad = inner_dia/2           ;
external_rad = inner_dia/2+thickness ;
circumfence_ratio = external_rad/internal_rad;
divisor_ = circumfence_ratio + 1;
number_external_nodes =  floor(circumfence_ratio*no_points/divisor_)   +1  ;
number_internal_nodes =  ceil(no_points/divisor_) +1;

angle_external = linspace(0, 2 * pi, number_external_nodes);
angle_external  = angle_external(1:end - 1)';
angle_internal = linspace(0, 2 * pi, number_internal_nodes);
angle_internal  = angle_internal(1:end - 1)';
outer_nodes  = [cos(angle_external), sin(angle_external)] * external_rad;    
inner_nodes  = [cos(angle_internal), sin(angle_internal)] * internal_rad;    
nodes_ =  [ inner_nodes ; outer_nodes ];

n_inner_nodes = size(inner_nodes,1);
n_outer_nodes = size(outer_nodes,1);

c_inner_nodes = [(1:n_inner_nodes-1)', (2:n_inner_nodes)'; n_inner_nodes, 1];
c_outer_nodes = [(1:n_outer_nodes-1)', (2:n_outer_nodes)'; n_outer_nodes, 1];

edge_ = [c_inner_nodes ; c_outer_nodes + n_inner_nodes ] ;

else    
angle_ = linspace(0, 2 * pi, no_points+1);    
angle_  = angle_(1:end - 1)';
nodes_  = [cos(angle_), sin(angle_)] * thickness;     
n_nodes = size(nodes_,1);
c_nodes = [(1:n_nodes-1)', (2:n_nodes)'; n_nodes, 1] ;
edge_ = [c_nodes] ;
end %if inner_dia ~=0  


if do_plot ==1
plot(nodes_(:,1),nodes_(:,2),'.')
axis equal
end % if do_plot ==1
%size(nodes_)
end  % function [nodes_,edge_] = create_arb_pipe(inner_dia , thickness , no_points , do_plot)


