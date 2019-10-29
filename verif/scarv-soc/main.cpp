
#include <assert.h>

#include <map>
#include <queue>
#include <string>
#include <iostream>
#include <cstdlib>
#include <cstdio>

#include "dut_wrapper.hpp"
#include "testbench.hpp"

//! Struct containing all of the outside arguments to the testbench.
typedef struct tb_arguments {

    //! Suppress most printed messages.
    bool        quiet               = false;
    
    //! Do we ever dump out waves?
    bool        dump_waves          = false;
    
    //! Should we wait for a keypress before starting the sim?
    bool        wait_at_start       = false;

    //! Where to dump wave files out too?
    std::string vcd_wavefile_path   = "waves.vcd";

    //! Maximum length in ticks of the simulation.
    uint64_t    max_sim_time        = 10000;

    uint32_t    sim_pass_address    ; //!< Pass if CPU hits this address
    uint32_t    sim_fail_address    ; //!< Fail if CPU hits this address
    bool        use_sim_pass_address=false; //!< Use the pass address mechanism
    bool        use_sim_fail_address=false; //!< Use the fail address mechanism

} tb_arguments_t;

/*
@brief Responsible for parsing all of the command line arguments.
*/
void process_arguments(int argc, char ** argv, tb_arguments_t * args) {

    for(int i =1; i < argc; i ++) {
        std::string s (argv[i]);
        
        if(s.find("+WAVES=") != std::string::npos) {
            std::string fpath = s.substr(7);
            
            args -> vcd_wavefile_path = fpath;

            if(args -> vcd_wavefile_path != "") {

                args -> dump_waves        = true;

                if(!args -> quiet){
                std::cout << ">> Dumping waves to: " 
                          << args -> vcd_wavefile_path 
                          << std::endl;
                }
            }
        }
        else if(s.find("+PASS_ADDR=") != std::string::npos) {
            
            std::string pass_addr_str = s.substr(11);

            args -> sim_pass_address     = std::stoul(pass_addr_str,0,16);
            args -> use_sim_pass_address = true;

        }
        else if(s.find("+FAIL_ADDR=") != std::string::npos) {
            
            std::string fail_addr_str = s.substr(11);

            args -> sim_fail_address     = std::stoul(fail_addr_str,0,16);
            args -> use_sim_fail_address = true;

        }
        else if(s.find("+TIMEOUT=") != std::string::npos) {
            std::string time = s.substr(9);

            args -> max_sim_time= std::stoul(time) * 10;

            if(!args -> quiet) {
                std::cout << ">> Timeout after " 
                          << time
                          << " cycles."
                          <<std::endl;
            }
        }
        else if(s == "+WAIT") {

            args -> wait_at_start = true;

        }
        else if(s == "+q") {

            args -> quiet = true;

        }
        else if(s == "--help" || s == "-h") {
            std::cout << argv[0] << " [arguments]" << std::endl
            << "\t+q                            -" << std::endl
            << "\t+WAIT                         -" << std::endl
            << "\t+WAVES=<VCD dump file path>   -" << std::endl
            << "\t+TIMEOUT=<timeout after N>    -" << std::endl
            ;
            exit(0);
        }
        else {
            std::cout <<"ERROR: Unknown argument '"<<s<<"'"<<std::endl;
            exit(1);
        }
    }
}


//! Address to hex.
int a2h(char c)
{
    int num = (int) c;
    if(num < 58 && num > 47){
        return num - 48;
    }
    if(num < 103 && num > 96){
        return num - 87;
    }
    return num;
}


/*
@brief Top level simulation function.
*/
int main(int argc, char** argv) {

    printf("> ");
    for(int i = 0; i < argc; i ++) {
        printf("%s ",argv[i]);
    }
    printf("\n");

    // Holds command line arguments to the simulation.
    tb_arguments_t args;

    process_arguments(argc, argv, &args);
    
    // Instance and configure the testbench.
    testbench tb (args.vcd_wavefile_path, args.dump_waves);

    tb.wait_at_start= args.wait_at_start;
    tb.max_sim_time = args.max_sim_time;

    if(args.use_sim_pass_address) {
        if(!args.quiet) {
            std::cout << ">> Pass Address: " 
                      << std::hex << args.sim_pass_address << std::endl;
        }
        tb.set_pass_address(args.sim_pass_address);
    }
    
    if(args.use_sim_fail_address) {
        if(!args.quiet) {
            std::cout << ">> Fail Address: " 
                      << std::hex << args.sim_fail_address << std::endl;
        }
        tb.set_fail_address(args.sim_fail_address);
    }
    
    tb.run_simulation();

    std::cout << ">> Finished after " 
              << std::dec<<tb.get_sim_time()/10
              << " simulated clock cycles" << std::endl;

    // Did we pass/fail/timeout.
    if(tb.get_sim_time() >= args.max_sim_time) {
        
        std::cout << ">> TIMEOUT" << std::endl;
        return 1;

    } else if(tb.sim_passed) {
        
        std::cout << ">> SIM PASS" << std::endl;
        return 0;
        
    } else {

        std::cout << ">> SIM FAIL" << std::endl;
        return 2;

    }

}

