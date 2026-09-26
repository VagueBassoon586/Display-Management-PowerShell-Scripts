$env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"
$package = "displayz"

if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue))
{
	Write-Warning "Cargo is not installed on this system! Exit at code 1."
	exit 1
}

if ((cargo install --list | Select-String $package) -like "$package*")
{
	Write-Host "$package is already installed." -ForegroundColor Green
} 
else
{
	Write-Host "Installing package '$package' from Cargo..."
	cargo install $package
	if ($LASTEXITCODE -ne 0)
	{
		Write-Error "Failed to install $package! Exit at code 2."
		Write-Error "Cargo exit code $LASTEXITCODE"
		exit 2
	}
}

$primary = @()
$listOutput = & $package info

if (-not $listOutput) 
{
	Write-Error "Somehow $package could not extract monitors info! Exit at code 3."
	exit 3
}

foreach ($line in $listOutput)
{
	if ($line -like "Primary*")
	{
		$primary += [System.Convert]::ToBoolean(($line.Substring(8) -replace '\s+', ''))
	}
}

$numMonitor = $primary.Length

if ($numMonitor -le 1)
{
	Write-Warning "Your system have atmost 1 monitor! Exit at code 4."
	exit 4
}

$newPrimaryDisplay = 0

for ($i = 0; $i -lt $numMonitor; $i++)
{
	if ($primary[$i] -eq $true)
	{
		$newPrimaryDisplay = ++$i
		if ($newPrimaryDisplay -eq $numMonitor)
		{
			$newPrimaryDisplay = 0
		}
	}
}

Write-Host "Setting Display with ID $newPrimaryDisplay to Primary"
& $package set-primary --id $newPrimaryDisplay