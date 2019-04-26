wavemaker_delay_factor = 0.0;
%this is used to advance (if +ve) the time domain data so that the
%temporal centre of the outgoing signal is at the time zero. 
%It this is already the case, set wavemaker_delay_factor to zero.
%Otherwise wavemaker_delay_factor is specfied as a multiple of the 
%specified input signal duration (i.e. input_cycles / input_freq).

%populated transducer positions row  = row, col = pos
trans_pos = [	[0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];%look - row 1 has four
				   [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0]];

%these are the actual transducer numbers which are used in the second prototype
trans_num = [	[0, 0, 1, 0, 2, 0, 0, 3, 0, 4, 0, 0];
				[0, 0,30, 0,29, 0, 0,28, 0,27, 0, 0];
				[0, 5, 0, 6, 0, 7, 8, 0, 9, 0,10, 0];
				[0,26, 0,25, 0,24,23, 0,22, 0,21, 0];
				[0,11, 0,12, 0,13,20, 0,19, 0,18, 0]];

               
%say which are the transmitter and which are the receiver rows
transmitter_rows = [1,1,1,1,1];
receiver_rows = [1,1,1,1,1];

%Phasings of transducer positions (i.e. orientations of transducers)
trans_pos_phasings=[0,1,1,-1,1,1,-1,-1,1,-1,-1,0];

%Node positions in FEfile corresponding to transducer positions - DON'T CHANGE
trans_node_list=[63, 53, 306, 72, 107, 139, 251, 279, 241, 409, 151, 197]; %this is the nearest nodes in the 5mm tapered mesh
trans_node_list_coarse_mesh=[18, 15, 100, 26, 37, 43, 78, 88, 79, 119, 50, 57]; %this is the nearest nodes in the 10mm tapered mesh

%Axial position of rows is set here
trans_row_pos = [-83, -45, -7, 31, 83] * 1e-3;


