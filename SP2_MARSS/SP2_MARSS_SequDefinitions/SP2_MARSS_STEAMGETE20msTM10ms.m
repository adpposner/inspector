function [G amplitudeUnit coherencePathway delays durations rephaseAreas rfOffsets rfPulses phaseShifts] = SP2_MARSS_STEAMGETE20msTM10ms()

G = [0    2.7786         0
    2.7786         0         0
         0         0    2.7786];

amplitudeUnit = 'Gauss';

coherencePathway = [1     0    -1];

delays = [0.0064    0.0064    0.0082];

durations = [0.0036    0.0036    0.0036];

rephaseAreas = [-0.0050   -0.0052         0
         0         0         0
         0         0   -0.0052];

phaseShifts = [0         0         0    0.5732];
         
rfOffsets = [337.9558  337.9558  337.9558];

rfPulses{1} = [
         0
   -0.0000
   -0.0001
   -0.0001
   -0.0002
   -0.0002
   -0.0003
   -0.0003
   -0.0004
   -0.0004
   -0.0005
   -0.0005
   -0.0006
   -0.0006
   -0.0007
   -0.0007
   -0.0008
   -0.0008
   -0.0009
   -0.0009
   -0.0010
   -0.0011
   -0.0011
   -0.0012
   -0.0012
   -0.0013
   -0.0013
   -0.0014
   -0.0014
   -0.0015
   -0.0015
   -0.0015
   -0.0016
   -0.0016
   -0.0016
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0016
   -0.0016
   -0.0016
   -0.0015
   -0.0014
   -0.0014
   -0.0013
   -0.0012
   -0.0011
   -0.0010
   -0.0009
   -0.0007
   -0.0006
   -0.0005
   -0.0003
   -0.0001
    0.0001
    0.0003
    0.0004
    0.0007
    0.0009
    0.0011
    0.0013
    0.0016
    0.0018
    0.0021
    0.0023
    0.0026
    0.0029
    0.0031
    0.0034
    0.0036
    0.0039
    0.0042
    0.0044
    0.0047
    0.0050
    0.0052
    0.0054
    0.0057
    0.0059
    0.0061
    0.0063
    0.0065
    0.0066
    0.0068
    0.0069
    0.0070
    0.0071
    0.0071
    0.0072
    0.0072
    0.0071
    0.0071
    0.0070
    0.0069
    0.0068
    0.0066
    0.0064
    0.0062
    0.0059
    0.0056
    0.0053
    0.0049
    0.0045
    0.0041
    0.0036
    0.0031
    0.0026
    0.0020
    0.0014
    0.0008
    0.0001
   -0.0006
   -0.0013
   -0.0020
   -0.0028
   -0.0036
   -0.0044
   -0.0052
   -0.0060
   -0.0069
   -0.0077
   -0.0086
   -0.0095
   -0.0103
   -0.0112
   -0.0121
   -0.0129
   -0.0138
   -0.0146
   -0.0154
   -0.0162
   -0.0170
   -0.0177
   -0.0185
   -0.0191
   -0.0198
   -0.0203
   -0.0209
   -0.0213
   -0.0218
   -0.0221
   -0.0224
   -0.0227
   -0.0228
   -0.0229
   -0.0229
   -0.0229
   -0.0227
   -0.0225
   -0.0221
   -0.0217
   -0.0212
   -0.0205
   -0.0198
   -0.0190
   -0.0181
   -0.0170
   -0.0159
   -0.0146
   -0.0133
   -0.0118
   -0.0102
   -0.0086
   -0.0068
   -0.0049
   -0.0029
   -0.0007
    0.0015
    0.0038
    0.0062
    0.0088
    0.0114
    0.0141
    0.0169
    0.0198
    0.0228
    0.0258
    0.0290
    0.0322
    0.0355
    0.0388
    0.0422
    0.0456
    0.0491
    0.0526
    0.0562
    0.0598
    0.0634
    0.0670
    0.0706
    0.0743
    0.0779
    0.0815
    0.0850
    0.0886
    0.0921
    0.0955
    0.0989
    0.1022
    0.1054
    0.1086
    0.1116
    0.1146
    0.1174
    0.1201
    0.1227
    0.1252
    0.1275
    0.1297
    0.1317
    0.1336
    0.1353
    0.1368
    0.1381
    0.1393
    0.1403
    0.1410
    0.1416
    0.1420
    0.1422
    0.1422
    0.1420
    0.1416
    0.1410
    0.1403
    0.1393
    0.1381
    0.1368
    0.1353
    0.1336
    0.1317
    0.1297
    0.1275
    0.1252
    0.1227
    0.1201
    0.1174
    0.1146
    0.1116
    0.1086
    0.1054
    0.1022
    0.0989
    0.0955
    0.0921
    0.0886
    0.0850
    0.0815
    0.0779
    0.0743
    0.0706
    0.0670
    0.0634
    0.0598
    0.0562
    0.0526
    0.0491
    0.0456
    0.0422
    0.0388
    0.0355
    0.0322
    0.0290
    0.0258
    0.0228
    0.0198
    0.0169
    0.0141
    0.0114
    0.0088
    0.0062
    0.0038
    0.0015
   -0.0007
   -0.0029
   -0.0049
   -0.0068
   -0.0086
   -0.0102
   -0.0118
   -0.0133
   -0.0146
   -0.0159
   -0.0170
   -0.0181
   -0.0190
   -0.0198
   -0.0205
   -0.0212
   -0.0217
   -0.0221
   -0.0225
   -0.0227
   -0.0229
   -0.0229
   -0.0229
   -0.0228
   -0.0227
   -0.0224
   -0.0221
   -0.0218
   -0.0213
   -0.0209
   -0.0203
   -0.0198
   -0.0191
   -0.0185
   -0.0177
   -0.0170
   -0.0162
   -0.0154
   -0.0146
   -0.0138
   -0.0129
   -0.0121
   -0.0112
   -0.0103
   -0.0095
   -0.0086
   -0.0077
   -0.0069
   -0.0060
   -0.0052
   -0.0044
   -0.0036
   -0.0028
   -0.0020
   -0.0013
   -0.0006
    0.0001
    0.0008
    0.0014
    0.0020
    0.0026
    0.0031
    0.0036
    0.0041
    0.0045
    0.0049
    0.0053
    0.0056
    0.0059
    0.0062
    0.0064
    0.0066
    0.0068
    0.0069
    0.0070
    0.0071
    0.0071
    0.0072
    0.0072
    0.0071
    0.0071
    0.0070
    0.0069
    0.0068
    0.0066
    0.0065
    0.0063
    0.0061
    0.0059
    0.0057
    0.0054
    0.0052
    0.0050
    0.0047
    0.0044
    0.0042
    0.0039
    0.0036
    0.0034
    0.0031
    0.0029
    0.0026
    0.0023
    0.0021
    0.0018
    0.0016
    0.0013
    0.0011
    0.0009
    0.0007
    0.0004
    0.0003
    0.0001
   -0.0001
   -0.0003
   -0.0005
   -0.0006
   -0.0007
   -0.0009
   -0.0010
   -0.0011
   -0.0012
   -0.0013
   -0.0014
   -0.0014
   -0.0015
   -0.0016
   -0.0016
   -0.0016
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0016
   -0.0016
   -0.0016
   -0.0015
   -0.0015
   -0.0015
   -0.0014
   -0.0014
   -0.0013
   -0.0013
   -0.0012
   -0.0012
   -0.0011
   -0.0011
   -0.0010
   -0.0009
   -0.0009
   -0.0008
   -0.0008
   -0.0007
   -0.0007
   -0.0006
   -0.0006
   -0.0005
   -0.0005
   -0.0004
   -0.0004
   -0.0003
   -0.0003
   -0.0002
   -0.0002
   -0.0001
   -0.0001
   -0.0000
         0];
 
