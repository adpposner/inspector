function [G amplitudeUnit coherencePathway delays durations rephaseAreas rfOffsets rfPulses phaseShifts] = SP2_MARSS_STEAMSiemensTE20msTM10ms()

G = [5.7000         0         0
         0    5.7000         0
         0         0    5.7000];

amplitudeUnit = 'Hz';

coherencePathway = [1     0    -1];

delays = [0.0074    0.0074    0.0087];

durations = [0.0026    0.0026    0.0026];
    
phaseShifts = [0         0         0    5.9032];

rephaseAreas = [-0.0074   -0.0074         0
         0         0         0
         0         0   -0.0074];

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
 
rfPulses{2} = 1.0e+02 * [
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
 
rfPulses{3} =  1.0e+02 * [
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
end
