$data = @()

for ($i = 0; $i -lt 100; $i++) { $data += [Guid]::NewGuid().ToString() }

$data | % {

    for ($i = 0; $i -lt 10; $i++) {

        try {
            Invoke-WebRequest -Method Post -Uri http://localhost:81 -Body $_ -UseBasicParsing | % {
                New-Object PsObject -Property @{
                    Cache = $_.Headers."X-Cached"
                    Content = [System.Text.Encoding]::UTF8.GetString($_.Content)
                }
            }
        } catch [System.Net.WebException] {
            $e = $_.Exception
            Write-host $e -ForegroundColor Red
            $e.Response.Headers.AllKeys | % {
                Write-host "$($_): $($e.Response.Headers[$_])" -ForegroundColor Red
            }
        }
    }

}


#http://sto-t-fecrs02.bde.local:9077/Content3/ContentService.svc/text