rfPulses{2} = [
         0
   -0.0000
   -0.0001
   -0.0001
   -0.0002
   -0.0002
   -0.0003
   -0.0003
   -0.0004
   -0.0004
   -0.0005
   -0.0005
   -0.0006
   -0.0006
   -0.0007
   -0.0007
   -0.0008
   -0.0008
   -0.0009
   -0.0009
   -0.0010
   -0.0011
   -0.0011
   -0.0012
   -0.0012
   -0.0013
   -0.0013
   -0.0014
   -0.0014
   -0.0015
   -0.0015
   -0.0015
   -0.0016
   -0.0016
   -0.0016
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0016
   -0.0016
   -0.0016
   -0.0015
   -0.0014
   -0.0014
   -0.0013
   -0.0012
   -0.0011
   -0.0010
   -0.0009
   -0.0007
   -0.0006
   -0.0005
   -0.0003
   -0.0001
    0.0001
    0.0003
    0.0004
    0.0007
    0.0009
    0.0011
    0.0013
    0.0016
    0.0018
    0.0021
    0.0023
    0.0026
    0.0029
    0.0031
    0.0034
    0.0036
    0.0039
    0.0042
    0.0044
    0.0047
    0.0050
    0.0052
    0.0054
    0.0057
    0.0059
    0.0061
    0.0063
    0.0065
    0.0066
    0.0068
    0.0069
    0.0070
    0.0071
    0.0071
    0.0072
    0.0072
    0.0071
    0.0071
    0.0070
    0.0069
    0.0068
    0.0066
    0.0064
    0.0062
    0.0059
    0.0056
    0.0053
    0.0049
    0.0045
    0.0041
    0.0036
    0.0031
    0.0026
    0.0020
    0.0014
    0.0008
    0.0001
   -0.0006
   -0.0013
   -0.0020
   -0.0028
   -0.0036
   -0.0044
   -0.0052
   -0.0060
   -0.0069
   -0.0077
   -0.0086
   -0.0095
   -0.0103
   -0.0112
   -0.0121
   -0.0129
   -0.0138
   -0.0146
   -0.0154
   -0.0162
   -0.0170
   -0.0177
   -0.0185
   -0.0191
   -0.0198
   -0.0203
   -0.0209
   -0.0213
   -0.0218
   -0.0221
   -0.0224
   -0.0227
   -0.0228
   -0.0229
   -0.0229
   -0.0229
   -0.0227
   -0.0225
   -0.0221
   -0.0217
   -0.0212
   -0.0205
   -0.0198
   -0.0190
   -0.0181
   -0.0170
   -0.0159
   -0.0146
   -0.0133
   -0.0118
   -0.0102
   -0.0086
   -0.0068
   -0.0049
   -0.0029
   -0.0007
    0.0015
    0.0038
    0.0062
    0.0088
    0.0114
    0.0141
    0.0169
    0.0198
    0.0228
    0.0258
    0.0290
    0.0322
    0.0355
    0.0388
    0.0422
    0.0456
    0.0491
    0.0526
    0.0562
    0.0598
    0.0634
    0.0670
    0.0706
    0.0743
    0.0779
    0.0815
    0.0850
    0.0886
    0.0921
    0.0955
    0.0989
    0.1022
    0.1054
    0.1086
    0.1116
    0.1146
    0.1174
    0.1201
    0.1227
    0.1252
    0.1275
    0.1297
    0.1317
    0.1336
    0.1353
    0.1368
    0.1381
    0.1393
    0.1403
    0.1410
    0.1416
    0.1420
    0.1422
    0.1422
    0.1420
    0.1416
    0.1410
    0.1403
    0.1393
    0.1381
    0.1368
    0.1353
    0.1336
    0.1317
    0.1297
    0.1275
    0.1252
    0.1227
    0.1201
    0.1174
    0.1146
    0.1116
    0.1086
    0.1054
    0.1022
    0.0989
    0.0955
    0.0921
    0.0886
    0.0850
    0.0815
    0.0779
    0.0743
    0.0706
    0.0670
    0.0634
    0.0598
    0.0562
    0.0526
    0.0491
    0.0456
    0.0422
    0.0388
    0.0355
    0.0322
    0.0290
    0.0258
    0.0228
    0.0198
    0.0169
    0.0141
    0.0114
    0.0088
    0.0062
    0.0038
    0.0015
   -0.0007
   -0.0029
   -0.0049
   -0.0068
   -0.0086
   -0.0102
   -0.0118
   -0.0133
   -0.0146
   -0.0159
   -0.0170
   -0.0181
   -0.0190
   -0.0198
   -0.0205
   -0.0212
   -0.0217
   -0.0221
   -0.0225
   -0.0227
   -0.0229
   -0.0229
   -0.0229
   -0.0228
   -0.0227
   -0.0224
   -0.0221
   -0.0218
   -0.0213
   -0.0209
   -0.0203
   -0.0198
   -0.0191
   -0.0185
   -0.0177
   -0.0170
   -0.0162
   -0.0154
   -0.0146
   -0.0138
   -0.0129
   -0.0121
   -0.0112
   -0.0103
   -0.0095
   -0.0086
   -0.0077
   -0.0069
   -0.0060
   -0.0052
   -0.0044
   -0.0036
   -0.0028
   -0.0020
   -0.0013
   -0.0006
    0.0001
    0.0008
    0.0014
    0.0020
    0.0026
    0.0031
    0.0036
    0.0041
    0.0045
    0.0049
    0.0053
    0.0056
    0.0059
    0.0062
    0.0064
    0.0066
    0.0068
    0.0069
    0.0070
    0.0071
    0.0071
    0.0072
    0.0072
    0.0071
    0.0071
    0.0070
    0.0069
    0.0068
    0.0066
    0.0065
    0.0063
    0.0061
    0.0059
    0.0057
    0.0054
    0.0052
    0.0050
    0.0047
    0.0044
    0.0042
    0.0039
    0.0036
    0.0034
    0.0031
    0.0029
    0.0026
    0.0023
    0.0021
    0.0018
    0.0016
    0.0013
    0.0011
    0.0009
    0.0007
    0.0004
    0.0003
    0.0001
   -0.0001
   -0.0003
   -0.0005
   -0.0006
   -0.0007
   -0.0009
   -0.0010
   -0.0011
   -0.0012
   -0.0013
   -0.0014
   -0.0014
   -0.0015
   -0.0016
   -0.0016
   -0.0016
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0016
   -0.0016
   -0.0016
   -0.0015
   -0.0015
   -0.0015
   -0.0014
   -0.0014
   -0.0013
   -0.0013
   -0.0012
   -0.0012
   -0.0011
   -0.0011
   -0.0010
   -0.0009
   -0.0009
   -0.0008
   -0.0008
   -0.0007
   -0.0007
   -0.0006
   -0.0006
   -0.0005
   -0.0005
   -0.0004
   -0.0004
   -0.0003
   -0.0003
   -0.0002
   -0.0002
   -0.0001
   -0.0001
   -0.0000
         0];
 
