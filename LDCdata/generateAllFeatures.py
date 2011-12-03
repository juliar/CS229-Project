'''

This performs feature extraction for specified languages, feature types, and 
subsets of data. This should be run from the LDCData directory.  It will put all new files 
in a new directory called features_<featuretype>.


Usage:

1) edit the dictionary 'configFiles' below to include all desired feature config files
2) edit 'languages' array to include desired languages  (lowercase, complete name)
3) verify subsets contains the appropriate suffixes to the subset filenames
4) delete existing stuff you want to replace

python generateAllFeatures.py

LDCData must contain the following files:

1) htk config files
2) .scp files containing all paths of wav files (one for each language and subset, eg. germanwavstrong2_0.scp)
3) wav files in directories for individual languages


Flags that would be convenient but aren't implemented:
- Option to just run HCOPY
- Specify the languages, featuretype, and/or data subsets

'''  


import csv
import sys
import generateFilenames as gen
import os

if __name__ == '__main__':
  
  languages = ['german', 'mandarin']
  subsets = ['strength0.scp'] #'strong2_0.scp', 'stronger2_5.scp', 'strongest2_7.scp', 
  
  configFiles = {}
  configFiles['mfcc'] = 'mfccconfig.txt'
  configFiles['fbank'] = 'fbankconfig.txt'
  configFiles['lpc'] = 'lpcconfig.txt'
  configFiles['mfccplus'] = 'mfccplusconfig.txt'
  
  #configFiles['mfcchamming'] = 'mfccconfighamming'
  
  all_feature_only_files = []
  
  for featuretype in configFiles.keys():
    configfilename = configFiles[featuretype]
    
    #makes a new directory for all feature files for a given featuretype
    feature_dir = 'features_' + featuretype
    os.system('mkdir ' + feature_dir)
    
    for lang in languages:
      for degreeSet in subsets:
      
        #make a new directory for feature files fo a given a language and degree
        feature_strength_dir = feature_dir + '/' + lang + 'wav' + degreeSet[0:-4]
        os.system('mkdir ' + feature_strength_dir)
        
        wavfiles = lang + 'wav' + degreeSet
        
        #this generates a file with pairs of 2 files (.wav file  .<featuretype> file) to be used with HCOPY
        wav_feature_pair_file, feature_only_file = gen.genFilenames(wavfiles, featuretype, lang)
        
        all_feature_only_files.append(feature_only_file)
        
        hcopycommand = 'HCOPY -C ' + configfilename + ' -S ' + wav_feature_pair_file
        print hcopycommand
        
        os.system(hcopycommand)
