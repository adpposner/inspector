function [G amplitudeUnit coherencePathway delays durations rephaseAreas rfOffsets rfPulses phaseShifts] = SP2_MARSS_PRESSSiemensTE30ms()

G = [3.6700         0         0
         0    1.4700         0
         0         0    1.4700];

amplitudeUnit = 'Hz';


phaseShifts = [0         0         0    2.5432];

coherencePathway = [-1     1    -1];

delays = [0.0048    0.0102    0.0042];

durations = [0.0024    0.0048    0.0048];

rephaseAreas = [-0.0044         0         0
         0         0         0
         0         0         0];

rfOffsets = [337.9558  337.9558  337.9558];

 
rfPulses{1} = 1.0e+02 *[
   0.0463 + 0.0000i
   0.0453 + 0.0000i
   0.0442 + 0.0000i
   0.0428 + 0.0000i
   0.0414 + 0.0000i
   0.0397 + 0.0000i
   0.0379 + 0.0000i
   0.0358 + 0.0000i
   0.0336 + 0.0000i
   0.0312 + 0.0000i
   0.0286 + 0.0000i
   0.0257 + 0.0000i
   0.0227 + 0.0000i
   0.0194 + 0.0000i
   0.0159 + 0.0000i
   0.0121 + 0.0000i
   0.0081 + 0.0000i
   0.0039 + 0.0000i
  -0.0005 - 0.0000i
  -0.0053 - 0.0000i
  -0.0102 - 0.0000i
  -0.0153 - 0.0000i
  -0.0207 - 0.0000i
  -0.0263 - 0.0000i
  -0.0321 - 0.0000i
  -0.0380 - 0.0000i
  -0.0441 - 0.0000i
  -0.0503 - 0.0000i
  -0.0567 - 0.0000i
  -0.0631 - 0.0000i
  -0.0696 - 0.0000i
  -0.0761 - 0.0000i
  -0.0826 - 0.0000i
  -0.0890 - 0.0000i
  -0.0954 - 0.0000i
  -0.1015 - 0.0000i
  -0.1075 - 0.0000i
  -0.1132 - 0.0000i
  -0.1187 - 0.0000i
  -0.1238 - 0.0000i
  -0.1284 - 0.0000i
  -0.1326 - 0.0000i
  -0.1363 - 0.0000i
  -0.1394 - 0.0000i
  -0.1419 - 0.0000i
  -0.1436 - 0.0000i
  -0.1446 - 0.0000i
  -0.1448 - 0.0000i
  -0.1442 - 0.0000i
  -0.1426 - 0.0000i
  -0.1401 - 0.0000i
  -0.1366 - 0.0000i
  -0.1320 - 0.0000i
  -0.1264 - 0.0000i
  -0.1196 - 0.0000i
  -0.1118 - 0.0000i
  -0.1027 - 0.0000i
  -0.0926 - 0.0000i
  -0.0812 - 0.0000i
  -0.0687 - 0.0000i
  -0.0550 - 0.0000i
  -0.0402 - 0.0000i
  -0.0243 - 0.0000i
  -0.0073 - 0.0000i
   0.0108 + 0.0000i
   0.0298 + 0.0000i
   0.0497 + 0.0000i
   0.0705 + 0.0000i
   0.0921 + 0.0000i
   0.1143 + 0.0000i
   0.1371 + 0.0000i
   0.1604 + 0.0000i
   0.1841 + 0.0000i
   0.2079 + 0.0000i
   0.2319 + 0.0000i
   0.2559 + 0.0000i
   0.2797 + 0.0000i
   0.3031 + 0.0000i
   0.3261 + 0.0000i
   0.3484 + 0.0000i
   0.3699 + 0.0000i
   0.3905 + 0.0000i
   0.4099 + 0.0000i
   0.4279 + 0.0000i
   0.4445 + 0.0000i
   0.4594 + 0.0000i
   0.4725 + 0.0000i
   0.4836 + 0.0000i
   0.4926 + 0.0000i
   0.4992 + 0.0000i
   0.5033 + 0.0000i
   0.5048 + 0.0000i
   0.5036 + 0.0000i
   0.4996 + 0.0000i
   0.4925 + 0.0000i
   0.4823 + 0.0000i
   0.4690 + 0.0000i
   0.4525 + 0.0000i
   0.4326 + 0.0000i
   0.4093 + 0.0000i
   0.3827 + 0.0000i
   0.3528 + 0.0000i
   0.3194 + 0.0000i
   0.2827 + 0.0000i
   0.2427 + 0.0000i
   0.1995 + 0.0000i
   0.1532 + 0.0000i
   0.1038 + 0.0000i
   0.0516 + 0.0000i
  -0.0034 - 0.0000i
  -0.0609 - 0.0000i
  -0.1208 - 0.0000i
  -0.1828 - 0.0000i
  -0.2467 - 0.0000i
  -0.3122 - 0.0000i
  -0.3790 - 0.0000i
  -0.4469 - 0.0000i
  -0.5155 - 0.0000i
  -0.5845 - 0.0000i
  -0.6535 - 0.0000i
  -0.7222 - 0.0000i
  -0.7902 - 0.0000i
  -0.8571 - 0.0000i
  -0.9224 - 0.0000i
  -0.9858 - 0.0000i
  -1.0469 - 0.0000i
  -1.1052 - 0.0000i
  -1.1602 - 0.0000i
  -1.2116 - 0.0000i
  -1.2590 - 0.0000i
  -1.3018 - 0.0000i
  -1.3396 - 0.0000i
  -1.3721 - 0.0000i
  -1.3988 - 0.0000i
  -1.4193 - 0.0000i
  -1.4332 - 0.0000i
  -1.4401 - 0.0000i
  -1.4397 - 0.0000i
  -1.4317 - 0.0000i
  -1.4156 - 0.0000i
  -1.3912 - 0.0000i
  -1.3582 - 0.0000i
  -1.3164 - 0.0000i
  -1.2656 - 0.0000i
  -1.2055 - 0.0000i
  -1.1359 - 0.0000i
  -1.0569 - 0.0000i
  -0.9681 - 0.0000i
  -0.8697 - 0.0000i
  -0.7615 - 0.0000i
  -0.6437 - 0.0000i
  -0.5161 - 0.0000i
  -0.3789 - 0.0000i
  -0.2323 - 0.0000i
  -0.0764 - 0.0000i
   0.0886 + 0.0000i
   0.2625 + 0.0000i
   0.4450 + 0.0000i
   0.6357 + 0.0000i
   0.8344 + 0.0000i
   1.0406 + 0.0000i
   1.2538 + 0.0000i
   1.4737 + 0.0000i
   1.6998 + 0.0000i
   1.9314 + 0.0000i
   2.1681 + 0.0000i
   2.4093 + 0.0000i
   2.6544 + 0.0000i
   2.9026 + 0.0000i
   3.1535 + 0.0000i
   3.4062 + 0.0000i
   3.6601 + 0.0000i
   3.9146 + 0.0000i
   4.1688 + 0.0000i
   4.4220 + 0.0000i
   4.6736 + 0.0000i
   4.9227 + 0.0000i
   5.1687 + 0.0000i
   5.4107 + 0.0000i
   5.6481 + 0.0000i
   5.8801 + 0.0000i
   6.1060 + 0.0000i
   6.3251 + 0.0000i
   6.5367 + 0.0000i
   6.7402 + 0.0000i
   6.9348 + 0.0000i
   7.1201 + 0.0000i
   7.2954 + 0.0000i
   7.4600 + 0.0000i
   7.6136 + 0.0000i
   7.7555 + 0.0000i
   7.8854 + 0.0000i
   8.0028 + 0.0000i
   8.1073 + 0.0000i
   8.1986 + 0.0000i
   8.2763 + 0.0000i
   8.3403 + 0.0000i
   8.3903 + 0.0000i
   8.4261 + 0.0000i
   8.4476 + 0.0000i
   8.4548 + 0.0000i
   8.4476 + 0.0000i
   8.4261 + 0.0000i
   8.3903 + 0.0000i
   8.3403 + 0.0000i
   8.2763 + 0.0000i
   8.1986 + 0.0000i
   8.1073 + 0.0000i
   8.0028 + 0.0000i
   7.8854 + 0.0000i
   7.7555 + 0.0000i
   7.6136 + 0.0000i
   7.4600 + 0.0000i
   7.2954 + 0.0000i
   7.1201 + 0.0000i
   6.9348 + 0.0000i
   6.7402 + 0.0000i
   6.5367 + 0.0000i
   6.3251 + 0.0000i
   6.1060 + 0.0000i
   5.8801 + 0.0000i
   5.6481 + 0.0000i
   5.4107 + 0.0000i
   5.1687 + 0.0000i
   4.9227 + 0.0000i
   4.6736 + 0.0000i
   4.4220 + 0.0000i
   4.1688 + 0.0000i
   3.9146 + 0.0000i
   3.6601 + 0.0000i
   3.4062 + 0.0000i
   3.1535 + 0.0000i
   2.9026 + 0.0000i
   2.6544 + 0.0000i
   2.4093 + 0.0000i
   2.1681 + 0.0000i
   1.9314 + 0.0000i
   1.6998 + 0.0000i
   1.4737 + 0.0000i
   1.2538 + 0.0000i
   1.0406 + 0.0000i
   0.8344 + 0.0000i
   0.6357 + 0.0000i
   0.4450 + 0.0000i
   0.2625 + 0.0000i
   0.0886 + 0.0000i
  -0.0764 - 0.0000i
  -0.2323 - 0.0000i
  -0.3789 - 0.0000i
  -0.5161 - 0.0000i
  -0.6437 - 0.0000i
  -0.7615 - 0.0000i
  -0.8697 - 0.0000i
  -0.9681 - 0.0000i
  -1.0569 - 0.0000i
  -1.1359 - 0.0000i
  -1.2055 - 0.0000i
  -1.2656 - 0.0000i
  -1.3164 - 0.0000i
  -1.3582 - 0.0000i
  -1.3912 - 0.0000i
  -1.4156 - 0.0000i
  -1.4317 - 0.0000i
  -1.4397 - 0.0000i
  -1.4401 - 0.0000i
  -1.4332 - 0.0000i
  -1.4193 - 0.0000i
  -1.3988 - 0.0000i
  -1.3721 - 0.0000i
  -1.3396 - 0.0000i
  -1.3018 - 0.0000i
  -1.2590 - 0.0000i
  -1.2116 - 0.0000i
  -1.1602 - 0.0000i
  -1.1052 - 0.0000i
  -1.0469 - 0.0000i
  -0.9858 - 0.0000i
  -0.9224 - 0.0000i
  -0.8571 - 0.0000i
  -0.7902 - 0.0000i
  -0.7222 - 0.0000i
  -0.6535 - 0.0000i
  -0.5845 - 0.0000i
  -0.5155 - 0.0000i
  -0.4469 - 0.0000i
  -0.3790 - 0.0000i
  -0.3122 - 0.0000i
  -0.2467 - 0.0000i
  -0.1828 - 0.0000i
  -0.1208 - 0.0000i
  -0.0609 - 0.0000i
  -0.0034 - 0.0000i
   0.0516 + 0.0000i
   0.1038 + 0.0000i
   0.1532 + 0.0000i
   0.1995 + 0.0000i
   0.2427 + 0.0000i
   0.2827 + 0.0000i
   0.3194 + 0.0000i
   0.3528 + 0.0000i
   0.3827 + 0.0000i
   0.4093 + 0.0000i
   0.4326 + 0.0000i
   0.4525 + 0.0000i
   0.4690 + 0.0000i
   0.4823 + 0.0000i
   0.4925 + 0.0000i
   0.4996 + 0.0000i
   0.5036 + 0.0000i
   0.5048 + 0.0000i
   0.5033 + 0.0000i
   0.4992 + 0.0000i
   0.4926 + 0.0000i
   0.4836 + 0.0000i
   0.4725 + 0.0000i
   0.4594 + 0.0000i
   0.4445 + 0.0000i
   0.4279 + 0.0000i
   0.4099 + 0.0000i
   0.3905 + 0.0000i
   0.3699 + 0.0000i
   0.3484 + 0.0000i
   0.3261 + 0.0000i
   0.3031 + 0.0000i
   0.2797 + 0.0000i
   0.2559 + 0.0000i
   0.2319 + 0.0000i
   0.2079 + 0.0000i
   0.1841 + 0.0000i
   0.1604 + 0.0000i
   0.1371 + 0.0000i
   0.1143 + 0.0000i
   0.0921 + 0.0000i
   0.0705 + 0.0000i
   0.0497 + 0.0000i
   0.0298 + 0.0000i
   0.0108 + 0.0000i
  -0.0073 - 0.0000i
  -0.0243 - 0.0000i
  -0.0402 - 0.0000i
  -0.0550 - 0.0000i
  -0.0687 - 0.0000i
  -0.0812 - 0.0000i
  -0.0926 - 0.0000i
  -0.1027 - 0.0000i
  -0.1118 - 0.0000i
  -0.1196 - 0.0000i
  -0.1264 - 0.0000i
  -0.1320 - 0.0000i
  -0.1366 - 0.0000i
  -0.1401 - 0.0000i
  -0.1426 - 0.0000i
  -0.1442 - 0.0000i
  -0.1448 - 0.0000i
  -0.1446 - 0.0000i
  -0.1436 - 0.0000i
  -0.1419 - 0.0000i
  -0.1394 - 0.0000i
  -0.1363 - 0.0000i
  -0.1326 - 0.0000i
  -0.1284 - 0.0000i
  -0.1238 - 0.0000i
  -0.1187 - 0.0000i
  -0.1132 - 0.0000i
  -0.1075 - 0.0000i
  -0.1015 - 0.0000i
  -0.0954 - 0.0000i
  -0.0890 - 0.0000i
  -0.0826 - 0.0000i
  -0.0761 - 0.0000i
  -0.0696 - 0.0000i
  -0.0631 - 0.0000i
  -0.0567 - 0.0000i
  -0.0503 - 0.0000i
  -0.0441 - 0.0000i
  -0.0380 - 0.0000i
  -0.0321 - 0.0000i
  -0.0263 - 0.0000i
  -0.0207 - 0.0000i
  -0.0153 - 0.0000i
  -0.0102 - 0.0000i
  -0.0053 - 0.0000i
  -0.0005 - 0.0000i
   0.0039 + 0.0000i
   0.0081 + 0.0000i
   0.0121 + 0.0000i
   0.0159 + 0.0000i
   0.0194 + 0.0000i
   0.0227 + 0.0000i
   0.0257 + 0.0000i
   0.0286 + 0.0000i
   0.0312 + 0.0000i
   0.0336 + 0.0000i
   0.0358 + 0.0000i
   0.0379 + 0.0000i
   0.0397 + 0.0000i
   0.0414 + 0.0000i
   0.0428 + 0.0000i
   0.0442 + 0.0000i
   0.0453 + 0.0000i];

 
