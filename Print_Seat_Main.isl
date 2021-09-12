//  ********************************************************************************************
//
//  The MIT License (MIT)
// 
//  Copyright (c) 2020 GitHub POS-Kitchen
// 
//  All rights reserved.
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  ********************************************************************************************
//  Simphony Extension  :   Recall Items by SEAT and print them during Rush Order NO KDS Supported
//  ********************************************************************************************
//
//  ********************************************************************************************
//  Integrated EVENTS
//  ********************************************************************************************
// 
//  INQ 11  Rush Order/Seat 1                                                      
//  INQ 12  Rush Order/Seat 2                                                      
//  INQ 13  Rush Order/Seat 3                                                      
//  INQ 14  Rush Order/Seat 4                                                      
//  INQ 15  Rush Order/Seat 5                                                      
//  INQ 16  Rush Order/Seat 6                                                      
//  INQ 17  Rush Order/Seat 7                                                      
//  INQ 18  Rush Order/Seat 8                                                      
//  INQ 19  Rush Order/Seat 9
//
//  ********************************************************************************************
//  File Version Release
//  ********************************************************************************************
//  AHA 2021.02.01  1.0.0.0     Review and Modification Simphony 18.2
//                              Add MIT License
//  AHA 2021.02.18  2.0.0.0     New Release with two External Files For Settings and Translate
//                              Main File Encryption tested
//  AHA 2021.02.19  2.0.1.0     Split ReadConfig and ReadTranslation
//  AHA 2021.02.24  3.0.0.0     Add LicenseKey Feature
//  AHA 2021.02.24  3.0.1.0     Add PropertyNameRemoveSpace for LicenseKey
//  AHA 2021.03.01  3.0.1.1     Add OrderDeviceNumber Translation for correct number
//  AHA 2021.05.20  3.0.1.2     Change (bit(@DTL_TYPEDEF[i],38)  to (mid(@DTL_TYPEDEF[i],34,1) 
//                              for MenuItem is Beverage Check
//  AHA 2021.07.18  3.0.2.0     Add New Variable Print_Design 1
//  AHA 2021.07.23  3.0.2.0     Add New Variable Print_Design 2
//  ********************************************************************************************

//  ********************************************************************************************
//  Standard Script Init's
//  ********************************************************************************************

NetImport from &".\wwwroot\EGateway\Handlers\ops.dll"


const ContentCfgName                : A    = "Print_Seat_Settings"
const ContentTranslationName        : A    = "Print_Seat_Translations"
UseISLTimeOuts

//  ********************************************************************************************
//  Configurations
//  ********************************************************************************************

//  ********************************************************************************************
//  Globales Variables Declaration
//  ********************************************************************************************

    var hODBCDLL                    : n12   = 0
    var constatus                   : n9
    var sql_cmd                     : A2000
    var i                           : n3
    var j                           : n3
    var dtl_qty                     : a3
    var print_detail                : n1    = 0
    var Suite                       : n2
    var Touch_CheckID               : key   = key(1,393222)
    var CheckID                     : a24
    var Kitchen_Header              : a32
    var printline1                  : a40
    var printline2                  : a40
    var printline3                  : a40
    var printline4                  : a40
    var printline5                  : a40
    var Printer_Num                 : n2
    var Debug_Mode                  : n1
    var optRead_Settings            : n1
    var optRead_Translations        : n1
    var charstring : A1

    var ISL_VERSION                 : A9    = "4.0.0.0"
    
    var TRUE                        : N5    = 1
    var FALSE                       : N5    = 0
    
    var gbl_ini_read                : N5
    var gbl_text_read               : N5
    var LogVerbosity                : N5
    var gbl_settings_read           : N1    
    var gbl_translations_read       : N1
    var gbl_log_buffer              : A
    var sText[100]                   : A90

    var Print_Design                : n1   
    var Printer_K1_active           : n1   
    var Printer_K1                  : a10
    var Printer_Backup1             : a10
    var Printer_Num1_Header         : n2
    var Printer_K2_active           : n1   
    var Printer_K2                  : a10
    var Printer_Backup2             : a10
    var Printer_Num2_Header         : n2
    var Printer_K3_active           : n1   
    var Printer_K3                  : a10
    var Printer_Backup3             : a10
    var Printer_Num3_Header         : n2    
    
 
    var Service_Total                 : key

    var PropertyName                : A128     = @OpsContext.PropertyName
    var PropertyNameWithoutSpace    : A128


    // Only one function Works at the same time
    // VIP Name Not Working with inq 1+2
    // Use INQ 1+2 
    // ClearTmpChkID = 1
    // PrintChkID = 0
   
    // VIP Name works with One Button per Send Course/Seat
    // Use INQ 11-18 
    // ClearTmpChkID = 0
    // PrintChkID = 1 (optional)
   
    var ClearTmpChkID               : n1        = 0                                                                        //  1 = Add CheckID 0 = Disable CheckID                                                                              
    var PrintChkID                  : n1        = 0                                                                        //  1 = Print CheckID 0 = Disable CheckID



//  ********************************************************************************************
//  Start Script Events
//  ********************************************************************************************


//  ********************************************************************************************
//  Event 11 Rush Suite 1 Order
//  ********************************************************************************************

Event Inq: 11
    
    Call read_settings()
    Call read_translations()  
     
    Suite = 1       //  Set Suite = 1
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   
    
EndEvent



//  ********************************************************************************************
//  Event 12 Rush Suite 2 Order
//  ********************************************************************************************

Event Inq: 12

    Call read_settings()
    Call read_translations()  
        
    Suite = 2       //  Set Suite = 2
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   
    
EndEvent



//  ********************************************************************************************
//  Event 13 Rush Suite 3 Order
//  ********************************************************************************************

