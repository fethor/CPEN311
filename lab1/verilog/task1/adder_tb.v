module adder_tb();
   
  reg [7:0] SW;
  wire [3:0] LEDR;
   
  adder DUT (
    .SW(SW),
    .LEDR(LEDR)
  );
   
  initial begin
    SW = 8'b00000000;
    #5
    SW = 8'b00010001;
    #5
    SW = 8'b00100010;
    #5
    $finish;
  end
   
endmodule