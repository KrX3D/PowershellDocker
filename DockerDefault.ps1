Write-Output "Default Script just to prevent the Container from exiting."

# Initialize counter
$counter = 1

# Record the start time of the script
$startTime = Get-Date

while ($true) {
    $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $uptime = (Get-Date) - $startTime

    # Output results
    Write-Output "Hello! The current time is: $currentTime"
    Write-Output "Container uptime: $($uptime.Hours) hours, $($uptime.Minutes) minutes, $($uptime.Seconds) seconds."
    Write-Output "Message count: $counter"

    # Increment the counter
    $counter++

    Start-Sleep -Seconds 5
}
