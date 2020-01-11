import os

for file_name in os.listdir('.'):
    if file_name[-3:] == 'dat':
        os.system('wfdb2mat -r ' + file_name[:-4])

