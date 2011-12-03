function [] = htktocsvmanyfiles(filenamesFiles, outputTrainFile, outputTestFile)
% FilenameFiles is a list of the names of files containing 
% the filenames to be parsed
% Based on function written by Mark Hasegawa-Johnson
% July 3, 2002
% Based on function mfcc_read written by Alexis Bernard
%

% Bucket sizes in seconds
bucketSize = 4;

% Sliding Buckets on/off
sliding = 0;
% slidingDist in seconds
slidingDist = 1;
% Coordinate Standardization
standardize = 0;


more off;
% This assumes feature windows of 0.025 seconds. Which means theres 40 features per second.
bucketConst = bucketSize*40;
slidingConst = slidingDist*40;



filenamesFiles
for filenamesFileInd = 1:size(filenamesFiles,1)
  ['reading files of class', filenamesFileInd-1]
  filename = filenamesFiles{filenamesFileInd}
  % size(filename, 1)
  % size(filename, 2)
  filesFid = fopen(filename,'r');

  
  if filesFid < 0,
    error(sprintf('Unable to read from file %s',filenamesFiles(filenamesFileInd,:)));
  end
  files = textscan(filesFid, '%s');
  
  for fileInd = 1:size(files{1,1},1)
    
    file = files{1,1}{fileInd,1};
    
    %['reading file', file]
    %size(file,1) 
    %size(file,2)
    file
    
    [DATA, HTKCode] = htkread(file);
    %DATA

    if (sliding)
      'Sliding Buckets'
      AVGDATA = repmat(0, (int32(floor(size(DATA, 1)/(slidingConst))) - bucketSize + 1), size(DATA, 2));
      for slide = 1:(int32(floor(size(DATA, 1)/(slidingConst))) - bucketSize + 1)

        for slideNum = 0:bucketConst-1
          for col = 1:size(DATA,2)
            AVGDATA(slide, col) = AVGDATA(slide, col) + DATA((slide + slideNum), col);
          end
        end
      end

    else
      'Non-sliding Buckets'
      AVGDATA = repmat(0, (int32(floor(size(DATA, 1)/bucketConst))), (size(DATA, 2)));
      for rowNum = 1:(size(DATA, 1)- mod(size(DATA, 1), bucketConst))
        avgRowNum = int32(floor((rowNum-1)/bucketConst))+1;
        for col=1:size(DATA,2) 
          AVGDATA(avgRowNum,col) = AVGDATA(avgRowNum,col) + DATA(rowNum,col);
        end
      end
    end
    
    AVGDATA = AVGDATA ./ bucketConst;
    
    classVec = repmat(filenamesFileInd-1,[size(AVGDATA, 1) 1]);

    if(standardize)
        

      if fileInd < size(files{1,1},1)*0.7
        dlmwrite('outputTrainTemp', [AVGDATA classVec], '-append');
      else
        dlmwrite('outputTestTemp', [AVGDATA classVec], '-append');
      end



    else
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
  end
  fclose(filesFid);

  []
end



if (standardize)
  'Starting Standardization'
  'Reading tempfiles'
  trainTemp = csvread('outputTrainTemp');
  numTrainRows = size(trainTemp,1);
  testTemp = csvread('outputTestTemp');
  numTestRows = size(testTemp,1);

  temp = vertcat (trainTemp, testTemp); %Concatinate train on top


  [numRows, numCols] = size(temp);
  numCols = numCols-1; % To not standardize the label

  % Calculate mean
  mean = repmat(0, 1, numCols);
  for row = 1:numRows
    for col = 1:numCols
      mean(1,col) = mean(1,col) + temp(row,col);
    end
  end
  mean = mean ./ numRows;

  % Calculate stddev
  stddev = repmat(0, 1, numCols);
  for row = 1:numRows
    for col = 1:numCols
      stddev(1,col) = stddev(1,col)+(temp(row,col) - mean(1,col))*(temp(row,col) - mean(1,col));
    end
  end
  stddev = stddev ./ numRows;
  stddev = sqrt(stddev)

  % Calculate coordinate standardization
  for row = 1:numRows
    for col = 1:numCols
      temp(row,col) = (temp(row,col) - mean(1,col))/stddev(1,col);
    end
  end


  %write index on first row
  dlmwrite(outputTrainFile, 1:(numCols + 1));
  dlmwrite(outputTestFile, 1:(numCols + 1));

  Train = zeros(numTrainRows, numCols + 1);
  Test = zeros(numRows - numTrainRows, numCols + 1);

  for i = 1:numRows
    if i < numTrainRows + 1
          Train(i,:) = temp(i,:);
    else
          Test(i-numTrainRows,:) = temp(i,:);
    end
  end
  dlmwrite(outputTrainFile, Train, '-append');
  dlmwrite(outputTestFile, Test, '-append');


  'Finished Standardization'
end