Event Inq: 13

    Call read_settings()
    Call read_translations()  
    
    Suite = 3       //  Set Suite = 3
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   
    
EndEvent



//  ********************************************************************************************
//  Event 14 Rush Suite 4 Order
//  ********************************************************************************************



Event Inq: 14

    Call read_settings()
    Call read_translations()  
    
    Suite = 4       //  Set Suite = 4
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   
    
EndEvent



//  ********************************************************************************************
//  Event 15 Rush Suite 5 Order
//  ********************************************************************************************

Event Inq: 15

    Call read_settings()
    Call read_translations()  
    
    Suite = 5       //  Set Suite = 5
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   

EndEvent



//  ********************************************************************************************
//  Event 16 Rush Suite 6 Order
//  ********************************************************************************************

Event Inq: 16

    Call read_settings()
    Call read_translations()  
    
    Suite = 6       //  Set Suite = 6
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total
    
EndEvent



//  ********************************************************************************************
//  Event 17 Rush Suite 7 Order
//  ********************************************************************************************

Event Inq: 17

    Call read_settings()
    Call read_translations()  
    
    Suite = 7       //  Set Suite = 7

    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   
    
EndEvent



//  ********************************************************************************************
//  Event 18 Rush Suite 8 Order
//  ********************************************************************************************

Event Inq: 18

    Call read_settings()
    Call read_translations()  
   
    Suite = 8       //  Set Suite = 8
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   
    
EndEvent



//  ********************************************************************************************
//  Event 19 Rush Suite 9 Order
//  ********************************************************************************************

Event Inq: 19

    Call read_settings()
    Call read_translations()
    
    Suite = 9       //  Set Suite = 9
    
    If Printer_K1_active = 1
        StartPrint Printer_K1, Printer_Backup1, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K2_active = 1
        StartPrint Printer_K2, Printer_Backup2, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf
 
    If Printer_K3_active = 1
        StartPrint Printer_K3, Printer_Backup3, sText[14]                                                   //  Start Print
        Call PRINT_ORDER                                                                                    //  Call subroutine For printing the order rush detail.
    EndIf  

    LoadKybdMacro Service_Total   
    
EndEvent



//  ********************************************************************************************
//  START SUB ROUTINES
//  ********************************************************************************************



Sub PRINT_ORDER
    
    var date : a18

