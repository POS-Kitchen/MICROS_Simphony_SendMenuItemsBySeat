# ORACLE Hospitality Simphony  
# Recall Items by SEAT and print them during Rush Order on Kitchen Printer, KDS are not Supported.
  
This ISL Script is designed as a workaround for the course function.  
Enables to print the MenuItems ordered by seat to print on a order device.  
Allows the waiter to jump back and forth between courses during the ordering process by simply changing the seat.  
The Touch Edit Seat view can be used before submitting the order.  

## System requirements
Hardware  
Windows 10 or higher based workstations  
Any other workstation running i.e. Linux, Windows CE, iOS or Android are not supported.  

## Software version
Simphony version 2.9 or higher

## Files included
1. Print_Seat_Main.isl  
2. Print_Seat_Settings.txt  
3. Print_Seat_Translations.txt  
and Example of Language File CAL Package  
  
  
## Application Setup  
Add/Insert new Records with Files in Extension Application  
  
MenuItemClass  
MenuItemClasse’s activated with Option "Is Beverage for all Beverages and Non-Food" will not printed.  
  
Format Parameters  
Disable Sort and Consolidate Current Round Items Touchscreen  

Page Design  
Extend/Add Macros as example  
  
Course 1 Order Function / Macro  
- Function / Clear/No  
- Function / Alphanumeric  
o Text: 1  
- Function / Seat #/Next Seat  
- Function / Enter/Yes  
  
Rush Items Button for Seat 1    
Legend "Rush Course 1"  
Arguments "Print_Seat:11"  
  
Rush Items Button for Seat 2  
Legend "Rush Course 2"  
Arguments "Print_Seat:12"  
