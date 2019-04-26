wavemaker_delay_factor = 0.0;
%this is used to advance (if +ve) the time domain data so that the
%temporal centre of the outgoing signal is at the time zero. 
%It this is already the case, set wavemaker_delay_factor to zero.
%Otherwise wavemaker_delay_factor is specfied as a multiple of the 
%specified input signal duration (i.e. input_cycles / input_freq).

%populated transducer positions row  = row, col = pos
trans_pos = [	[0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];
				   [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
					[0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
				   [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0];
					[0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0];
				   [0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 0]];
%say which are the transmitter and which are the receiver rows
transmitter_rows = [1,1,1,1,1,0,0,0,0,0];
receiver_rows = [0,0,0,0,0,1,1,1,1,1];

%Phasings of transducer positions (i.e. orientations of transducers)
trans_pos_phasings=[0,1,1,-1,1,1,-1,-1,1,-1,-1,0];

%Node positions in FEfile corresponding to transducer positions - DON'T CHANGE
trans_node_list=[63, 53, 306, 72, 107, 139, 251, 279, 241, 409, 151, 197];

%Axial position of rows is set here
trans_row_pos = [-0.1850, -0.1470, -0.1090, -0.0710, -0.0190, 0.0190, 0.0710, 0.1090, 0.1470, 0.1850];