If Print_Design = 1
  
    //   Call FORMAT_DATE( Date, @DAY, @MONTH, @YEAR)                                                       //  Not in Use Simphony Call subroutine For date Format.
        
    PrintLine @dwon, @RVC_Name {=20}, @dwoff                                                                // Format Header
    PrintLine sText[11]{=40}
    PrintLine " "{=40}
    
    format printline1 as @Tremp, " ", @tremp_chkname
    PrintLine printline1{<40}
    printline1 = ""
    
    PrintLine sText[95]{<40}
    format printline1 as "CHK"," ", @cknum{<5}
    format printline2 as "TISCH"," ",@TBLID,"/", @Grpnum
    
    PrintLine printline1{<20},printline2{>20}
    printline1 = ""
    printline2 = ""
    
    PrintLine sText[95]{<40}
    PrintLine " "{=40}
    

    PrintLine @redon, "Gang"," ",Suite


    var dtlcnt            : N5 = @numdtlt                                                                   // Start Print Item Detail
    var d_qty[ dtlcnt]    : N9
    var d_ttl[ dtlcnt]    : $12
    var d_name[dtlcnt]    : A32
    var d_type[dtlcnt]    : A2
    var d_seat[dtlcnt]    : A2
    var d_objn[dtlcnt]    : N9
    var d_mlvl[dtlcnt]    : N9
    var d_slvl[dtlcnt]    : N9
    var d_plvl[dtlcnt]    : N9
    var d_typedef[dtlcnt] : N100
    var print_detail      : N1
    var dtl               : N5
    var i                 : N5
    var j                 : N5
    var mitype_isbev      : N1 = 0

    For i = 1 to dtlcnt                                                                                     //  Start For Loop For every Item on Check
        dtl = dtl + 1
            d_seat[dtl]     = @DTL_SEAT[i]
            d_type[dtl]     = @DTL_TYPE[i]
            d_name[dtl]     = @DTL_NAME[i]
            d_qty[dtl]      = @DTL_QTY[i]
            d_ttl[dtl]      = @DTL_TTL[i]
            d_typedef[dtl]  = @DTL_TYPEDEF[i]
            d_objn[dtl]     = @DTL_OBJNUM[i]
            d_mlvl[dtl]     = @DTL_MLVL[i]
            d_slvl[dtl]     = @DTL_SLVL[i]
            d_plvl[dtl]     = @DTL_PLVL[i]
                                                                                                            //  Scan Item and select them regarding of the seat number called
        If @Dtl_Seat[i] = Suite                                                                             //  Check the SEAT number of the Item.                                                                                                       

            If mitype_isbev = 0                                                                             //  Check If Detail is NOT BEVERAGE

                If Debug_Mode = 1
                InfoMessage "Detail is Reference",@DTL_NAME[i] 
                EndIf

                If @DTL_TYPE[i] = "R"                                                                       //  Check If Detail is Reference
                PrintLine @redon, "   ", @DTL_NAME[i]{<16} , @redoff                                        //  Print Reference in red without quantity.
                EndIf 

            EndIf
        
            If @DTL_TYPE[i] = "M"                                                                           //  Check If Detail is MenuItem
      
                If @DTL_IS_VOID[i] = 0                                                                      //  If the Item is not a void edit item.
                    
                    
                    If @DTL_IS_COND[i] = 0                                                                  //  Check If Detail is Condiment
        
                        If Debug_Mode = 1
                            InfoMessage "Detail is MenuItem",@DTL_NAME[i] 
                        EndIf
          
                        If (mid(@DTL_TYPEDEF[i],34,1) = 1)                                                   //  If the Item has the option ITEM IS BEVERAGE"
              
                            If Debug_Mode = 1
                                InfoMessage "Detail Is Beverage",@DTL_NAME[i] 
                            EndIf
              
                        mitype_isbev = 1                                                                    //  Set ITEM IS BEVERAGE For next Condiment"
                    
                        EndIf
            
                        If (mid(@DTL_TYPEDEF[i],34,1) = 0)                                                   //  If the Item IS NOT BEVERAGE"
              
                            If Debug_Mode = 1
                                InfoMessage "Detail Is Food",@DTL_NAME[i] 
                            EndIf
              
                        mitype_isbev = 0                                                                    //  Set ITEM IS FOOD For next Condiment"

                            If (bit(@DTL_STATUS[i], 5) = 1)                                                 //  Check If the Detail is a Void Item     
                                PrintLine @redon,d_qty[i]{<4}, d_name[i]{<16}, @redoff                      //  Print VOID Then the Item in Red.
                            ElseIf (bit(@DTL_STATUS[i], 15) = 1)                                            //  Check If the Detail is a Touch Void Item  
                                PrintLine @redon,d_qty[i]{<4}, d_name[i]{<16}, @redoff                      //  Print VOID Then the Item in Red.   
                            Else
                            
                            format printline1 as " G",Suite,"  ",d_qty[i]," ", d_name[i]{<16} 
                            format printline2 as "   ",d_ttl[i]{<12}
                            //PrintLine d_qty[i]{<4}, d_name[i]{<16}, d_ttl[i]{>6}                                      //  Print MenuItem Quantity and Name. 
                            //ErrorMessage printline1
                            //ErrorMessage printline2
                            PrintLine " "{=40}
                            PrintLine printline1{<25}, printline2{<12}
                            printline1 = ""
                            printline2 = ""
                            
                            EndIf
                        EndIf
        
                    Else
                
                        If Debug_Mode = 1
                            InfoMessage "Detail is Condiment",@DTL_NAME[i] 
                            ErrorMessage mitype_isbev
                        EndIf
                  
                        If mitype_isbev = 0
                            If d_qty[i] <> 1                                                                //  If detail is Condiment and quantity is more than 1.
                                
                            Format printline1 as "  G",Suite,"  ",d_qty[i]{<2}," ", d_name[i]{<16} 
                            Format printline2 as "  ",d_ttl[i]{>12},"  "
                            PrintLine @redon, printline1{<27}, printline2{>13}
                            printline1 = ""
                            printline2 = "" 
                                 
                            //  PrintLine @redon, d_qty[i]{<4},"   ", d_name[i]{<16} , @redoff              //  If Same Condiment Several Times. Print the Condiment with Quantity and Name in Red.
                            
                            Else                                                                            //  Else
                                
                            format printline1 as "      G",Suite,"   ",d_name[i]{<16} 
                                If d_ttl[i] <>0
                                Format printline2 as "   ",d_ttl[i]{<12}
                                EndIf
                                PrintLine @redon, printline1{<25}, printline2{>12}
                            printline1 = ""
                            printline2 = ""
                            
                            //PrintLine @redon, "       ", d_name[i]{<16} , @redoff                       //  Only one Condiment. Print the condiment without quantity and in red.
                            
                                
                                
                                EndIf
                        EndIf
                    EndIf  
                EndIf
            EndIf
        EndIf
    EndFor                                                                                                  //  End For Loop Scan every Item
  
 

   
    //PrintLine @dwoff,sText[90]{<32}                                                                         //  Format Trailer

    PrintLine sText[95]{<40}   

    var month_arr[12] : a3
    
    //Listing of all the months
    month_arr[1] = "JAN" 
    month_arr[2] = "FEB" 
    month_arr[3] = "MAR" 
    month_arr[4] = "APR" 
    month_arr[5] = "MAY"
    month_arr[6] = "JUN" 
    month_arr[7] = "JUL" 
    month_arr[8] = "AUG" 
    month_arr[9] = "SEP"
    month_arr[10] = "OCT" 
    month_arr[11] = "NOV" 
    month_arr[12] = "DEC"

    var yearday : a4
    format yearday as @YEAR + 1900
    format yearday as Mid(yearday,3,2)
    
    var minute : a2
    If len(@MINUTE) = 1
        format minute as "0",@MINUTE
    Else
        format minute as @MINUTE
    EndIf 
    
    format printline5 as @DAY{2}, " ", month_arr[@MONTH], "'", yearday," ", @HOUR, ":", minute

    PrintLine printline5{=40}
    
    
    EndPrint

    
