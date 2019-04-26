function gl = fn_build_global_matrices(mesh, options)
%new vectorised version of global matrix builder
default_options.SAFE_element = 0;
default_options.return_C = 0;
default_options.sparse_matrices = 0;
options = fn_set_default_fields(options, default_options);

% prepare matrices and look-ups
% new method - gl.X always initially has all nodes in order with all DOF at
% eaach node to avoid lookup

%no of DOFs present
dofs = find(sum(mesh.nd.dof,1));
dof_per_node = length(dofs);
nds = ones(size(dofs))' * [1:size(mesh.nd.pos,1)];
gl.nd = nds(:);
dofs = repmat(dofs', 1, size(mesh.nd.pos,1));
gl.dof = dofs(:);
total_dof = length(gl.nd);

% build all element matrices
% there should be something else in here to check element types and only do
% els of same type together

el = fn_get_element_matrices(mesh.nd, mesh.el, mesh.matl, options);

disp('Global matrices ...');
t1 = clock;

%create the global matrix indices matrices
nds = mesh.el.nds';
nds_per_el = size(nds, 1);
nd1 = ones(dof_per_node,1) * [1:nds_per_el];
nd1 = nd1(:);
dof1 = [1:dof_per_node]' * ones(1, nds_per_el);
dof1 = dof1(:);
[nd2, nd1] = meshgrid(nd1, nd1);
nd1 = nd1(:);
nd2 = nd2(:);
[dof2, dof1] = meshgrid(dof1, dof1);
dof1 = dof1(:);
dof2 = dof2(:);
i1 = nds(nd1,:);
i2 = nds(nd2,:);
for ii = 1:size(i1,1)
    i1(ii,:) = i1(ii,:) * dof_per_node - dof_per_node + 1 + dof1(ii) - 1;
    i2(ii,:) = i2(ii,:) * dof_per_node - dof_per_node + 1 + dof2(ii) - 1;
end;

%build the matrices
gl.M = sparse(i1(:), i2(:), el.M(:), total_dof, total_dof);
gl.K0 = sparse(i1(:), i2(:), el.K0(:), total_dof, total_dof);
if options.SAFE_element
    gl.K1 = sparse(i1(:), i2(:), el.K1(:), total_dof, total_dof);
    gl.K2 = sparse(i1(:), i2(:), el.K2(:), total_dof, total_dof);
end;
if options.return_C
    gl.C = sparse(i1(:), i2(:), el.C(:), total_dof, total_dof);
end;

if ~options.sparse_matrices
    gl.M = full(gl.M);
    gl.K0 = full(gl.K0);
    if options.SAFE_element
        gl.K1 = full(gl.K1);
        gl.K2 = full(gl.K2);
    end;
    if options.return_C
        gl.C = full(gl.C);
    end;
end;

disp(sprintf('    ... built in %.2f secs', etime(clock, t1)));

return;