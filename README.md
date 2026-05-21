### Endpoint Threat Hunting with Native (mostly!) Tools

My idea is that, if your AV/EDR/SIEM "see it/stop it," you don't need to "hunt" for it! With that frame of reference, you need some other "lens" (visibility capability) to hunt with (or at least to have an option). 

As it turns out, PowerShell, bash, etc., are VERY capable of artifact acquisition, even "at scale" (1:many) with some care/caution. 

If you've followd "rapid triage workflow" (or any of my talks/courses/repos)...you'll know that I am keen on selecting the HIGHEST-VALUE ARTIFACTS, prioritizing analysis thereof, then letting that analysis guide next steps. As such, what follow are generally high-value artifact categories, with some remote query ("hunt!") LOLBIN options. 
_____________
### Windows: Processes
### Windows: Network Sockets
### Windows: Scheduled Tasks
### Windows: Event Logs
### Linux: Processes
### Linux: Network Sockets
### Linux: Last Login
_____________
Stay tuned! As always, a work in progress!

