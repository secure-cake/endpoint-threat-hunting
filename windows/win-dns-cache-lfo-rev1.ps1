$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$dns_input_filename  = "C:\cases\threathunt-case-1\servers-dns-$timestamp.csv"
$dns_output_filename = "C:\cases\threathunt-case-1\servers-dns-sorted-lfo-$timestamp.csv"

#$servers = (Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "ou=servers,dc=test,dc=local").Name
$servers = "RTW-W2K22-1"

# Private IP ranges to exclude
function IsPrivateIP {
    param([string]$ip)
    $private = @(
        '^10\.',
        '^172\.(1[6-9]|2[0-9]|3[0-1])\.',
        '^192\.168\.',
        '^127\.',
        '^::1$',
        '^0\.'
    )
    foreach ($pattern in $private) {
        if ($ip -match $pattern) { return $true }
    }
    return $false
}

foreach ($server in $servers) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        Get-DnsClientCache
    } |
    Where-Object {
        $_.Data -and !(IsPrivateIP $_.Data)
    } |
    Select-Object @{N='ComputerName'; E={$server}},
                  @{N='Entry';        E={$_.Entry}},
                  @{N='RecordName';   E={$_.RecordName}},
                  @{N='RecordType';   E={$_.RecordType}},
                  @{N='Data';         E={$_.Data}},
                  @{N='TTL';          E={$_.TimeToLive}},
                  @{N='DataLength';   E={$_.DataLength}} |
    Export-Csv $dns_input_filename -NoTypeInformation -Append
}

# Import CSV
$all_dns = Import-Csv $dns_input_filename

# Least-Frequency-of-Occurrence: Stack — Entry + Data combo
$lfo = $all_dns |
    Group-Object { "$($_.Entry.ToLower())|$($_.Data.ToLower())" } |
    Select-Object @{N='Entry';          E={$_.Group[0].Entry}},
                  @{N='RecordName';     E={$_.Group[0].RecordName}},
                  @{N='RecordType';     E={$_.Group[0].RecordType}},
                  @{N='Data';           E={$_.Group[0].Data}},
                  @{N='TTL';            E={$_.Group[0].TTL}},
                  @{N='MachineCount';   E={($_.Group.ComputerName | Sort-Object -Unique).Count}},
                  @{N='TotalInstances'; E={$_.Count}},
                  @{N='Computers';      E={($_.Group.ComputerName | Sort-Object -Unique) -join ", "}} |
    Sort-Object MachineCount

# Uncomment to display results on-screen
# $lfo | Sort-Object -Property TotalInstances -Descending | Format-Table -AutoSize

# Export
$lfo | Sort-Object -Property TotalInstances | Export-Csv $dns_output_filename -NoTypeInformation