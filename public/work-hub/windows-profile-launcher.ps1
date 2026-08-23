$ErrorActionPreference = 'Stop'

$port = 8765
$destinationUrl = 'https://admin.microsoft.com/'
$localState = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Local State'
$chromeCandidates = @(
    (Join-Path $env:PROGRAMFILES 'Google\Chrome\Application\chrome.exe'),
    (Join-Path ${env:PROGRAMFILES(X86)} 'Google\Chrome\Application\chrome.exe'),
    (Join-Path $env:LOCALAPPDATA 'Google\Chrome\Application\chrome.exe')
)
$chrome = $chromeCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
$allowedOrigins = @(
    'http://127.0.0.1:4173',
    'http://localhost:4173',
    'https://prashilthegreat.github.io'
)

if (-not $chrome) { throw 'Google Chrome was not found.' }
if (-not (Test-Path $localState)) { throw 'Google Chrome profile data was not found.' }

function Get-Profiles {
    $state = Get-Content -Raw -LiteralPath $localState | ConvertFrom-Json
    $profiles = [ordered]@{}
    foreach ($property in $state.profile.info_cache.PSObject.Properties) {
        $name = if ($property.Value.name) { [string]$property.Value.name } else { $property.Name }
        $profiles[$name] = $property.Name
    }
    return $profiles
}

function Send-Response($stream, [int]$status, [string]$contentType, [byte[]]$body, [string]$origin = '') {
    $reason = if ($status -eq 200) { 'OK' } elseif ($status -eq 204) { 'No Content' } elseif ($status -eq 404) { 'Not Found' } else { 'Error' }
    $headers = "HTTP/1.1 $status $reason`r`nContent-Type: $contentType`r`nContent-Length: $($body.Length)`r`nCache-Control: no-store`r`nConnection: close`r`n"
    if ($allowedOrigins -contains $origin) { $headers += "Access-Control-Allow-Origin: $origin`r`nVary: Origin`r`n" }
    $headers += "Access-Control-Allow-Methods: GET, OPTIONS`r`nAccess-Control-Allow-Private-Network: true`r`n`r`n"
    $headerBytes = [Text.Encoding]::UTF8.GetBytes($headers)
    $stream.Write($headerBytes, 0, $headerBytes.Length)
    if ($body.Length) { $stream.Write($body, 0, $body.Length) }
}

$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $port)
$listener.Start()
Write-Host "Chrome profile launcher listening at http://127.0.0.1:$port"

try {
    while ($true) {
        $client = $listener.AcceptTcpClient()
        try {
            $stream = $client.GetStream()
            $reader = [IO.StreamReader]::new($stream, [Text.Encoding]::ASCII, $false, 1024, $true)
            $requestLine = $reader.ReadLine()
            $headers = @{}
            while (($line = $reader.ReadLine())) {
                $split = $line.IndexOf(':')
                if ($split -gt 0) { $headers[$line.Substring(0, $split).Trim()] = $line.Substring($split + 1).Trim() }
            }
            $parts = $requestLine -split ' '
            $method = $parts[0]
            $path = [Uri]::UnescapeDataString(($parts[1] -split '\?')[0])
            $origin = $headers['Origin']

            if ($method -eq 'OPTIONS') {
                Send-Response $stream 204 'text/plain' ([byte[]]@()) $origin
            } elseif ($path -eq '/health') {
                Send-Response $stream 200 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('ready')) $origin
            } elseif ($path -eq '/profiles') {
                $json = @((Get-Profiles).Keys) | ConvertTo-Json -Compress
                Send-Response $stream 200 'application/json; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes($json)) $origin
            } elseif ($path.StartsWith('/launch/')) {
                $name = $path.Substring(8)
                $profiles = Get-Profiles
                if ($profiles.Contains($name)) {
                    $directory = [string]$profiles[$name]
                    $arguments = "--profile-directory=`"$directory`" `"$destinationUrl`""
                    Start-Process -FilePath $chrome -ArgumentList $arguments
                    Send-Response $stream 200 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes("Opened $name")) $origin
                } else {
                    Send-Response $stream 404 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('Unknown profile')) $origin
                }
            } else {
                Send-Response $stream 404 'text/plain; charset=utf-8' ([Text.Encoding]::UTF8.GetBytes('Not found')) $origin
            }
        } finally {
            $client.Close()
        }
    }
} finally {
    $listener.Stop()
}
