function unsorted_results = fn_SAFE_modal_solver(mesh, var, indep_var, options)
if  ~isfield(options,'axial_stress')
options.axial_stress = 0;
disp('No axial strain set - set to be zero')
else
disp([ 'Axial strain (%) = ' , num2str(100*options.axial_stress/mesh.matl{1}.youngs_modulus) , ' %' ])
end %if  ~isfield(options,'axial_stress')

default_options.power_normalisation = 1 ;
default_options.sparse_matrices = 1     ;
%default_options.sparse_matrices = 0     ; % original values
%default_options.max_sparse_modes = 40   ;
default_options.max_sparse_modes  = 30  ; % original values


default_options.sigma = 'sm'            ;
default_options.return_mode_shapes = 1  ;

options = fn_set_default_fields(options, default_options);

ops1.SAFE_element = 1;
ops1.sparse_matrices = options.sparse_matrices;
ops1.return_C = 1;

%addpath('..\NDT FE');
gl = fn_build_global_matrices(mesh, ops1);
%rmpath('..\NDT FE');

if full(any(any(gl.C))) & strcmp(indep_var, 'waveno')
    warning('One or more materials have Rayleigh damping specified, but this cannot be solved with wavenumber as independent variable. Damping will be ignored.')
end;

disp('SAFE modal solver ...');
t1 = clock;

switch indep_var
    case 'waveno'
        waveno = var;
        current_index = 1;
        for ii = 1:length(waveno)
            if ii == 1
                %initialise outputs
                if options.sparse_matrices
                    sz = options.max_sparse_modes * length(waveno);
                else
                    sz = length(gl.nd) * length(waveno);
                end;
                unsorted_results.freq = zeros(1, sz);
                unsorted_results.waveno = zeros(1, sz);
                if options.return_mode_shapes
                    unsorted_results.mode_shapes = zeros(length(gl.nd), sz);
                end;
                unsorted_results.nd = gl.nd;
                unsorted_results.dof = gl.dof;
                unsorted_results.gl = gl;
                
            end;
            
            % -----------------------------------------------------------------------------------------------------------------
            % gl.K = gl.K2 * waveno(ii) ^ 2 + gl.K1 * waveno(ii) + gl.K0; %old code
            % new modified by jimE 2016 using loveday 2009 theory
            gl.K =  (waveno(ii) ^ 2)* ((options.axial_stress/mesh.matl{1}.density)*gl.M  + gl.K2) + gl.K1 * waveno(ii) + gl.K0;
            % -----------------------------------------------------------------------------------------------------------------
            
            if options.sparse_matrices
                ops.disp = 0;
                if options.return_mode_shapes
                    [eig_vecs, eig_vals] = eigs(gl.K, gl.M, options.max_sparse_modes, 0, ops);
                    eig_vals = diag(eig_vals) .';
                else
                    eig_vals = eigs(gl.K, gl.M, options.max_sparse_modes, 0, ops).';
                end;
            else
                if options.return_mode_shapes
                    [eig_vecs, eig_vals] = eig(gl.K, gl.M);
                    eig_vals = diag(eig_vals) .';
                else
                    eig_vals = eig(gl.K, gl.M) .';
                end;
            end;
            i1 = current_index;
            i2 = current_index + length(eig_vals) - 1;
            current_index = i2 + 1;
            unsorted_results.freq(i1:i2) = sqrt(eig_vals) / (2 * pi);
            unsorted_results.waveno(i1:i2) = waveno(ii);
            if options.return_mode_shapes
                unsorted_results.mode_shapes(:, i1:i2) = eig_vecs;
                if options.power_normalisation
                    unsorted_results.mode_shapes(:, i1:i2) = fn_power_normalisation(unsorted_results.mode_shapes(:, i1:i2), unsorted_results.waveno(i1:i2), unsorted_results.freq(i1:i2), gl);
                end;
            end;
            fn_show_progress(ii, length(waveno));
        end;
    case 'freq'
        freq = var;
        current_index = 1;
        for ii = 1:length(freq);
            if ii == 1
                %initialise outputs
                if options.sparse_matrices
                    sz = options.max_sparse_modes * length(freq);
                else
                    sz = 2 * length(gl.nd) * length(freq);
                end;
                unsorted_results.freq = zeros(1, sz);
                unsorted_results.waveno = zeros(1, sz);
                if options.return_mode_shapes
                    unsorted_results.mode_shapes = zeros(length(gl.nd), sz);
                end;
                unsorted_results.nd = gl.nd;
                unsorted_results.dof = gl.dof;
            end;
            %reshape global matrices
            sz = size(gl.K2,1);
            M = gl.M + i * 2 * pi * freq(ii) * gl.C;
            %solve Eigenvalue problem
            if options.sparse_matrices
                % -----------------------------------------------------------------------------------------------------------------
                % K_left = [gl.K2, sparse(sz,sz); sparse(sz,sz), (2 * pi * freq(ii)) ^ 2 * M - gl.K0];
                % K_right = [sparse(sz,sz), gl.K2; gl.K2, gl.K1]; 
                % new modified by jimE 2016 using loveday 2009 theory  and weaver paper(2004)
                stress_term = (options.axial_stress/mesh.matl{1}.density)*gl.M;
                K_left       =     [(stress_term + gl.K2) , sparse(sz,sz); sparse(sz,sz), (2 * pi * freq(ii)) ^ 2 * M - gl.K0];
                K_right      =     [sparse(sz,sz), (stress_term + gl.K2) ; (stress_term + gl.K2) , gl.K1];
                % -----------------------------------------------------------------------------------------------------------------
                if options.return_mode_shapes
                    [eig_vecs, eig_vals] = eigs_special(K_left, K_right, options.max_sparse_modes, options.sigma);
                    eig_vals = diag(eig_vals);
                    eig_vecs = eig_vecs(1: end / 2, :);
                else
                    eig_vals = eigs_special(K_left, K_right, options.max_sparse_modes, options.sigma);
                end;
            else
                K_left = [gl.K2, zeros(sz); zeros(sz), (2 * pi * freq(ii)) ^ 2 * M - gl.K0];
                K_right = [zeros(sz), gl.K2; gl.K2, gl.K1];
                if options.return_mode_shapes
                    [eig_vecs, eig_vals] = eig(K_left, K_right);
                    eig_vals = diag(eig_vals);
                    eig_vals = eig_vals(end / 2 + 1: end);
                    eig_vecs = eig_vecs(1: end / 2,end / 2 + 1: end);
                else
                    eig_vals = eig(K_left, K_right);
                    eig_vals = eig_vals(end / 2 + 1: end);
                end;
            end;
            i1 = current_index;
            i2 = current_index + length(eig_vals) - 1;
            current_index = i2 + 1;
            unsorted_results.freq(i1:i2) = freq(ii);
            unsorted_results.waveno(i1:i2) = eig_vals;
            if options.return_mode_shapes
                unsorted_results.mode_shapes(:, i1:i2) = eig_vecs;
                if options.power_normalisation
                    unsorted_results.mode_shapes(:, i1:i2) = fn_power_normalisation(unsorted_results.mode_shapes(:, i1:i2), unsorted_results.waveno(i1:i2), unsorted_results.freq(i1:i2), gl);
                end;
            end;
            fn_show_progress(ii, length(freq), 'SAFE modal solver');
        end;
        last_index = current_index - 1;
        unsorted_results.freq = unsorted_results.freq(1:last_index);
        unsorted_results.waveno = unsorted_results.waveno(1:last_index);
        if options.return_mode_shapes
            unsorted_results.mode_shapes = unsorted_results.mode_shapes(:, 1:last_index);
        end;
