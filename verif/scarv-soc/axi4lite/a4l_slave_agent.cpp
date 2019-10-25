
#include <iostream>

#include "a4l_slave_agent.hpp"
    
a4l_slave_agent::a4l_slave_agent (
    uint8_t  * awvalid,
    uint8_t  * awready,
    uint32_t * awaddr ,
    uint8_t  * awprot ,
    uint8_t  * wvalid ,
    uint8_t  * wready ,
    uint32_t * wdata  ,
    uint8_t  * wstrb  ,
    uint8_t  * bvalid ,
    uint8_t  * bready ,
    uint8_t  * bresp  ,
    uint8_t  * arvalid,
    uint8_t  * arready,
    uint32_t * araddr ,
    uint8_t  * arprot ,
    uint8_t  * rvalid ,
    uint8_t  * rready ,
    uint8_t  * rresp  ,
    uint32_t * rdata  
){
    sig_awvalid = awvalid;
    sig_awready = awready;
    sig_awaddr  = awaddr ;
    sig_awprot  = awprot ;
    sig_wvalid  = wvalid ;
    sig_wready  = wready ;
    sig_wdata   = wdata  ;
    sig_wstrb   = wstrb  ;
    sig_bvalid  = bvalid ;
    sig_bready  = bready ;
    sig_bresp   = bresp  ;
    sig_arvalid = arvalid;
    sig_arready = arready;
    sig_araddr  = araddr ;
    sig_arprot  = arprot ;
    sig_rvalid  = rvalid ;
    sig_rready  = rready ;
    sig_rdata   = rdata  ;
    sig_rresp   = rresp  ;
}

//! Must be called on the rising edge of each clock cycle.
void a4l_slave_agent::on_posedge_clk(){
    
    handle_channel_r();
    handle_channel_b();

    handle_channel_ar();

    handle_channel_aw();
    handle_channel_w();

    *sig_awready  = n_sig_awready      ;

    *sig_wready   = n_sig_wready       ;

    *sig_bresp    = n_sig_bresp        ;
    *sig_bvalid   = n_sig_bvalid       ;

    *sig_arready  = n_sig_arready      ;

    *sig_rdata    = n_sig_rdata        ;
    *sig_rvalid   = n_sig_rvalid       ;
    *sig_rresp    = n_sig_rresp        ;

}

//! Must be called whenever the bus reset signal is set.
void a4l_slave_agent::set_reset(){

    //
    // Clear channel flow control signals.
    *sig_arready = 0;
    *sig_awready = 0;
    *sig_wready  = 0;
    *sig_bvalid  = 0;
    *sig_rvalid  = 0;
    
    n_sig_arready = 0;
    n_sig_awready = 0;
    n_sig_wready  = 0;
    n_sig_bvalid  = 0;
    n_sig_rvalid  = 0;
    
    //
    // Empty the request and response queues.

    while(read_reqs.size()) {               // Read Requests
        delete read_reqs.front();
        read_reqs.pop();
    }
    
    while(write_addr_reqs.size()) {         // Write Address Requests
        delete write_addr_reqs.front();
        write_addr_reqs.pop();
    }
   
    while(write_data_reqs.size()) {         // Write Data Requests
        delete write_data_reqs.front();
        write_data_reqs.pop();
    }

}

//! Must be called whenever the bus reset signal is cleared.
void a4l_slave_agent::clr_reset() {

    // Randomise each of the channel ready control flow signals.
    
    n_sig_arready   = (uint8_t)rand_chance(5,10);
    n_sig_awready   = (uint8_t)rand_chance(5,10);
    n_sig_wready    = (uint8_t)rand_chance(5,10);
    
    *sig_arready        = n_sig_arready;
    *sig_awready        = n_sig_awready;
    *sig_wready         = n_sig_wready ;

}


