//  input logic wclk, wrst_n,
//  input logic rclk, rrst_n,
//  input logic w_en, r_en,
//  input logic [DATA_WIDTH-1:0] data_in,
//  output logic [DATA_WIDTH-1:0] data_out,
//  output logic full, empty

class fifo_packet #(parameter DATA_WIDTH = 8);

    //packet properties
    randc logic [DATA_WIDTH-1:0] id;
    rand logic [DATA_WIDTH-1:0] length;
    rand logic [DATA_WIDTH-1:0] payload[];
    logic [DATA_WIDTH-1:0] parity;

    rand int write_idle_cycles;
    rand int read_idle_cycles; 

    //constraints
    constraint len {length > 0;}
    constraint pkt_len { payload.size() == length; }
    constraint idle_cycles { write_idle_cycles == 0; read_idle_cycles == 4;}

    //packet methods
    function bit [DATA_WIDTH-1:0] calc_parity();
        calc_parity = '0;
        foreach(payload[i]) begin
            calc_parity = calc_parity^payload[i];
        end
    endfunction

    function void set_parity();
        parity = calc_parity();
    endfunction

    function void post_randomize();
        set_parity();
        cg.sample();
    endfunction

    //coverage
    covergroup cg;
        coverpoint length;
    endgroup

    function new();
        cg = new;
    endfunction

endclass