% Define the data

function [output] = func_VIR_IRheader_MyLevel1B(output_file_path, samples, lines, bands, spectral_resolution)

if spectral_resolution == 1
    load('VIR_HighSpecRes_IR_wavelengths');
    wavelengths=VIR_HighSpecRes_IR_wavelengths;
else
    load('VIR_LowSpecRes_IR_wavelengths');
    wavelengths=VIR_LowSpecRes_IR_wavelengths;
end

dtype = 4;
order = 0;
interleave = 'bip';
header_offset = 0;

if isempty(bands)
    bands = 1;
else
    bands=bands;
end


% Header file creation
fid = fopen([output_file_path '.HDR'],'wt');    % Open in text write mode

text = 'ENVI';
fprintf(fid,'%s\n',text);
text = sprintf('description\t= { VIR IR Data Cube }');
fprintf(fid,'%s\n',text);
text = sprintf('samples\t= %d', samples);
fprintf(fid,'%s\n',text);
text = sprintf('lines\t= %d', lines);
fprintf(fid,'%s\n',text);
text = sprintf('bands\t= %d', bands);
fprintf(fid,'%s\n',text);
text = sprintf('header offset\t= %d', header_offset);
fprintf(fid,'%s\n',text);
text = sprintf('file type\t= ENVI Standard');
fprintf(fid,'%s\n',text);
text = sprintf('data type\t= %d', dtype);
fprintf(fid,'%s\n',text);
text = sprintf('interleave\t= %s', interleave);
fprintf(fid,'%s\n',text);
text = sprintf('sensor type\t= Unknown');
fprintf(fid,'%s\n',text);
text = sprintf('byte order\t= %d', order);
fprintf(fid,'%s\n',text);
text = sprintf('wavelength units\t= Micrometers');
fprintf(fid,'%s\n',text);
%text = sprintf('wavelength = {1.0194,1.0456,1.0784,1.1505,1.2095,1.2489,1.2554,1.2620,1.2751,1.3276,1.3671,1.3933,1.4262,1.4656,1.4985,1.5050,1.5576,1.6234,1.6563,1.6893,1.7485,1.8078,1.8737,1.9265,1.9727,1.9793,2.0057,2.0651,2.1179,2.1377,2.1642,2.2038,2.2302,2.2501,2.2898,2.3162,2.3295,2.3493,2.3890,2.4287,2.4552,2.5280,2.6006,2.6270,2.6996,2.9974,3.1233,3.2494,3.3224,3.3956,3.5020,3.6351,3.7551,3.9219,4.0}');
%fprintf(fid,'%s\n',text);

% Now for the wavelength stuff...
text = 'wavelength = { ';
fprintf(fid,'%s\n',text);

for i = 1:(length(wavelengths)-1)
%text = sprintf('%f, ',wavelengths(1:length(wavelengths)-1));
    fprintf(fid,'%s',[num2str(wavelengths(i)) ', ']);
end

text = num2str(wavelengths(length(wavelengths)));
fprintf(fid,'%s}\n',text);



fclose(fid);
output = 1;
