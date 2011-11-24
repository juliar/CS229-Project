function [] = htktocsvmanyfiles( filenamesFiles )
% FilenameFiles is a list of the names of files containing 
% the filenames to be parsed
% Based on function written by Mark Hasegawa-Johnson
% July 3, 2002
% Based on function mfcc_read written by Alexis Bernard
%

more off;
for filenamesFileInd=1:size(filenamesFiles,1)
  ['reading files of class', filenamesFileInd-1]
  filesFid = fopen(filenamesFiles(filenamesFileInd,:),'r','b');
  if filesFid<0,
    error(sprintf('Unable to read from file %s',filenamesFiles(filenamesFileInd,:)));
  end
  files = fscanf(filesFid, '%[^\n]');
  for fileInd=1:size(files,1)
    file = files(fileInd,:);
    ['reading file', file]
    size(file,1) 
    size(file,2)
    [DATA, HTKCode] = htkread(file(1,1:(size(file,2)-1)));
    'done'

    AVGDATA = repmat(0, (int32(floor(size(DATA, 1)/160))), (size(DATA, 2)));
    'here'
    for rowNum = 1:(size(DATA, 1)- mod(size(DATA, 1), 160))
      avgRowNum = int32(floor((rowNum-1)/160))+1;
      rowNum
      for col=1:size(DATA,2) 
        col
        AVGDATA(avgRowNum,col) = AVGDATA(avgRowNum,col) + DATA(rowNum,col);
      end
    end
    'there'
    AVGDATA = AVGDATA ./ 160;
    'uhuh'
    classVec = repmat(filenamesFileInd-1,[size(AVGDATA, 1) 1]);
    'yep'
    dlmwrite('features_test.csv', [AVGDATA classVec], '-append');
    'ok'
  end
  fclose(filesFid);
  []
end