//! Accept new requests from the AR channel.
void a4l_slave_agent::handle_channel_ar() {

    if(*sig_arvalid && *sig_arready) {
        
        a4l_ar_txn * new_ar = new a4l_ar_txn (
            *sig_araddr,
            *sig_arprot
        );

        this -> read_reqs.push(new_ar);

    }

    n_sig_arready = (uint8_t)rand_chance(5,10);

}


//! Accept new requests from the AW channel.
void a4l_slave_agent::handle_channel_aw() {

    if(*sig_awvalid && *sig_awready) {
        
        a4l_aw_txn * new_aw = new a4l_aw_txn (
            *sig_awaddr,
            *sig_awprot
        );

        this -> write_addr_reqs .push(new_aw);

    }

    n_sig_awready = (uint8_t)rand_chance(5,10);

}


//! Accept new requests from the AW channel.
void a4l_slave_agent::handle_channel_w() {

    if(*sig_wvalid && *sig_wready) {
        
        a4l_w_txn * new_w = new a4l_w_txn (
            *sig_wdata,
            *sig_wstrb
        );

        this -> write_data_reqs.push(new_w);

    }

    n_sig_wready = (uint8_t)rand_chance(5,10);

}


//! Send read responses
void a4l_slave_agent::handle_channel_r () {

    if(*sig_rvalid && *sig_rready) {

        delete read_reqs.front();
        
        read_reqs.pop();
        
        n_sig_rvalid = 0;

    } else if(*sig_rvalid && !*sig_rready) {
        
        n_sig_rvalid = 1;
        return;

    }
    
    else if(read_reqs.size() && rand_chance(5,10)) {
        
        a4l_ar_txn * req = read_reqs.front();

        memory_req_txn * req_txn = new memory_req_txn (
            req -> address, 4, false
        );

        memory_rsp_txn * rsp_txn = bus -> request(req_txn);

        n_sig_rdata  = rsp_txn -> data_word();
        n_sig_rresp  = rsp_txn -> error()    ? 2 : 0;
        n_sig_rvalid = 1;

        delete req_txn;
        delete rsp_txn;

    } else {
        
        n_sig_rvalid = 0;

    }

}

//! Send write responses
void a4l_slave_agent::handle_channel_b () {

    if(*sig_bvalid && *sig_bready) {

        delete write_addr_reqs.front();
        delete write_data_reqs.front();
        
        write_addr_reqs.pop();
        write_data_reqs.pop();
        
        n_sig_bvalid = 0;

    } else if(*sig_bvalid && !*sig_bready) {
        
        n_sig_bvalid = 1;
        return;

    }

    if(write_addr_reqs.size() &&
       write_data_reqs.size() &&
       rand_chance(5,10)        ) {
        
        a4l_aw_txn * req_addr = write_addr_reqs.front();
        a4l_w_txn  * req_data = write_data_reqs.front();
        
        memory_req_txn * req_txn = new memory_req_txn (
            req_addr -> address, 4, true
        );

        req_txn -> data()[0] = (req_data -> data >>  0) & 0xFF;
        req_txn -> data()[1] = (req_data -> data >>  8) & 0xFF;
        req_txn -> data()[2] = (req_data -> data >> 16) & 0xFF;
        req_txn -> data()[3] = (req_data -> data >> 24) & 0xFF;

        req_txn -> strb()[0] = (req_data -> strb >>  0) & 0x1 ;
        req_txn -> strb()[1] = (req_data -> strb >>  1) & 0x1 ;
        req_txn -> strb()[2] = (req_data -> strb >>  2) & 0x1 ;
        req_txn -> strb()[3] = (req_data -> strb >>  3) & 0x1 ;

        memory_rsp_txn * rsp_txn = bus -> request(req_txn);

        n_sig_bresp  = rsp_txn -> error()    ? 2 : 0;
        n_sig_bvalid = 1;

        delete req_txn;
        delete rsp_txn;

    } else {
        
        n_sig_bvalid = 0;

    }

}