rfPulses{3} = [
         0
   -0.0000
   -0.0001
   -0.0001
   -0.0002
   -0.0002
   -0.0003
   -0.0003
   -0.0004
   -0.0004
   -0.0005
   -0.0005
   -0.0006
   -0.0006
   -0.0007
   -0.0007
   -0.0008
   -0.0008
   -0.0009
   -0.0009
   -0.0010
   -0.0011
   -0.0011
   -0.0012
   -0.0012
   -0.0013
   -0.0013
   -0.0014
   -0.0014
   -0.0015
   -0.0015
   -0.0015
   -0.0016
   -0.0016
   -0.0016
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0016
   -0.0016
   -0.0016
   -0.0015
   -0.0014
   -0.0014
   -0.0013
   -0.0012
   -0.0011
   -0.0010
   -0.0009
   -0.0007
   -0.0006
   -0.0005
   -0.0003
   -0.0001
    0.0001
    0.0003
    0.0004
    0.0007
    0.0009
    0.0011
    0.0013
    0.0016
    0.0018
    0.0021
    0.0023
    0.0026
    0.0029
    0.0031
    0.0034
    0.0036
    0.0039
    0.0042
    0.0044
    0.0047
    0.0050
    0.0052
    0.0054
    0.0057
    0.0059
    0.0061
    0.0063
    0.0065
    0.0066
    0.0068
    0.0069
    0.0070
    0.0071
    0.0071
    0.0072
    0.0072
    0.0071
    0.0071
    0.0070
    0.0069
    0.0068
    0.0066
    0.0064
    0.0062
    0.0059
    0.0056
    0.0053
    0.0049
    0.0045
    0.0041
    0.0036
    0.0031
    0.0026
    0.0020
    0.0014
    0.0008
    0.0001
   -0.0006
   -0.0013
   -0.0020
   -0.0028
   -0.0036
   -0.0044
   -0.0052
   -0.0060
   -0.0069
   -0.0077
   -0.0086
   -0.0095
   -0.0103
   -0.0112
   -0.0121
   -0.0129
   -0.0138
   -0.0146
   -0.0154
   -0.0162
   -0.0170
   -0.0177
   -0.0185
   -0.0191
   -0.0198
   -0.0203
   -0.0209
   -0.0213
   -0.0218
   -0.0221
   -0.0224
   -0.0227
   -0.0228
   -0.0229
   -0.0229
   -0.0229
   -0.0227
   -0.0225
   -0.0221
   -0.0217
   -0.0212
   -0.0205
   -0.0198
   -0.0190
   -0.0181
   -0.0170
   -0.0159
   -0.0146
   -0.0133
   -0.0118
   -0.0102
   -0.0086
   -0.0068
   -0.0049
   -0.0029
   -0.0007
    0.0015
    0.0038
    0.0062
    0.0088
    0.0114
    0.0141
    0.0169
    0.0198
    0.0228
    0.0258
    0.0290
    0.0322
    0.0355
    0.0388
    0.0422
    0.0456
    0.0491
    0.0526
    0.0562
    0.0598
    0.0634
    0.0670
    0.0706
    0.0743
    0.0779
    0.0815
    0.0850
    0.0886
    0.0921
    0.0955
    0.0989
    0.1022
    0.1054
    0.1086
    0.1116
    0.1146
    0.1174
    0.1201
    0.1227
    0.1252
    0.1275
    0.1297
    0.1317
    0.1336
    0.1353
    0.1368
    0.1381
    0.1393
    0.1403
    0.1410
    0.1416
    0.1420
    0.1422
    0.1422
    0.1420
    0.1416
    0.1410
    0.1403
    0.1393
    0.1381
    0.1368
    0.1353
    0.1336
    0.1317
    0.1297
    0.1275
    0.1252
    0.1227
    0.1201
    0.1174
    0.1146
    0.1116
    0.1086
    0.1054
    0.1022
    0.0989
    0.0955
    0.0921
    0.0886
    0.0850
    0.0815
    0.0779
    0.0743
    0.0706
    0.0670
    0.0634
    0.0598
    0.0562
    0.0526
    0.0491
    0.0456
    0.0422
    0.0388
    0.0355
    0.0322
    0.0290
    0.0258
    0.0228
    0.0198
    0.0169
    0.0141
    0.0114
    0.0088
    0.0062
    0.0038
    0.0015
   -0.0007
   -0.0029
   -0.0049
   -0.0068
   -0.0086
   -0.0102
   -0.0118
   -0.0133
   -0.0146
   -0.0159
   -0.0170
   -0.0181
   -0.0190
   -0.0198
   -0.0205
   -0.0212
   -0.0217
   -0.0221
   -0.0225
   -0.0227
   -0.0229
   -0.0229
   -0.0229
   -0.0228
   -0.0227
   -0.0224
   -0.0221
   -0.0218
   -0.0213
   -0.0209
   -0.0203
   -0.0198
   -0.0191
   -0.0185
   -0.0177
   -0.0170
   -0.0162
   -0.0154
   -0.0146
   -0.0138
   -0.0129
   -0.0121
   -0.0112
   -0.0103
   -0.0095
   -0.0086
   -0.0077
   -0.0069
   -0.0060
   -0.0052
   -0.0044
   -0.0036
   -0.0028
   -0.0020
   -0.0013
   -0.0006
    0.0001
    0.0008
    0.0014
    0.0020
    0.0026
    0.0031
    0.0036
    0.0041
    0.0045
    0.0049
    0.0053
    0.0056
    0.0059
    0.0062
    0.0064
    0.0066
    0.0068
    0.0069
    0.0070
    0.0071
    0.0071
    0.0072
    0.0072
    0.0071
    0.0071
    0.0070
    0.0069
    0.0068
    0.0066
    0.0065
    0.0063
    0.0061
    0.0059
    0.0057
    0.0054
    0.0052
    0.0050
    0.0047
    0.0044
    0.0042
    0.0039
    0.0036
    0.0034
    0.0031
    0.0029
    0.0026
    0.0023
    0.0021
    0.0018
    0.0016
    0.0013
    0.0011
    0.0009
    0.0007
    0.0004
    0.0003
    0.0001
   -0.0001
   -0.0003
   -0.0005
   -0.0006
   -0.0007
   -0.0009
   -0.0010
   -0.0011
   -0.0012
   -0.0013
   -0.0014
   -0.0014
   -0.0015
   -0.0016
   -0.0016
   -0.0016
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0017
   -0.0016
   -0.0016
   -0.0016
   -0.0015
   -0.0015
   -0.0015
   -0.0014
   -0.0014
   -0.0013
   -0.0013
   -0.0012
   -0.0012
   -0.0011
   -0.0011
   -0.0010
   -0.0009
   -0.0009
   -0.0008
   -0.0008
   -0.0007
   -0.0007
   -0.0006
   -0.0006
   -0.0005
   -0.0005
   -0.0004
   -0.0004
   -0.0003
   -0.0003
   -0.0002
   -0.0002
   -0.0001
   -0.0001
   -0.0000
         0];
end
