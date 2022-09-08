This directory contains two test scripts:
 - `testall` tests all the M-files with a `!#codgen -args`
   specification as well as test blocks `%#test`. It will run
   all of the tests in uncompiled modes as well as compiled with
   row-major and column-major.
   
 - `testbuild` tests the same M-files as `testall`, but it
   is meant to be used to test a single set of tests after
   `build_momp4cpp` without recompiling the codes.

This folder is not added into MATLAB's search path by default.
To run the tests, use the command `run tests/testall` or 
`run tests/testbuild` in its parent directory.
