%function [ DATA, HTKCode ] = htkread( Filename1, Filename2)
% [ DATA, HTKCode ] = htkread( Filename1 )
%
% Read DATA from possibly compressed HTK format file.
%
% Filename1 (string) - Name of the file to read from
% DATA (nSamp x NUMCOFS) - Output data array
% HTKCode - HTKCode describing file contents
%%
% Compression is handled using the algorithm in 5.10 of the HTKBook.
% CRC is not implemented.
%
% Mark Hasegawa-Johnson
% July 3, 2002
% Based on function mfcc_read written by Alexis Bernard
%

more off;
Filename1 = 'M_features_w25.fbank';
Filename2 = 'G_features_w25.fbank';
fid1=fopen(Filename1,'r','b');
fid2=fopen(Filename2, 'r', 'b');
if fid1<0,
    error(sprintf('Unable to read from file %s',Filename1));
end
if fid2<0,
    error(sprintf('Unable to read from file %s',Filename2));
end

% Read number of frames
nSamp = fread(fid1,1,'int32');

% Read sampPeriod
sampPeriod = fread(fid1,1,'int32');

% Read sampSize
sampSize = fread(fid1,1,'int16');

% Read HTK Code
HTKCode = fread(fid1,1,'int16');

%%%%%%%%%%%%%%%%%
% Read the data
if bitget(HTKCode, 11),
    DIM=sampSize/2;
    nSamp = nSamp-4;
    disp(sprintf('htkread: Reading %d frames, dim %d, compressed, from %s',nSamp,DIM,Filename1)); 

    % Read the compression parameters
    A = fread(fid1,[1 DIM],'float');
B = fread(fid1,[1 DIM],'float');
    
    % Read and uncompress the data
    DATA1 = fread(fid1, [DIM nSamp], 'int16')';
    DATA1 = (repmat(B, [nSamp 1]) + DATA1) ./ repmat(A, [nSamp 1]);


else
    DIM=sampSize/4;
    disp(sprintf('htkread: Reading %d frames, dim %d, uncompressed, from %s',nSamp,DIM,Filename1)); 

    % If not compressed: Read floating point data
    DATA1 = fread(fid1, [DIM nSamp], 'float')';
end

'averaging'
AVGDATA1 = repmat(0, (int32(floor(size(DATA1, 1)/160))), (size(DATA1, 2)));
for rowNum = 1:(size(DATA1, 1)- mod(size(DATA1, 1), 160))
  avgRowNum = int32(floor((rowNum-1)/160))+1;

  for col=1:size(DATA1,2) 
     AVGDATA1(avgRowNum,col) = AVGDATA1(avgRowNum,col) + DATA1(rowNum,col);
  end
end
AVGDATA1 = AVGDATA1 ./ 160;
'done averaging'


%%%%%%%%%%% DATA 2 %%%%%%%%%%%%%%%%%%%%%%%%%%

% Read number of frames
nSamp = fread(fid2,1,'int32');

% Read sampPeriod
sampPeriod = fread(fid2,1,'int32');

% Read sampSize
sampSize = fread(fid2,1,'int16');

% Read HTK Code
HTKCode = fread(fid2,1,'int16');

%%%%%%%%%%%%%%%%%
% Read the data
if bitget(HTKCode, 11),
    DIM=sampSize/2;
    nSamp = nSamp-4;
    disp(sprintf('htkread: Reading %d frames, dim %d, compressed, from %s',nSamp,DIM,Filename2)); 

    % Read the compression parameters
    A = fread(fid2,[1 DIM],'float');
    B = fread(fid2,[1 DIM],'float');
    
    % Read and uncompress the data
    DATA2 = fread(fid2, [DIM nSamp], 'int16')';
    DATA2 = (repmat(B, [nSamp 1]) + DATA2) ./ repmat(A, [nSamp 1]);


else
    DIM=sampSize/4;
    disp(sprintf('htkread: Reading %d frames, dim %d, uncompressed, from %s',nSamp,DIM,Filename2)); 

    % If not compressed: Read floating point data
    DATA2 = fread(fid2, [DIM nSamp], 'float')';
end




'averaging'
AVGDATA2 = repmat(0, (int32(floor(size(DATA2, 1)/160))), (size(DATA2, 2)));
for rowNum = 1:(size(DATA2, 1) - mod(size(DATA2, 1), 160))
  avgRowNum = int32(floor((rowNum-1)/160))+1;
  for col=1:size(DATA2,2) 
     AVGDATA2(avgRowNum,col) = AVGDATA2(avgRowNum,col) + DATA2(rowNum,col);
  end
end
AVGDATA2 = AVGDATA2 ./ 160;
'done averaging'

%%%%%% to csv %%%%%%%%%%%%%%%%%%

'creating matrix'
M = 0:size(AVGDATA1,2);
zrs = repmat(0,[size(AVGDATA1, 1) 1]);
M = [M; zrs AVGDATA1];
ons = repmat(1,[size(AVGDATA2, 1) 1]);
M = [M; ons AVGDATA2];
'writing csv'
csvwrite('features.csv', M);

fclose(fid1);
fclose(fid2);