$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$task_input_filename  = "c:\cases\threathunt-case-1\servers-scheduledtasks-$timestamp.csv"
$task_output_filename = "c:\cases\threathunt-case-1\servers-scheduledtasks-sorted-lfo-$timestamp.csv"

#$servers = (Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "ou=servers,dc=test,dc=local").Name
$servers = "RTW-W2K22-1"

foreach ($server in $servers) {
    Get-ScheduledTask -CimSession $server |
    Select-Object @{N='ComputerName';    E={$server}},
                  TaskName,
                  TaskPath,
                  @{N='ExecutablePath'; E={$_.Actions.Execute}},
                  @{N='Arguments';      E={$_.Actions.Arguments}},
                  State |
    Export-Csv $task_input_filename -NoTypeInformation -Append
}

# Import CSV
$all_tasks = Import-Csv $task_input_filename

# Least-Frequency-of-Occurrence: Stack — TaskName + ExecutablePath combo
$lfo = $all_tasks |
    Group-Object { "$($_.TaskName.ToLower())|$($_.ExecutablePath.ToLower())" } |
    Select-Object @{N='TaskName';       E={$_.Group[0].TaskName}},
                  @{N='TaskPath';       E={$_.Group[0].TaskPath}},
                  @{N='ExecutablePath'; E={$_.Group[0].ExecutablePath}},
                  @{N='Arguments';      E={$_.Group[0].Arguments}},
                  @{N='State';          E={$_.Group[0].State}},
                  @{N='MachineCount';   E={($_.Group.ComputerName | Sort-Object -Unique).Count}},
                  @{N='TotalInstances'; E={$_.Count}},
                  @{N='Computers';      E={($_.Group.ComputerName | Sort-Object -Unique) -join ", "}} |
    Sort-Object MachineCount

# Uncomment to display results on-screen
#$lfoo | Sort-Object -Property TotalInstances -Descending | Format-Table -AutoSize

# Export
$lfo | Sort-Object -Property TotalInstances | Export-Csv $task_output_filename -NoTypeInformation