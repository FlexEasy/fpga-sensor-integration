`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2018 01:25:22 PM
// Design Name: 
// Module Name: counter60k
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


module counter60k(
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [31:0] count
    );
    
    initial begin
        count = 32'b0; //initialize counter to 0
    end 
    
    always @( posedge clk ) begin
        count <= count+1'b1; //by default count increments
    
//        else if( enable == 0 )
//            count <= count;
        
        if( count == 32'd307_200 ) begin //reset at 60,000
            count <= 32'd0;
        end
                      
    end
    
endmodule
