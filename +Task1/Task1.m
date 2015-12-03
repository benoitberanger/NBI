function [ TaskData ] = Task1( DataStruct )

try
    
    TaskData = DataStruct;
    
catch err
    
    sca
    rethrow(err)
    
end

