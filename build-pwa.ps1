# asobihiroba.html から docs/index.html(オフライン対応版)とアイコンを生成する
# docs/ は GitHub Pages の配信フォルダ。本体を更新したらこのスクリプトを再実行して push する
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Join-Path $root 'asobihiroba.html'
$pwa  = Join-Path $root 'docs'
if (-not (Test-Path $pwa)) { New-Item -ItemType Directory $pwa | Out-Null }

# ---- index.html ----
$content = Get-Content -Raw -Encoding UTF8 $src
$head = @'
<!doctype html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover, user-scalable=no">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="apple-mobile-web-app-title" content="あそびひろば">
<meta name="theme-color" content="#CDEBF7">
<link rel="manifest" href="manifest.webmanifest">
<link rel="apple-touch-icon" href="icon-180.png">
</head>
<body>
'@
$tail = @'
<script>
if ('serviceWorker' in navigator) { navigator.serviceWorker.register('./sw.js'); }
</script>
</body>
</html>
'@
$utf8 = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText((Join-Path $pwa 'index.html'), ($head + $content + $tail), $utf8)
Write-Host "generated docs/index.html"

# ---- icons (おひさま) ----
Add-Type -AssemblyName System.Drawing
function New-Icon([int]$size, [string]$path) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.Clear([System.Drawing.ColorTranslator]::FromHtml('#CDEBF7'))
  $sun  = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#FFB730'))
  $rayP = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#F09E00'), [float]($size*0.05))
  $rayP.StartCap = 'Round'; $rayP.EndCap = 'Round'
  $c = $size/2.0; $r = $size*0.26
  for ($i=0; $i -lt 12; $i++) {
    $a = $i*[Math]::PI/6
    $g.DrawLine($rayP,
      [float]($c+[Math]::Cos($a)*$r*1.4), [float]($c+[Math]::Sin($a)*$r*1.4),
      [float]($c+[Math]::Cos($a)*$r*1.75), [float]($c+[Math]::Sin($a)*$r*1.75))
  }
  $g.FillEllipse($sun, [float]($c-$r), [float]($c-$r), [float](2*$r), [float](2*$r))
  $ink = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#4A3200'))
  $er = $size*0.03
  $g.FillEllipse($ink, [float]($c-$r*0.42-$er), [float]($c-$r*0.18-$er), [float](2*$er), [float](2*$er))
  $g.FillEllipse($ink, [float]($c+$r*0.42-$er), [float]($c-$r*0.18-$er), [float](2*$er), [float](2*$er))
  $smile = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#4A3200'), [float]($size*0.028))
  $smile.StartCap = 'Round'; $smile.EndCap = 'Round'
  $g.DrawArc($smile, [float]($c-$r*0.4), [float]($c-$r*0.45), [float]($r*0.8), [float]($r*0.8), 35, 110)
  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host "generated $path"
}
New-Icon 180 (Join-Path $pwa 'icon-180.png')
New-Icon 512 (Join-Path $pwa 'icon-512.png')
Write-Host "done."
