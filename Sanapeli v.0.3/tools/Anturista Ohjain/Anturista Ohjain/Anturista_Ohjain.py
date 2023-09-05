import serial
import time
import vgamepad as vg
import os

def clean():
    for i in range(30): print("")

gamepad = vg.VX360Gamepad()

# Define scaling and clamping parameters
min_value = 0.0
max_value = 100.0
min_scaled = -32768
max_scaled = 32767
button_press_distance = 50


# Define the serial port and baud rate
serial_port = 'COM3'
baud_rate = 57600

# Create a serial connection
ser = serial.Serial(serial_port, baud_rate, timeout=1)  # Set a timeout of 1 second

nullValueTimes = 0
maxNullValueTimes = 100
def value_was_null():
    global nullValueTimes
    nullValueTimes += 1
    if nullValueTimes >= maxNullValueTimes:
        nullValueTimes = 0
        gamepad.left_joystick(x_value=0, y_value=max_scaled)

buttonFalseTimes = 0
maxButtonFalseTimes = 40
buttonPressed = False
def control_button(f):
    global buttonPressed
    if f > 0 and f < button_press_distance:
        gamepad.press_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A)  # press the A button
        if not buttonPressed: 
            clean()
            print(f"A (response: {f})")
            buttonPressed = True
    else:
        global buttonFalseTimes
        buttonFalseTimes += 1
        if buttonFalseTimes >= maxButtonFalseTimes:
            buttonFalseTimes = 0
            gamepad.release_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A)
            if buttonPressed: 
                clean()
                print(f"- (response: {f})")
                buttonPressed = False
    
    #if buttonPressed: print("button pressed: A")
    #else: print("button pressed: -")

try:
    while True:
        # Send the letter 'r' over the serial port
        ser.write(b'r')

    
        # Read the response from the device
        response = ser.read_until().decode('utf-8').strip()
        
        # Check if a response is received
        if response:
            
            #print(f'Response: {response}')
            f = min(float(response), 100)
            
            control_button(f)

            scaled_reading = ((f - min_value) / (max_value - min_value)) * (max_scaled - min_scaled) + min_scaled
            clamped_reading = min(max(scaled_reading, min_scaled), max_scaled)

            if f > 0:
                gamepad.left_joystick(x_value=0, y_value=int(clamped_reading))  # values between -32768 and 32767
            else: value_was_null()
            gamepad.update()  # send the updated state to the computer

except KeyboardInterrupt:
    # Handle Ctrl+C gracefully
    pass

finally:
    # Close the serial connection
    ser.close()
