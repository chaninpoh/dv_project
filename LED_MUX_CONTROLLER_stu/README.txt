# 📘 Simulation Environment README



This repository provides a structured simulation flow for SystemVerilog/UVM-based testbenches using Makefile automation. It supports compilation, elaboration, and execution of tests via standardized commands.



---



## Quick Start
cd  LED_MUX_CONTROLLER_name
source proj1.setup



cd ./sim/ folder to start.


### 1. Build and run (Compile)


make dv TESTNAME=<testname> SEED=<seed>

###  	Compiles all SystemVerilog/UVM source files.

###  	Checks syntax, resolves dependencies, and prepares for elaboration.


### Runs the specified test, and other runtime options

### Replace <testname>  with the name of your UVM test class (e.g., , ).



### Example
make build

make elab

make run TESTNAME="basic_test"


### Directory Structure
├── src/              # RTL and testbench source files

├── tb/               # Testbench components (env, agent, sequences)

├── sim/            # UVM test classes

	├── Makefile          # Build automation

├── README.txt         # This file


###📄 Licensing and Proper Use

This simulation framework is provided for educational and professional development purposes. Please observe the following:

- Use responsibly: Ensure all IP blocks and third-party libraries are properly licensed.

- Respect confidentiality: Do not include proprietary or client-specific code unless authorized.

- Credit original authors: If you reuse components or templates, retain original attribution headers.

- No redistribution: Do not publicly distribute modified versions without permission.

If your project integrates commercial tools (e.g., Synopsys VCS), ensure you have valid licenses and follow vendor usage guidelines.

### Troubleshooting

- Compilation errors: Check for missing files, incorrect paths, or syntax issues.

- Elaboration failures: Verify hierarchy, parameter overrides, and UVM component registration.

- Runtime issues: Use +UVM_VERBOSITY=UVM_DEBUG and +UVM_CONFIG_DB_TRACE for debugging.



### Contact

For questions, contributions, or bug reports, please reach out to the Su Lin Poh(slpoh@consultetl.com) or PSDC Trainers.









