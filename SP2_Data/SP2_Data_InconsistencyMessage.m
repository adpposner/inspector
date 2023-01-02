function msg = SP2_Data_InconsistencyMessage(callername, origmsg,s,value1,value2)
    line_num = dbstack; 
    msg = sprintf('%s %s: %s is not consistent %f - %f \n',origmsg,callername,s,value1,value2);
end 