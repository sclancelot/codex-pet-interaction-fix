param([switch]$InspectOnly)
$ErrorActionPreference = 'Stop'
$apps = @(Get-CimInstance Win32_Process -Filter "Name='ChatGPT.exe'" | Where-Object { $_.ExecutablePath -like '*\OpenAI.Codex_*\app\ChatGPT.exe' -and $_.CommandLine -notmatch '--type=' })
if ($apps.Count -ne 1) { throw 'Expected exactly one Codex desktop process.' }
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public static class PetResetOnce {
 delegate bool Callback(IntPtr h,IntPtr p);
 [DllImport("user32.dll")] static extern bool EnumWindows(Callback f,IntPtr p);
 [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] static extern bool IsWindow(IntPtr h);
 [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h,out uint p);
 [DllImport("user32.dll",EntryPoint="GetWindowLongPtrW")] static extern IntPtr GetLong(IntPtr h,int n);
 [DllImport("user32.dll",EntryPoint="SetWindowLongPtrW")] static extern IntPtr SetLong(IntPtr h,int n,IntPtr value);
 [DllImport("user32.dll")] static extern bool SetWindowPos(IntPtr h,IntPtr a,int x,int y,int w,int v,uint flags);
 static long Style(IntPtr h) { return GetLong(h,-20).ToInt64(); }
 static void Refresh(IntPtr h) { if(!SetWindowPos(h,IntPtr.Zero,0,0,0,0,0x237)) throw new Exception("Frame refresh failed"); }
 public static void Run(uint pid,bool inspect) {
  var candidates=new List<IntPtr>();
  EnumWindows((h,p)=>{uint owner;GetWindowThreadProcessId(h,out owner);long s=Style(h);
   if(owner==pid && IsWindowVisible(h) && (s&0x80088)==0x80088) candidates.Add(h);return true;},IntPtr.Zero);
  if(candidates.Count!=1) throw new Exception("Expected exactly one visible layered, topmost tool window; no changes made.");
  var target=candidates[0];long before=Style(target);
  Console.WriteLine("HWND={0} before=0x{1:X}",target,before);
  if(inspect)return;
  try {
   SetLong(target,-20,new IntPtr(before&~0x80000L));
   if((Style(target)&0x80000)!=0)throw new Exception("Layer reset was not applied");
   Refresh(target);
   System.Threading.Thread.Sleep(3000);
  } finally {
   uint owner;GetWindowThreadProcessId(target,out owner);
   if(IsWindow(target)&&owner==pid){
    SetLong(target,-20,new IntPtr(Style(target)|0x80000L));
    Refresh(target);
    if((Style(target)&0x80000)==0)throw new Exception("Layer restore failed");
    Console.WriteLine("HWND={0} after=0x{1:X}; original layered state restored; exiting",target,Style(target));
   } else { Console.WriteLine("Original window closed; no replacement window changed."); }
  }
 }
}
'@
[PetResetOnce]::Run([uint32]$apps[0].ProcessId,$InspectOnly.IsPresent)
