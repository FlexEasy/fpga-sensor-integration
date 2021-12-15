`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2018 12:33:31 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
       input wire sys_clkn,
       input wire sys_clkp,
       
       input wire [4:0] okUH,
       output wire[2:0] okHU,
       inout wire[31:0] okUHU,
       inout wire okAA,
       
       input [3:0] BUTTON,
       output [3:0] LED,
       output [7:0] xled,
       output [7:0] USER_33,
       
       input wire CVM300_SPI_OUT,
       output wire CVM300_Enable_LVDS, CVM300_SPI_IN, CVM300_SPI_EN, CVM300_SPI_CLK,
       
       output wire CVM300_FRAME_REQ,
       output wire CVM300_SYS_RES_N,
       input  wire CVM300_Data_valid,
       input  wire CVM300_CLK_OUT, 
       output wire CVM300_CLK_IN,
       input  wire [9:0] CVM300_D
    );
    
    assign CVM300_Enable_LVDS = 1'b0; //GND this PIN sets us to CMOS output
    
    //READ CLOCK GENERATION    
        wire clk;// 200MHZ oscillator clock
        reg rst;
        reg [27:0] clkdiv; 
        reg clock40; // 40MHZ FIFO read clock
        wire okClk, slowclk; //assigned in okhost assignments but declared here
        wire [31:0] go, go2, control;
        
        assign USER_33 = clock40;
        assign slowclk = clock40;
        
        initial begin
            clkdiv <= 3'b0;
            clock40 <= 1'b0;
        end
        
        IBUFGDS osc_clk(
            .O(clk),
            .I(sys_clkp),
            .IB(sys_clkn)
        );
        
        always @(posedge clk) begin
            clkdiv <= clkdiv + 1'b1;
            if(clkdiv == 28'd3) begin // clock40 runs at 1/6th the speed of osc clock
                clkdiv <= 3'd0;
                clock40 <= ~clock40;
            end
        end
    //END CLOCK GENERATION
    
// instantiating FIFO module    
        wire wr_clk, rd_clk, wr_en, rd_en, fifo_reset_en;
        reg  fifo_reset, fifowrite;
        wire [31:0] din, dout;
        wire full, almost_full, empty, almost_empty;
        wire epA3read;
        
        
        assign wr_clk = ~CVM300_CLK_OUT; //write at 40MHz clock
        assign rd_clk = okClk; //read at okCLK speed, the usb interface clock
        assign wr_en = CVM300_Data_valid && fifowrite;
        assign rd_en = epA3read; //read enable based on read output from pipeout
        //assign rst = ~BUTTON[0]; //BUTTON[0] is the RESET button
     
        fifo_generator_0 FIFO_0(
        //FIFO inputs
            .rst(fifo_reset_en),
            .wr_clk(wr_clk),
            .rd_clk(rd_clk),
            .din(din[9:2]),
            .wr_en(wr_en), 
            .rd_en(rd_en),
        // FIFO outputs       
            .dout(dout),
            .full(full),
            .prog_full(almost_full),
            .empty(empty),
            .prog_empty(almost_empty)
        ); 
// END FIFO INSTANTIATION         


//FP wires    
    //  wire okClk; // declared earlier
        wire [112:0] okHE;
        wire [32:0] okEH;
        wire epA3strobe, epA3ready;
        
        // Adjust size of okEHx to fit the number of outgoing endpoints in your design (n*65-1:0)
     
        okHost hostIF (
            .okUH(okUH),
            .okHU(okHU),
            .okUHU(okUHU),
            .okClk(okClk),
            .okAA(okAA),
            .okHE(okHE),
            .okEH(okEH)
        );
         
        // Adjust NUMBER_OF_OUTPUTS to fit the number of outgoing endpoints in your design
        localparam NUMBER_OF_OUTPUTS = 2;
            
        wire [NUMBER_OF_OUTPUTS*65-1:0] okEHx;
        okWireOR # (.N(NUMBER_OF_OUTPUTS)) wireOR (okEH, okEHx);
        wire [7:0] RegDataOut, RegAddrIn, RegDataIn;
    
            
        okWireIn wire10(
             .okHE(okHE),
             .ep_addr(8'h10),
             .ep_dataout(go)
        );
        
        okWireIn wire11(
                 .okHE(okHE),
                 .ep_addr(8'h11),
                 .ep_dataout(control)
            );
            
        okWireIn wire12(
                .okHE(okHE),
                .ep_addr(8'h12),
                .ep_dataout(RegAddrIn)
            );
        
        okWireIn wire13(
                 .okHE(okHE),
                 .ep_addr(8'h13),
                 .ep_dataout(RegDataIn)
            );
        
        okTriggerIn trigger53(
            .okHE(okHE),
            .ep_addr(8'h53),
            .ep_clk(slowclk), //trigger clock runs at same spd as write clock (clock40)
            .ep_trigger({31'd0,go2})
        );
        
        okWireOut wire21(
            .okHE(okHE),
            .okEH(okEHx[1*65+:65]),
            .ep_addr(8'h21),
            .ep_datain(RegDataOut)
        );
        
        okBTPipeOut btPipeOutA3(
            .okHE(okHE), 
            .okEH(okEHx[0*65+:65]),
            .ep_addr(8'ha3), 
            .ep_datain(dout), //input
            .ep_read(epA3read),  //output                        
            .ep_blockstrobe(epA3strobe), //output
            .ep_ready(almost_full) //input
        );
                  
    //END OK host modules
    
    
    /*
    Check Point 3 (using counter )
    reg counter 10'd0;
    local param [648][9:0] Data_Out //not sure how the pixel data should be handled.
    */
    
    reg [7:0] FrameReqState;
    reg [9:0] FrameData;
    reg [31:0] counter;
    reg [9:0] PixelData_in;
    reg FrameReq_en, SysRes_N_en;
    reg [3:0] LED_next;
    
    assign CVM300_CLK_IN = slowclk;
    assign din[9:0] = CVM300_D; 
    assign CVM300_FRAME_REQ = FrameReq_en;
    //assign CVM300_SYS_RES_N = 1'b1;
    assign LED = LED_next; //system flags
    assign CVM300_SYS_RES_N = SysRes_N_en;
    
    initial begin
        PixelData_in <= 10'd0;
        FrameReqState <= 8'd0;
        FrameData <= 10'd0;
        FrameReq_en <= 1'b0;
        SysRes_N_en <= 1'b0;
        counter <= 32'd0;
        fifo_reset <= 1'b1;
        fifowrite <= 1'b0;
        LED_next <= 1'b0; 
    end
     
   
    
     always@(negedge CVM300_CLK_OUT) begin // use output clock from the CMOS imager
            
            if( (epA3read == 1'b1) && (FrameReqState > 8'd3) )begin
                LED_next[0] <= 1'b1;
            end
            
            if( wr_en == 1'b1) begin
                LED_next[1] <= 1'b1;
            end
            
            if( (full == 1'b1) && (FrameReqState>8'd03) ) begin
                LED_next[2] <= 1'b1;
            end
            
            if(CVM300_FRAME_REQ == 1'b1) begin
                LED_next[3] <= 1'b1;
            end
            
            case( FrameReqState )
                
                8'd00: begin //IDLE  
                    fifo_reset <= 1'b0;                                                     
                    if( go2 == 1'b1 ) begin //wait for trigger signal
                       
                       //LED_next[1] <= 1'b1;
                       FrameReqState <= FrameReqState + 1'b1; //move from idle on Trigger assertion from Python
                     end
                    else
                       FrameReqState <= FrameReqState + 1'b0; // otherwise remain in IDLE *****Changed while simulating!*****               
                end
                
                8'd01: begin // 1 us Wait State
                    counter <= counter + 1'b1;
                    if( counter >= 32'd2500 ) begin// 10 ms reached
                        counter <= 32'd0; //reset the counter
                        FrameReqState <= FrameReqState + 2'd1;
                    end
                    else
                        FrameReqState <= FrameReqState; 
                end
                
                8'd02: begin  // Deactivate SysRes_N and Wait another 1us                      
                    //SysRes_N_en <= 1'b1;
                    counter <= counter + 1;
                    if( counter >= 32'h0 ) begin// 1 us reached  
                        counter <= 32'd0; //reset the counter     
                        FrameReqState <= FrameReqState + 1'b1;   
                    end                                          
                    else                                         
                        FrameReqState <= FrameReqState;               
                 end
                    
                8'd03: begin // activate Frame Request
                    FrameReq_en <= 1'b1;                                   
                    FrameReqState <= FrameReqState + 1'b1;                                   
                end
                
                    
                8'd04: begin // deactivate Frame Request
                    FrameReq_en <= 1'b0;
                    FrameReqState <= FrameReqState + 1'b1;  
                end
                
                8'd05: begin //prep state
                    if( CVM300_Data_valid == 1'b1 ) begin //when data is valid
                        //LED_next[0] <= 1'b1; //turns on if data is ever valid
                        PixelData_in <= CVM300_D; //"acquire" pixel 0
                        FrameReqState <= FrameReqState + 1'b1; //move on to active state
                        counter <= counter + 1'b1; //increment counter
                    end
                    else FrameReqState <= FrameReqState; //otherwise remain in prep state
                end
                
                8'd06: begin //active state
                    counter <= counter + 1'b1;
                    if( counter <= 3 || counter >= 644 ) begin
                        fifowrite <= 1'b0; // do NOT write the first & last 4 pixels of each row into the fifo
                    end
                    else begin
                        fifowrite <= 1'b1;
                        //LED_next[2] <= 1'b1;  
                    end //otherwise do write
                    
                    PixelData_in <= CVM300_D;
                    
                    if( (counter >= 648) && (CVM300_Data_valid == 1'b0) ) begin
                        //LED_next[3] <= 1'b1; 
                        FrameReqState <= FrameReqState - 1'b1; //return to the prep state 
                    end //remain in active until row is done
                    else begin 
                        FrameReqState <= FrameReqState;
                    end                   
                end
                      
        endcase
    end
    
    
    // Start of Check Point 2 SPI protocol
    
    // STATEMACHINE DEFINITION
        
        reg [7:0] Currentstate;
        reg SPI_CLK, SPI_EN, SPI_IN;
        reg [7:0] DataOut;
        
        assign RegDataOut = DataOut;
        assign CVM300_SPI_CLK = SPI_CLK;
        assign CVM300_SPI_EN = SPI_EN;
        assign CVM300_SPI_IN = SPI_IN;
        
        initial begin
            Currentstate <= 1'b0;
            SPI_CLK <= 1'b0;    // starts at state 02, switches at half the speed of the slow clock, (HIGH-EVEN, LOW-ODD) 
            SPI_EN <= 1'b0;    // SET HIGH AT STATE 1, REMAINS HIGH UNTIL 2 STATES AFTER THE LAST BIT
            SPI_IN <= 1'b0;   //CHANGES ON EVERY ODD STATE
            DataOut <= 8'd0; //initialized to 0.
        end   
        
        always@(posedge slowclk) begin
            
            case( Currentstate )
                
                8'd00: begin //IDLE\
                    
                                    
                    SPI_CLK <= 1'b0;
                    SPI_EN <= 1'b0;
                    SPI_IN <= 1'b0;
                    
                    if( go[0] == 1'b1 ) begin
                        SysRes_N_en <= 1'b1;
                        Currentstate <= Currentstate + 1'b1; //move from idle on WireIn assertion from Python
                    end
                    else
                        Currentstate <= Currentstate; // otherwise remain in IDLE *****Changed while simulating!*****               
                end
                
                8'd01: begin // Asserting SPI_EN, Control bit 
                    SPI_CLK <= 1'b0;
                    SPI_EN <= 1'b1; //asserting SPI_EN half of an SPI clk cycle before asserting SPI_CLK
                    SPI_IN <= control; //SPI_IN sends the control bit determining read/write
                    Currentstate <= Currentstate + 1'b1; 
                end
                
                8'd02: begin // SPI_CLK_P 1
                    SPI_CLK <= 1'b1; //SPI CLK goes high
                    //SPI_EN <= 1'b1; // SPI_EN remains high
                    SPI_IN <= control[0]; //SPI_IN does not change
                    Currentstate <= Currentstate + 1'b1;
                end
                                
                
                8'd03: begin  //D[6]       
                    SPI_CLK <= 1'b0; //low on odd
                    //SPI_EN <= 1'b1;  
                    SPI_IN <= RegAddrIn[6];  // bit 6
                    Currentstate <= Currentstate + 1'b1;
                end    
                              
                8'd04: begin         
                    SPI_CLK <= 1'b1; //high on even
                    //SPI_EN <= 1'b1;  
                    SPI_IN <= RegAddrIn[6];
                    Currentstate <= Currentstate + 1'b1;  
                end
                
                8'd05: begin    //D[5]      
                    SPI_CLK <= 1'b0; //low on odd
                    //SPI_EN <= 1'b1;  
                    SPI_IN <= RegAddrIn[5];  // bit 5
                    Currentstate <= Currentstate + 1'b1;
                end                  
                
                8'd06: begin         
                    SPI_CLK <= 1'b1;  //high on even
                    //SPI_EN <= 1'b1;  
                    SPI_IN <= RegAddrIn[5];
                    Currentstate <= Currentstate + 1'b1;  
                end                                    
                
                8'd07: begin    //D[4]                  
                    SPI_CLK <= 1'b0; //low on odd       
                    //SPI_EN <= 1'b1;                     
                    SPI_IN <= RegAddrIn[4];  // bit 4
                    Currentstate <= Currentstate + 1'b1;          
                end                                     
                                                        
                8'd08: begin                            
                    SPI_CLK <= 1'b1;  //high on even    
                    //SPI_EN <= 1'b1;                     
                    //SPI_IN <= RegAddrIn[4];
                    Currentstate <= Currentstate + 1'b1;                     
                end                                     
                
                8'd09: begin    //D[3]                  
                    SPI_CLK <= 1'b0; //low on odd       
                    //SPI_EN <= 1'b1;                     
                    SPI_IN <= RegAddrIn[3];  // bit 3
                    Currentstate <= Currentstate + 1'b1;           
                end                                     
                                                        
                8'd10: begin                            
                    SPI_CLK <= 1'b1;  //high on even    
                    //SPI_EN <= 1'b1;                     
                    SPI_IN <= RegAddrIn[3];
                    Currentstate <= Currentstate + 1'b1;                     
                end                                     
                
                8'd11: begin    //D[2]               
                    SPI_CLK <= 1'b0; //low on odd    
                    //SPI_EN <= 1'b1;                  
                    SPI_IN <= RegAddrIn[2];  // bit 2
                    Currentstate <= Currentstate + 1'b1;        
                end                                  
                                                     
                8'd12: begin                         
                    SPI_CLK <= 1'b1;  //high on even 
                    //SPI_EN <= 1'b1;                  
                    SPI_IN <= RegAddrIn[2]; 
                    Currentstate <= Currentstate + 1'b1;                 
                end
                
                8'd13: begin    //D[1]               
                    SPI_CLK <= 1'b0; //low on odd    
                    //SPI_EN <= 1'b1;                  
                    SPI_IN <= RegAddrIn[1];  // bit 1 
                    Currentstate <= Currentstate + 1'b1;       
                end                                  
                                                     
                8'd14: begin                         
                    SPI_CLK <= 1'b1;  //high on even 
                    //SPI_EN <= 1'b1;                  
                    SPI_IN <= RegAddrIn[1];      
                    Currentstate <= Currentstate + 1'b1;            
                end                                  
                
                8'd15: begin    //D[0]               
                    SPI_CLK <= 1'b0; //low on odd    
                    //SPI_EN <= 1'b1;                  
                    SPI_IN <= RegAddrIn[0];  // bit 0
                    Currentstate <= Currentstate + 1'b1;        
                end                                  
                                                     
                8'd16: begin                         
                    SPI_CLK <= 1'b1;  //high on even 
                    //SPI_EN <= 1'b1;                  
                    SPI_IN <= RegAddrIn[0];      
                    Currentstate <= Currentstate + 1'b1;            
                end                                  
                
                //FROM THIS POINT ON, OPERATION DIVERGES BETWEEN READING FROM AND WRITING TO REGISTERS                                 
                8'd17: begin
                    SPI_CLK <= 1'b0; //low on odd
                    //SPI_EN <= 1'b1; 
                    SPI_IN <= 1'b0;
                    Currentstate <= Currentstate + 1'b1;
                    
                    //if writing           
                    SPI_IN <= RegDataIn[7];
                end
                
                8'd18: begin
                    SPI_CLK <= 1'b1; //high on even
                    //if reading                                         
                    DataOut[7] <= CVM300_SPI_OUT; //reading bit 8 of data on clk high
                    Currentstate <= Currentstate + 1'b1;                    
                end
                
                8'd19: begin                                               
                    SPI_CLK <= 1'b0; //low on odd                          
                    //SPI_EN <= 1'b1;                                      
                    SPI_IN <= 1'b0;       
                    Currentstate <= Currentstate + 1'b1;                                 
                                                                           
                      
                      
                    //if writing                                        
                    SPI_IN <= RegDataIn[6];      //writing bit 7 of data                                                                         
                                              
                end                                                        
                                                                           
                8'd20: begin                                               
                    SPI_CLK <= 1'b1; //high on even 
                    //if reading                                         
                    DataOut[6] <= CVM300_SPI_OUT; //reading bit 7 of data of data on clk high
                    Currentstate <= Currentstate + 1'b1;
                                        
                end                                                        
                
                8'd21: begin                                               
                    SPI_CLK <= 1'b0; //low on odd                          
                    //SPI_EN <= 1'b1;                                      
                    SPI_IN <= 1'b0;   
                    Currentstate <= Currentstate + 1'b1;                                      
                    //if writing                                        
                    SPI_IN <= RegDataIn[5];      //writing bit 6 of data                                                       
                                    
                end                                                        
                                                                           
                8'd22: begin                                               
                    SPI_CLK <= 1'b1; //high on even
                    //if reading                                                               
                    DataOut[5] <= CVM300_SPI_OUT; //reading bit 6 of data of data on clk high  
                                                           
                    Currentstate <= Currentstate + 1'b1;                        
                end                                                        
                
                8'd23: begin                                               
                    SPI_CLK <= 1'b0; //low on odd                          
                    //SPI_EN <= 1'b1;                                      
                    SPI_IN <= 1'b0;  
                    Currentstate <= Currentstate + 1'b1;                                      
                                                                           
                    //if writing                                           
                    SPI_IN <= RegDataIn[4];                                
                end                                                        
                                                                           
                8'd24: begin                                               
                    SPI_CLK <= 1'b1; //high on even
                    //if reading                                                               
                    DataOut[4] <= CVM300_SPI_OUT; //reading bit 5 of data of data on clk high  
                                                            
                    Currentstate <= Currentstate + 1'b1;                       
                end
                
                8'd25: begin                                               
                    SPI_CLK <= 1'b0; //low on odd                          
                    //SPI_EN <= 1'b1;                                      
                    SPI_IN <= 1'b0;    
                    Currentstate <= Currentstate + 1'b1;                                    
                                                                                                                              
                    //if writing                                           
                    SPI_IN <= RegDataIn[3];                                
                end                                                        
                                                                           
                8'd26: begin                                               
                    SPI_CLK <= 1'b1; //high on even\
                    //if reading                                                               
                    DataOut[3] <= CVM300_SPI_OUT; //reading bit 7 of data of data on clk high                                        
                    Currentstate <= Currentstate + 1'b1;                       
                end                                                                                                                
                
                8'd27: begin                                               
                    SPI_CLK <= 1'b0; //low on odd                          
                    //SPI_EN <= 1'b1;                                      
                    SPI_IN <= 1'b0; 
                    Currentstate <= Currentstate + 1'b1;                                       
                                                                                                                               
                    //if writing                                           
                    SPI_IN <= RegDataIn[2];                                
                end                                                        
                                                                           
                8'd28: begin                                               
                    SPI_CLK <= 1'b1; //high on even
                    //if reading                                                               
                    DataOut[2] <= CVM300_SPI_OUT; //reading bit 7 of data of data on clk high                                     
                    Currentstate <= Currentstate + 1'b1;                        
                end
                
                8'd29: begin                                                  
                    SPI_CLK <= 1'b0; //low on odd                             
                    //SPI_EN <= 1'b1;                                         
                    SPI_IN <= 1'b0;   
                    Currentstate <= Currentstate + 1'b1;                                        
                    //if writing                                              
                    SPI_IN <= RegDataIn[1];                                   
                end                                                           
                                                                              
                8'd30: begin                                                  
                    SPI_CLK <= 1'b1; //high on even
                    //if reading                                                             
                    DataOut[1] <= CVM300_SPI_OUT; //reading bit 7 of data of data on clk high
                    Currentstate <= Currentstate + 1'b1;                           
                end                                                           
                
                8'd31: begin                                                  
                    SPI_CLK <= 1'b0; //low on odd                             
                    //SPI_EN <= 1'b1;                                         
                    SPI_IN <= 1'b0;     
                    Currentstate <= Currentstate + 1'b1;                                      
                                                              
                    //if writing                                              
                    SPI_IN <= RegDataIn[0];                                   
                end                                                           
                                                                              
                8'd32: begin                                                  
                    SPI_CLK <= 1'b1; //high on even
                    //if reading                                                             
                    DataOut[0] <= CVM300_SPI_OUT; //reading bit 7 of data of data on clk high
                    Currentstate <= Currentstate + 1'b1;                           
                end                                                           
                
                8'd33: begin
                    SPI_CLK <= 1'b0; //final negative edge of SPI_CLK
                    Currentstate <= Currentstate + 1'b1;
                end
                
                8'd34: begin
                    SPI_EN <= 1'b0; // disabling SPI 1 full clock cylce after CLK is high when the databit is sampled
                    Currentstate <= 8'b0; //return to idle once finished.
                end                     
                                           
                default: begin Currentstate = 4'd0; end            
                            
            endcase
        end     
                
       assign xled = {~FrameReqState,~Currentstate};
       
       wire trig_in_ack;
       
       ila_0 your_instance_name (
           .clk(clk), // input wire clk
           .trig_in(go2),// input wire trig_in 
           .trig_in_ack(trig_in_ack),// output wire trig_in_ack 
           .probe0(CVM300_D), // input wire [9:0]  probe0  
           .probe1(dout), // input wire [31:0]  probe1 
           .probe2(wr_en), // input wire [0:0]  probe2 
           .probe3(rd_en), // input wire [0:0]  probe3 
           .probe4(CVM300_FRAME_REQ), // input wire [0:0]  probe4 
           .probe5(almost_empty), // input wire [0:0]  probe5 
           .probe6(CVM300_FRAME_REQ), // input wire [0:0]  probe6 
           .probe7(CVM300_Data_valid) // input wire [0:0]  probe7
       );

    endmodule











