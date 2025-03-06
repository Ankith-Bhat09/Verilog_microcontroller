module pc (
    input wire [31:0]next,
    input wire clk,
    input wire reset,
    output reg [31:0]ppc
);
    always @(posedge clk ) begin
        if(reset)
        ppc<=32'b0;
        else
        ppc<=next;
    end
endmodule
