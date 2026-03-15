class fifo_monitor_in #(parameter DATA_WIDTH = 16) extends uvm_monitor;

    `uvm_component_utils(fifo_monitor_in)

    uvm_analysis_port #(fifo_packet) fifo_in;
    uvm_analysis_port #(fifo_packet) fifo_cov_in;

    virtual interface fifo_if vif;

    fifo_packet packet;

    int num_pkt_col = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        fifo_in = new("fifo_in", this);
        fifo_cov_in = new("fifo_cov_in", this);
    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), {"start of simulation phase", get_full_name()}, UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            fork
                get_driven_packet();
                fifo_reset();
            join_any
            disable fork;
        end
    endtask

    virtual function void connect_phase(uvm_phase phase);
        if(!uvm_config_db#(virtual fifo_if)::get(this, get_full_name(), "vif", vif))
            `uvm_error("NOVIF", "vif not set")
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: FIFO Monitor IN Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction

    task fifo_reset();
        begin
            @(negedge vif.wrst_n);
        end
    endtask

    task get_driven_packet();
        wait(vif.wrst_n == 1'b1);

        `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM);

        forever begin
            packet = fifo_packet#()::type_id::create("packet", this);

            collect_in_packet(packet.length, packet.parity, packet.id, packet.payload);
            // `uvm_info(get_type_name(), $sformatf("Packet Collected: \n%s", packet.sprint()), UVM_LOW);
            fifo_in.write(packet);
            fifo_cov_in.write(packet);
            num_pkt_col++;
        end
    endtask

    task collect_in_packet(
        output bit [DATA_WIDTH-1:0] length, 
        bit [DATA_WIDTH-1:0] parity,
        bit [DATA_WIDTH-1:0] id,
        logic [DATA_WIDTH-1:0] payload[]
    );
        fifo_packet packet_for_func_cov = fifo_packet#()::type_id::create("packet_for_func_cov", this);
        @(posedge vif.wclk iff(vif.w_en && !vif.full));
            id = vif.data_in;
    
        @(posedge vif.wclk iff(vif.w_en && !vif.full));
            length = vif.data_in;

        payload = new[length];

        foreach(payload[i]) begin
            packet_for_func_cov.w_en = vif.w_en;
            packet_for_func_cov.r_en = vif.r_en;
            packet_for_func_cov.empty = vif.empty;
            packet_for_func_cov.full = vif.full;
            fifo_cov_in.write(packet_for_func_cov);
            @(posedge vif.wclk iff(vif.w_en && !vif.full));
                payload[i] = vif.data_in;
        end

        @(posedge vif.wclk iff(vif.w_en && !vif.full));
        parity = vif.data_in;
        @(posedge vif.wclk iff(!vif.full));
        
    endtask

endclass