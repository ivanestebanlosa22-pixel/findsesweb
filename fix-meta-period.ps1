# Normalize meta descriptions — ensure consistent period ending
$productoPath = "C:\Users\ivane\Desktop\findses\producto"
$fixed = 0

Get-ChildItem -Path $productoPath -Filter "*.html" | ForEach-Object {
    $content = Get-Content -Path $_.FullName -Raw -Encoding UTF8
    
    # Remove trailing period before closing quote: "China." -> "China"
    $newContent = $content -replace '(content="[^"]*?China)\.(")', '$1$2'
    
    if ($newContent -ne $content) {
        Set-Content -Path $_.FullName -Value $newContent -Encoding UTF8 -NoNewline
        $fixed++
    }
}

Write-Host "Normalized $fixed descriptions (removed trailing period)"
