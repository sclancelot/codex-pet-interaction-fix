param([int]$OwnerPid,[switch]$ResetLayer)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;using System.Runtime.InteropServices;
public class PetRegion {
 public delegate bool CB(IntPtr h,IntPtr p);
 [StructLayout(LayoutKind.Sequential)] public struct R{public int l,t,r,b;}
 [DllImport("user32.dll")] static extern bool EnumWindows(CB cb,IntPtr p);
 [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h,out uint pid);
 [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
 [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h,out R r);
 [DllImport("user32.dll")] static extern IntPtr SetThreadDpiAwarenessContext(IntPtr p);
 [DllImport("user32.dll",EntryPoint="GetWindowLongPtrW")] static extern IntPtr GetWindowLongPtr(IntPtr h,int n);
 [DllImport("user32.dll",EntryPoint="SetWindowLongPtrW")] static extern IntPtr SetWindowLongPtr(IntPtr h,int n,IntPtr v);
 [DllImport("user32.dll")] static extern int SetWindowRgn(IntPtr h,IntPtr region,bool redraw);
 [DllImport("gdi32.dll")] static extern IntPtr CreateRectRgn(int l,int t,int r,int b);
 [DllImport("gdi32.dll")] static extern int CombineRgn(IntPtr dest,IntPtr a,IntPtr b,int mode);
 [DllImport("gdi32.dll")] static extern bool DeleteObject(IntPtr h);
 [DllImport("user32.dll")] static extern int GetWindowRgn(IntPtr h,IntPtr r);
 public static bool Owned(IntPtr h,uint pid){uint owner;GetWindowThreadProcessId(h,out owner);return owner==pid;}
 public static IntPtr Save(IntPtr h){var r=CreateRectRgn(0,0,0,0);if(GetWindowRgn(h,r)==0){DeleteObject(r);return IntPtr.Zero;}return r;}
 public static void Restore(IntPtr h,IntPtr r,uint pid){if(Owned(h,pid)){if(SetWindowRgn(h,r,true)==0&&r!=IntPtr.Zero)DeleteObject(r);}else if(r!=IntPtr.Zero)DeleteObject(r);}
 public static void ResetLayer(IntPtr h){long s=GetWindowLongPtr(h,-20).ToInt64();try{SetWindowLongPtr(h,-20,new IntPtr(s&~0x80000L));}finally{SetWindowLongPtr(h,-20,new IntPtr(s));}}
 public static IntPtr Find(uint pid,int w,int height){SetThreadDpiAwarenessContext(new IntPtr(-4));IntPtr result=IntPtr.Zero;int count=0;EnumWindows((h,p)=>{uint owner;GetWindowThreadProcessId(h,out owner);if(owner!=pid||!IsWindowVisible(h))return true;long s=GetWindowLongPtr(h,-20).ToInt64();R r;GetWindowRect(h,out r);if((s&0x80)!=0&&Math.Abs(r.r-r.l-w)<5&&Math.Abs(r.b-r.t-height)<5){result=h;count++;}return true;},IntPtr.Zero);return count==1?result:IntPtr.Zero;}
 public static bool Apply(IntPtr h,int[] coords){var total=CreateRectRgn(0,0,0,0);for(int i=0;i<coords.Length;i+=4){var r=CreateRectRgn(coords[i],coords[i+1],coords[i+2],coords[i+3]);CombineRgn(total,total,r,2);DeleteObject(r);}if(SetWindowRgn(h,total,true)==0){DeleteObject(total);return false;}return true;}
 public static void Clear(IntPtr h){SetWindowRgn(h,IntPtr.Zero,true);}
}
'@
$petHandle=[IntPtr]::Zero
$petSaved=[IntPtr]::Zero
try {
 while($null -ne ($petLine=[Console]::ReadLine())) {
  if($petLine -eq 'stop'){break}
  $petState=$petLine|ConvertFrom-Json
  $petFound=[PetRegion]::Find($OwnerPid,[int]$petState.width,[int]$petState.height)
  if($petFound -eq [IntPtr]::Zero){[Console]::Error.WriteLine('No unique matching pet window for viewport '+$petState.width+'x'+$petState.height);continue}
  if($petHandle -eq [IntPtr]::Zero){$petHandle=$petFound;$petSaved=[PetRegion]::Save($petHandle);if($ResetLayer){[PetRegion]::ResetLayer($petHandle)}}
  if($petFound -ne $petHandle){throw 'Pet window changed; stop and run preflight again'}
  $petCoordinates=[int[]]@($petState.rects|ForEach-Object{[int]$_})
  if($petCoordinates.Length -eq 0 -or $petCoordinates.Length % 4 -ne 0){throw 'No valid visible pet rectangles'}
  for($petIndex=0;$petIndex -lt $petCoordinates.Length;$petIndex+=4){
   if($petCoordinates[$petIndex] -lt 0 -or $petCoordinates[$petIndex+1] -lt 0 -or $petCoordinates[$petIndex+2] -gt $petState.width -or $petCoordinates[$petIndex+3] -gt $petState.height -or $petCoordinates[$petIndex+2] -le $petCoordinates[$petIndex] -or $petCoordinates[$petIndex+3] -le $petCoordinates[$petIndex+1]){throw 'Invalid pet rectangle bounds'}
  }
  if(-not [PetRegion]::Apply($petHandle,$petCoordinates)){throw 'Could not apply pet window region'}
  [Console]::WriteLine('applied')
 }
} finally {if($petHandle -ne [IntPtr]::Zero){[PetRegion]::Restore($petHandle,$petSaved,$OwnerPid)}}
