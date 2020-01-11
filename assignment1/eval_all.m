% Directory for data files.
data_folder = './data2/';
files = dir(fullfile(data_folder, '*.mat'));

% Remove results from previous runs.
system('rm results.txt &> /dev/null');
cd res/
system('rm eval1.txt eval2.txt %> /dev/null');
cd ..

% Go over data files 
for idx_file = 1:length(files)
    
    % Compute results for next record.
    fprintf('Evaluating record %s (%d/%d)\n', files(idx_file).name, idx_file, length(files))
    record_nxt = files(idx_file).name(1:end-5);
    detector(record_nxt, data_folder);
    cd res/
    system(sprintf('wrann -r %s -a qrs < %s.asc', record_nxt, record_nxt));
    system(sprintf('bxb -r %s -f 0 -a atr qrs -l eval1.txt eval2.txt', record_nxt));
    cd ..
end

% Compute stats.
cd res/
system('sumstats eval1.txt eval2.txt > results.txt');
system('mv results.txt ..');
cd ..
