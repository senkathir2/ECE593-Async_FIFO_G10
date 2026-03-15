class fifo_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(fifo_scoreboard)

    `uvm_analysis_imp_decl(_fifo_in)
    `uvm_analysis_imp_decl(_fifo_out)

    uvm_analysis_imp_fifo_in #(fifo_packet, fifo_scoreboard) fifo_in;
    uvm_analysis_imp_fifo_out #(fifo_packet, fifo_scoreboard) fifo_out;

    fifo_packet packet_in, packet_out;

    fifo_packet in_queue[$];

    integer mismatch = 0;

    integer packets_received = 0;
    integer fifo_in_packets_received = 0;
    integer fifo_out_packets_received = 0;


    function new (string name = "", uvm_component parent);
        super.new(name, parent);
        fifo_in = new("fifo_in", this);
        fifo_out = new("fifo_out", this);
    endfunction

    virtual function void write_fifo_in(fifo_packet packet);
        fifo_packet sb_packet;
        $cast(sb_packet, packet.clone());
        in_queue.push_back(sb_packet);
        fifo_in_packets_received++;
    endfunction

    virtual function void write_fifo_out(fifo_packet packet);
        packet_out = in_queue.pop_front();
        fifo_out_packets_received++;
        if(packet.compare(packet_out)) 
            `uvm_info("COMPARE", "Packets match", UVM_LOW)
        else begin
            mismatch++;
            `uvm_error("COMPARE", "Packets do not match")
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Checking FIFO Scoreboard", UVM_LOW)
        if(in_queue.size())
            `uvm_error(get_type_name(), $sformatf("Check:\n\n FIFO Scorboard Queue Not Empty in_queue %0d", in_queue.size()))
        else
            `uvm_info(get_type_name(), "Check: \n\n FIFO Scoreboard Queue Empty", UVM_LOW)
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(
            get_type_name(), 
            $sformatf("Report: \n\n Scoreboard: Statistics \n FIFO In Packets :%0d FIFO Out Packets :%0d \n Mismatch :%0d", fifo_in_packets_received, fifo_out_packets_received, mismatch),
            UVM_LOW
        )
        if(mismatch || fifo_in_packets_received != fifo_out_packets_received)
            `uvm_error(get_type_name(), "Sim Failed")
        else
            `uvm_info(get_type_name(), "Sim Passed", UVM_NONE)
    endfunction

endclass