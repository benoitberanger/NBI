% Acceleration factor
Catch.minrand = Catch.minrand/Speed;
Catch.maxrand = Catch.maxrand/Speed;

Catch.onset = linspace(0,Catch.stimDuration,Catch.N + 1 ) + ( Catch.minrand + (Catch.maxrand-Catch.minrand).*rand(1,Catch.N + 1) );
Catch.onset(end) = [];

Catch.frame = round(Catch.onset/DataStruct.PTB.IFI); % convert onset (seconds) into frame number
