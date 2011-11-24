function [] = htktocsvmanyfiles(filenamesFiles, outputFile)
% FilenameFiles is a list of the names of files containing 
% the filenames to be parsed
% Based on function written by Mark Hasegawa-Johnson
% July 3, 2002
% Based on function mfcc_read written by Alexis Bernard
%

more off;
dlmwrite(outputFile, []);
filenamesFiles
for filenamesFileInd=1:size(filenamesFiles,1)
  ['reading files of class', filenamesFileInd-1]
  filename = filenamesFiles{filenamesFileInd}
  size(filename, 1)
  size(filename, 2)
  filesFid = fopen(filename,'r');

  'passed here'
  if filesFid<0,
    error(sprintf('Unable to read from file %s',filenamesFiles(filenamesFileInd,:)));
  end
  files = textscan(filesFid, '%s');
  'passed here too'
  for fileInd=1:size(files{1,1},1)
    'here also'
    file = files{1,1}{fileInd,1};
    'me too'
    %['reading file', file]
    size(file,1) 
    size(file,2)
    file
    'righto'
    [DATA, HTKCode] = htkread(file);
    'done'

    AVGDATA = repmat(0, (int32(floor(size(DATA, 1)/160))), (size(DATA, 2)));
    'here'
    for rowNum = 1:(size(DATA, 1)- mod(size(DATA, 1), 160))
      avgRowNum = int32(floor((rowNum-1)/160))+1;
      %rowNum
      for col=1:size(DATA,2) 
        %col
        AVGDATA(avgRowNum,col) = AVGDATA(avgRowNum,col) + DATA(rowNum,col);
      end
    end
    'there'
    AVGDATA = AVGDATA ./ 160;
    'uhuh'
    classVec = repmat(filenamesFileInd-1,[size(AVGDATA, 1) 1]);
    'yep'
    dlmwrite(outputFile, [AVGDATA classVec], '-append');
    'ok'
  end
  fclose(filesFid);
  []
end