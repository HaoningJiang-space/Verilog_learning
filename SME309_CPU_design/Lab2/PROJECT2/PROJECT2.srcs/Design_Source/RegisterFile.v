module RegisterFile(
    input CLK,
    input WE3,
    input [3:0] A1,
    input [3:0] A2,
    input [3:0] A3,
    input [31:0] WD3,
    input [31:0] R15,

    output [31:0] RD1,
    output [31:0] RD2
    );
    
    // declare RegBank
    reg [31:0] RegBank[0:14] ;




 //写入时序逻辑
 always@(posedge CLK)begin
    if(WE3)begin
        RegBank[A3]<=WD3;
    end
 end

/*读取组合逻辑  单周期CPU，需要指令在一个周期内完成读写
寄存器R15的值由PC模块直接传入
寄存器R15不在RegBank中存储 实际上PC是R15*/
 assign RD1 = (A1==4'b1111) ? R15 : RegBank[A1];
 assign RD2 = (A2==4'b1111) ? R15 : RegBank[A2];
 


    
endmodule