ElseIf Print_Design = 2
  
    //   Call FORMAT_DATE( Date, @DAY, @MONTH, @YEAR)                                                       //  Not in Use Simphony Call subroutine For date Format.
        
    PrintLine @dwon, @RVC_Name {=20}, @dwoff                                                                // Format Header
    PrintLine sText[11]{=40}
    PrintLine " "{=40}
    
    format printline1 as @Tremp, " ", @tremp_chkname
    PrintLine printline1{<40}
    printline1 = ""
    
    PrintLine sText[95]{<40}
    format printline1 as "CHK"," ", @cknum{<5}
    format printline2 as "TISCH"," ",@TBLID,"/", @Grpnum
    
    PrintLine printline1{<20},printline2{>20}
    printline1 = ""
    printline2 = ""
    
    PrintLine sText[95]{<40}
    PrintLine " "{=40}
    

    PrintLine @redon, "Gang"," ",Suite


    var dtlcnt            : N5 = @numdtlt                                                                   // Start Print Item Detail
    var d_qty[ dtlcnt]    : N9
    var d_ttl[ dtlcnt]    : $12
    var d_name[dtlcnt]    : A32
    var d_type[dtlcnt]    : A2
    var d_seat[dtlcnt]    : A2
    var d_objn[dtlcnt]    : N9
    var d_mlvl[dtlcnt]    : N9
    var d_slvl[dtlcnt]    : N9
    var d_plvl[dtlcnt]    : N9
    var d_typedef[dtlcnt] : N100
    var print_detail      : N1
    var dtl               : N5
    var i                 : N5
    var j                 : N5
    var mitype_isbev      : N1 = 0

    For i = 1 to dtlcnt                                                                                     //  Start For Loop For every Item on Check
        dtl = dtl + 1
            d_seat[dtl]     = @DTL_SEAT[i]
            d_type[dtl]     = @DTL_TYPE[i]
            d_name[dtl]     = @DTL_NAME[i]
            d_qty[dtl]      = @DTL_QTY[i]
            d_ttl[dtl]      = @DTL_TTL[i]
            d_typedef[dtl]  = @DTL_TYPEDEF[i]
            d_objn[dtl]     = @DTL_OBJNUM[i]
            d_mlvl[dtl]     = @DTL_MLVL[i]
            d_slvl[dtl]     = @DTL_SLVL[i]
            d_plvl[dtl]     = @DTL_PLVL[i]
                                                                                                            //  Scan Item and select them regarding of the seat number called
        If @Dtl_Seat[i] = Suite                                                                             //  Check the SEAT number of the Item.                                                                                                       

            If mitype_isbev = 0                                                                             //  Check If Detail is NOT BEVERAGE

                If Debug_Mode = 1
                InfoMessage "Detail is Reference",@DTL_NAME[i] 
                EndIf

                If @DTL_TYPE[i] = "R"                                                                       //  Check If Detail is Reference
                PrintLine @redon, "   ", @DTL_NAME[i]{<16} , @redoff                                        //  Print Reference in red without quantity.
                EndIf 

            EndIf
        
            If @DTL_TYPE[i] = "M"                                                                           //  Check If Detail is MenuItem
      
                If @DTL_IS_VOID[i] = 0                                                                      //  If the Item is not a void edit item.
                    
                    
                    If @DTL_IS_COND[i] = 0                                                                  //  Check If Detail is Condiment
        
                        If Debug_Mode = 1
                            InfoMessage "Detail is MenuItem",@DTL_NAME[i] 
                        EndIf
          
                        If (mid(@DTL_TYPEDEF[i],34,1) = 1)                                                   //  If the Item has the option ITEM IS BEVERAGE"
              
                            If Debug_Mode = 1
                                InfoMessage "Detail Is Beverage",@DTL_NAME[i] 
                            EndIf
              
                        mitype_isbev = 1                                                                    //  Set ITEM IS BEVERAGE For next Condiment"
                    
                        EndIf
            
                        If (mid(@DTL_TYPEDEF[i],34,1) = 0)                                                   //  If the Item IS NOT BEVERAGE"
              
                            If Debug_Mode = 1
                                InfoMessage "Detail Is Food",@DTL_NAME[i] 
                            EndIf
              
                        mitype_isbev = 0                                                                    //  Set ITEM IS FOOD For next Condiment"

                            If (bit(@DTL_STATUS[i], 5) = 1)                                                 //  Check If the Detail is a Void Item     
                                PrintLine @redon,d_qty[i]{<4}, d_name[i]{<16}, @redoff                      //  Print VOID Then the Item in Red.
                            ElseIf (bit(@DTL_STATUS[i], 15) = 1)                                            //  Check If the Detail is a Touch Void Item  
                                PrintLine @redon,d_qty[i]{<4}, d_name[i]{<16}, @redoff                      //  Print VOID Then the Item in Red.   
                            Else
                            
                            format printline1 as " G",Suite,"  ",d_qty[i]," ", d_name[i]{<16} 
                            format printline2 as "   ",d_ttl[i]{<12}
                            //PrintLine d_qty[i]{<4}, d_name[i]{<16}, d_ttl[i]{>6}                                      //  Print MenuItem Quantity and Name. 
                            //ErrorMessage printline1
                            //ErrorMessage printline2
                            PrintLine " "{=40}
                            PrintLine printline1{<25}, printline2{<12}
                            printline1 = ""
                            printline2 = ""
                            
                            EndIf
                        EndIf
        
                    Else
                
                        If Debug_Mode = 1
                            InfoMessage "Detail is Condiment",@DTL_NAME[i] 
                            ErrorMessage mitype_isbev
                        EndIf
                  
                        If mitype_isbev = 0
                            If d_qty[i] <> 1                                                                //  If detail is Condiment and quantity is more than 1.
                                
                            Format printline1 as "  G",Suite,"  ",d_qty[i]{<2}," ", d_name[i]{<16} 
                            Format printline2 as "  ",d_ttl[i]{>12},"  "
                            PrintLine @redon, printline1{<27}, printline2{>13}
                            printline1 = ""
                            printline2 = "" 
                                 
                            //  PrintLine @redon, d_qty[i]{<4},"   ", d_name[i]{<16} , @redoff              //  If Same Condiment Several Times. Print the Condiment with Quantity and Name in Red.
                            
                            Else                                                                            //  Else
                                
                            format printline1 as "      G",Suite,"   ",d_name[i]{<16} 
                                If d_ttl[i] <>0
                                Format printline2 as "   ",d_ttl[i]{<12}
                                EndIf
                                PrintLine @redon, printline1{<25}, printline2{>12}
                            printline1 = ""
                            printline2 = ""
                            
                            //PrintLine @redon, "       ", d_name[i]{<16} , @redoff                       //  Only one Condiment. Print the condiment without quantity and in red.
                            
                                
                                
                                EndIf
                        EndIf
                    EndIf  
                EndIf
            EndIf
        EndIf
    EndFor                                                                                                  //  End For Loop Scan every Item
  
 

   
    //PrintLine @dwoff,sText[90]{<32}                                                                         //  Format Trailer

    PrintLine sText[95]{<40}
    

    var month_arr[12] : a3
    
    //Listing of all the months
    month_arr[1] = "JAN" 
    month_arr[2] = "FEB" 
    month_arr[3] = "MAR" 
    month_arr[4] = "APR" 
    month_arr[5] = "MAY"
    month_arr[6] = "JUN" 
    month_arr[7] = "JUL" 
    month_arr[8] = "AUG" 
    month_arr[9] = "SEP"
    month_arr[10] = "OCT" 
    month_arr[11] = "NOV" 
    month_arr[12] = "DEC"

    var yearday : a4
    format yearday as @YEAR + 1900
    format yearday as Mid(yearday,3,2)
    
    var minute : a2
    If len(@MINUTE) = 1
        format minute as "0",@MINUTE
    Else
        format minute as @MINUTE
    EndIf 
    
    format printline5 as @DAY{2}, " ", month_arr[@MONTH], "'", yearday," ", @HOUR, ":", minute

    PrintLine printline5{=40}
    
    
    EndPrint


