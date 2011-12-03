import csv
import sys

'''
usage:

create the following directories:
LDCdata/features_<feature_type>/MA
LDCdata/features_<feature_type>/GE

from LDCdata directory:
python generateFilenames.py <wavfilenamelist>.scp <feature_type> <language>

--
ex.
LDCdata/features_fbank/MA
LDCdata/features_fbank/GE

python generateFilenames.py germanwav.scp fbank german

--

output (2 .scp files in LDCdata/features_fbank):
LDCdata/features_fbank/germanwav_wav_fbank_files.scp --> contains wav and fbank file paths
LDCdata/features_fbank/germanwav_fbank_files.scp --> contains fbank file paths

Note: paths from LDCdata

--
running HCOPY:

this should work...but...

(from LDCdata directory)

HCOPY -C fbankcconfig.txt -S features_fbank/german_wav_fbank_files.scp

'''

def genFilenames(infile, featuretype, language):
  infilename = infile[0:-4] #removes .scp extension
  directoryname = 'features_' + featuretype

  list_of_filenames = csv.reader(open(infile, 'rb'), delimiter=' ')
  
  wav_feature_fn = directoryname+'/'+infilename+'_wav_'+featuretype+'_files.scp'
  features_only_fn = directoryname+'/'+infilename + '_' + featuretype+'_files.scp'
  
  wav_and_features = csv.writer(open(wav_feature_fn, 'wb'), delimiter = ' ')
  feature_filenames = csv.writer(open(features_only_fn, 'wb'), delimiter = ' ')
  
  for filename in list_of_filenames:
    filename = filename[0]
    outfilename = directoryname + '/' + infilename + '/' +filename[3:-4] + '.'+featuretype
    wav_and_features.writerow([filename, outfilename]) 
    feature_filenames.writerow([outfilename])
  return wav_feature_fn, features_only_fn
    
if __name__ == '__main__':
  wavfilenamelist = sys.argv[1]
  featuretype = sys.argv[2]
  language = sys.argv[3]
  genFilenames(wavfilenamelist, featuretype, language)
