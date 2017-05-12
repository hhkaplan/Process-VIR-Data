function [DataLevel, bands, samples, lines, Integration_Time, SpacecraftSolarDistance,...
    CurrentDistance, spectral_resolution,spatial_resolution,slit_mode] = Read_VIR_LBL(header_info)

    ProductType = char(header_info(strmatch('PRODUCT_TYPE',header_info)+2));

    if strcmp(ProductType,'EDR')
        DataLevel = 0; % Data should be EDR, in DN
    else
        DataLevel = 1; % Data should be RDR, in radiance
    end

    % For some reason the header info is read in differently for EDR and RDR
    % files. Have one set of conditions to strip out necessary info for RDR
    % files (DataLevel = 1) and another set of conditions to strip out
    % necessary info for EDR files.

    if DataLevel == 1 % condition met for RDR (radiance) data, Level 1B
        bands = char(header_info(strmatch('CORE_ITEMS',header_info)+1));
        bands(1) = [];
        bands(length(bands)) = [];
        bands = str2num(bands);

        samples = char(header_info(strmatch('CORE_ITEMS',header_info)+2));
        samples(length(samples)) = [];
        samples = str2num(samples);

        lines = char(header_info(strmatch('CORE_ITEMS',header_info)+3));
        lines(length(lines)) = [];
        lines = str2num(lines);

    else
        bands = char(header_info(strmatch('CORE_ITEMS',header_info)+3));
        bands(length(bands)) = [];
        bands = str2num(bands);

        samples = char(header_info(strmatch('CORE_ITEMS',header_info)+4));
        samples(length(samples)) = [];
        samples = str2num(samples);

        lines = char(header_info(strmatch('CORE_ITEMS',header_info)+5));
        lines = str2num(lines);

    end

    Instrument_Mode = char(header_info(min(strmatch('INSTRUMENT_MODE_ID',header_info))+2));
    Instrument_Mode(1) = [];
    Instrument_Mode(length(Instrument_Mode)) = [];

    % Determine integration time (in seconds).
    % This is the first of four values under the FRAME_PARAMETER keyword in the
    % associated .LBL file.

    Integration_Time = char(header_info(min(strmatch('FRAME_PARAMETER',header_info))+2));
    Integration_Time(1) = [];
    Integration_Time(length(Integration_Time)) = [];
    Integration_Time = str2num(Integration_Time);

    % Determine spacecraft (target) distance from Sun, in kilometers
    SpacecraftSolarDistance = char(header_info(min(strmatch('SPACECRAFT_SOLAR_DISTANCE',header_info))+2));
    SpacecraftSolarDistance = str2num(SpacecraftSolarDistance);

    if isempty(SpacecraftSolarDistance)==1
        SpacecraftSolarDistance = 414000000; %default distance in kilometers if header value is empty
    end
    % Get instrument modes
spectral_resolution = 0;
spatial_resolution = 0;
slit_mode = 0;

% Determine spatial resolution mode. High = 1;, Low = 0
if Instrument_Mode(1,3) == 'H'
    spectral_resolution = 1;
end

% Determine spatial resolution mode. High = 1;, Low = 0
if Instrument_Mode(1,9) == 'H'
    spatial_resolution = 1;
end

% Determine slit mode. Full = 1;, Quarter = 0
if Instrument_Mode(1,15) == 'F'
    slit_mode = 1;
end

%Determine current distance
AU = 149597870.7; 
CurrentDistance = (AU/SpacecraftSolarDistance)^2; % reduction factor for radiance at given distance

end
