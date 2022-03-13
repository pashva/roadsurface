# Road Surface Analyzer

![alt text](https://img.shields.io/badge/Framework-Flutter-9cf) ![alt text](https://img.shields.io/badge/Language-Dart-blue) ![alt text](https://img.shields.io/badge/Cloud-Firebase-yellow)  ![alt text](https://img.shields.io/badge/Cloud-Google%20Cloud%20Platform-informational) 

This Flutter App records accelerometer data during cycling and uses this data to automatically predict the surface type of the driven route.
The processing of the accelerometer data and the surface prediction is accomplished with [LG04QS_Cycling](https://github.com/NilsHMeier/LG04QS_Cycling) integrated into the App as a Google Cloud Function.

This App is part of a university project called "Ground recognition via machine Learning", whose members are [NilsHMeier](https://github.com/NilsHMeier), [Lennart401](https://github.com/Lennart401) and [niggels](https://github.com/niggels).

## How to download

For Android the App can be downloaded as an .apk file here: [Download Road Surface Analyzer from Google Drive](https://drive.google.com/file/d/1YKhcKSShJuJNiPi0LxwDXpNms1kuC1By/view?usp=sharing) 

## How to use

| Screenshot from App | Description |
| --- | --- |
| <img src="https://imgur.com/KqbKV21.jpg" width="800"> | Start recording accelerometer data by clicking on 'Start Cycling'. After that, put your smartphone in the side pocket of your trousers (upright position and screen to the outside) and start cycling. You need to record for at least 30 seconds. |
| <img src="https://imgur.com/3DffOJH.jpg" width="800"> | When done cycling, click on 'Stop Cycling'. |
| <img src="https://imgur.com/j11KK8R.jpg" width="800"> | Then, choose your suspension type. The suspension type reflects the suspension strength of your bicycle. Next, you can decide whether you want to see line charts of your accelerometer data and start the surface prediction of your driven route afterwards or go directly to the surface prediction and skip the charts. |
| <img src="https://imgur.com/Efp3GBL.png" width="800"> | This would be the screen if you choose the first option. Have a look at the charts and thereafter click on 'Predict Road Surface'. |
| <img src="https://imgur.com/axBb3S5.jpg" width="800"> | On the last page, you will see your driven route and the corresponding surface type prediction. Please keep in mind that you need to restart the App after this screen in order to do another accelerometer data recording and surface prediction. |
