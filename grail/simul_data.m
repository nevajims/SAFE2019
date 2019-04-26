%specify whether to create new file from data here, or just load an existing file
new_file=1;
%specify filenames
fname='n:\grail\matlab\simul-files\excitation-config';
model_fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';
actual_fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';

%mode_colors='cmyrgbkcmyrgbkcmyrgbkcmyrgbkcmyrgbk';
mode_colors='yycymyrgbkcmyyyyyyyyyyyyyyyyyyyyyyy';
%load file, display and return if desired
if ~new_file
   load(fname);
   a=who;
   for count=1:length(a);
      eval(char(a(count)));
   end;
   return;
end;

%INPUT SIGNALS
cent_freq=15e3;
cycles=10;
pts_per_cycle=10;
db_down=40;

%TRANSDUCER POSITIONS

%transducer nodes around cross section
trans_node_list=[63 53 306 72 107 139 251 279 241 409 151 197];%NB these nodes must be in perimeter node list


	%ax_pos refers to axial pos given by this vector
	trans_ax_pos=[0, 0.1, 0.2, 0.3, 0.4, 0.5];

	xs_pos=[2,3,4,5,6,7,8,9,10,11];
	xs_dir=[3,3,3,2,2,2,2,3,3,3];%1=normal, 2=in-plane torsional, 3=axial
   ax_pos=[1];
   %total number if transducers = length(xs_pos)*length(ax_pos)
   
%weighting
	%general
   extract_mode_indices=[3,5,7,8,10];%,5,7,8,10]; %these are the modes that will be extracted and displayed
  modes_of_interest=[3,5,6,7,8,9,10,11,12]; %set empty to include all modes in finel file
  modes_of_interest=[3,5,7,8,10]; %set empty to include all modes in finel file
%   modes_of_interest=[];
		%around the rail cross section
	   xs_weight_type=1;%1=manual, 2=addition, 3=subtraction
      %manual weights - should have cols=length xs-pos, and rows=length(extract_mode_indices)
      xs_manual_weights=[0,1,0,0,0,0,0,0,-1,0;
						  	    0,0,0,0,1,1,0,0,0,0;
						  	    0,0,0,1,0,0,-1,0,0,0;
						  	    1,0,1,0,0,0,0,1,0,1;
						  	    1,0,-1,0,0,0,0,-1,0,1];
         %addition
         xs_add_cent_freq_only=0;
         %subtraction
         xs_sub_cent_freq_only=0;
         xs_sub_mode_indices=[5;3]; %each row gives the modes only will be included in weighting calculation for that extracted mode
		%along the rail
      ax_weight_type=2;%1=manual, 2=addition, 3=subtraction
      	%manual weights - each row is weight per extracted mode
         ax_manual_weights=[1,i;
					            -1,1];
         %addition
         ax_add_cent_freq_only=1;
         %subtraction
         ax_sub_cent_freq_only=0;
         ax_sub_mode_indices=[-8;-10];%modes to suppress - each row is modes to suppress for each exracted mode
         
%save the data         
save(fname);
return;