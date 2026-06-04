#NOTE: You'll need to use an account with adequate permissions for remote PoSh access to your targets
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"

#Change these to match your desired output directory paths
$process_input_filename  = "c:\cases\threathunt-case-1\servers-processes-$timestamp.csv"
$process_output_filename = "c:\cases\threathunt-case-1\servers-processes-sorted-lfoo-$timestamp.csv"

#Uncomment and edit the lines below to populate your $servers target list via AD or manually
$servers = (Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "ou=servers,dc=test,dc=local").Name
#$servers = "RTW-W2K22-1"

Get-CimInstance -ComputerName $servers -ClassName Win32_Process -OperationTimeoutSec 30 |
    Select-Object @{N='ComputerName';    E={$_.PSComputerName}},
                  Name,
                  ExecutablePath,
                  ProcessId,
                  ParentProcessId,
                  CommandLine |
    Export-Csv $process_input_filename -NoTypeInformation -Append

Write-Host "Raw process data written to: $process_input_filename"

# Import CSV
$all_processes = Import-Csv $process_input_filename

# Least-Frequency-of-Occurrence: Stack — Name + Path + CommandLine combo
$lfoo = $all_processes |
    Group-Object { 
        "$($_.Name.ToLower())|$(if($_.ExecutablePath){$_.ExecutablePath.ToLower()}else{''})|$(if($_.CommandLine){$_.CommandLine.ToLower()}else{''})" 
    } |
    Select-Object @{N='ProcessName';    E={$_.Group[0].Name}},
                  @{N='Path';           E={$_.Group[0].ExecutablePath}},
                  @{N='CommandLine';    E={$_.Group[0].CommandLine}},
                  @{N='PID';            E={($_.Group.ProcessId | Sort-Object -Unique) -join ", "}},
                  @{N='PPID';           E={($_.Group.ParentProcessId | Sort-Object -Unique) -join ", "}},
                  @{N='MachineCount';   E={($_.Group.ComputerName | Sort-Object -Unique).Count}},
                  @{N='TotalInstances'; E={$_.Count}},
                  @{N='Computers';      E={($_.Group.ComputerName | Sort-Object -Unique) -join ", "}} |
    Sort-Object MachineCount, TotalInstances

# Uncomment to display results on-screen
# $lfoo | Sort-Object -Property TotalInstances -Descending | Format-Table -AutoSize

# Export
$lfoo | Export-Csv $process_output_filename -NoTypeInformation

Write-Host "LFOO results written to: $process_output_filename"

# Summary
Write-Host "`nTotal unique process combos : $($lfoo.Count)"
Write-Host "Total processes collected   : $($all_processes.Count)"
