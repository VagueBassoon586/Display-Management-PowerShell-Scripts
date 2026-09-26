$env:Path = "$env:USERPROFILE\.cargo\bin;$env:Path"
$BurntToastAvailable = $false

try 
{
	Import-Module BurntToast -ErrorAction Stop
	$BurntToastAvailable = $true
}
catch 
{
	Write-Warning "Failed to import BurntToast! Installing BurntToast."

	try
	{
		Install-Module BurntToast -Scope CurrentUser -Force -ErrorAction Stop
		Import-Module BurntToast -ErrorAction Stop
		$BurntToastAvailable = $true
		Write-Host "BurntToast installed successfully."
	}
	catch
	{
		Write-Warning "Failed to install BurntToast! Using WScript.Shell."
	}
}

$package = "displayz"

if (-not (Get-Command cargo.exe -ErrorAction SilentlyContinue))
{
	$urlCargo = "https://doc.rust-lang.org/cargo/getting-started/installation.html"
	$cargo = "Cargo (click here)"
	$hyperlinksCargo = "`e]8;;$urlCargo`e\$cargo`e]8;;`e\"
	Write-Error "$hyperlinksCargo is not installed on this system! Exit at code 1."
	exit 1
}

if ((cargo install --list | Select-String $package) -like "$package*")
{
	Write-Host "$package is already installed." -ForegroundColor Green
} 
else
{
	Write-Warning "Installing package '$package' from Cargo..."
	cargo install $package
	if ($LASTEXITCODE -ne 0)
	{
		$urlPackage = "https://github.com/michidk/displayz"
		$displayz = "displayz (click here)"
		$hyperlinksPackage = "`e]8;;$urlPackage`e\$displayz`e]8;;`e\"
		Write-Error "Failed to install $hyperlinksPackage! Exit at code 2."
		Write-Error "Cargo exit code $LASTEXITCODE"
		exit 2
	}
}

$monitors = [ordered]@{"ID" = @(); "Primary" = @(); "Connector" = @(); "Resolution" = @(); "Frequency" = @()}
$listOutput = & $package info

if (-not $listOutput) 
{
	Write-Error "Somehow $package could not extract monitors info! Exit at code 3."
	exit 3
}

foreach ($line in $listOutput)
{
	if ($line -like "Display ID:*")
	{
		$monitors["ID"] += [int]($line.Substring(11) -replace '\s+', '')
	}
	elseif ($line -like "Primary:*")
	{
		$monitors["Primary"] += [System.Convert]::ToBoolean(($line.Substring(8) -replace '\s+', ''))
	}
	elseif ($line -like "Connector:*")
	{
		$monitors["Connector"] += ($line.Substring(10) -replace '\s+', '')
	}
	elseif ($line -like "*Resolution:*")
	{
		$monitors["Resolution"] += ($line -replace '\s+', '').Substring(11)
	}
	elseif ($line -like "*Frequency:*")
	{
		$monitors["Frequency"] += [int](($line -replace '\s+', '').Substring(10) -replace '[a-zA-Z]', '')
	}
}

$index = 0

for ($i = 0; $i -lt $monitors["ID"].Length; $i++)
{
	if ($monitors["Primary"][$i] -eq $true)
	{
		$index = $i
	}
}

$res = "3840x2160"
$freq = 120

if ($monitors["Connector"][$index] -like "Internal")
{
	if ($monitors["Frequency"][$index] -eq 240)
	{
		$freq = 60
		& $package properties --id $monitors["ID"][$index] --frequency $freq
	}
	elseif ($monitors["Frequency"][$index] -eq 60)
	{
		$freq = 240
		& $package properties --id $monitors["ID"][$index] --frequency $freq
	}
	
	if ($LASTEXITCODE -ne 0)
	{
		Write-Error "Error: displayz failed to execute commands! Exit at code 4."
		Write-Error "Log: displayz exited at code $LASTEXITCODE"
		exit 4
	}
	
	Start-Sleep 1
	
	if ($BurntToastAvailable)
	{
		New-BurntToastNotification -Text "Frequency changed", "New refresh rate: $freq Hz" -Silent
	}
	else
	{
		$wshell = (New-Object -ComObject WScript.Shell).Popup("New frequency: $freq Hz", 6, "Change Resolution", 64)
	}
}
else
{
	if ($monitors["Frequency"][$index] -ge 239 -and $monitors["Resolution"][$index] -like "2560x1440")
	{
		$res = "3840x2160"
		$freq = 120
		& $package properties --id $monitors["ID"][$index] --frequency $freq --resolution $res
		$res = "3840 x 2160"
	}
	elseif ($monitors["Frequency"][$index] -eq 120 -and $monitors["Resolution"][$index] -like "3840x2160")
	{
		$res = "2560x1440"
		$freq = 240
		& $package properties --id $monitors["ID"][$index] --frequency 240 --resolution "2560x1440"
		$res = "2560 x 1440"
	}

	if ($LASTEXITCODE -ne 0)
	{
		Write-Error "Error: displayz failed to execute commands! Exit at code 4."
		Write-Error "Log: displayz exited at code $LASTEXITCODE"
		exit 4
	}
	
	Start-Sleep 2
	
	if ($BurntToastAvailable)
	{
		New-BurntToastNotification -Text "Resolution & Frequency changed", "Resolution: $res`nRefresh rate: $freq Hz" -Silent
	}
	else
	{
		$wshell = (New-Object -ComObject WScript.Shell).Popup("Resolution: $res`nRefresh rate: $freq Hz", 6, "Change Resolution", 64)
	}
}