Else
  
    //   Call FORMAT_DATE( Date, @DAY, @MONTH, @YEAR)                                                       //  Not in Use Simphony Call subroutine For date Format.

    PrintLine @dwon, @RVC_Name {<16}, @dwoff                                                                // Format Header
    PrintLine @dwoff," "
    PrintLine @dwon, @redon, sText[11]{<16}, @dwoff, @redoff
    PrintLine @dwoff," "
    
    var minute : a2
    If len(@MINUTE) = 1
        format minute as "0",@MINUTE
    Else
        format minute as @MINUTE
    EndIf 
    
    PrintLine sText[2]," ", @dwon, @redon, @HOUR, ":", minute, @dwoff, @redoff 
    PrintLine sText[27]," ", @cknum{<5}," ", date
    //PrintLine @dwon, Kitchen_Header {<16}, @dwoff
    PrintLine @dwoff," "
        If PrintChkID = 1
            PrintLine @CKID
        EndIf
    PrintLine @Tremp, " ", @tremp_chkname
    PrintLine @dwoff,sText[90]{<32}
    PrintLine @dwon, @redon, sText[4]," ", @TBLID,"/", @Grpnum ,"  ",sText[5], " ", @gst, @dwoff, @redoff
    PrintLine @dwoff,sText[90]{<32}
    PrintLine @dwon, @redon, Suite, ".",  sText[10]{<13}, @dwoff, @redoff
    PrintLine @dwoff,sText[90]{<32}

    var dtlcnt            : N5 = @numdtlt                                                                   // Start Print Item Detail
    var d_qty[ dtlcnt]    : N9
    var d_name[dtlcnt]    : A32
    var d_type[dtlcnt]    : A2
    var d_seat[dtlcnt]    : A2
    var d_objn[dtlcnt]    : N9
    var d_mlvl[dtlcnt]    : N9
    var d_slvl[dtlcnt]    : N9
    var d_plvl[dtlcnt]    : N9
    var d_typedef[dtlcnt] : N100
    var print_detail      : N1
    var dtl               : N5
    var i                 : N5
    var j                 : N5
    var mitype_isbev      : N1 = 0

    For i = 1 to dtlcnt                                                                                     //  Start For Loop For every Item on Check
        dtl = dtl + 1
            d_seat[dtl]     = @DTL_SEAT[i]
            d_type[dtl]     = @DTL_TYPE[i]
            d_name[dtl]     = @DTL_NAME[i]
            d_qty[dtl]      = @DTL_QTY[i]
            d_typedef[dtl]  = @DTL_TYPEDEF[i]
            d_objn[dtl]     = @DTL_OBJNUM[i]
            d_mlvl[dtl]     = @DTL_MLVL[i]
            d_slvl[dtl]     = @DTL_SLVL[i]
            d_plvl[dtl]     = @DTL_PLVL[i]
                                                                                                            //  Scan Item and select them regarding of the seat number called
        If @Dtl_Seat[i] = Suite                                                                             //  Check the SEAT number of the Item.                                                                                                       

            If mitype_isbev = 0                                                                             //  Check If Detail is NOT BEVERAGE

                If Debug_Mode = 1
                InfoMessage "Detail is Reference",@DTL_NAME[i] 
                EndIf

                If @DTL_TYPE[i] = "R"                                                                       //  Check If Detail is Reference
                PrintLine @redon, "   ", @DTL_NAME[i]{<16} , @redoff                                        //  Print Reference in red without quantity.
                EndIf 

            EndIf
        
            If @DTL_TYPE[i] = "M"                                                                           //  Check If Detail is MenuItem
      
                If @DTL_IS_VOID[i] = 0                                                                      //  If the Item is not a void edit item.
                    
                    
                    If @DTL_IS_COND[i] = 0                                                                  //  Check If Detail is Condiment
        
                        If Debug_Mode = 1
                            InfoMessage "Detail is MenuItem",@DTL_NAME[i] 
                        EndIf
          
                        If (mid(@DTL_TYPEDEF[i],34,1) = 1)                                                   //  If the Item has the option ITEM IS BEVERAGE"
              
                            If Debug_Mode = 1
                                InfoMessage "Detail Is Beverage",@DTL_NAME[i] 
                            EndIf
              
                        mitype_isbev = 1                                                                    //  Set ITEM IS BEVERAGE For next Condiment"
                    
                        EndIf
            
                        If (mid(@DTL_TYPEDEF[i],34,1) = 0)                                                   //  If the Item IS NOT BEVERAGE"
              
                            If Debug_Mode = 1
                                InfoMessage "Detail Is Food",@DTL_NAME[i] 
                            EndIf
              
                        mitype_isbev = 0                                                                    //  Set ITEM IS FOOD For next Condiment"

                            If (bit(@DTL_STATUS[i], 5) = 1)                                                 //  Check If the Detail is a Void Item     
                                PrintLine @redon,d_qty[i]{<4}, d_name[i]{<16}, @redoff                      //  Print VOID Then the Item in Red.
                            ElseIf (bit(@DTL_STATUS[i], 15) = 1)                                            //  Check If the Detail is a Touch Void Item  
                                PrintLine @redon,d_qty[i]{<4}, d_name[i]{<16}, @redoff                      //  Print VOID Then the Item in Red.   
                            Else
                                PrintLine d_qty[i]{<4}, d_name[i]{<16}                                      //  Print MenuItem Quantity and Name. 
                            EndIf
                        EndIf
        
                    Else
                
                        If Debug_Mode = 1
                            InfoMessage "Detail is Condiment",@DTL_NAME[i] 
                            ErrorMessage mitype_isbev
                        EndIf
                  
                        If mitype_isbev = 0
                            If d_qty[i] <> 1                                                                //  If detail is Condiment and quantity is more than 1.
                                PrintLine @redon, d_qty[i]{<4},"   ", d_name[i]{<16} , @redoff              //  If Same Condiment Several Times. Print the Condiment with Quantity and Name in Red.
                            Else                                                                            //  Else
                                PrintLine @redon, "       ", d_name[i]{<16} , @redoff                       //  Only one Condiment. Print the condiment without quantity and in red.
                            EndIf
                        EndIf
                    EndIf  
                EndIf
            EndIf
        EndIf
    EndFor                                                                                                  //  End For Loop Scan every Item
  
 

   
    PrintLine @dwoff,sText[90]{<32}                                                                         //  Format Trailer

    EndPrint
    
