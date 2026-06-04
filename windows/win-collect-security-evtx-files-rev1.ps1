$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$outputDir = "d:\cases\case-xyz\evtx\$timestamp"

If (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force }

$servers = (Get-ADComputer -Filter {Enabled -eq $true} -SearchBase "ou=servers,dc=test,dc=local").Name

Write-Host "Servers found: $($servers.Count)`n"

foreach ($server in $servers) {
    try {
        Copy-Item "\\$server\c$\Windows\System32\winevt\Logs\Security.evtx" `
                  "$outputDir\$server-Security-$timestamp.evtx" -ErrorAction Stop
        $size = [math]::Round((Get-Item "$outputDir\$server-Security-$timestamp.evtx").Length / 1MB, 2)
        Write-Host "$server - Collected ($size MB)" -ForegroundColor Green
    }
    catch {
        Write-Host "$server - Failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "`nCollection complete: $outputDir"
Write-Host "Files collected: $((Get-ChildItem $outputDir | Measure-Object).Count)"