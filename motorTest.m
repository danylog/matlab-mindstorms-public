brickObj = EV3();
brickObj.connect('usb');

brickObj.beep();

xAxisMotor = brickObj.motorA;
yAxisMotor = brickObj.motorD;
penMotor = brickObj.motorC;

% Touch sensor on X axis stopper (sensor 1)
tastsensor = brickObj.sensor1;
tastsensor.mode = DeviceMode.Touch.Pushed;

% Light sensor on Y axis for paper detection (sensor 2)
lichtsensor = brickObj.sensor2;
lichtsensor.mode = DeviceMode.Color.Reflect;

% Motor configuration
xAxisMotor.limitMode = 'Tacho';
xAxisMotor.brakeMode = 'Brake';
yAxisMotor.limitMode = 'Tacho';
yAxisMotor.brakeMode = 'Brake';
penMotor.limitMode = 'Tacho';
penMotor.brakeMode = 'Brake';

% Homing speed (negative = reversed direction to reach bottom-right)
homingSpeed = 30;

%% HOMING ROUTINE - Go to starting position (bottom-right)
disp('Starting homing routine...');

% Step 1: Move X axis until touch sensor is pressed (stopper reached)
disp('Homing X axis (moving to right stopper)...');
xAxisMotor.limitValue = 0;    % 0 = run indefinitely
xAxisMotor.power = -homingSpeed;  % Reversed: negative = move right
xAxisMotor.start();

while tastsensor.value == 0
    pause(0.05);
end

xAxisMotor.stop();
xAxisMotor.resetTachoCount();
disp('X axis homed!');

% Step 2: Move Y axis until light sensor detects no paper (< 30)
disp('Homing Y axis (moving to paper edge)...');
yAxisMotor.limitValue = 0;    % 0 = run indefinitely
yAxisMotor.power = -homingSpeed;  % Reversed: negative = move down
yAxisMotor.start();

while lichtsensor.value >= 30
    pause(0.05);
end

yAxisMotor.stop();
yAxisMotor.resetTachoCount();
disp('Y axis homed!');

disp('Homing complete! Starting position set (bottom-right).');
brickObj.beep();

% Now motors are at (0,0) = bottom-right
% Positive X movement = left (reversed)
% Positive Y movement = up (reversed)

%% Test pen motor
penMotor.power = -20;
penMotor.limitValue = 180;
penMotor.start();
penMotor.waitFor();
penMotor.stop();

brickObj.disconnect();

