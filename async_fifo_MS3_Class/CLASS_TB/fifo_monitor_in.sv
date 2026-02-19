class fifo_monitor_in #(parameter DATA_WIDTH = 8);

    mailbox inf_mon_scb;

    virtual interface fifo_if vif;

    fifo_packet packet;

    int num_pkt_col = 0;

    function new(mailbox inf_mon_scb, virtual interface fifo_if vif);
        this.inf_mon_scb = inf_mon_scb;
        this.vif = vif;
    endfunction

    task run();
        @(negedge vif.wrst_n);
        @(posedge vif.wrst_n);

        $display("[iMON] Detected Reset Done");

        forever begin
            packet = new;

            collect_in_packet(packet.length, packet.parity, packet.id, packet.payload);
            $display("[iMON] ---------Packet Collected ID: %0d------- \n%p\n---------------------", packet.id, packet);
            inf_mon_scb.put(packet);
            num_pkt_col++;
        end

    endtask

    task collect_in_packet(
        output bit [DATA_WIDTH-1:0] length, 
        bit [DATA_WIDTH-1:0] parity,
        bit [DATA_WIDTH-1:0] id,
        logic [DATA_WIDTH-1:0] payload[]);

        @(posedge vif.wclk iff(vif.w_en && !vif.full));
            id = vif.data_in;
    
        @(posedge vif.wclk iff(vif.w_en && !vif.full));
            length = vif.data_in;

        payload = new[length];

        foreach(payload[i]) begin
            @(posedge vif.wclk iff(vif.w_en && !vif.full));
                payload[i] = vif.data_in;
        end

        @(posedge vif.wclk iff(vif.w_en && !vif.full));
        parity = vif.data_in;
        @(posedge vif.wclk iff(!vif.full));
        
    endtask

endclass