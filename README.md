# Systolic Array implementation in Verilog

Systolic array design that reads a sequence of matrix sizes x_i, matrices a_i and b_i, and performs a matrix multiplication.
Design was tested in EDA playground with the Icarus Verilog 0.10.0 simulator.

Files
-----
* `design.v`: Design of circuit. Contains modules for the top level circuit, instruction memory, input (matrix) memories, output memory, systolic array, and array processors.
* `diagram.png`: Image of a top-level diagram drawn in CircuitSim to show the signaling. Shows state machine as seperate but it is implmented in the top modeue in design.v.
* `testbench.v`: Runs a test case from a file and prints the resulting matrix and how many elements are correct.
* `testgen.py`: Contains Python code to generate test cases with random instruction length, matrix sizes, and matrix values. Matrices are preprocessed with padding before writing to a file.
* `cases/`: test cases
 * `test_x.txt`: test case x
 * `mandatory_test.txt`: contains test case with instructions [4,8,16] and random matrices
* `results/`
  * `result_x.txt`: test case x results
  * `mandatory_result.txt`: contains results for mandatory_test.txt
 

Design.sv Modules:
* `top`: contains top level controller with state machine as well as instantiation of memory and systolic array modules.
  * Defines control signal equivalents to read enable A, B, I, O, write enable O, and reset_array. These manipulate actions based off the current state.
* `instruction_memory`: Has 3 bits of storage so store up to 8 instructions (matrix sizes)
* `output_memory`: Contains output of systolic array sequentially, with a new matrix starting every 16 indices.
* `input_memory`: Instantiated into memoryA and memoryB. Stores matrix values with padding to with output wires into the systolic array.
* `processor`:  Computes C = C + A*B. A and B are matrix values, and C is an output register that gets incremented. C is reset after each instruction.
* `systolic_array`: Instantiated 16 processors (4 by 4 systolic array), and creates wire connections between processing elements as well as providing input.