EndIf
    
EndSub


//===========================================================================
//= msg_2log - Log system messages                                          =
//===========================================================================
Sub msg_2log(var remark: A, var msg: A)
    If (LogVerbosity > 0)
        LogPlainSystemMessage(System.String.Format( "SEATPRINT: {0} | {1}", remark, msg))
    EndIf
EndSub


//===========================================================================
//= advtrim - Get the trim part of the content                              =
//===========================================================================
Sub advtrim(ref sText)
lvar sTemp : A999
lvar j     : N3
    j = instr( 1, sTemp, chr(10))
    If j = 0
        j = instr(1, sText, chr(13))
    EndIf
    If j > 0
        sTemp = mid( sText, 1, j - 1 )
    Else
        stemp = stext
    EndIf
    sText = sTemp
EndSub


//===========================================================================================================
//= Read_Settings - Read the Config File from the Content                                                     =
//===========================================================================================================
Sub read_settings()
    
lvar i              : N
lvar msgIdx         : N
lvar skipLine       : N1
lvar fline[500]     : A
lvar f_str1         : A
lvar f_str2         : A
lvar xContent       : object
lvar settings       : A
lvar strErrText     : A

    If gbl_settings_read = TRUE
       Return
    EndIf
    
    LogVerbosity = 1


     // WRITE PLATFORM and VERSION TO LOGFILE     
    
    
    Format gbl_log_buffer as @PLATFORM, ",", @VERSION, " V.", ISL_VERSION
    Call msg_2log("@PLATFORM, @VERSION, ISL VER.", gbl_log_buffer)    

    
    
// READ CONFIG INI FILE ContentCfgName    
    

    Try
    settings = @DataStore.ReadExtensionApplicationContentTextByNameKey( @OpsContext.RvcID, @ApplicationName, ContentCfgName )
    catch ex
    Call msg_2log("read_config()", System.String.Format( "Exception in read_config/Settings ReadExtensionApplicationContentTextByNameKey [{0}] : [{1}]", ex.Message, ex.Details))       // "
    EndTry

    If (settings = "")
        Try
        xContent = @DataStore.ReadContentByName(@OpsContext.RvcID, ContentCfgName)
        If xContent <> @NULL
            settings = System.Text.Encoding.Unicode.GetString(xContent.ContentData.DataBlob, 0, xContent.ContentData.DataBlob.Length)
            Call msg_2log("read_config()", System.String.Format( "ISL V.{0} ReadContentByName [{1}] returned String Len : [{2}]", ISL_VERSION, ContentCfgName, len(settings)))       // "
        Else
            Call msg_2log("read_config()", System.String.Format( "ReadContentByName [{0}] returned NULL", ContentCfgName))      // "
            ErrorMessage "Cannot read content [", ContentCfgName, "]. Aborting!"
            ExitCancel
        EndIf
        Catch ex
        Call msg_2log("read_config()", System.String.Format( "Exception in ReadContentByName [{0}] - [{1}] : [{2}]", ContentCfgName, ex.Message, ex.Details))      // "
        EndTry
    Else
        Call msg_2log("read_config()", System.String.Format( "ISL V.{0} ReadExtensionApplicationContentTextByNameKey [{1}] returned String Len : [{2}]", ISL_VERSION, ContentCfgName, len(settings)))       // "
