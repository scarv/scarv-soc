
#include <cstdint>
#include <queue>
#include <utility>
#include <cstdlib>

#include "a4l_txns.hpp"

#ifndef A4L_AGENT_HPP
#define A4L_AGENT_HPP


class a4l_slave_agent {

public:
    
    //! create a new slave agent from the supplied signal variable pointers.
    a4l_slave_agent (
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
    );


    //! Must be called on the rising edge of each clock cycle.
    void on_posedge_clk();

    //! Must be called whenever the bus reset signal is set.
    void set_reset();

    //! Must be called whenever the bus reset signal is cleared.
    void clr_reset();

protected:

    //! Accept new requests from the AR channel.
    void handle_channel_ar();

    //! Send the next read response to the R channel
    void handle_channel_r();

    //! Accept new requests from the W address channel
    void handle_channel_aw();

    //! Accept new requests from the W data channel
    void handle_channel_w();

    //! Send the next write response to the B channel
    void handle_channel_b();

    //! Queue of outstanding read requests.
    std::queue<a4l_ar_txn*> read_reqs;

    //! Queue of outstanding write address requests.
    std::queue<a4l_aw_txn*> write_addr_reqs;
    
    //! Queue of outstanding write data requests.
    std::queue<a4l_w_txn *> write_data_reqs;

    //
    // These are the pointers to the verilated signals.

    uint8_t  * sig_awvalid      ; //
    uint8_t  * sig_awready      ; //
    uint32_t * sig_awaddr       ; //
    uint8_t  * sig_awprot       ; //
    uint8_t  n_sig_awready = 0  ;
    
    uint8_t  * sig_wvalid       ; //
    uint8_t  * sig_wready       ; //
    uint32_t * sig_wdata        ; //
    uint8_t  * sig_wstrb        ; //
    uint8_t  n_sig_wready  = 0  ;
    
    uint8_t  * sig_bvalid       ; //
    uint8_t  * sig_bready       ; //
    uint8_t  * sig_bresp        ; //
    uint8_t  n_sig_bresp        ;
    uint8_t  n_sig_bvalid   = 0 ;
    
    uint8_t  * sig_arvalid      ; //
    uint8_t  * sig_arready      ; //
    uint32_t * sig_araddr       ; //
    uint8_t  * sig_arprot       ; //
    uint8_t  n_sig_arready  = 0 ;
    
    uint8_t  * sig_rvalid       ; //
    uint8_t  * sig_rready       ; //
    uint32_t * sig_rdata        ; //
    uint8_t  * sig_rresp        ; //
    uint32_t n_sig_rdata    = 0 ;
    uint8_t  n_sig_rvalid   = 0 ;
    uint8_t  n_sig_rresp    = 0 ;


    bool rand_chance(int x, int y) {
        return (std::rand() % y) < x;
    }


};


#endif
