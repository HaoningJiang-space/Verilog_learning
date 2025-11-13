module ProgramCounter(
    input CLK,
    input Reset,
    input PCSrc,
    input [31:0] Result,
    
    output reg [31:0] PC,
    output [31:0] PC_Plus_4
); 
//æœ?ç»ˆåœåœ?0x00000018
//fill your Verilog code here
always@(posedge CLK )begin //in order to be the same as the waveform in PPT Lab2 ,change the method of reset
        if(Reset)begin
            PC<=32'd0;
        end
        else begin
             if (PCSrc)
            PC<=Result;
             else
            PC<=PC_Plus_4;
        end
end

assign PC_Plus_4=PC+32'd4;



endmodule