function detector(record, data_folder)
    % function wrapping the qrs detector for detecting hearbeats.
    % Parameter record specifies the name of the record to evaluate.
    % Parameter data_folder specifies the relative path to the data folder.
    
    % parse file name.
    fileName = sprintf('%sm.mat', record);
    t=cputime();
    
    % Sampling frequency.
    fs = 360;
    
    % Load data.
    V = load(sprintf('%s%s', data_folder, fileName));
    
    % Parse descriptions.
    cd res;
    hea = wfdbdesc(record);
    desc = {hea.Description};
    cd ..
    
    idx = qrs_detect_multichannel(V.val, fs, desc, false);
    
    % Store results.
    fprintf('Running time: %f\n', cputime() - t);
    asciName = sprintf('./res/%s.asc', record);
    fid = fopen(asciName, 'wt');
    for i=1:size(idx,2)
        fprintf(fid,'0:00:00.00 %d N 0 0 0\n', idx(1,i) );
    end
    fclose(fid);
end
