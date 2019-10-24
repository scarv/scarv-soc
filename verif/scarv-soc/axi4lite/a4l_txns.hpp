
#include <cstdint>
#include <utility>

#ifndef A4L_TXNS_HPP
#define A4L_TXNS_HPP

//! Typedef for an AXI4 Lite transaction ID.
typedef uint64_t a4l_txn_id_t;

//! AXI response classifications
typedef enum {
    A4L_OKAY    = 0,
    A4L_EXOKAY  = 1,
    A4L_SLVERR  = 2,
    A4L_DECERR  = 3
} a4l_resp_t;

    
//! Counter for assigning unique id's to new transactions.
static a4l_txn_id_t __a4l_txn_id_counter;

//! Base class for all AXI4 Lite transactions.
class a4l_txn {

public:

    a4l_txn () {
        this -> id = __a4l_txn_id_counter++;
    }
    
    //! Return the unique ID of this transaction.
    a4l_txn_id_t get_id() {
        return id;
    }
    
protected:
    
    //! Unique ID for the transaction
    a4l_txn_id_t id;

};


//! AXI4Lite address read channel transaction.
class a4l_ar_txn : public a4l_txn {

public:
    
    //! Create a new AXI4Lite read request.
    a4l_ar_txn (
        uint32_t txn_address,   //!< Target address of the read
        uint8_t  txn_prot       //!< Protection characteristics of the read.
    ) : a4l_txn() {
        this -> address = txn_address;
        this -> prot    = txn_prot   ;
    }
    
    //! Address of the read request.
    uint32_t address;
    
    //! Protection characteristics of the request.
    uint8_t  prot   ;

};


//! AXI4Lite address write channel transaction.
class a4l_aw_txn : public a4l_txn {

public:
    
    //! Create a new AXI4Lite read request.
    a4l_aw_txn (
        uint32_t txn_address,   //!< Target address of the write.
        uint8_t  txn_prot       //!< Protection characteristics of the read.
    ) : a4l_txn() {
        this -> address = txn_address;
        this -> prot    = txn_prot   ;
    }
    
    //! Address of the write request.
    uint32_t address;
    
    //! Protection characteristics of the request.
    uint8_t  prot   ;

};


//! AXI4Lite write data channel transaction.
class a4l_w_txn : public a4l_txn {

public:
    
    //! Create a new AXI4Lite Write data transaction.
    a4l_w_txn (
        uint32_t txn_data   ,   //!< Data to write
        uint8_t  txn_strb       //!< Strobe bits
    ) : a4l_txn() {
        this -> data    = txn_data   ;
        this -> strb    = txn_strb   ;
    }
    
    //! Data to write
    uint32_t data   ;
    
    //! Byte strobe lines. Only uses the low nibble.
    uint8_t  strb   ;

};

//! Typedef of a pair defining a complete A4L write transaction.
typedef std::pair<a4l_aw_txn*,a4l_w_txn*> a4l_write_txn;

//! AXI4Lite read data channel transaction.
class a4l_r_txn : public a4l_txn {

public:
    
    //! Create a new AXI4Lite read data transaction.
    a4l_r_txn (
        uint32_t   txn_data   ,   //!< Data read
        a4l_resp_t txn_resp       //!< Transaction response.
    ) : a4l_txn() {
        this -> data    = txn_data   ;
        this -> resp    = txn_resp   ;
    }

    //! Data read
    uint32_t    data   ;
    
    //! Transaction response
    a4l_resp_t  resp   ;

};


//! AXI4Lite write response channel transaction.
class a4l_b_txn : public a4l_txn {

public:
    
    //! Create a new AXI4Lite write response transaction.
    a4l_b_txn (
        a4l_resp_t txn_resp       //!< Transaction response.
    ) : a4l_txn() {
        this -> resp    = txn_resp   ;
    }

    //! Transaction response
    a4l_resp_t  resp   ;

};

#endif

