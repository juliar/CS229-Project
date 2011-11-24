function [] = htktocsvmanyfiles(filenamesFiles, outputTrainFile, outputTestFile)
% FilenameFiles is a list of the names of files containing 
% the filenames to be parsed
% Based on function written by Mark Hasegawa-Johnson
% July 3, 2002
% Based on function mfcc_read written by Alexis Bernard
%

more off;
filenamesFiles
for filenamesFileInd=1:size(filenamesFiles,1)
  ['reading files of class', filenamesFileInd-1]
  filename = filenamesFiles{filenamesFileInd}
  size(filename, 1)
  size(filename, 2)
  filesFid = fopen(filename,'r');

  
  if filesFid<0,
    error(sprintf('Unable to read from file %s',filenamesFiles(filenamesFileInd,:)));
  end
  files = textscan(filesFid, '%s');
  
  %for fileInd = 1
  for fileInd=1:size(files{1,1},1)
    
    file = files{1,1}{fileInd,1};
    
    %['reading file', file]
    size(file,1) 
    size(file,2)
    file
    
    [DATA, HTKCode] = htkread(file);

    AVGDATA = repmat(0, (int32(floor(size(DATA, 1)/160))), (size(DATA, 2)));
    
    for rowNum = 1:(size(DATA, 1)- mod(size(DATA, 1), 160))
      avgRowNum = int32(floor((rowNum-1)/160))+1;
      %rowNum
      for col=1:size(DATA,2) 
        %col
        AVGDATA(avgRowNum,col) = AVGDATA(avgRowNum,col) + DATA(rowNum,col);
      end
    end
    
    AVGDATA = AVGDATA ./ 160
    
    classVec = repmat(filenamesFileInd-1,[size(AVGDATA, 1) 1]);
    
    if filenamesFileInd == 1 && fileInd == 1
      dlmwrite(outputTrainFile, 1:(size(AVGDATA,2))+1);
      dlmwrite(outputTestFile, 1:(size(AVGDATA,2))+1);

    end
    if fileInd < size(files{1,1},1)*0.7
      dlmwrite(outputTrainFile, [AVGDATA classVec], '-append');
    else
      dlmwrite(outputTestFile, [AVGDATA classVec], '-append');
    end
  end
  fclose(filesFid);
  []
end