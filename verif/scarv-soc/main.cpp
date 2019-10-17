
#include <assert.h>

#include <map>
#include <queue>
#include <string>
#include <iostream>
#include <cstdlib>
#include <cstdio>

#include "dut_wrapper.hpp"
#include "testbench.hpp"

bool        quiet               = false;

bool        dump_waves          = false;
std::string vcd_wavefile_path   = "waves.vcd";

uint64_t    max_sim_time        = 10000;

/*
@brief Responsible for parsing all of the command line arguments.
*/
void process_arguments(int argc, char ** argv) {

    for(int i =0; i < argc; i ++) {
        std::string s (argv[i]);
        
        if(s.find("+WAVES=") != std::string::npos) {
            std::string fpath = s.substr(7);
            vcd_wavefile_path = fpath;
            if(vcd_wavefile_path != "") {
                dump_waves        = true;
                if(!quiet){
                std::cout << ">> Dumping waves to: " << vcd_wavefile_path 
                          << std::endl;
                }
            }
        }
        else if(s.find("+TIMEOUT=") != std::string::npos) {
            std::string time = s.substr(9);
            max_sim_time= std::stoul(time) * 10;
            if(!quiet) {
            std::cout << ">> Timeout after " << time <<" cycles."<<std::endl;
            }
        }
        else if(s == "+q") {
            quiet = true;
        }
        else if(s == "--help" || s == "-h") {
            std::cout << argv[0] << " [arguments]" << std::endl
            << "\t+q                            -" << std::endl
            << "\t+WAVES=<VCD dump file path>   -" << std::endl
            << "\t+TIMEOUT=<timeout after N>    -" << std::endl
            ;
            exit(0);
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

    process_arguments(argc, argv);

    testbench tb (vcd_wavefile_path, dump_waves);

    tb.max_sim_time = max_sim_time;

    tb.run_simulation();

    std::cout << ">> Finished after " 
              << std::dec<<tb.get_sim_time()/10
              << " simulated clock cycles" << std::endl;


    if(tb.get_sim_time() >= max_sim_time) {
        
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

