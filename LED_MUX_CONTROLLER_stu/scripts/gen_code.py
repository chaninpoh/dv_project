#!/bin/python3
print(f" covergroup payload_cg(input int burst_no);")
print(f"PL:  coverpoint payload[burst_no] {{") 
print(f"bins zero = {{0}};")
print(f"bins misc = {{[1:'hFFFF]}};")

print(f"}}")


for i in range(512):
   print(f"`COV_POINT_FOR_ARRAY(payload,{i})")
print(f"endgroup")
