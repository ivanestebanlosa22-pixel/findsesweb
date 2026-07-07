import xml.etree.ElementTree as ET
from datetime import datetime

# Cargar sitemap original
tree = ET.parse('sitemap.xml')
root = tree.getroot()

# Extraer URLs
urls = []
for url in root.findall('{http://www.sitemaps.org/schemas/sitemap/0.9}url'):
    loc = url.find('{http://www.sitemaps.org/schemas/sitemap/0.9}loc').text
    lastmod = url.find('{http://www.sitemaps.org/schemas/sitemap/0.9}lastmod').text
    priority = url.find('{http://www.sitemaps.org/schemas/sitemap/0.9}priority').text
    urls.append({'loc': loc, 'lastmod': lastmod, 'priority': priority})

# Separar páginas principales de productos
main_pages = []
products = []

for url in urls:
    if '/producto/' in url['loc']:
        products.append(url)
    else:
        main_pages.append(url)

# Crear sitemap principal
main_root = ET.Element('{http://www.sitemaps.org/schemas/sitemap/0.9}urlset')
main_root.set('xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9')

for url in main_pages:
    url_elem = ET.SubElement(main_root, '{http://www.sitemaps.org/schemas/sitemap/0.9}url')
    ET.SubElement(url_elem, '{http://www.sitemaps.org/schemas/sitemap/0.9}loc').text = url['loc']
    ET.SubElement(url_elem, '{http://www.sitemaps.org/schemas/sitemap/0.9}lastmod').text = '2026-07-05'
    ET.SubElement(url_elem, '{http://www.sitemaps.org/schemas/sitemap/0.9}priority').text = url['priority']

main_tree = ET.ElementTree(main_root)
main_tree.write('sitemap-main.xml', encoding='UTF-8', xml_declaration=True)

# Dividir productos en chunks de 1000
chunks = [products[i:i+1000] for i in range(0, len(products), 1000)]

for i, chunk in enumerate(chunks):
    chunk_root = ET.Element('{http://www.sitemaps.org/schemas/sitemap/0.9}urlset')
    chunk_root.set('xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9')
    
    for url in chunk:
        url_elem = ET.SubElement(chunk_root, '{http://www.sitemaps.org/schemas/sitemap/0.9}url')
        ET.SubElement(url_elem, '{http://www.sitemaps.org/schemas/sitemap/0.9}loc').text = url['loc']
        ET.SubElement(url_elem, '{http://www.sitemaps.org/schemas/sitemap/0.9}lastmod').text = '2026-07-05'
        ET.SubElement(url_elem, '{http://www.sitemaps.org/schemas/sitemap/0.9}priority').text = url['priority']
    
    chunk_tree = ET.ElementTree(chunk_root)
    chunk_tree.write(f'sitemap-products-{i+1}.xml', encoding='UTF-8', xml_declaration=True)

# Crear sitemap index
index_root = ET.Element('{http://www.sitemaps.org/schemas/sitemap/0.9/siteindex}sitemapindex')
index_root.set('xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9')

# Agregar sitemap principal
sitemap = ET.SubElement(index_root, '{http://www.sitemaps.org/schemas/sitemap/0.9/siteindex}sitemap')
ET.SubElement(sitemap, '{http://www.sitemaps.org/schemas/sitemap/0.9/siteindex}loc').text = 'https://findses.com/sitemap-main.xml'
ET.SubElement(sitemap, '{http://www.sitemaps.org/schemas/sitemap/0.9/siteindex}lastmod').text = datetime.now().strftime('%Y-%m-%d')

# Agregar sitemaps de productos
for i in range(len(chunks)):
    sitemap = ET.SubElement(index_root, '{http://www.sitemaps.org/schemas/sitemap/0.9/siteindex}sitemap')
    ET.SubElement(sitemap, '{http://www.sitemaps.org/schemas/sitemap/0.9/siteindex}loc').text = f'https://findses.com/sitemap-products-{i+1}.xml'
    ET.SubElement(sitemap, '{http://www.sitemaps.org/schemas/sitemap/0.9/siteindex}lastmod').text = datetime.now().strftime('%Y-%m-%d')

index_tree = ET.ElementTree(index_root)
index_tree.write('sitemap-index.xml', encoding='UTF-8', xml_declaration=True)

print(f"Sitemap dividido exitosamente:")
print(f"- Páginas principales: sitemap-main.xml ({len(main_pages)} URLs)")
print(f"- Productos: {len(chunks)} archivos (sitemap-products-1.xml a sitemap-products-{len(chunks)}.xml)")
print(f"- Sitemap index: sitemap-index.xml")
print(f"\nActualiza tu robots.txt para apuntar a sitemap-index.xml")
