Add-Type -AssemblyName System.Web
$productoPath = "C:\Users\ivane\Desktop\findses\producto"
$fixed = 0

$files = Get-ChildItem -Path $productoPath -Filter "*.html"
foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    if ($content -notmatch 'class="crumb">(.*?)</div>') { continue }
    $crumbHtml = $matches[1]
    
    # Extract category: 3rd <a> tag content
    if ($crumbHtml -match '(?s)<a[^>]*>([^<]+)</a>\s*.\s*<a[^>]*>([^<]+)</a>\s*.\s*<a[^>]*>([^<]+)</a>') {
        $categoryRaw = $matches[3].Trim()
    } else { continue }
    
    # Extract product: last <b> tag content
    if ($crumbHtml -match '<b>([^<]+)</b>') {
        $productTitle = $matches[1].Trim()
    } else { continue }
    
    $catEnc = [System.Web.HttpUtility]::HtmlEncode($categoryRaw)
    $prodEnc = [System.Web.HttpUtility]::HtmlEncode($productTitle)
    
    $newCrumb = @"
<nav aria-label="Breadcrumb" class="crumb"><ol itemscope itemtype="https://schema.org/BreadcrumbList"><li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem"><a itemprop="item" href="../index.html"><span itemprop="name">Inicio</span></a><meta itemprop="position" content="1"></li><li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem"><a itemprop="item" href="../catalogo.html"><span itemprop="name">Catálogo</span></a><meta itemprop="position" content="2"></li><li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem"><a itemprop="item" href="../catalogo.html"><span itemprop="name">$catEnc</span></a><meta itemprop="position" content="3"></li><li itemprop="itemListElement" itemscope itemtype="https://schema.org/ListItem"><span itemprop="name">$prodEnc</span><meta itemprop="position" content="4"></li></ol></nav>
"@
    
    $newContent = $content -replace '<div class="crumb">.*?</div>', $newCrumb.Trim()
    
    # Clean trailing numbers/periods from Product schema description
    $newContent = $newContent -replace '("description":"[^"]*?)\s*\d+\.\d+(")', '$1$2'
    $newContent = $newContent -replace '("description":"[^"]*?)\.\s*"category', '$1"category'
    
    if ($newContent -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.UTF8Encoding]::new($false))
        $fixed++
    }
}
Write-Host "Fixed $fixed product pages with semantic breadcrumbs + BreadcrumbList schema"
