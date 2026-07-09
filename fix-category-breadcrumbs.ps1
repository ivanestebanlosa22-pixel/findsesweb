$dir = "C:\Users\ivane\Desktop\findses\categoria"
$files = @("bolsos-y-carteras.html","gorras.html","relojes.html","ropa.html","zapatillas.html")
$names = @("Bolsos y Carteras","Gorras","Relojes","Ropa","Zapatillas")
$rn = "`r`n"

for ($i = 0; $i -lt $files.Length; $i++) {
    $path = Join-Path $dir $files[$i]
    $c = Get-Content $path -Raw -Encoding UTF8
    $name = $names[$i]
    $file = $files[$i]
    $json = '{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Inicio","item":"https://findses.com/"},{"@type":"ListItem","position":2,"name":"Catalogo","item":"https://findses.com/catalogo.html"},{"@type":"ListItem","position":3,"name":"' + $name + '","item":"https://findses.com/categoria/' + $file + '"}]}'
    $tag = '<script type="application/ld+json">' + $rn + $json + $rn + '</script>'
    $c = $c.Replace('</script>' + $rn + '<link rel="preconnect"', '</script>' + $rn + $tag + $rn + '<link rel="preconnect"')
    Set-Content -Path $path -Value $c -Encoding UTF8 -NoNewline
    Write-Host "OK: $file"
}
