module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import fifo_pkg::*;

    `include "fifo_tb.sv"
    `include "fifo_test_lib.sv"

    bit wclk, rclk;
    bit wrst_n, rrst_n;

    fifo_if vif(wclk, rclk, wrst_n, rrst_n);

    asynchronous_fifo as_fifo (
        .wclk(vif.wclk), 
        .rclk(vif.rclk), 
        .wrst_n(vif.wrst_n), 
        .rrst_n(vif.rrst_n),
        .w_en(vif.w_en),
        .r_en(vif.r_en),
        .data_in(vif.data_in),
        .data_out(vif.data_out),
        .full(vif.full),
        .empty(vif.empty),
        .full_3_4(vif.full_3_4),
        .empty_1_4(vif.empty_1_4)
    );

    clkgen wclkgen(.clk_period(4), .clk(wclk));
    clkgen rclkgen(.clk_period(4), .clk(rclk));

    initial begin
        vif.w_en = 0;
        vif.r_en = 0;
        wrst_n = 1'b0;
        rrst_n = 0;
        repeat(10) @(posedge wclk);
        wrst_n = 1'b1;
        repeat(20) @(posedge rclk);
        rrst_n = 1;
        // repeat(400) @(posedge wclk);
        // wrst_n = 1'b0;
        // rrst_n = 0;
        // @(posedge wclk);
        // wrst_n = 1'b1;
        // rrst_n = 1;
    end

    initial begin
        uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.tb.env.agent.*", "vif", vif);
        run_test("test2");
    end

endmodule