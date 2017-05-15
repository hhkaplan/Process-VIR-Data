function Lbb = Lbb(Temp,Wavelengths)

%Solves Plancks Law using given Temperature and Wavelengths
    %Lbb = zeros(length(Wavelengths),1);
    
    C1 = 119104259;
    C2 = 14387.7509;
    
    term1 = C1./Wavelengths.^5;
    term2 = 1./(exp(C2./(Wavelengths.*Temp))-1);
    Lbb = term1.*term2;

end