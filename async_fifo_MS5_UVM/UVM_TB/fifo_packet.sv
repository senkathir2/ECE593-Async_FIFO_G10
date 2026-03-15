//  input logic wclk, wrst_n,
//  input logic rclk, rrst_n,
//  input logic w_en, r_en,
//  input logic [DATA_WIDTH-1:0] data_in,
//  output logic [DATA_WIDTH-1:0] data_out,
//  output logic full, empty
class fifo_packet #(parameter DATA_WIDTH = 16) extends uvm_sequence_item;

    //packet properties
    randc logic [DATA_WIDTH-1:0] id;
    rand logic [DATA_WIDTH-1:0] length;
    rand logic [DATA_WIDTH-1:0] payload[];
    logic [DATA_WIDTH-1:0] parity;

    rand int write_idle_cycles;
    rand int read_idle_cycles;

    //control signals for func cov
    bit w_en;
    bit r_en;
    bit full;
    bit empty;

    `uvm_object_utils_begin(fifo_packet)
        `uvm_field_int(id, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(length, UVM_ALL_ON | UVM_DEC)
        `uvm_field_array_int(payload, UVM_ALL_ON)
        `uvm_field_int(parity, UVM_ALL_ON)
        `uvm_field_int(write_idle_cycles, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
        `uvm_field_int(read_idle_cycles, UVM_ALL_ON | UVM_DEC | UVM_NOCOMPARE)
    `uvm_object_utils_end

    //constraints
    constraint len {length > 0;}
    constraint pkt_len { payload.size() == length; }
    constraint idle_cycles { write_idle_cycles == 0; read_idle_cycles == 3;}

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
    endfunction

    function new(string name = "fifo_packet");
        super.new(name);
    endfunction

endclass