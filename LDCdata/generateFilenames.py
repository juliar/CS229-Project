import csv
import sys

'''
usage:

create the following directories:
LDCdata/features_<feature_type>/MA
LDCdata/features_<feature_type>/GE

from LDCdata directory:
python addOutputFilenames.py <wavfilenamelist>.scp <feature_type> <language>

--
ex.
LDCdata/features_fbank/MA
LDCdata/features_fbank/GE

python addOutputFilenames.py germanwav.scp fbank german

--

output (2 .scp files in LDCdata/features_fbank):
LDCdata/features_fbank/german_wav_fbank_files.scp --> contains wav and fbank file paths
LDCdata/features_fbank/german_fbank_files.scp --> contains fbank file paths

Note: paths from LDCdata

--
running HCOPY:

this should work...but...

(from LDCdata directory)

HCOPY -C fbankcconfig.txt -S features_fbank/german_wav_fbank_files.scp

'''

if __name__ == '__main__':
  infile = sys.argv[1]
  featuretype = sys.argv[2]
  language = sys.argv[3]
  directoryname = 'features_' + featuretype #ex features_fbank

  list_of_filenames = csv.reader(open(infile, 'rb'), delimiter=' ')
  wav_and_features = csv.writer(open(directoryname+'/'+language+'_wav_fbank_files.scp', 'wb'), delimiter = ' ')
  feature_filenames = csv.writer(open(directoryname+'/'+language + '_fbank_files.scp', 'wb'), delimiter = ' ')
  
  for filename in list_of_filenames:
    filename = directoryname + '/' +filename[0][0:-4]
    outfilename =filename+'.'+featuretype #directoryname+'/' +filename[0][0:-4] + '.' + featuretype
    wav_and_features.writerow([filename, outfilename]) 
    feature_filenames.writerow([outfilename])