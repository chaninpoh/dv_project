# Phase 1 gate — PowerShell (run from sim/ after Linux sim produces logs)
param(
    [string]$CompLog = "dut_comp.log",
    [string]$SimLog  = "phase1_tb_top_test_seed_0_sim.log"
)
$Mark = "PHASE 1 : testbench top"

if (-not (Test-Path $CompLog)) { throw "Missing $CompLog" }
if (-not (Test-Path $SimLog))  { throw "Missing $SimLog" }

$sim  = Get-Content $SimLog -Raw
$comp = Get-Content $CompLog -Raw

if ($sim -notmatch [regex]::Escape($Mark)) { throw "Phase marker not found in $SimLog" }
if ($sim -match "UVM_ERROR")   { throw "UVM_ERROR in sim log" }
if ($sim -match "UVM_FATAL")   { throw "UVM_FATAL in sim log" }
if ($comp -match "(?i)error-|syntax error") { throw "Compile error in $CompLog" }
if ($comp -match "UVM_ERROR")  { throw "UVM_ERROR in compile log" }

Write-Host "GATE PASS: Phase 1 — $SimLog"
