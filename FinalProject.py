# -*- coding: utf-8 -*-
"""
Created on Mon Nov  5 16:25:13 2018

@author: jjhwang3
"""
import FrontPanel as ok
import time as time
dev = ok.okCFrontPanel()
import array as array
import numpy as np
import matplotlib.pyplot as pp

#%% 
# Next we open the device and program it

time.sleep(.01)

numValues = 307200;
length = numValues*4;
dataBuffer = bytearray(length)
data = array.array('i',(0 for i in range(0,numValues)))

TimeDelay = 2;#3000;
dev.SetWireInValue(0x14, TimeDelay );
dev.UpdateWireIns();

error_OpenBySerial = dev.OpenBySerial("")
#%%
error_ConfigureFpga = dev.ConfigureFPGA("top.bit");

#%% 

#matplotlib

# Display some diagnostic code
print("Open by Serial Error Code: " + str(error_OpenBySerial))
print("Configure FPGA Error Code: " + str(error_ConfigureFpga))


 
# It’s a good idea to check for errors here!!
 
# Send brief reset signal to initialize the FIFO.
 #%% 
# Address x12 corresponds to register address.
# Address x13 corresponds to register data.
# Address x10 corresponds to go signal for SPI
# Address x53 corresponds to go2 signal for frame reading



RegAddr = 69;
RegData = 9;
dev.SetWireInValue(0x12, RegAddr );
dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading From Register 69...")
time.sleep(.01);

dev.UpdateWireOuts();
reg69 = dev.GetWireOutValue(0x21);
print("Register 69 Data:" + str(reg69));

dev.SetWireInValue(0x11, 0xff); #Sets Control bit to 1 (WRITE)
dev.SetWireInValue(0x13, RegData); #Sets Data to be written.
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so multiple sequences are not asserted.
dev.UpdateWireIns(); 

print("Writing to Register 69...")
time.sleep(.01);

dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading from Registr 69...")
time.sleep(.01);

dev.UpdateWireOuts();
reg69 = dev.GetWireOutValue(0x21);
print("New Reg 69 Value: " + str(reg69));
if reg69 == 9:
    print("Register 69 is properly set to activate Clock Out\n")
    
    
#%%


RegAddr = 57;
RegData = 3;
dev.SetWireInValue(0x12, RegAddr );
dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading From Register 57...")
time.sleep(.01);

dev.UpdateWireOuts();
reg57 = dev.GetWireOutValue(0x21);
print("Register 57 Data:" + str(reg57));

dev.SetWireInValue(0x11, 0xff); #Sets Control bit to 1 (WRITE)
dev.SetWireInValue(0x13, RegData); #Sets Data to be written.
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so multiple sequences are not asserted.
dev.UpdateWireIns(); 

print("Writing to Register 57...")
time.sleep(.01);

dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading from Register 57...")
time.sleep(.01);

dev.UpdateWireOuts();
reg57 = dev.GetWireOutValue(0x21);
print("New Register 57 Value: " + str(reg57));

if reg57 == 3:
    print("Register 57 is properly set to Parallel CMOS Output\n")

#%%
    
    
RegAddr = 83;
RegData = 187;
dev.SetWireInValue(0x12, RegAddr );
dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading From Register 83...")
time.sleep(.01);

dev.UpdateWireOuts();
reg83 = dev.GetWireOutValue(0x21);
print("Register 83 Data:" + str(reg83));

dev.SetWireInValue(0x11, 0xff); #Sets Control bit to 1 (WRITE)
dev.SetWireInValue(0x13, RegData); #Sets Data to be written.
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so multiple sequences are not asserted.
dev.UpdateWireIns(); 

print("Writing to Register 83...")
time.sleep(.01);

dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading from Register 83...")
time.sleep(.01);

dev.UpdateWireOuts();
reg83 = dev.GetWireOutValue(0x21);
print("New Register 83 Value: " + str(reg83));

if reg83 == 187:
    print("Register 83 is properly set to Clock Speeds btwn 20.8 and 40 MHz \n")

#%%


RegAddr = 1;
RegData = 224;
dev.SetWireInValue(0x12, RegAddr );
dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading From Register 1...")
time.sleep(.01);

dev.UpdateWireOuts();
reg1 = dev.GetWireOutValue(0x21);
print("Register 1 Data:" + str(reg1));

dev.SetWireInValue(0x11, 0xff); #Sets Control bit to 1 (WRITE)
dev.SetWireInValue(0x13, RegData); #Sets Data to be written.
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so multiple sequences are not asserted.
dev.UpdateWireIns(); 

