$data = @()

for ($i = 0; $i -lt 100; $i++) { $data += [Guid]::NewGuid().ToString() }

$data | % {

    for ($i = 0; $i -lt 10; $i++) {

        Invoke-WebRequest -Method Post -Uri http://localhost:81/ -Body $_ -UseBasicParsing | % {
            New-Object PsObject -Property @{
                Cache = $_.Headers."X-Cached"
                Content = [System.Text.Encoding]::UTF8.GetString($_.Content)
            }
        }

    }

}
