# verstraten_model
model of 1 joint of quasi direct drive actuated joint based on https://doi.org/10.1016/j.mechatronics.2015.07.004

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=AAImrit/verstraten_model)

## Folder & Modules:
### Data
Biomechanics data is not in repo. Dowload the data from https://springernature.figshare.com/collections/_/5175254 and place in the Data folder

### Scripts
***Main Modules:***
- **getOutputShaft.m**: get values related to the output shaft of the actautor (Tload, theta_dot, theta_double_dot, theta)
- **getMotorValues.m**: get values related to the motor (Tm, I, V, thetam_dot)
- **getEfficiency.m**: calculated efficiency of the motor

***Supplementaty Modules:***
- **getBioData.m**: a module to extract the biomechanics data we want
- **evaluateSymbolic.m**: evaluates a set of symbolic function over desired range
- **numericDiff.m**: does numeric differentition
- **txtToDict.m**: used to turn the constant file into a dictionary

***Plotting File:***
- **test.m**: use to make time domain plots of efficiency and all other variables for specific actuator motion (inputs are time based functions)
- **testEffMap.m**: use to make a torque-velocity efficiency heatmap trying to replicate a benchtop testing of an actuator