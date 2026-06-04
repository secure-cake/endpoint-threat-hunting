$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$eventlog_output_filename = "c:\cases\threathunt-case-1\servers-eventlogs-$timestamp.csv"

# --- Tunable Parameters ---
$lookback_window_hours   = .5
$maxEvents    = 100
$eventIDs     = @(
    4624,  # Successful logon
    4625,  # Failed logon
    #4728  #User added to global security group
    #4648,  # Logon with explicit credentials
    #4672,  # Special privileges assigned
    #4698,  # Scheduled task created
    #4720,  # User account created
    #4732,  # User added to privileged group
    7045   # New service installed
)
# --------------------------

$startTime = (Get-Date).AddHours(-$lookback_window_hours)
#$servers   = (Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "ou=servers,dc=test,dc=local").Name
$servers = "RTW-W2K22-1"

Write-Host "Servers found: $($servers.Count)"
Write-Host "Collecting events from last $hoursBack hours, max $maxEvents per server..."

foreach ($server in $servers) {
    Write-Host "Collecting from $server..."
    try {
        Get-WinEvent -ComputerName $server -MaxEvents $maxEvents -FilterHashtable @{
            LogName   = @('Security', 'System')
            StartTime = $startTime
            Id        = $eventIDs
        } -ErrorAction Stop |
        Select-Object @{N='ComputerName'; E={$server}},
                      TimeCreated,
                      Id,
                      @{N='EventType';   E={$_.LevelDisplayName}},
                      @{N='Message';     E={$_.Message -replace '\r?\n', ' '}},
                      UserId |
        Export-Csv $eventlog_output_filename -NoTypeInformation -Append
    }
    catch {
        Write-Host "  Warning: Could not collect from $server - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "Export complete: $eventlog_output_filename" -ForegroundColor Green