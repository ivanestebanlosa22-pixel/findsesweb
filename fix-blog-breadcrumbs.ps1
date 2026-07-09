$dir = "C:\Users\ivane\Desktop\findses\blog"
$files = @("como-comprar-en-kakobuy.html","como-comprar-weidian-espana.html","cuanto-tarda-envio-china-espana.html","glosario-comprador-china.html","guia-tallas-china-eu.html","kakobuy-vs-usfans-vs-litbuy.html","mejor-agente-china-2026.html","que-son-fotos-qc.html")
$titles = @("Como comprar en Kakobuy","Comprar en Weidian desde Espana","Cuanto tarda el envio de China a Espana","Glosario del comprador en China","Guia de tallas chinas a espanolas","Kakobuy vs USFans vs Litbuy","Mejor agente China en 2026","Que son las fotos QC")
$rn = "`r`n"

for ($i = 0; $i -lt $files.Length; $i++) {
    $path = Join-Path $dir $files[$i]
    $c = Get-Content $path -Raw -Encoding UTF8
    $title = $titles[$i]
    $file = $files[$i]

    $json = '{"@context":"https://schema.org","@type":"BreadcrumbList","itemListElement":[{"@type":"ListItem","position":1,"name":"Inicio","item":"https://findses.com/"},{"@type":"ListItem","position":2,"name":"Blog","item":"https://findses.com/blog.html"},{"@type":"ListItem","position":3,"name":"' + $title + '","item":"https://findses.com/blog/' + $file + '"}]}'
    $tag = '<script type="application/ld+json">' + $rn + $json + $rn + '</script>'

    # Blog pages use </script>\r\n\r\n<style>
    $c = $c.Replace('</script>' + $rn + $rn + '<style>', '</script>' + $rn + $rn + $tag + $rn + $rn + '<style>')

    Set-Content -Path $path -Value $c -Encoding UTF8 -NoNewline
    Write-Host "OK: $file"
}
