%Mat data to load ahead of time
load('VIR_IR_SolarSpectrum'); % values are already divided by PI to produce solar radiance, Lsolar; value is at 1 AU.

%%%%%%%%%%%%%%%% Locate and List all the files

%Directory - works only if this is directory above folders containing data
%(i.e. 2 levels above the data)
parentdir = '/Volumes/TempFiles/DAWN/DWNCHVIR_I1B/DATA/20150816_HAMO/';
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

%%%%%%%%%%%%%%% Loop through files starting here (!) indicates where looping info needed

%Read the header
Hdr_file = strcat(Img_files{1}(1), '.LBL'); %(!)
header_info = textread(Hdr_file{1}, '%s', 1000);
[DataLevel, bands, samples, lines, Integration_Time, SpacecraftSolarDistance,...
    CurrentDistance, spectral_resolution,spatial_resolution,slit_mode] = Read_VIR_LBL(header_info);
header_offset = 0;
interleave = 'bip';

% Read in the Level 1B data (values are in radiance).
RadianceData = multibandread([Img_files{1}(1) '.QUB'],[lines, samples, bands], 'float32',0,'bip','ieee-be'); %(!)

% Channels near ~3 um are currently not calibrated and will have values of INF. Find these values and set them to zero.
InfinityList = isinf(RadianceData);
InfinityID = find(InfinityList == 1);
RadianceData(InfinityID) = 0;

% Case for radiance data, need to convert to reflectance
SolarSpectrum = VIR_IR_SolarSpectrum;
SolarSpectrum = SolarSpectrum*CurrentDistance; % convert radiance to appropriate Vesta or Ceres distance
SolarSpectrum = permute(SolarSpectrum,[2 3 1]); % permute so wavelength is in 'z' dimension
SolarSpectrum = repmat(SolarSpectrum, [lines samples 1]);





%Write a new header
%%%ASSUMING DATA IS 1B (RADIANCE) VIR (NOT VIS) 
func_VIR_IRheader_Level1B([Img_files{1}(1),'_HannahUpdate'], samples, lines, bands, spectral_resolution); %(!)