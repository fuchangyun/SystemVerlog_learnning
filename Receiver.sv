`ifndef INC_RECEIVERBASE_SV
`define INC_RECEIVERBASE_SV
`include "Packet.sv"
class Receiver;
  Packet pkt2cmp;
  logic[7:0] pkt2cmp_payload[$];      // actual packet data array
  //static int pkt_cnt;

  extern function new(string name = "ReceiverBase", Packet pkt_in, virtual router_io.TB rtr_io);
  extern virtual task recv(); //Receive packets from the DUT output port
  extern virtual task get_payload();

endclass

function Receiver::new (string name = "ReceiverBase", Packet pkt_in, virtual router_io.TB rtr_io);
  this.pkt2cmp=new();
  this.pkt2cmp=pkt_in.copy();
  //pkt_cnt = 0;
endfunction : new

task Receiver::recv();
	//$display("rwceiver%d",this.pkt2cmp.sa);
  get_payload();
    //Assign pkt2cmp.da with global da
  //this.pkt2cmp.da = this.pkt.da;
    //Assign pkt2cmp.payload with pkt2cmp_payload
  this.pkt2cmp.payload = pkt2cmp_payload;
    //Set a unique name for pkt2cmp. Use pkt_cnt
  this.pkt2cmp.name = $sformatf("rcvdPkt[%0d]", this.pkt2cmp.sa);
  endtask: recv

task Receiver::get_payload();
    pkt2cmp_payload.delete();
    fork
      begin: wd_timer_fork
      fork: frameo_wd_timer
        //Do not use @(negedge rtr_io.cb.frameo_n[da]);
    //This may cause timing issues because of how the LRM defines it.
    begin
      wait(rtr_io.cb.frameo_n[this.pkt2cmp.da] != 0);
      @(rtr_io.cb iff(rtr_io.cb.frameo_n[this.pkt2cmp.da] == 0 ));
    end
        begin                              //this is another thread
          repeat(1000) @(rtr_io.cb);
          $display("\n%m\n[ERROR]%t Frame signal timed out!\n", $realtime);
          $finish;
        end
      join_any: frameo_wd_timer
      disable fork;
      end: wd_timer_fork
    join

    forever begin
      logic[7:0] datum;
      for(int i=0; i<8; i=i)  begin 
        if(!rtr_io.cb.valido_n[this.pkt2cmp.da])
          datum[i++] = rtr_io.cb.dout[this.pkt2cmp.da];
        if(rtr_io.cb.frameo_n[this.pkt2cmp.da])
          if(i==8) begin //byte alligned
            pkt2cmp_payload.push_back(datum);
            return;      //done with payload
          end

          else begin
            $display("\n%m\n[ERROR]%t Packet payload not byte aligned!\n", $realtime);
            $finish;
          end
        @(rtr_io.cb);
      end
      pkt2cmp_payload.push_back(datum);
    end
endtask: get_payload

`endif
