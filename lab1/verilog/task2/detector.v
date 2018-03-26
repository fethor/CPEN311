module detector(
  input [0:0] insig,
  input [0:0] reset,
  input [0:0] clk,
  output reg [0:0] alert);
  
  reg [1:0] c_state, n_state;
  
  always @(posedge clk) 
  begin
    c_state <= n_state;
  end
  
  always @(c_state)
  begin
    case (c_state)
      "00":
        if (insig) begin 
          n_state <= 2'b01;
        end else begin
          n_state <= 2'b00;
        end 
        
      "01": 
        if (insig) begin 
          n_state <= 2'b10;
        end else begin
          n_state <= 2'b01;
        end 
        
      "10": 
        if (insig) begin 
          n_state <= 2'b11;
        end else begin
          n_state <= 2'b10;
        end  
            
    