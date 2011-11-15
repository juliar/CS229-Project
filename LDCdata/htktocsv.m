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
Filename1 = 'M_features.lpc';
Filename2 = 'G_features.lpc';
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
    DATA2 = fread(fid1, [DIM nSamp], 'float')';
end

M = 0:size(DATA1,2);
M
zrs = zeros(size(DATA1, 1));
M = [M; zrs DATA1];
size(M,1)
size(M,2)
ons = ones(size(DATA2, 1));
M = [M; ons DATA2];
size(M,1)
size(M,2)
csvwrite('features.csv', M);

fclose(fid1);