rfPulses{2} = 1.0e+03 * [
   -0.0316
   -0.0317
   -0.0319
   -0.0324
   -0.0330
   -0.0337
   -0.0344
   -0.0352
   -0.0360
   -0.0367
   -0.0373
   -0.0378
   -0.0381
   -0.0382
   -0.0382
   -0.0380
   -0.0375
   -0.0369
   -0.0362
   -0.0353
   -0.0344
   -0.0333
   -0.0321
   -0.0309
   -0.0297
   -0.0284
   -0.0270
   -0.0256
   -0.0241
   -0.0226
   -0.0209
   -0.0192
   -0.0173
   -0.0153
   -0.0132
   -0.0109
   -0.0085
   -0.0059
   -0.0032
   -0.0003
    0.0026
    0.0057
    0.0089
    0.0121
    0.0154
    0.0187
    0.0221
    0.0255
    0.0290
    0.0324
    0.0359
    0.0394
    0.0429
    0.0463
    0.0498
    0.0533
    0.0567
    0.0600
    0.0634
    0.0666
    0.0697
    0.0728
    0.0756
    0.0784
    0.0809
    0.0833
    0.0854
    0.0873
    0.0890
    0.0905
    0.0917
    0.0926
    0.0933
    0.0937
    0.0939
    0.0938
    0.0934
    0.0928
    0.0918
    0.0906
    0.0891
    0.0873
    0.0852
    0.0827
    0.0800
    0.0769
    0.0735
    0.0698
    0.0657
    0.0614
    0.0567
    0.0517
    0.0465
    0.0409
    0.0351
    0.0291
    0.0228
    0.0163
    0.0095
    0.0026
   -0.0045
   -0.0118
   -0.0192
   -0.0268
   -0.0346
   -0.0425
   -0.0504
   -0.0585
   -0.0666
   -0.0748
   -0.0830
   -0.0913
   -0.0994
   -0.1076
   -0.1156
   -0.1235
   -0.1313
   -0.1389
   -0.1464
   -0.1536
   -0.1605
   -0.1672
   -0.1735
   -0.1796
   -0.1853
   -0.1906
   -0.1955
   -0.1999
   -0.2039
   -0.2074
   -0.2104
   -0.2129
   -0.2147
   -0.2159
   -0.2165
   -0.2164
   -0.2156
   -0.2140
   -0.2116
   -0.2084
   -0.2044
   -0.1996
   -0.1938
   -0.1871
   -0.1795
   -0.1710
   -0.1615
   -0.1510
   -0.1395
   -0.1270
   -0.1134
   -0.0989
   -0.0832
   -0.0664
   -0.0486
   -0.0297
   -0.0097
    0.0115
    0.0337
    0.0571
    0.0815
    0.1070
    0.1336
    0.1612
    0.1898
    0.2193
    0.2498
    0.2812
    0.3133
    0.3463
    0.3799
    0.4142
    0.4491
    0.4844
    0.5201
    0.5561
    0.5922
    0.6285
    0.6646
    0.7006
    0.7362
    0.7714
    0.8058
    0.8395
    0.8722
    0.9037
    0.9339
    0.9626
    0.9896
    1.0147
    1.0378
    1.0588
    1.0775
    1.0937
    1.1074
    1.1184
    1.1267
    1.1323
    1.1350
    1.1349
    1.1319
    1.1262
    1.1176
    1.1064
    1.0925
    1.0761
    1.0573
    1.0362
    1.0130
    0.9877
    0.9606
    0.9319
    0.9016
    0.8701
    0.8373
    0.8036
    0.7691
    0.7340
    0.6983
    0.6624
    0.6262
    0.5900
    0.5539
    0.5179
    0.4823
    0.4470
    0.4123
    0.3780
    0.3445
    0.3116
    0.2795
    0.2482
    0.2178
    0.1883
    0.1598
    0.1323
    0.1057
    0.0802
    0.0558
    0.0325
    0.0102
   -0.0109
   -0.0310
   -0.0499
   -0.0677
   -0.0845
   -0.1001
   -0.1147
   -0.1283
   -0.1408
   -0.1523
   -0.1628
   -0.1723
   -0.1808
   -0.1885
   -0.1951
   -0.2009
   -0.2058
   -0.2099
   -0.2131
   -0.2155
   -0.2171
   -0.2180
   -0.2181
   -0.2176
   -0.2164
   -0.2145
   -0.2121
   -0.2091
   -0.2055
   -0.2015
   -0.1970
   -0.1921
   -0.1867
   -0.1810
   -0.1749
   -0.1685
   -0.1617
   -0.1548
   -0.1475
   -0.1400
   -0.1324
   -0.1245
   -0.1165
   -0.1084
   -0.1002
   -0.0919
   -0.0836
   -0.0753
   -0.0669
   -0.0587
   -0.0505
   -0.0423
   -0.0343
   -0.0264
   -0.0187
   -0.0111
   -0.0037
    0.0035
    0.0106
    0.0174
    0.0240
    0.0304
    0.0365
    0.0424
    0.0481
    0.0534
    0.0585
    0.0633
    0.0678
    0.0719
    0.0758
    0.0793
    0.0825
    0.0853
    0.0878
    0.0900
    0.0919
    0.0934
    0.0947
    0.0956
    0.0962
    0.0966
    0.0967
    0.0965
    0.0960
    0.0953
    0.0943
    0.0931
    0.0916
    0.0899
    0.0879
    0.0858
    0.0834
    0.0808
    0.0780
    0.0750
    0.0719
    0.0686
    0.0653
    0.0618
    0.0583
    0.0547
    0.0510
    0.0474
    0.0437
    0.0401
    0.0364
    0.0328
    0.0292
    0.0256
    0.0221
    0.0186
    0.0151
    0.0117
    0.0083
    0.0050
    0.0018
   -0.0014
   -0.0044
   -0.0073
   -0.0101
   -0.0128
   -0.0153
   -0.0177
   -0.0199
   -0.0219
   -0.0239
   -0.0257
   -0.0273
   -0.0289
   -0.0304
   -0.0318
   -0.0331
   -0.0344
   -0.0356
   -0.0368
   -0.0379
   -0.0389
   -0.0399
   -0.0407
   -0.0414
   -0.0420
   -0.0424
   -0.0426
   -0.0426
   -0.0424
   -0.0420
   -0.0414
   -0.0407
   -0.0398
   -0.0387
   -0.0377
   -0.0365
   -0.0354
   -0.0344
   -0.0335
   -0.0328
   -0.0322
   -0.0318];
 
