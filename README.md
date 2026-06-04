### Endpoint Threat Hunting with Native (mostly!) Tools

If your AV/EDR/SIEM "see it/stop it," you don't need to "hunt" for it! With that frame of reference, you need some other "lens" (visibility capability) to hunt with (or at least to have an option). 

As it turns out, PowerShell, bash, etc., are VERY capable of artifact acquisition, even "at scale" (1:many) with some care/caution. 

If you've followd "rapid triage workflow" (or any of my talks/courses/repos)...you'll know that I am keen on selecting the HIGHEST-VALUE ARTIFACTS, prioritizing analysis thereof, then letting that analysis guide next steps. As such, what follow are generally high-value artifact categories, with some remote query ("hunt!") LOLBIN options. 
_____________
### Windows: [Processes](https://github.com/secure-cake/endpoint-threat-hunting/blob/main/windows/win-process-lfo-rev2.ps1)
### Windows: [Network Sockets](https://github.com/secure-cake/endpoint-threat-hunting/blob/main/windows/win-established-network-sockets-lfo-rev1.ps1)
### Windows: [Scheduled Tasks](https://github.com/secure-cake/endpoint-threat-hunting/blob/main/windows/win-tasks-lfo-rev1.ps1)
### Windows: [Event Logs Triage](https://github.com/secure-cake/endpoint-threat-hunting/blob/main/windows/win-triage-security-event-logs-rev1.ps1)
### Windows: [Collect Security Event Logs](https://github.com/secure-cake/endpoint-threat-hunting/blob/main/windows/win-collect-security-evtx-files-rev1.ps1)
### Linux: Processes
### Linux: Network Sockets
### Linux: Last Login
_____________
Stay tuned! As always, a work in progress!