EndIf
    If (settings = "")
        Call msg_2log("read_config()", System.String.Format("Both Extension Application Content and Content [{0}] did not Return any value", ContentCfgName))       // "
        ErrorMessage "Fatal Error reading both Extension Application Content and Content [", ContentCfgName, "]. Unable to continue."
        exitcancel
    EndIf

    Split settings, chr(10), #500, fline[]
    For i = 1 to arraysize(fLine)
        skipLine = 0
        If trim(fline[i]) = ""
           skipLine = 1
        ElseIf mid(trim(fline[i]), 1, 1) = "#"
            skipLine = 1
        EndIf
        If skipLine = 0
            f_str2 = ""
            Split fline[i], "=", f_str1, f_str2
            Call advtrim(f_str2)
            UpperCase f_str1
         
            If trim(f_str1) = "PRINTER_1_ACTIVE"
                Printer_K1_Active = mid(trim(f_str2), 1, varsize(Printer_K1_Active))

                ElseIf trim(f_str1) = "PRINTER_1_ORDER_DEVICE"
                
                    Call OrderDeviceNumber(f_str2)
                    Printer_K1 = @ORDR[mid(trim(f_str2), 1, varsize(Printer_K1))]

                    
                ElseIf trim(f_str1) = "PRINTER_1_BACKUP_ORDER_DEVICE"
                    Call OrderDeviceNumber(f_str2)
                    Printer_Backup1 = @ORDR[mid(trim(f_str2), 1, varsize(Printer_Backup1))]

                    ElseIf trim(f_str1) = "PRINTER_1_HEADER"
                    Call OrderDeviceNumber(f_str2)
                        Printer_Num1_Header = mid(trim(f_str2), 1, varsize(Printer_Num1_Header)) 

                ElseIf trim(f_str1) = "PRINT_DESIGN"
                Print_Design = mid(trim(f_str2), 1, varsize(Print_Design))

                ElseIf trim(f_str1) = "PRINTER_2_ACTIVE"
                Printer_K2_Active = mid(trim(f_str2), 1, varsize(Printer_K2_Active))

                ElseIf trim(f_str1) = "PRINTER_2_ORDER_DEVICE"
                    Call OrderDeviceNumber(f_str2)
                    Printer_K2 = @ORDR[mid(trim(f_str2), 1, varsize(Printer_K2))]
                    
                ElseIf trim(f_str1) = "PRINTER_2_BACKUP_ORDER_DEVICE"
                    Call OrderDeviceNumber(f_str2)
                    Printer_Backup2 = @ORDR[mid(trim(f_str2), 1, varsize(Printer_Backup2))]

                ElseIf trim(f_str1) = "PRINTER_2_HEADER"
                    Call OrderDeviceNumber(f_str2)
                    Printer_Num2_Header = mid(trim(f_str2), 1, varsize(Printer_Num2_Header)) 
                        
                ElseIf trim(f_str1) = "PRINTER_3_ACTIVE"
                Printer_K3_Active = mid(trim(f_str2), 1, varsize(Printer_K3_Active))

                ElseIf trim(f_str1) = "PRINTER_3_ORDER_DEVICE"
                    Call OrderDeviceNumber(f_str2)
                    Printer_K3 = @ORDR[mid(trim(f_str2), 1, varsize(Printer_K3))]
                    
                ElseIf trim(f_str1) = "PRINTER_3_BACKUP_ORDER_DEVICE"
                    Call OrderDeviceNumber(f_str2)
                    Printer_Backup3 = @ORDR[mid(trim(f_str2), 1, varsize(Printer_Backup3))]

                    ElseIf trim(f_str1) = "PRINTER_3_HEADER"
                        Printer_Num3_Header = mid(trim(f_str2), 1, varsize(Printer_Num3_Header)) 

                 ElseIf trim(f_str1) = "SERVICE_TOTAL"
                     Service_Total = key(7,(mid(trim(f_str2), 1, varsize(Service_Total))))

                 ElseIf trim(f_str1) = "DEBUG_MODE"
                     DEBUG_MODE = mid(trim(f_str2), 1, varsize(DEBUG_MODE))
                     
                 ElseIf trim(f_str1) = "READ_SETTINGS"
                     optRead_Settings = mid(trim(f_str2), 1, varsize(optRead_Settings))

                 ElseIf trim(f_str1) = "READ_TRANSLATIONS"
                     optRead_Translations = mid(trim(f_str2), 1, varsize(optRead_Translations))
                     
                EndIf
        EndIf
    EndFor
    
    If optRead_Settings = 1
        gbl_settings_read = FALSE
    Else
        gbl_settings_read = TRUE
    EndIf
    
EndSub


Sub OrderDeviceNumber(ref f_str2)
    
   If       f_str2=1
            f_str2=2
       
   ElseIf   f_str2=2
            f_str2=3
       
   ElseIf   f_str2=3
            f_str2=4
            
   ElseIf   f_str2=4
            f_str2=5
       
   ElseIf   f_str2=5
            f_str2=6
            
   ElseIf   f_str2=6
            f_str2=7
            
   ElseIf   f_str2=7
            f_str2=8
       
   ElseIf   f_str2=8
            f_str2=9
            
   ElseIf   f_str2=9
            f_str2=10
       
   ElseIf   f_str2=10
            f_str2=11
            
   ElseIf   f_str2=11
            f_str2=12
            
   ElseIf   f_str2=12
            f_str2=13
       
   ElseIf   f_str2=13
            f_str2=14
            
   ElseIf   f_str2=14
            f_str2=15
       
   ElseIf   f_str2=15
            f_str2=16
            
   ElseIf   f_str2=16
            f_str2=17
            
   ElseIf   f_str2=17
            f_str2=18
       
   ElseIf   f_str2=18
            f_str2=19
            
   ElseIf   f_str2=19
            f_str2=20
       
   ElseIf   f_str2=20
            f_str2=21
            
   ElseIf   f_str2=21
            f_str2=22
            
   ElseIf   f_str2=22
            f_str2=23
       
   ElseIf   f_str2=23
            f_str2=24
            
   ElseIf   f_str2=24
            f_str2=25
       
   ElseIf   f_str2=25
            f_str2=26
            
   ElseIf   f_str2=26
            f_str2=27
            
   ElseIf   f_str2=27
            f_str2=28
       
   ElseIf   f_str2=28
            f_str2=29
            
   ElseIf   f_str2=29
            f_str2=30
       
   ElseIf   f_str2=30
            f_str2=31
            
   ElseIf   f_str2=31
            f_str2=32

   ElseIf   f_str2=32
            f_str2=33                       
   EndIf
                    
