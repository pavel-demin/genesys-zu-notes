
`timescale 1 ns / 1 ps

module vadj_gpio
(
  input  wire       aclk,

  output wire [2:0] gpio
);

  reg [2:0] int_cntr_reg = 3'd0;

  wire int_and_wire = &int_cntr_reg;

  always @(posedge aclk)
  begin
    if(~int_and_wire)
    begin
      int_cntr_reg <= int_cntr_reg + 1'b1;
    end
  end

  assign gpio = {2'd3, int_and_wire};

endmodule
