#!/bin/csh

set i = 0
while($i<10)
set rand = `awk 'BEGIN {srand(); print int(rand()*100)}'`
echo $rand 
make run TESTNAME="led_basic_test" SEED=$rand >& /dev/null
make run TESTNAME="sdram_basic_test" SEED=$rand>& /dev/null
make run TESTNAME="master_basic_test" SEED=$rand >& /dev/null
echo "Iteration $i"
@ i++
end 

echo "Iteration $i"
set rand = `awk 'BEGIN {srand(); print int(rand()*100)}'`
make run TESTNAME="sdram_directed_test" SEED=$rand >& /dev/null
@ i++
echo "Iteration $i"
set rand = `awk 'BEGIN {srand(); print int(rand()*100)}'`
make run TESTNAME="sdram_directed1_test" SEED=$rand >& /dev/null
