import csv

if __name__ == '__main__':
  filesToMerge = ['test_train_csv_files/strength0_mfcc_test.csv', 'test_train_csv_files/strength0_mfccplus_test.csv']
  
  #create csv readers for each file
  readers = [csv.reader(open(filename, 'rb'), delimiter =',') for filename in filesToMerge]
  
  #create output file
  outfile = 'test_train_csv_files/all_features_test.csv'  
  writer = csv.writer(open(outfile, 'wb'), delimiter = ',')

  numRows = 0
  for row in readers[0]:
    numRows = numRows + 1
  readers[0] = csv.reader(open(filesToMerge[0], 'rb'), delimiter =',')
  
  numFiles = len(filesToMerge)
  
  print readers
  for i in xrange(numRows):    
    curr_row = []
    
    for i in xrange(numFiles):
      reader = readers[i]
      if i == numFiles-1:
        curr_row.extend(reader.next())
      else:
        curr_row.extend(reader.next()[0:-1])
    writer.writerow(curr_row)

