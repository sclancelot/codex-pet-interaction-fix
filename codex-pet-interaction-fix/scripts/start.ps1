param([switch]$ResetLayer)
$ErrorActionPreference='Stop'
$petRoot=$PSScriptRoot
$petNode=(Get-Command node.exe -ErrorAction Stop).Source
& $petNode (Join-Path $petRoot 'bridge.cjs') --check
if($LASTEXITCODE -ne 0){throw 'Preflight failed'}
$petArgs='"'+(Join-Path $petRoot 'bridge.cjs')+'"'
if($ResetLayer){$petArgs+=' --reset-layer'}
$petStarted=Get-Date
$petProcess=Start-Process -FilePath $petNode -ArgumentList $petArgs -WorkingDirectory $petRoot -WindowStyle Hidden -RedirectStandardOutput (Join-Path $petRoot 'helper.log') -RedirectStandardError (Join-Path $petRoot 'helper-error.log') -PassThru
for($petAttempt=0;$petAttempt -lt 120;$petAttempt++){
 Start-Sleep -Milliseconds 500
 if($petProcess.HasExited){throw (Get-Content (Join-Path $petRoot 'helper-error.log') -Raw)}
 $petStatus=Join-Path $petRoot 'status.json'
 if((Test-Path $petStatus) -and (Get-Item $petStatus).LastWriteTime -gt $petStarted){Write-Output 'Region tracker active; verify real hover and dragging.';exit 0}
}
Set-Content -LiteralPath (Join-Path $petRoot 'stop.signal') -Value 'stop'
throw 'No native region was applied within 60 seconds; stop requested.'