print("Writing to Register 1...")
time.sleep(.01);

dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading from Register 1...")
time.sleep(.01);

dev.UpdateWireOuts();
reg1 = dev.GetWireOutValue(0x21);
print("New Register 1 Value: " + str(reg1));

if reg1 == 224:
    print("Register 1 is properly set to read 480 Lines per frame \n")
    
#%%


RegAddr = 3;
RegData = 4;
dev.SetWireInValue(0x12, RegAddr );
dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading From Register 1...")
time.sleep(.01);

dev.UpdateWireOuts();
reg3 = dev.GetWireOutValue(0x21);
print("Register 1 Data:" + str(reg3));

dev.SetWireInValue(0x11, 0xff); #Sets Control bit to 1 (WRITE)
dev.SetWireInValue(0x13, RegData); #Sets Data to be written.
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so multiple sequences are not asserted.
dev.UpdateWireIns(); 

print("Writing to Register 3...")
time.sleep(.01);

dev.SetWireInValue(0x11, 0x00); #Sets Control bit to 0 (READ)
dev.SetWireInValue(0x10, 0xff); #Leaves Idle state on FPGA
dev.UpdateWireIns();
dev.SetWireInValue(0x10, 0x00); #returns the value to 0 so it doesn't start multiple operations
dev.UpdateWireIns(); 


print("Reading from Register 3...")
time.sleep(.01);

dev.UpdateWireOuts();
reg3 = dev.GetWireOutValue(0x21);
print("New Register 3 Value: " + str(reg3));

if reg3 == 4:
    print("Register 3 is properly set to start from line 4 of the CMOS sensor  \n")
    
    
#%%
btPipeAddr = 0xA4
blockSizeInBytes = 1024

#%%s
i = 1;
f=pp.figure()
#%%
while i<=250:
    dev.ActivateTriggerIn(0x53, 0x00);  
    errorMessage= dev.ReadFromBlockPipeOut(btPipeAddr , blockSizeInBytes , dataBuffer)
    #print(errorMessage)
    x=0;
    B1 = 4*x
    B2 = 4*x+1;
    B3 = 4*x+2;
    B4 = 4*x+3;
    data[x] = (((dataBuffer[B3]))<<16) | ((dataBuffer[B2])<<8) | ((dataBuffer[B1]));
        
    for x in range(1, numValues):
        #counter = dev.GetWireOutValue(0x20);
        #print(dataBuffer[x])
        #time.sleep(.1)
          
        B1 = 4*x
        B2 = 4*x+1;
        B3 = 4*x+2;
        B4 = 4*x+3;
        data[x] = (((dataBuffer[B3]))<<16) | ((dataBuffer[B2])<<8) | ((dataBuffer[B1]));
    y = np.reshape(data,(480,640));
    #print(i)
    pp.imshow(y, interpolation = None, cmap='gray')
    f.canvas.draw()
    f.canvas.flush_events();
    dev.UpdateWireOuts()
    dataa = dev.GetWireOutValue(0x22)
    datab = dev.GetWireOutValue(0x23)
    datac = dev.GetWireOutValue(0x24)
    print("the ack is: "+ bin(dataa)) #For each bit, 0= acknowledge, 1= notAckowledge
    print("the temperature is: %2.3f C" %(datac / 16.0)) #Rough esitmate of conversion is divide by 16
    print("") #newline
    datad = dev.GetWireOutValue(0x25)
    datae = dev.GetWireOutValue(0x26)
    dataf = dev.GetWireOutValue(0x27)
    print("the ack is: "+ bin(datad)) #For each bit, 0= acknowledge, 1= notAckowledge
    print("the Capacitance is: %2.3f C" %(dataf / 16.0)) #Rough esitmate of conversion is divide by 16
    i+=1
    #    dataBuffer[B3]>>2;
    #    dataBuffer[B4]>>2;
    #    dataBuffer[B1]>>2;
    #    dataBuffer[B2]>>2;
       
    #    if( data[x] - data[x-1]) != 1:
    #        print( 'Error at:')
    #        print(x)
    #        print(data[x])
    #        print(x-1)
    #        print(data[x-1])
        
#    pp.plot(range(numValues),data);
#    pp.xlabel('index');
#    pp.ylabel('value');
#    pp.show();
#    
#    
#    print(data[:257]);
#    print(data[307000:307199]);
    
###############

