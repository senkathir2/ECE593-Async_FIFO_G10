module clkgen(
    input logic [31:0] clk_period,
    output bit clk = 0
);
    always begin
        #(clk_period/2);
        clk = ~ clk;
    end
endmodule