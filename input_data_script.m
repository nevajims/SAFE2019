
% option_1 Material_type
% 1 = aluminium
% 2 = steel
% option_2 Profile_type 
% 1 is circular rod 
% 2 is a rail
% option_3 solver_par 

% Material_type ***********************************************
input_data.matl_name             = 'aluminium' ; 
input_data.youngs_modulus        = 70e9        ;
input_data.poissons_ratio        = 1/3         ;
input_data.density               = 2700        ;
% input_data.matl_name            = 'steel';
% input_data.youngs_modulus       = 216.9e9      ; 
% input_data.poissons_ratio       = 0.2865       ;
% input_data.density              = 7932         ;

% Profile_type ***********************************************
% 1 is circular rod 
% 2 is a rail
input_data.Profile_type  = 'circular rod or pipe' ;
%input_data.Profile_type  = 'polygon' ;
input_data.Profile_type  = 'arb shape'    ;   %  this generally a rail

% option_3 solver_par ***********************************************
% solver parameters
indep_var                = 'waveno'     ;
pts                      = 300          ;
max_freq                 = 5e4          ;
safe_opts.use_sparse     = 1            ;
triangular_element_type  = 2;