EndSub

                    

//===========================================================================================================
//= Read_Translations - Read the Config File from the Content                                                     =
//===========================================================================================================
Sub read_translations()
lvar i              : N
lvar msgIdx         : N
lvar skipLine       : N1
lvar fline[500]     : A
lvar f_str1         : A
lvar f_str2         : A
lvar xContent       : object
lvar settings       : A
lvar strErrText     : A

    If gbl_translations_read = TRUE
       Return
    EndIf
    LogVerbosity = 1

    Call setDefaultText()

     // WRITE PLATFORM and VERSION TO LOGFILE     
    
    
    Format gbl_log_buffer as @PLATFORM, ",", @VERSION, " V.", ISL_VERSION
    Call msg_2log("@PLATFORM, @VERSION, ISL VER.", gbl_log_buffer)    
  
    settings = ""
    
// READ TRANSLATION INI FILE ContentTranslationName       
    
    Try
    settings = @DataStore.ReadExtensionApplicationContentTextByNameKey( @OpsContext.RvcID, @ApplicationName, ContentTranslationName )
    catch ex
    Call msg_2log("read_config()", System.String.Format( "Exception in read_config/Translation ReadExtensionApplicationContentTextByNameKey [{0}] : [{1}]", ex.Message, ex.Details))  //"    Call setDefaultText
    EndTry

    
    If DEBUG_MODE= 1
        ErrorMessage "Read Translation File Text"
    EndIf

    If (settings = "")
        
        Try
        xContent = @DataStore.ReadContentByName(@OpsContext.RvcID, ContentTranslationName)
        
        If xContent <> @NULL
            settings = System.Text.Encoding.Unicode.GetString(xContent.ContentData.DataBlob, 0, xContent.ContentData.DataBlob.Length)
            Call msg_2log("read_config()", System.String.Format( "ISL V.{0} ReadContentByName [{1}] returned String Len : [{2}]", ISL_VERSION, ContentTranslationName, len(settings)))   //"
        Else
            Call msg_2log("read_config()", System.String.Format( "ReadContentByName [{0}] returned NULL", ContentTranslationName))   //"
        EndIf
        catch ex
        Call msg_2log("read_config()", System.String.Format( "Exception in ReadContentByName [{0}] - [{1}] : [{2}]", ContentTranslationName, ex.Message, ex.Details))   //"
        EndTry
    Else
        Call msg_2log("read_config()", System.String.Format( "ISL V.{0} ReadExtensionApplicationContentTextByNameKey [{1}] returned String Len : [{2}]", ISL_VERSION, ContentTranslationName, len(settings)))   //"
    EndIf

    If (settings <> "")
        Split settings, chr(10), #150, fline[]

        For i = 1 to arraysize(fLine)
            skipLine = 0
            If trim(fline[i]) = ""
                skipLine = 1
            ElseIf mid(trim(fline[i]), 1, 1) = "#"
                skipLine = 1
            EndIf

            If skipLine = 0
                f_str2 = ""
                Split fline[i], "=", f_str1, f_str2
                Call advtrim(f_str2)
                UpperCase f_str1
                
                For msgIdx = 1 to arraysize(sText)
                    Format strErrText as "ERROR-TEXT", msgIdx
                    If trim(f_str1) = strErrText
                        sText[msgIdx] = trim(f_str2)
                        Call msg_2log("SETUP ERROR-TEXT", System.String.Format( "[{0}] - [{1}]", msgIdx, sText[msgIdx]))
                        break
                    EndIf
                EndFor
            EndIf
        EndFor
    EndIf
    
    If optRead_Translations = 1
        gbl_translations_read = FALSE
    Else
        gbl_translations_read = TRUE
    EndIf
    
EndSub



//===========================================================================================================
//= setDefaultText - Read the Config File For Text Default                                                  =
//===========================================================================================================
Sub setDefaultText()
    
If DEBUG_MODE= 1
    ErrorMessage "Read Default Text"
EndIf

    sText[1]  = "Abteilung"
    sText[2]  = "Abgerufen um :"
    sText[3]  = "Nicht vorhanden in dieser Abteilung !!"
    sText[4]  = "Ti: "
    sText[5]  = "  Gst "
    sText[6]  = "****************"
    sText[7]  = "****************"
    sText[8]  = "****************"
    sText[9]  = "****************"
    sText[10] = "GANG SCHICKEN"
    sText[11] = "*** ABRUFBON ***"
    sText[12] = "POS Operations im Offline Modus, Keine Datenbank Verbindung"
    sText[13] = "****************"
    sText[14] = "ERROR"
    sText[15] = "Januar"
    sText[16] = "Februar"
    sText[17] = "Marz"
    sText[18] = "April"
    sText[19] = "Mai"
    sText[20] = "Juni"
    sText[21] = "Juli"
    sText[22] = "August"
    sText[23] = "September"
    sText[24] = "Oktober"
    sText[25] = "November"
    sText[26] = "Dezember"
    sText[27] = "Rechnungsnummer : "
    sText[28] = "Nicht erlaubt im Trainingsmodus"
    sText[90] = "------------------------------"
    sText[95] = "----------------------------------------"
    
EndSub
