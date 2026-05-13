module ALU_tb;
  reg [15:0] A, B;
  reg [3:0] opcode;
  reg en;
  wire [31:0] result;

  ALU a1(A, B, en, opcode, result);

  // VCD setup block — runs at time 0
  initial begin
    $dumpfile("dump.vcd");       // Create VCD file
    $dumpvars(0, ALU_tb);        // Dump all variables in ALU_tb
  end

  // Stimulus block
  initial begin
    for (integer i = 0; i < 20; i = i + 1) begin
      A = $random();
      B = $random();
      en = 1;
      opcode = $random;
      #5;
      $display("A=%d, B=%d, en=%d, opcode=%b, result=%d", A, B, en, opcode, result);
    end
  end

  // Simulation end block
  initial begin
    #400;
    $finish();
  end
endmodule