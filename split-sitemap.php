<?php
// Script para dividir el sitemap grande en múltiples archivos
$sitemapFile = __DIR__ . '/sitemap.xml';
$xml = simplexml_load_file($sitemapFile);

if ($xml === false) {
    die("Error al cargar sitemap.xml\n");
}

$urls = [];
foreach ($xml->url as $url) {
    $urls[] = [
        'loc' => (string)$url->loc,
        'lastmod' => (string)$url->lastmod,
        'priority' => (string)$url->priority
    ];
}

// Separar páginas principales de productos
$mainPages = [];
$products = [];

foreach ($urls as $url) {
    if (strpos($url['loc'], '/producto/') !== false) {
        $products[] = $url;
    } else {
        $mainPages[] = $url;
    }
}

// Dividir productos en chunks de 1000
$chunks = array_chunk($products, 1000);

// Guardar sitemap principal
$mainXml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"></urlset>');
foreach ($mainPages as $url) {
    $urlElem = $mainXml->addChild('url');
    $urlElem->addChild('loc', $url['loc']);
    $urlElem->addChild('lastmod', $url['lastmod']);
    $urlElem->addChild('priority', $url['priority']);
}
$mainXml->asXML(__DIR__ . '/sitemap-main.xml');

// Guardar chunks de productos
foreach ($chunks as $i => $chunk) {
    $chunkXml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"></urlset>');
    foreach ($chunk as $url) {
        $urlElem = $chunkXml->addChild('url');
        $urlElem->addChild('loc', $url['loc']);
        $urlElem->addChild('lastmod', $url['lastmod']);
        $urlElem->addChild('priority', $url['priority']);
    }
    $chunkXml->asXML(__DIR__ . "/sitemap-products-" . ($i + 1) . ".xml");
}

// Crear sitemap index
$indexXml = new SimpleXMLElement('<?xml version="1.0" encoding="UTF-8"?><sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9/siteindex"></sitemapindex>');
$indexXml->addAttribute('xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9');

// Agregar sitemap principal
$sitemap = $indexXml->addChild('sitemap');
$sitemap->addChild('loc', 'https://findses.com/sitemap-main.xml');
$sitemap->addChild('lastmod', date('Y-m-d'));

// Agregar sitemaps de productos
foreach ($chunks as $i => $chunk) {
    $sitemap = $indexXml->addChild('sitemap');
    $sitemap->addChild('loc', "https://findses.com/sitemap-products-" . ($i + 1) . ".xml");
    $sitemap->addChild('lastmod', date('Y-m-d'));
}

$indexXml->asXML(__DIR__ . '/sitemap.xml');

echo "Sitemap dividido exitosamente:\n";
echo "- Páginas principales: sitemap-main.xml\n";
echo "- Productos: " . count($chunks) . " archivos (sitemap-products-1.xml a sitemap-products-" . count($chunks) . ".xml)\n";
echo "- Sitemap index actualizado: sitemap.xml\n";
