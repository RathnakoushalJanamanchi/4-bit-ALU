module ALU(input [15:0] A,B,
           input en, input [3:0] opcode, output reg [31:0] result);
  always @(A or B or opcode or en ) begin
    if (en==1)
    case (opcode)
      4'b0000: result=A+B;       // ADDITION
      4'b0001: result=A-B;       // Subtraction
      4'b0010: result=A*B;       // Multiplication
      4'b0011: result=A/B;       // Division
      4'b0100: result=A+1;       // Increment
      4'b0101: result=A-1;       // Decrement
      4'b0110: result=~A;        // NOT gate
      4'b0111: result=A&B;       // AND gate
      4'b1000: result=A|B;       // OR gate
      4'b1001: result=A^B;       // XOR gate
      4'b1010: result=~(A&B);    // NAND gate
      4'b1011: result=~(A|B);    // NOR gate
      4'b1100: result=~(A^B);    // XNOR gate
      4'b1101: result=A>>1;      // RIGHT SHIFT
      4'b1110: result=A<<1;      // LEFT SHIFT
      4'b1111: result=A/B;       // DIVISION
      default : result=16'hxxxx;
    endcase
  end
endmodule