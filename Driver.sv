`ifndef INC_DRIVERBASE_SV
`define INC_DRIVERBASE_SV
`include "Packet.sv"
class Driver;
 Packet pkt;
 //int p;

  extern function new(string name = "DriverBase",Packet pkt_in , virtual router_io.TB rtr_io);
  extern virtual task send(); //Send packet
  extern virtual task send_addrs(); //Subtask of the send task, used to send the address
  extern virtual task send_pad();   //Subtask of the send task, used to send the pad
  extern virtual task send_payload();//Subtask of the send task, used to send the payload

endclass

function Driver::new(string name = "DriverBase",Packet pkt_in ,virtual router_io.TB rtr_io );

  //Inside new() assign class property name with string passed via argument
  
  this.pkt = new();
  this.pkt=pkt_in.copy();
  //this.p=0;
endfunction: new


task Driver::send();
  
  	//$display("Driver%d",this.pkt.sa);
    this.send_addrs();
    this.send_pad();
    this.send_payload();
    //$display("Driver%d",this.pkt.sa);

  endtask: send

  task Driver::send_addrs();
  
    rtr_io.cb.frame_n[this.pkt.sa] <= 1'b0; //start of packet
    for(int i=0; i<4; i++) begin
      rtr_io.cb.din[this.pkt.sa] <= this.pkt.da[i]; //i'th bit of da
      @(rtr_io.cb);
    end

  endtask: send_addrs

  task Driver::send_pad();
  
    rtr_io.cb.frame_n[this.pkt.sa] <= 1'b0;
    rtr_io.cb.din[this.pkt.sa] <= 1'b1;
    rtr_io.cb.valid_n[this.pkt.sa] <= 1'b1;
    repeat(5) @(rtr_io.cb);

  endtask: send_pad

  task Driver::send_payload();
  
    foreach(pkt.payload[index])
      for(int i=0; i<8; i++) begin
        rtr_io.cb.din[this.pkt.sa] <= pkt.payload[index][i];
        rtr_io.cb.valid_n[this.pkt.sa] <= 1'b0; //driving a valid bit
        rtr_io.cb.frame_n[this.pkt.sa] <= ((i == 7) && (index == (this.pkt.payload.size() - 1)));
        @(rtr_io.cb);
      end
    rtr_io.cb.valid_n[this.pkt.sa] <= 1'b1;
  endtask: send_payload


`endif
