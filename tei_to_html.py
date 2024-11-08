from bs4 import BeautifulSoup
import re
from typing import Dict, List
import uuid
import os
import shutil

class TEItoHTMLConverter:
    def __init__(self):
        self.footnotes = []
        self.editorial_notes = []
        self.apparatus_entries = []
        self.current_page = ""
        self.facsimile_images = []
        
    def generate_id(self) -> str:
        return str(uuid.uuid4())[:8]

    def create_html_template(self, title: str) -> str:
        return """
        <!DOCTYPE html>
        <html lang="de">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>%s</title>
            <link rel="stylesheet" href="styles.css">
        </head>
        <body>
            <div class="container">
                <div class="facsimile" id="facsimile-panel">
                    <h3>Manuscript Images</h3>
                    <div class="image-controls">
                        <button onclick="zoomIn()">Zoom In</button>
                        <button onclick="zoomOut()">Zoom Out</button>
                        <button onclick="resetZoom()">Reset</button>
                    </div>
                    %s
                </div>
                <div class="main-text">
                    <h1>%s</h1>
                    <div class="text-controls">
                        <input type="text" id="search" placeholder="Search text...">
                        <button onclick="toggleNotes()">Toggle Notes</button>
                    </div>
                    %s
                </div>
                <div class="apparatus">
                    <h3>Critical Apparatus</h3>
                    <div class="apparatus-controls">
                        <select id="apparatus-filter">
                            <option value="all">All Notes</option>
                            <option value="footnotes">Footnotes</option>
                            <option value="editorial">Editorial</option>
                            <option value="variants">Variants</option>
                        </select>
                    </div>
                    <div id="footnotes">
                        <h4>Footnotes</h4>
                        %s
                    </div>
                    <div id="editorial-notes">
                        <h4>Editorial Notes</h4>
                        %s
                    </div>
                    <div id="apparatus-entries">
                        <h4>Textual Variants</h4>
                        %s
                    </div>
                </div>
            </div>
            <script>
                document.addEventListener('DOMContentLoaded', function() {
                    // Enhanced image viewer functionality
                    let scale = 1;
                    window.zoomIn = function() {
                        scale *= 1.2;
                        updateZoom();
                    };
                    window.zoomOut = function() {
                        scale /= 1.2;
                        updateZoom();
                    };
                    window.resetZoom = function() {
                        scale = 1;
                        updateZoom();
                    };
                    function updateZoom() {
                        document.querySelectorAll('.facsimile img').forEach(img => {
                            img.style.transform = `scale(${scale})`;
                        });
                    }

                    // Enhanced text highlighting
                    document.querySelectorAll('[data-target]').forEach(item => {
                        item.addEventListener('click', e => {
                            const targetId = e.currentTarget.getAttribute('data-target');
                            const targetElement = document.getElementById(targetId);
                            if (targetElement) {
                                // Remove previous highlights
                                document.querySelectorAll('.highlighted').forEach(el => {
                                    el.classList.remove('highlighted');
                                });
                                // Add new highlight
                                targetElement.classList.add('highlighted');
                                targetElement.scrollIntoView({behavior: 'smooth', block: 'center'});
                            }
                        });
                    });

                    // Apparatus filtering
                    document.getElementById('apparatus-filter').addEventListener('change', function(e) {
                        const filter = e.target.value;
                        const sections = {
                            'footnotes': document.getElementById('footnotes'),
                            'editorial': document.getElementById('editorial-notes'),
                            'variants': document.getElementById('apparatus-entries')
                        };
                        
                        if (filter === 'all') {
                            Object.values(sections).forEach(section => {
                                section.style.display = 'block';
                            });
                        } else {
                            Object.entries(sections).forEach(([key, section]) => {
                                section.style.display = key === filter ? 'block' : 'none';
                            });
                        }
                    });

                    // Text search functionality
                    const searchInput = document.getElementById('search');
                    let searchTimeout;
                    searchInput.addEventListener('input', function(e) {
                        clearTimeout(searchTimeout);
                        searchTimeout = setTimeout(() => {
                            const searchText = e.target.value.toLowerCase();
                            const content = document.querySelector('.main-text');
                            if (!searchText) {
                                // Reset highlights
                                content.innerHTML = content.innerHTML.replace(/<mark>|<\/mark>/g, '');
                                return;
                            }
                            
                            const regex = new RegExp(searchText, 'gi');
                            content.innerHTML = content.innerHTML.replace(/<mark>|<\/mark>/g, '');
                            content.innerHTML = content.innerHTML.replace(regex, match => `<mark>${match}</mark>`);
                        }, 300);
                    });
                });
            </script>
        </body>
        </html>
        """

    def process_element(self, element) -> str:
        if not element:
            return ""
            
        if isinstance(element, str):
            return element
            
        element_id = self.generate_id()
        
        if element.name == 'supplied':
            return f'<span class="supplied" title="Editorial addition">[{element.get_text()}]</span>'
            
        elif element.name == 'foreign':
            return f'<span class="foreign" lang="{element.get("xml:lang", "")}">{element.get_text()}</span>'
            
        elif element.name == 'note':
            note_type = element.get('type', '')
            if note_type == 'footnote':
                note_id = f'fn-{element_id}'
                self.footnotes.append((note_id, element.get_text()))
                return f'<sup class="footnote-marker" data-target="{note_id}">{len(self.footnotes)}</sup>'
            elif note_type == 'editorial':
                note_id = f'en-{element_id}'
                self.editorial_notes.append((note_id, element.get_text()))
                return f'<span class="editorial-note" data-target="{note_id}">†</span>'
                
        elif element.name == 'app':
            app_id = f'app-{element_id}'
            lem = element.find('lem')
            rdg = element.find('rdg')
            if lem and rdg:
                self.apparatus_entries.append((
                    app_id,
                    f'Lemma: {lem.get_text()}, Reading: {rdg.get_text()} ({rdg.get("type", "")}, {rdg.get("resp", "")})'
                ))
                return f'<span class="apparatus" id="{app_id}" data-type="variant">{lem.get_text()}</span>'
                
        elif element.name == 'pb':
            page_num = element.get('n', '')
            self.current_page = page_num
            return f'<div class="page-break" id="page-{page_num}">|{page_num}|</div>'
            
        elif element.name == 'hi':
            rend = element.get('rend', '')
            if 'underline' in rend:
                return f'<span class="underline">{self.process_children(element)}</span>'
            elif 'italic' in rend:
                return f'<span class="italic">{self.process_children(element)}</span>'
            elif 'bold' in rend:
                return f'<span class="bold">{self.process_children(element)}</span>'
                
        elif element.name == 'choice':
            abbr = element.find('abbr')
            expan = element.find('expan')
            if abbr and expan:
                return f'<abbr title="{expan.get_text()}" class="expansion">{abbr.get_text()}</abbr>'
                
        elif element.name == 'del':
            return f'<del class="deletion">{self.process_children(element)}</del>'
            
        elif element.name == 'title':
            return f'<span class="title">{self.process_children(element)}</span>'
            
        elif element.name == 'persName':
            return f'<span class="person">{self.process_children(element)}</span>'
            
        elif element.name == 'list':
            list_type = element.get('type', '')
            rend = element.get('rend', '')
            if list_type == 'ordered':
                if rend == 'letters':
                    return f'<ol class="letter-list">{self.process_children(element)}</ol>'
                else:
                    return f'<ol>{self.process_children(element)}</ol>'
            else:
                return f'<ul>{self.process_children(element)}</ul>'
                
        elif element.name == 'item':
            return f'<li>{self.process_children(element)}</li>'
            
        elif element.name == 'p':
            return f'<p>{self.process_children(element)}</p>'
            
        elif element.name == 'head':
            return f'<h2>{self.process_children(element)}</h2>'
            
        elif element.name == 'div':
            div_type = element.get('type', '')
            n = element.get('n', '')
            div_class = f'class="{div_type}"' if div_type else ''
            div_id = f' id="div-{n}"' if n else ''
            return f'<div {div_class}{div_id}>{self.process_children(element)}</div>'
            
        return self.process_children(element)

    def process_children(self, element) -> str:
        return ''.join(self.process_element(child) for child in element.children)

    def process_facsimile(self, image_files: List[str]) -> str:
        return '\n'.join(
            f'<figure class="manuscript-page">'
            f'<img src="{img}" alt="Manuscript page {i+1}" class="zoomable-image">'
            f'<figcaption>Page {i+1}</figcaption>'
            f'</figure>'
            for i, img in enumerate(image_files)
        )

    def convert(self, xml_content: str, image_files: List[str] = None) -> str:
        soup = BeautifulSoup(xml_content, 'xml')
        
        # Process main content
        body = soup.find('body')
        main_content = self.process_element(body) if body else ""
        
        # Generate apparatus sections
        footnotes_html = '\n'.join(
            f'<div id="{id}" class="footnote" data-page="{self.current_page}">{i+1}. {content}</div>'
            for i, (id, content) in enumerate(self.footnotes)
        )
        
        editorial_notes_html = '\n'.join(
            f'<div id="{id}" class="editorial-note" data-page="{self.current_page}">{content}</div>'
            for id, content in self.editorial_notes
        )
        
        apparatus_entries_html = '\n'.join(
            f'<div id="{id}" class="apparatus-entry" data-page="{self.current_page}">{content}</div>'
            for id, content in self.apparatus_entries
        )
        
        # Process facsimile images
        facsimile_html = self.process_facsimile(image_files) if image_files else ""
        
        # Fill template
        title = "Philosophische Bemerkungen"
        template = self.create_html_template(title)
        html = template % (
            title,
            facsimile_html,
            title,
            main_content,
            footnotes_html,
            editorial_notes_html,
            apparatus_entries_html
        )
        
        return html

def main():
    # Create output directory if it doesn't exist
    output_dir = 'output'
    os.makedirs(output_dir, exist_ok=True)

    # Read TEI XML file
    with open('data/KG21III6b69.xml', 'r', encoding='utf-8') as f:
        xml_content = f.read()
    
    # List of facsimile images
    image_files = ['KG21III6b69-img.png']
    
    # Convert to HTML
    converter = TEItoHTMLConverter()
    html_output = converter.convert(xml_content, image_files)
    
    # Write HTML output
    with open(os.path.join(output_dir, 'KG21III6b69.html'), 'w', encoding='utf-8') as f:
        f.write(html_output)

    # Copy CSS file to output directory
    css_source = 'styles.css'
    if os.path.exists(css_source):
        shutil.copy2(css_source, os.path.join(output_dir, 'styles.css'))
    else:
        print("Warning: styles.css not found. Please create a CSS file.")

    # Copy images to output directory
    for image in image_files:
        if os.path.exists(image):
            shutil.copy2(image, os.path.join(output_dir, image))
        else:
            print(f"Warning: Image file {image} not found.")

if __name__ == "__main__":
    main()