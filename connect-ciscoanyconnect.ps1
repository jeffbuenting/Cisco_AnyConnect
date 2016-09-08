Function Connect-CiscoAnyConnect {

<#
    .Link
        http://www.staze.org/scripting-cisco-anyconnect-powershell/
#>

    [Cmdletbinding()]
    Param (
        [String]$CiscoVPNHost,

        [PSCredential]$Credential
    )

#    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop

    #Set foreground window function
     #This function is called in VPNConnect
 #    Add-Type @'
 #using System;
 #using System.Runtime.InteropServices;
 #public class Win {
 #    [DllImport("user32.dll")]
 #    [return: MarshalAs(UnmanagedType.Bool)]
 #    public static extern bool SetForegroundWindow(IntPtr hWnd);
 #}
#'@ -ErrorAction Stop

    #Check if VPN is running, but disconnected, and if so, kill the process so we can reconnect.
    write-Verbose "Connect-CiscoAnyConnect : Checking if VPN is already running.  "
    if ( (Start-Process -Filepath 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' -ArgumentList 'status' -wait ) -Match 'Disconnected' ) {
        Write-Verbose "Connect-CiscoAnyConnect : Stopping VPNUI"
        Get-Process -Name vpnui | Stop-Process
        Write-Verbose "Connect-CiscoAnyConnect : Stopping VPNCLI"
        Get-Process -Name vpncli | Stop-Process
    }
    
    # ----- Start the VPNCLI connection and bring the window to foreground
    Start-Process -FilePath 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe' -ArgumentList "connect $CiscoVPNHost" 
    $counter = 0; $h = 0;
    while($counter++ -lt 1000 -and $h -eq 0) {
        sleep -m 10
        $h = (Get-Process vpncli).MainWindowHandle
    }
    #if it takes more than 10 seconds then display message
    if($h -eq 0){ 
            Throw "Connect-CiscoAnyConnect : Could not start VPNUI it takes too long."
        }
        else {
            [void] [Win]::SetForegroundWindow($h)
    }
    #Write login and password
    [System.Windows.Forms.SendKeys]::SendWait("$($Credential.Username){Enter}")
    [System.Windows.Forms.SendKeys]::SendWait("$($Credential.GetNetwork().Password){Enter}")
    [System.Windows.Forms.SendKeys]::SendWait("y{Enter}")

    #Start vpnui
    start-Process -FilePath $vpnuiAbsolutePath

}

Connect-CiscoAnyConnect -verbose