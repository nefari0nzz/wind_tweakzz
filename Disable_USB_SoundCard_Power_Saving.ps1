# Disable power saving for all USB sound cards

Get-PnpDevice -Class MEDIA | Where-Object {$_.HardwareID -like "*USB\VID_*&PID_*&MI_*"} | ForEach-Object {
    $hardwareID = $_.HardwareID | Select-Object -First 1
    $powerSettings = Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerSettingDataIndex | Where-Object {$_.InstanceID -like "*$hardwareID*"}

    if ($powerSettings) {
        $powerSettings | ForEach-Object {
            $guid = $_.GUID
            $index = $_.Index

            $powerSetting = Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerSetting | Where-Object {$_.InstanceID -eq $guid}

            if ($powerSetting) {
                $powerSetting | Invoke-CimMethod -MethodName "RemovePowerSetting" -Arguments @{PowerSettingIndex=$index}
            }
        }
    }
}
