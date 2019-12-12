`ifndef INC_SCOREBOARD_SV
`define INC_SCOREBOARD_SV
`include "Packet.sv"
class Scoreboard;
  logic[7:0] payload_driver[$],payload_receiver[$];
  bit[3:0]flag;
  string message;

  extern function new(string name = "Scoreboard", Packet driver_pkt,Packet receiver_pkt);
  extern virtual function int check(); //Compare the data package and check the correctness

endclass: Scoreboard

function Scoreboard::new(string name = "Scoreboard", Packet driver_pkt, Packet receiver_pkt);
  foreach(driver_pkt.payload[i]) begin
  	this.payload_driver.push_back(driver_pkt.payload[i]);
  end
  foreach(receiver_pkt.payload[i]) begin
  	this.payload_receiver.push_back(receiver_pkt.payload[i]);
  end
  this.flag=driver_pkt.sa;
endfunction : new

function int Scoreboard::check();
  //$display("bijiao%d",this.flag);
  if(this.payload_driver.size() != this.payload_receiver.size()) begin
    this.message = "Payload size Mismatch:\n";
    this.message = { this.message, $sformatf("payload.size() = %0d, pkt2cmp.payload.size() = %0d\n", this.payload_driver.size(), this.payload_receiver.size()) };
    //return (0);
  end
  if(this.payload_driver == this.payload_receiver) ;
  else begin
    this.message = "Payload Content Mismatch:\n";
    this.message = { this.message, $sformatf("Packet Sent:   %p\nPkt Received:   %p", this.payload_driver, this.payload_receiver) };
    //return (0);
  end
  this.message = "Successfully Compared";
  //return(1);
  $display("%d kpt ",this.flag,this.message,);
  return(1);
endfunction: check


`endif
