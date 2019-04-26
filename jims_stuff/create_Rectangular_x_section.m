function [ nodes_, edge_ ] = create_Rectangular_x_section(w1,w2,thickness,pts_per_mm)

% w1 > w2
%if thickness >= 2*w2 then assume solid
% dimension in mm
% make origin in the centre
% minimum value  for any side is 2-  round to an even number
pts_per_w1  =   ceil(w1 * pts_per_mm/2) *2;
pts_per_w2   = ceil(w2 * pts_per_mm/2) *2;
disp(['pts_per_w1= ',num2str(pts_per_w1),', pts_per_w2= ',num2str(pts_per_w2),'.'])

if w1 >= w2

if thickness >= w2/2
disp    ('solid rectangle case')
% side 1 
x_1      =  linspace(-w1/2,w1/2 ,pts_per_w1)'  ;    
y_1      =  w2/2*ones(size(x_1))                ; 
side_1  = [x_1,y_1]                             ;

y_o     =  linspace(w2/2,-w2/2 ,pts_per_w2)'     ;        
y_2      =  y_o(2:length(y_o)-1)                 ;
x_2      =  w1/2*ones(size(y_2))                 ; 
side_2  = [x_2,y_2]                              ;

side_3 = [flipud(x_1), -y_1 ]                    ;
side_4 = [-x_2 , flipud(y_2) ]                   ;
out_edge = [side_1;side_2;side_3;side_4]         ;

nodes_ = out_edge;
n_out_edge = size(out_edge,1);
c_out_edge = [(1:n_out_edge-1)', (2:n_out_edge)'; n_out_edge, 1] ;
edge_ = [c_out_edge] ;

else
disp    ('hollow rectangle case')
x_1      =  linspace(-w1/2,w1/2 ,pts_per_w1)'     ;    
y_1      =  w2/2*ones(size(x_1))                  ; 
x_i1      =  linspace(-w1/2+thickness ,w1/2-thickness ,pts_per_w1)'  ;    
y_i1      =  (w2/2-thickness)*ones(size(x_i1))    ; 

side_1    = [x_1,y_1]                             ;
side_1_i  = [x_i1,y_i1]                           ;

y_o     =  linspace(w2/2,-w2/2 ,pts_per_w2)'      ;        
y_2      =  y_o(2:length(y_o)-1)                  ;
x_2      =  w1/2*ones(size(y_2))                  ;  

y_o_i    =  linspace(w2/2-thickness,-w2/2+thickness ,pts_per_w2)' ;        
y_i2      =  y_o_i(2:length(y_o_i)-1)             ;
x_i2      =  (w1/2-thickness)*ones(size(y_i2))    ; 

side_2  = [x_2,y_2]                               ;
side_2_i  = [x_i2,y_i2]                           ;


side_3   = [flipud(x_1), -y_1 ]                   ;
side_3_i = [flipud(x_i1), -y_i1 ]                 ;
side_4   = [-x_2   , flipud(y_2)]                 ;
side_4_i = [-x_i2 , flipud(y_i2)]                 ;

out_edge = [side_1;side_2;side_3;side_4]          ;
in_edge = [side_1_i;side_2_i;side_3_i;side_4_i]   ;    
nodes_ = [out_edge;in_edge]                       ;
n_out_edge = size(out_edge,1);
n_in_edge = size(in_edge,1);
c_out_edge = [(1:n_out_edge-1)', (2:n_out_edge)'; n_out_edge, 1] ;
c_in_edge = [(1:n_in_edge-1)', (2:n_in_edge)'; n_in_edge, 1] ;
edge_ = [c_out_edge ; c_in_edge + n_out_edge ] ;
end %if thickness >= 2*w2    

else   
disp('error make w1 > w2')
        
end %if w1 > w2

end