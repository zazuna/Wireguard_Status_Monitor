# Variables
$processName = "wireguard" # Application Name, In this case wireguard
$pingAddress = "8.8.8.8" # Just any IP address to ping time to time for connectivity check
$logFile = "X:\XXX\XXXXXX.log" # Path for logs
$defaultIp = "IP Address You Want to Keep Connection With"
$exePath = "C:\Program Files\WireGuard\wireguard.exe" # Wireguard Installation Path
$argList = '/installtunnelservice', '"C:\Program Files\WireGuard\Data\Configurations\Config_Name.conf.dpapi"' # Wireguard Shell Run Command
$tryCount = 0

# Function to Log Messages
function Log-Message {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry
}

# Function to get the service name associated with the process (if any)
function Get-ServiceName {
    param([string]$processName)
    $services = Get-WmiObject -Query "SELECT * FROM Win32_Service WHERE PathName LIKE '%$processName%'" -ErrorAction SilentlyContinue
    if ($services) {
        return $services.Name
    } else {
        Log-Message "No service found associated with process $processName."
        return $null
    }
}

# Function to check process status
function Check-Process {
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
    $services = Get-ServiceName -processName $processName
    if ($null -eq $services) {
        Log-Message "$processName process not found."
        Log-Message "Attempting to start the wireguard service..."
        Start-Process -FilePath $exePath
        Start-Sleep -Seconds 10
        Start-Process -FilePath $exePath -ArgumentList $argList
        Log-Message "$service service started."
    } elseif ($services) {
            Log-Message "Shutting down $proccessName procces..."
            Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
            Log-Message "$processName was successfully shut down."
            # As long as network checking proccess will run continiously we need to implement 
            # sleep time between "continious checks" to prevent server being unreachable if VPN server is permanently
            # down. This gives us time to connect serve and mannualy prevent / shut down processes.
            if ($tryCount -eq 10) {
                Start-Sleep -Seconds 600 # Change this to desirable Sleep Time 
                $tryCount = 0
            }
            $tryCount = $tryCount + 1
            Log-Message "Launching $execPath"
            Start-Process -FilePath $exePath
            Log-Message "$processName was successfully launched."
            Start-Sleep -Seconds 10
            Log-Message "Connecting to VPN Netwrok.."
            Start-Process -FilePath $exePath -ArgumentList $argList
            Log-Message "VPN Connected, Reruning Network Check.."
            Check-Network
    }
    return $services
}

# Function to Check Network Conectivity
function Check-Network{
    $pingResult = Test-Connection -ComputerName $pingAddress -Count 3 -ErrorAction SilentlyContinue
    Log-Message ($pingResult.StatusCode)

    if ($pingResult.StatusCode -ne 0) {
        Log-Message "Unable to Connect"
        Check-Process
    } else {
        Log-Message "Pinged $pingAddress Successfuly"
        Log-Message "Checking if we are connected to correct network..."
        $ip = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
        if ($ip -ne $defaultIp) {
            Log-Message "We are connected to $ip, running wireguard to reconnect to $defaultIp"
            Check-Process
        } else {
            Log-Message "IP Address is $defaultIp, we are connected to right network."
            $tryCount = 0
        }
    }
}
# Run Functions
Check-Network