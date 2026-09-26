# Display Management PowerShell Scripts

Two small PowerShell scripts for Windows display management using [`displayz`](https://github.com/michidk/displayz).

## Scripts

- `ChangeResolution(2).ps1` — toggles the primary display's resolution/refresh rate.
- `SwitchPrimaryDisplay.ps1` — switches the primary display between connected monitors.

## Requirements

- Windows
- PowerShell
- Rust/Cargo

The scripts automatically install `displayz` with:

```powershell
cargo install displayz
```

## Usage

```powershell
.\ChangeResolution(2).ps1
```

```powershell
.\SwitchPrimaryDisplay.ps1
```

## Credit

Display management is powered by [`michidk/displayz`](https://github.com/michidk/displayz).
