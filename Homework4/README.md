# Homework 4

## Multiplexer

The 32-bit multiplexer uses a basic tree-style hierarchy to pare down the selection of bits with each layer. The first layer uses a simple 2:1 multiplexer with an enable signal to select the input to release to output. 

The 4:1 multiplexer splits the input into two two-bit wires. The least significant bit of the enable signal (which is two bits for the 4:1) determines which of the bits in each of the two-bit wires should be selected for. The most significant bit then determines which wire should be enabled.

This simple structure is easily scalable by layer. At each layer, it employs two multiplexers that deal with half of the input bitstring each using all but the most significant bit of the enable bus. That most significant bit then is used to determine which of the multiplexers' outputs should be enabled.

As an example, if the bitstring is 10101100 and the enable bitstring is 010, then the program splits into two four-bit multiplexers with enable values of 10. The first multiplexer (defined as mux_low) takes in the less significant bitstring 1100 and returns the value at the enable index (10), 0. The second multiplexer (mux_high) takes in the bitstring 1010 and also returns the value at the enable index, 1. The most significant bit of the original enable bitstring then determines which multiplexer to choose, effectively acting as a 2:1 multiplexer for the output of mux_low and mux_high. Because the most significant bit is 0, the 8:1 multiplexer chooses the mux_low output, 0. 

### Testing the Multiplexer

Tests were run at all of the hierarchical levels of the multiplexer. The test files were based on example code from previous work done. The overall structure involves a nested for loops to iterate through all possible inputs and returning the outputs. For narrower multiplexers, iterating through to check all inputs return the correct outputs is quite simple. However, once the multiplexers reached even 8 bits, the results of test code were much too long. To combat this, smaller ranges within the total 4,294,967,296 possible different bitstrings that could be selected from were chosen. Each bitstring also is matched with a 5-bit enable signal, for a total of 137,438,953,472 different possible tests to run. 

To augment testing in random ranges, an overall random test was run to generate random 32-bit input signals and random 5-bit enable signals. This test checks that the enable signal works analogously to indexing to various input bits. For example, if the input bitstring is 0110011100101011, and the enable signal is 0101, the program checks that the index 5 in the input is equal to the output of the multiplexer.

Running this test is simple. After navigating to the correct directory, run the command "make test_mux32" and the test code will run. If the program returns "SUCCESS" at the end, no errors have been encountered.

## Adder

The 32-bit adder does not use the same hierarchical structure. It does rely on the basic function of a full adder that takes in two one-bit values and a carry in value. The full adder returns the one-bit sum and a one-bit carry out value.

The 32-bit form uses generate statements to create 32 full adders to deal with each bit of the input. It also uses a generate statement to calculate the generate and propagate signals at each index. 

The generate and propagate signals are characteristics of a carry-lookahead adder, where the generate signal determines whether two bits must "generate" a carry regardless of the carry in, and the propagate signal determines whether two bits would "propagate" a carry value if there is a carry in. 

These two signals are used to calculate the carry out from each bit. Doing these calculations separately allows for faster compute times and permits the adder to not wait for the full adder for each bit of the long string to calculate carry values before it can move to the next bit. 

The network of adders take in the carry values calculated using the generate and propagate signals (carry out = generate AND (propagate OR carry in)) to return a 32-bit sum much faster than a hierarchical network of adders or even a ripple carry adder. The final 33-bit output is determined by concatenating the final carry out value to the 32-bit sum. 

### Testing the Adder

The adder faces a similar problem with the multiplexer. Its sheer size prevents testing by reading all of the test outputs and verifying their values. Instead, each of the input values were swept across ranges of 100 at varying places across the total 2,147,483,648 options for each input. 

The first approach (test_adder32a.sv) used this method, but it was not effective. Instead, a second method was introduced to generate random numbers and check that they are added correctly. This method allows for checking of wide ranges of values, without having to iterate through parameters in all the various ranges. 

The program does not generate new random numbers every time it is run. Instead, it produces the same "random" numbers repeatedly. But it does help validate the function of the 32 bit adder. 

Running this test is simple. After navigating to the correct directory, run the command "make test_adder32" and the test code will run. If the program returns "SUCCESS" at the end, no errors have been encountered.

To run the first implementation that sweeps through inputs over specific ranges, simply run the command "make test_adder32a".