rfPulses{3} = 1.0e+03 *[
   -0.0316
   -0.0317
   -0.0319
   -0.0324
   -0.0330
   -0.0337
   -0.0344
   -0.0352
   -0.0360
   -0.0367
   -0.0373
   -0.0378
   -0.0381
   -0.0382
   -0.0382
   -0.0380
   -0.0375
   -0.0369
   -0.0362
   -0.0353
   -0.0344
   -0.0333
   -0.0321
   -0.0309
   -0.0297
   -0.0284
   -0.0270
   -0.0256
   -0.0241
   -0.0226
   -0.0209
   -0.0192
   -0.0173
   -0.0153
   -0.0132
   -0.0109
   -0.0085
   -0.0059
   -0.0032
   -0.0003
    0.0026
    0.0057
    0.0089
    0.0121
    0.0154
    0.0187
    0.0221
    0.0255
    0.0290
    0.0324
    0.0359
    0.0394
    0.0429
    0.0463
    0.0498
    0.0533
    0.0567
    0.0600
    0.0634
    0.0666
    0.0697
    0.0728
    0.0756
    0.0784
    0.0809
    0.0833
    0.0854
    0.0873
    0.0890
    0.0905
    0.0917
    0.0926
    0.0933
    0.0937
    0.0939
    0.0938
    0.0934
    0.0928
    0.0918
    0.0906
    0.0891
    0.0873
    0.0852
    0.0827
    0.0800
    0.0769
    0.0735
    0.0698
    0.0657
    0.0614
    0.0567
    0.0517
    0.0465
    0.0409
    0.0351
    0.0291
    0.0228
    0.0163
    0.0095
    0.0026
   -0.0045
   -0.0118
   -0.0192
   -0.0268
   -0.0346
   -0.0425
   -0.0504
   -0.0585
   -0.0666
   -0.0748
   -0.0830
   -0.0913
   -0.0994
   -0.1076
   -0.1156
   -0.1235
   -0.1313
   -0.1389
   -0.1464
   -0.1536
   -0.1605
   -0.1672
   -0.1735
   -0.1796
   -0.1853
   -0.1906
   -0.1955
   -0.1999
   -0.2039
   -0.2074
   -0.2104
   -0.2129
   -0.2147
   -0.2159
   -0.2165
   -0.2164
   -0.2156
   -0.2140
   -0.2116
   -0.2084
   -0.2044
   -0.1996
   -0.1938
   -0.1871
   -0.1795
   -0.1710
   -0.1615
   -0.1510
   -0.1395
   -0.1270
   -0.1134
   -0.0989
   -0.0832
   -0.0664
   -0.0486
   -0.0297
   -0.0097
    0.0115
    0.0337
    0.0571
    0.0815
    0.1070
    0.1336
    0.1612
    0.1898
    0.2193
    0.2498
    0.2812
    0.3133
    0.3463
    0.3799
    0.4142
    0.4491
    0.4844
    0.5201
    0.5561
    0.5922
    0.6285
    0.6646
    0.7006
    0.7362
    0.7714
    0.8058
    0.8395
    0.8722
    0.9037
    0.9339
    0.9626
    0.9896
    1.0147
    1.0378
    1.0588
    1.0775
    1.0937
    1.1074
    1.1184
    1.1267
    1.1323
    1.1350
    1.1349
    1.1319
    1.1262
    1.1176
    1.1064
    1.0925
    1.0761
    1.0573
    1.0362
    1.0130
    0.9877
    0.9606
    0.9319
    0.9016
    0.8701
    0.8373
    0.8036
    0.7691
    0.7340
    0.6983
    0.6624
    0.6262
    0.5900
    0.5539
    0.5179
    0.4823
    0.4470
    0.4123
    0.3780
    0.3445
    0.3116
    0.2795
    0.2482
    0.2178
    0.1883
    0.1598
    0.1323
    0.1057
    0.0802
    0.0558
    0.0325
    0.0102
   -0.0109
   -0.0310
   -0.0499
   -0.0677
   -0.0845
   -0.1001
   -0.1147
   -0.1283
   -0.1408
   -0.1523
   -0.1628
   -0.1723
   -0.1808
   -0.1885
   -0.1951
   -0.2009
   -0.2058
   -0.2099
   -0.2131
   -0.2155
   -0.2171
   -0.2180
   -0.2181
   -0.2176
   -0.2164
   -0.2145
   -0.2121
   -0.2091
   -0.2055
   -0.2015
   -0.1970
   -0.1921
   -0.1867
   -0.1810
   -0.1749
   -0.1685
   -0.1617
   -0.1548
   -0.1475
   -0.1400
   -0.1324
   -0.1245
   -0.1165
   -0.1084
   -0.1002
   -0.0919
   -0.0836
   -0.0753
   -0.0669
   -0.0587
   -0.0505
   -0.0423
   -0.0343
   -0.0264
   -0.0187
   -0.0111
   -0.0037
    0.0035
    0.0106
    0.0174
    0.0240
    0.0304
    0.0365
    0.0424
    0.0481
    0.0534
    0.0585
    0.0633
    0.0678
    0.0719
    0.0758
    0.0793
    0.0825
    0.0853
    0.0878
    0.0900
    0.0919
    0.0934
    0.0947
    0.0956
    0.0962
    0.0966
    0.0967
    0.0965
    0.0960
    0.0953
    0.0943
    0.0931
    0.0916
    0.0899
    0.0879
    0.0858
    0.0834
    0.0808
    0.0780
    0.0750
    0.0719
    0.0686
    0.0653
    0.0618
    0.0583
    0.0547
    0.0510
    0.0474
    0.0437
    0.0401
    0.0364
    0.0328
    0.0292
    0.0256
    0.0221
    0.0186
    0.0151
    0.0117
    0.0083
    0.0050
    0.0018
   -0.0014
   -0.0044
   -0.0073
   -0.0101
   -0.0128
   -0.0153
   -0.0177
   -0.0199
   -0.0219
   -0.0239
   -0.0257
   -0.0273
   -0.0289
   -0.0304
   -0.0318
   -0.0331
   -0.0344
   -0.0356
   -0.0368
   -0.0379
   -0.0389
   -0.0399
   -0.0407
   -0.0414
   -0.0420
   -0.0424
   -0.0426
   -0.0426
   -0.0424
   -0.0420
   -0.0414
   -0.0407
   -0.0398
   -0.0387
   -0.0377
   -0.0365
   -0.0354
   -0.0344
   -0.0335
   -0.0328
   -0.0322
   -0.0318];
