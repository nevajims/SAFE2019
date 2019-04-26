fid=fopen('c:\mark\fe773d\5mm_tap_3d_blank.DAT','r')
nlines=1;
temp=fgetl(fid);
while temp>=0
    if findstr('insert',temp);
       insert_line=nlines;
    end;
    temp=fgetl(fid);
    nlines=nlines+1;
end
nlines=nlines-1;
fseek(fid,0,'bof');
file_lines=cell(nlines,1);
for count=1:nlines
    file_lines(count)={fgetl(fid)};
end
fclose(fid);
fid=fopen('c:\mark\fe773d\test.DAT','w');
fseek(fid,0,'bof');
for count=1:insert_line-1
    fprintf(fid,'%s\n',char(file_lines(count)));
end
fclose(fid);
