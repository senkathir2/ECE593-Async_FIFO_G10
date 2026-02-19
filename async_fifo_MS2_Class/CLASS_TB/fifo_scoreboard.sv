class fifo_scoreboard;

    mailbox mon_scb_mb;
    mailbox inf_mon_scb;

    fifo_packet packet_in, packet_out;

    fifo_packet in_quene[$];

    integer mismatch = 0;

    integer packets_received = 0;
    integer mismatch_packets = 0;


    function new (mailbox mon_scb_mb, mailbox inf_mon_scb);
        this.mon_scb_mb = mon_scb_mb;
        this.inf_mon_scb = inf_mon_scb;
    endfunction

    task run();
        fork
            get_inputs();
            check_packets();
        join_any
    endtask

    task get_inputs();
        forever begin
            inf_mon_scb.get(packet_in);
            in_quene.push_back(packet_in);
        end
    endtask

    task check_packets();
        fifo_packet packet = new;
        forever begin
            mon_scb_mb.get(packet_out);

            packet = in_quene.pop_front();

            if(packet.id != packet_out.id) begin
                $display("ID mismatch");
                mismatch = 1;
            end

            if(packet.length != packet_out.length) begin
                $display("Length mismatch");
                mismatch = 1;
            end

            foreach(packet.payload[i]) begin
                if(packet.payload[i] != packet_out.payload[i]) begin
                    // $display("Packet data mismatch at %0d", i);
                    mismatch = 1;
                end
            end

            if(packet.parity != packet_out.parity) begin
                $display("Parity mismatch");
                mismatch = 1;
            end

            if(mismatch) begin
                $display("[SCB] Packet In %p\n---------------\nPacket Out %p\n---------------", packet, packet_out);
            end
            
            if(!mismatch) $display("[SCB] Packet Match ID: %0d",packet.id);

            mismatch = 0;

            packets_received++;

            $display("packet received %0d", packets_received);
        end
    endtask

endclass