wavemaker_delay_factor = 0.0;
%this is used to advance (if +ve) the time domain data so that the
%temporal centre of the outgoing signal is at the time zero. 
%It this is already the case, set wavemaker_delay_factor to zero.
%Otherwise wavemaker_delay_factor is specfied as a multiple of the 
%specified input signal duration (i.e. input_cycles / input_freq).

%populated transducer positions row  = row, col = pos
trans_pos = [      [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];%look - row 1 has six
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
                   [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];
				   [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];
				   [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0]];

%these are the actual G3 channel numbers used
trans_num = [	[0, 17, 0, 18, 0, 2, 1, 0, 10, 0,  9, 0];
				[0, 29, 0, 30, 0, 4, 3, 0, 26, 0, 25, 0];
                [0, 19, 0, 20, 0, 6, 5, 0, 12, 0, 11, 0];
				[0, 0, 21, 0, 22, 0, 0, 14, 0, 13, 0, 0];
				[0, 0, 31, 0, 32, 0, 0, 28, 0, 27, 0, 0];
                [0, 0, 23, 0, 24, 0, 0, 16, 0, 15, 0, 0]];

               
%say which are the transmitter and which are the receiver rows
transmitter_rows = [1,1,1,1,1,1];
receiver_rows = [1,1,1,1,1,1];

%Phasings of transducer positions (i.e. orientations of transducers)
%trans_pos_phasings=[0,1,1,-1,1,1,-1,-1,1,-1,-1,0]; %These are the phasings for the 5 row instruments
%trans_pos_phasings=[0,1,1,1,-1,-1,1,1,-1,-1,-1,0]; %These are the phasings for the 6 row CEN60 instrument
trans_pos_phasings=[0,1,-1,-1,1,1,-1,-1,1,1,-1,0]; %These are the phasings for the 6 row BS80 instrument


%Node positions in FEfile corresponding to transducer positions - DON'T CHANGE
%trans_node_list=[63, 53, 306, 72, 107, 139, 251, 279, 241, 409, 151, 197]; %this is the nearest nodes in the 5mm tapered mesh
%trans_node_list=[11, 19,  24, 30,  34,  38,  42,  46,  52,  56,  61,  69]; %this is the nearest nodes in the CEN60_course mesh
trans_node_list=[153, 319, 329, 193, 216, 238, 118, 96, 73, 273, 258, 33]; %this is the nearest nodes in the BS80 5mm tapered mesh


%Axial position of rows is set here
%trans_row_pos = [-95, -57, -19, 19, 57 95] * 1e-3; %These are the row positions for the 6 row CEN60 instrument
trans_row_pos = [81, 48, 15, -15, -50, -99] * 1e-3; %These are the row positions for the 6 row BS80 instrument


