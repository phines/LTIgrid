%function make
% a home-brew make file for the mexosi program

% check that we are running this from the current directory
make_dir = regexprep( which('make'), '(.*).make\.m', '$1' );
if ~strcmp(pwd,make_dir)
    error('make should be run from within the mexosi directory');
end

%% get the Cbc version number
cbc_zip = dir('Cbc*.zip');
if isempty(cbc_zip)
    error('Could not find Cbc');
end
cbc_zip = cbc_zip(end).name;
cbc_dir = regexprep(cbc_zip, '(.*).zip', '$1');

%% unzip cbc
if ~exist(cbc_dir,'dir')
    f = unzip(cbc_zip);
end

%% build cbc
cd(cbc_dir);
path_to_cbc = pwd;
config_cmd = sprintf('./configure -C --prefix=%s',path_to_cbc);
status = system(config_cmd,'-echo');
if (status~=0)
    error('configure failed');
end
status = system('make');
if (status~=0)
    error('make failed');
end
status = system('make install');
if (status~=0)
    error('make install failed');
end

cd ..
disp('If we ended above with something like: Nothing to be done for `install-data-am');
disp('the cbc build was successful.');
disp('');

%% build the mex file
cbc_libs = '-lCbcSolver -lCbc -lCgl -lOsiClp -lOsiCbc -lOsi -lClp -lCoinUtils';
mexopts  = '-v';
cmd = sprintf('mex %s -largeArrayDims -I%s/include mexosi.cpp ''-Wl,-rpath,%s/lib/coin'' -L%s/lib/coin %s',...
    mexopts, path_to_cbc, path_to_cbc, path_to_cbc, cbc_libs);

disp(['Compiling mexosi with: ' cmd]);
eval(cmd);

disp('Testing the solver...');
disp('-----------------------------------');
testosi;
