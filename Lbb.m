function Lbb = Lbb(Temp,Wavelengths)

%Solves Plancks Law using given Temperature and Wavelengths
    Lbb = zeros(length(Wavelengths),1);
    
   	L = Wavelengths; %Wavelengths in microns
    T = Temp; %Temperature in K
    
    %H = 6.62607*10^-34; %Planck constant J*s
    %C = 2.887825*10^8; %Speed of light m/s
    %Kb = 1.3806*10^-23; %Boltzmann constant J/K
    C1 = 119104259;
    C2 = 14387.7509;
    
    for i = 1:length(Wavelengths)
         Lbb(i) = (C1/L(i)^5)*(1/(exp(C2/(L(i)*T))-1));
        
    end
end