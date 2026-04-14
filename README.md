# AMSI-Bypass
PowerShell AMSI bypass using Reflection.Emit to dynamically create P/Invoke wrappers in memory  patches AmsiScanBuffer and AmsiScanString at runtime without Add-Type or disk writes. 

# Tested on PowerShell 5.1

| Name  | Value |
| ------------- | ------------- |
| PSVersion  | 5.1.26100.7019  |
| PSEdition  | Desktop  |
| PSCompatibleVersions  | {1.0, 2.0, 3.0, 4.0...}  |
| BuildVersion  | 10.0.26100.7019  |
| CLRVersion  | 4.0.30319.42000  |
| WSManStackVersion  | 3.0  |
| PSRemotingProtocolVersion  | 2.3  |
| SerializationVersion  | 1.1.0.1  |
