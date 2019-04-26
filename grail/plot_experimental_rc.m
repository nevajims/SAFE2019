db_range=40;
input_modes=[3 5 7 8 10];
h=figure;
set(h,'Position',[400 300 540 400]);
surf(20*log10(exp_rc));
axis tight;
axis off;
view(2);
shading interp
caxis([-db_range 0]);
colorbar
h=text(3,5.2,'Thermit Weld Without Defect');
set(h,'HorizontalAlignment','center');
set(h,'VerticalAlignment','middle');
h=text([1:5],ones(1,5)*0.7,int2str(input_modes'));
set(h,'HorizontalAlignment','center');
set(h,'VerticalAlignment','middle');
set(h,'Color','blue')
h=text(ones(1,5)*0.7,[1:5],int2str(input_modes'));
set(h,'HorizontalAlignment','center');
set(h,'VerticalAlignment','middle');
set(h,'Color','red')
