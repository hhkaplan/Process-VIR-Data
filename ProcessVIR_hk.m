%Mat data to load ahead of time
parentdir = '/Volumes/TempFiles/DAWN/DWNCHVIR_I1B/DATA/20150816_HAMO/';
addpath(genpath(parentdir))
load('VIR_IR_SolarSpectrum'); % values are already divided by PI to produce solar radiance, Lsolar; value is at 1 AU.
load('VIR_HighSpecRes_IR_wavelengths');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Locate and List all the files
%Directory - works only if this is directory above folders containing data
%(i.e. 2 levels above the data)
dirs = regexp(genpath(parentdir),('[^:]*'),'match');
Img_files{1} = [];

%Get unique filenames in all subdirectories
for i = 2:size(dirs,2)
    
    VIR_Image_Filepath = dirs{i};
    filenames = dir([VIR_Image_Filepath '/*.QUB.HDR']);
    Img = struct2cell(filenames); % Copies data from the structure array to a cell array.
    Img= Img(1,:)'; % Removes unnecessary fields such as date,size, etc. and creates a column vector of file names.
    Img = strcat(VIR_Image_Filepath,'/',Img); %Adds the filepath back in
    Img_files{1} = [Img_files{1};Img];
    
end

%Strip off the filetype so we can access all related files
for i = 1:size(Img_files{1},1)
    Img_files{1}(i) = strrep(Img_files{1}(i), '.QUB.HDR','');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Loop through files starting here (!) indicates where looping info needed
%Read the header
t1 = tic;
parfor fl = 1:size(Img_files{1},1)
    Hdr_file = strcat(Img_files{1}(fl), '.LBL'); %(!)
    header_info = textread(char(Hdr_file), '%s', 1000);
    [DataLevel, bands, samples, lines, Integration_Time, SpacecraftSolarDistance,...
        CurrentDistance, spectral_resolution,spatial_resolution,slit_mode] = Read_VIR_LBL(header_info);
    header_offset = 0;
    interleave = 'bip';

    % Read in the Level 1B data (values are in radiance).'
    Qub_file = strcat(Img_files{1}(fl),'.QUB');%(!)
    RadianceData = multibandread(char(Qub_file),[lines, samples, bands], 'float32',0,'bip','ieee-be'); 

    % Channels near ~3 um are currently not calibrated and will have values of INF. Find these values and set them to zero.
    RadianceData(isinf(RadianceData)) = 0;

    % Case for radiance data, need to convert to reflectance
    SolarSpectrum = VIR_IR_SolarSpectrum*CurrentDistance; % convert radiance to appropriate Vesta or Ceres distance
    SolarSpectrum = permute(SolarSpectrum,[2 3 1]); % permute so wavelength is in 'z' dimension
    SolarSpectrum = repmat(SolarSpectrum, [lines samples 1]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Solve for blackbody temperature
    xdata = VIR_HighSpecRes_IR_wavelengths; %wavelengths
    xdata_sub = xdata(380:end-5,:); %wavelengths from 4.7-5.05 that will be fit with blackbody
    t0 = 200;  %starting guess temp
    T = zeros(lines*samples,1); %pre-allocate space
    LBB = zeros(lines*samples,bands);%pre-allocate space
    R_RadianceData = reshape(RadianceData, [lines*samples,bands]); %reshaped radiance data
    options=optimset('MaxFunEvals',100000,'TolFun',1e-5,'MaxIter',10000, 'Display', 'off','DiffMinChange', 1e-5); %Options for curve fitting (no output)

    %For each pixel find apropriate T and then compute blackbody curve from
    %that T
    t2 = tic;
    for xl = 1:lines*samples
            ydata = squeeze(R_RadianceData(xl,:))';
            ydata_sub = ydata(380:end-5,:);
            T(xl) = lsqcurvefit(@Lbb,t0,xdata_sub,ydata_sub,[],[],options);
            LBB(xl,:) = Lbb(T(xl),xdata);
    end
    s2 = toc(t2)

    %Reshape the data:
    T = reshape(T, [lines,samples,1]);
    LBB = reshape(LBB, [lines, samples, bands]);

    %Divide out solar spectrum and subtract blackbody curve -> corrected
    %reflectance data
    Reflectance = (RadianceData-LBB)./(SolarSpectrum - LBB);
    Reflectance = single(Reflectance);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Write a new header and save file
    %%%ASSUMING DATA IS 1B (RADIANCE) VIR (NOT VIS) 
    Out_file = strcat(Img_files{1}(1),'_Refl_ThermalCorr_v1','.IMG');
    multibandwrite(Reflectance, char(Out_file),'bip');   
    func_VIR_IRheader_MyLevel1B(char(Out_file), samples, lines, bands, spectral_resolution);

    Out_file2 = strcat(Img_files{1}(1),'_Temp_ThermalCorr_v1','.IMG');
    multibandwrite(single(T), char(Out_file2),'bip');   
    func_VIR_IRheader_MyLevel1B(char(Out_file2), samples, lines, 1, spectral_resolution);
end
s1 = toc(t1)