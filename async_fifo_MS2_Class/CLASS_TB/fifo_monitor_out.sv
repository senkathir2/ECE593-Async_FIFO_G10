class fifo_monitor_out #(parameter DATA_WIDTH = 8);

    virtual interface fifo_if vif;

    mailbox mon_scb_mb;

    fifo_packet packet;

    int num_pkt_col = 0;

    function new (mailbox mon_scb_mb, virtual interface fifo_if vif);
        this.mon_scb_mb = mon_scb_mb;
        this.vif = vif;
    endfunction

    task run();
        @(negedge vif.rrst_n);
        @(posedge vif.rrst_n);

        $display("[oMON] Detected Reset Done");
        
        forever begin
            packet = new;

            fork
                collect_packet(packet.length, packet.parity, packet.id, packet.payload);
            join
            $display("[oMON] ---------Packet Collected ID:%0d------- \n%p\n---------------------",packet.id, packet);
            mon_scb_mb.put(packet);
            num_pkt_col++;
        end
    endtask

    task collect_packet(
        output bit [DATA_WIDTH-1:0] length, 
        bit [DATA_WIDTH-1:0] parity, 
        bit [DATA_WIDTH-1:0] id,
        logic [DATA_WIDTH-1:0] payload[]
    );

        @(negedge vif.rclk);
        vif.r_en <= 1'b1;
        vif.monstart = 1'b1;

        @(posedge vif.rclk iff(!vif.empty));
            #1ns;
            id = vif.data_out;

        @(posedge vif.rclk iff(!vif.empty));
            #1ns;
            length = vif.data_out;

        payload = new[length];

        foreach(payload[i]) begin
            @(posedge vif.rclk iff(!vif.empty));
                #1ns;
                payload[i] = vif.data_out;
                vif.r_en <= 0;
            repeat(3) @(posedge vif.rclk iff(!vif.empty));
                vif.r_en <= 1;
        end

        @(posedge vif.rclk iff(!vif.empty));
            #1ns;
            parity = vif.data_out;
        @(posedge vif.rclk);
        
        vif.r_en <= '0;
        
        vif.monstart = 1'b0;
    endtask

endclass