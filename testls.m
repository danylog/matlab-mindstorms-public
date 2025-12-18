brickObj = EV3();
brickObj.connect('usb');

xAxisMotor = brickObj.motorA;
yAxisMotor = brickObj.motorB;

xAxisMotor.power = 50;
xAxisMotor.limitMode = 'Tacho';
xAxisMotor.brakeMode = 'Brake';

yAxisMotor.power = 50;
yAxisMotor.limitMode = 'Tacho';
yAxisMotor.brakeMode = 'Brake';

xDegreesPerCm = 37.7952755906; % pixels per inch for x-axis
yDegreesPerCm = 37.7952755906; % pixels per inch for y-axis