end;

disp(sprintf('    ... completed in %.2f secs', etime(clock, t1)));

return;

function pn_ms = fn_power_normalisation(ms, k, f, gl)
pn_ms = zeros(size(ms));
n3 = find(gl.dof == 3);
for ii = 1:size(ms, 2)
    omega = 2 * pi * f(ii);
    u = ms(:, ii);
    u_plus = u;
    u_minus = u;
    u_minus(n3) = -u(n3);
    %method 1 - direct from stiffness matrices (this needs proper
    %checking!)
%     P = omega * u' * (gl.K1 + 2 * k(ii) * gl.K2) * u / 4;
    P = omega * u_minus.' * (gl.K1 + 2 * k(ii) * gl.K2) * u_plus / 4;
    pn_ms(:, ii) = u / sqrt(P);
end;

return


function [V,D] = eigs_special(A, B, nev, sigma)
% keyboard
%this method to handle non-positive definite B taken from
%http://www.mathworks.com/matlabcentral/newsreader/view_thread/242225
ops.disp = 0;
ops.isreal = 0;
ops.issym = 0;
if isscalar(sigma)
    % sigma = target.
    [L,U,P,Q,R] = lu(A - sigma*B);
    applyAmsigB = @(x) Q*(U\(L\(P*(R\x))));
    fun = @(x) applyAmsigB(B*x);
else
    if strcmp('sm', sigma)
        [L,U,P,Q,R] = lu(A);
        applyAmsigB = @(x) Q*(U\(L\(P*(R\x))));
        fun = @(x) applyAmsigB(B*x);
    else
        %for all other sigma strings
        [L,U,P,Q,R] = lu(B);
        applyBinv = @(x) Q*(U\(L\(P*(R\x))));
        fun = @(x) applyBinv(A*x);
    end;
end;
if nargout == 2
    [V,D] = eigs(fun, size(A,1), nev, sigma, ops);
else
    V = eigs(fun, size(A,1), nev, sigma, ops);
    D = [];
end;
return;