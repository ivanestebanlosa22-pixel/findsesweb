# Fix meta descriptions — remove trailing numbers like "22.0", "14.0", etc.
$productoPath = "C:\Users\ivane\Desktop\findses\producto"
$fixed = 0
$errors = 0

Get-ChildItem -Path $productoPath -Filter "*.html" | ForEach-Object {
    try {
        $content = Get-Content -Path $_.FullName -Raw -Encoding UTF8
        
        # Pattern: meta description ending with ". NUMBER" or just " NUMBER" before the closing quote
        # Match: content="...China. 22.0" or content="...China 22.0"
        $newContent = $content -replace '(content="[^"]*?(?:China|China\.))\s+\d+\.?\d*(")', '$1$2'
        
        if ($newContent -ne $content) {
            Set-Content -Path $_.FullName -Value $newContent -Encoding UTF8 -NoNewline
            $fixed++
        }
    } catch {
        $errors++
        Write-Host "ERROR: $($_.Name) - $_"
    }
}

Write-Host "Done. Fixed: $fixed, Errors: $errors"
