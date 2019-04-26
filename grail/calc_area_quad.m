function area=calc_area_quad(x1,y1,x2,y2,x3,y3,x4,y4);
%Note: nodes are number either clockwise or
%anticlockwise around perimeter (not like Finel)
area=calc_area_triangle(x1,y1,x2,y2,x3,y3)+calc_area_triangle(x3,y3,x4,y4,x1,y1);