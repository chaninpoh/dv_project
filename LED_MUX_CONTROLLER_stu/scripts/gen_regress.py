#!/bin/python3
import csv
import subprocess
import re


# Input file path

input_file = "ask.csv"  # Replace with your actual filename



# Output file path

output_file = "run_commands.sh"



# Open the input CSV and output shell script

with open(input_file, mode='r') as csvfile, open(output_file, mode='w') as outfile:

    reader = csv.DictReader(csvfile)

    

    for row in reader:

        testname = row['TEST']

        run_id = row['RUN_ID']

        seed = row['SEED']

        match = re.match(r"^(.*?)(_\d+)$", testname)        

        testname_only = match.group(1)
        # Construct the command

        command = f"make run TESTNAME={testname_only} RUN_ID={run_id} SEED={seed} >& /dev/null"

        

        # Write to output file

        outfile.write(command + "\n")



print(f"Commands written to {output_file}")
result = subprocess.run(['chmod +x run_command.csh'],shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,universal_newlines=True )


# Print the output

print(result.stdout)





