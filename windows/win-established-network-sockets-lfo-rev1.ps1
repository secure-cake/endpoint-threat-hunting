#NOTE: You'll need to use an account with adequate permissions for remote PoSh access and netstat on remote hosts
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
#Change these variables to match your desired output directory path
$socket_input_filename  = "C:\cases\threathunt-case-1\servers-sockets-$timestamp.csv"
$socket_output_filename = "C:\cases\threathunt-case-1\servers-sockets-sorted-lfo-$timestamp.csv"

#Uncomment and edit the next lines to either populate your $servers target list from AD or manually
$servers = (Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "ou=servers,dc=test,dc=local").Name
#$servers = "RTW-W2K22-1"

# Private IP ranges to exclude
function IsPrivateIP {
    param([string]$ip)
    $private = @(
        '^10\.',                          # 10.0.0.0/8
        '^172\.(1[6-9]|2[0-9]|3[0-1])\.', # 172.16.0.0/12
        '^192\.168\.',                    # 192.168.0.0/16
        '^127\.'                         # loopback
        '^::1$',                          # IPv6 loopback
        '^0\.'                            # unspecified
    )
    foreach ($pattern in $private) {
        if ($ip -match $pattern) { return $true }
    }
    return $false
}

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
    Get-NetTCPConnection | ForEach-Object {
        $proc = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
        $_ | Add-Member -NotePropertyName ProcessName -NotePropertyValue $proc -PassThru
    }
} |
    Where-Object { $_.RemoteAddress -and !(IsPrivateIP $_.RemoteAddress) } |
    Select-Object @{N='ComputerName';    E={$server}},
                  @{N='LocalAddress';   E={$_.LocalAddress}},
                  @{N='LocalPort';      E={$_.LocalPort}},
                  @{N='RemoteAddress';  E={$_.RemoteAddress}},
                  @{N='RemotePort';     E={$_.RemotePort}},
                  @{N='OwningProcess';  E={$_.OwningProcess}},
                  @{N='ProcessName';    E={
                      (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
                  }} |
    Export-Csv $socket_input_filename -NoTypeInformation -Append
}

# Import CSV
$all_sockets = Import-Csv $socket_input_filename

# Least-Frequency-of-Occurrence: Stack — RemoteAddress + RemotePort + ProcessName combo
$lfo = $all_sockets |
    Group-Object { "$($_.RemoteAddress.ToLower())|$($_.RemotePort)|$($_.ProcessName.ToLower())" } |
    Select-Object @{N='RemoteAddress';  E={$_.Group[0].RemoteAddress}},
                  @{N='RemotePort';     E={$_.Group[0].RemotePort}},
                  @{N='LocalPort';      E={$_.Group[0].LocalPort}},
                  @{N='ProcessName';    E={$_.Group[0].ProcessName}},
                  @{N='OwningProcess';  E={$_.Group[0].OwningProcess}},
                  @{N='MachineCount';   E={($_.Group.ComputerName | Sort-Object -Unique).Count}},
                  @{N='TotalInstances'; E={$_.Count}},
                  @{N='Computers';      E={($_.Group.ComputerName | Sort-Object -Unique) -join ", "}} |
    Sort-Object MachineCount

# Uncomment to display results on-screen
#$lfo | Sort-Object -Property TotalInstances -Descending | Format-Table -AutoSize

# Export
$lfo | Sort-Object -Property TotalInstances | Export-Csv $socket_output_filename -NoTypeInformation
