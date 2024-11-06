import requests
import time
from dataclasses import dataclass
from typing import List, Dict, Optional
import json
import re
from pathlib import Path

@dataclass
class Section:
    name: str
    items: List[str]
    subsections: List['Section']

def parse_markdown_file(file_path: str) -> List[Section]:
    """Parse the markdown file and return a structured representation"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    lines = content.split('\n')
    sections = []
    current_section = None
    current_subsection = None
    
    for line in lines:
        if line.strip() == '':
            continue
            
        # Main section (##)
        if line.startswith('## '):
            if current_section:
                sections.append(current_section)
            current_section = Section(
                name=line.strip('# ').strip(),
                items=[],
                subsections=[]
            )
            current_subsection = None
            
        # Subsection (###)
        elif line.startswith('### '):
            if current_section:
                if current_subsection:
                    current_section.subsections.append(current_subsection)
                current_subsection = Section(
                    name=line.strip('# ').strip(),
                    items=[],
                    subsections=[]
                )
                
        # List item
        elif line.strip().startswith('* '):
            item = line.strip('* ').strip()
            if current_subsection:
                current_subsection.items.append(item)
            elif current_section:
                current_section.items.append(item)
    
    # Add last section
    if current_section:
        if current_subsection:
            current_section.subsections.append(current_subsection)
        sections.append(current_section)
    
    return sections

@dataclass
class WikidataMatch:
    query: str
    qid: str
    label: str
    description: str
    entity_type: str
    score: float

class WikidataReconciliation:
    def __init__(self, language: str = "en"):
        self.endpoint = "https://www.wikidata.org/w/api.php"
        self.language = language
        self.session = requests.Session()
        
    def search_entity(self, query: str, entity_type: str = None) -> Optional[WikidataMatch]:
        """Search for an entity in Wikidata"""
        # Clean up query (remove parenthetical descriptions)
        clean_query = re.sub(r'\s*\([^)]*\)', '', query).strip()
        
        params = {
            "action": "wbsearchentities",
            "format": "json",
            "language": self.language,
            "search": clean_query,
            "limit": 5
        }
        
        try:
            response = self.session.get(self.endpoint, params=params)
            response.raise_for_status()
            data = response.json()
            
            if not data.get("search"):
                return None
            
            # Get the best match
            best_match = data["search"][0]
            
            return WikidataMatch(
                query=query,
                qid=best_match["id"],
                label=best_match.get("label", ""),
                description=best_match.get("description", ""),
                entity_type=entity_type,
                score=best_match.get("score", 0.0)
            )
            
        except requests.exceptions.RequestException as e:
            print(f"Error searching for '{query}': {e}")
            return None

def process_sections(sections: List[Section], reconciler: WikidataReconciliation) -> Dict:
    """Process all sections and reconcile entities with Wikidata"""
    results = {}
    
    for section in sections:
        print(f"\nProcessing section: {section.name}")
        section_results = []
        
        # Process main section items
        for item in section.items:
            print(f"Processing: {item}")
            match = reconciler.search_entity(item, section.name)
            time.sleep(1)  # Be nice to the Wikidata API
            
            if match:
                result = {
                    "input": item,
                    "wikidata_id": match.qid,
                    "wikidata_label": match.label,
                    "wikidata_description": match.description,
                    "confidence_score": match.score,
                    "wikidata_url": f"https://www.wikidata.org/wiki/{match.qid}"
                }
            else:
                result = {
                    "input": item,
                    "matched": False
                }
            
            section_results.append(result)
        
        # Process subsections
        subsection_results = {}
        for subsection in section.subsections:
            print(f"Processing subsection: {subsection.name}")
            subsection_items = []
            
            for item in subsection.items:
                print(f"Processing: {item}")
                match = reconciler.search_entity(item, subsection.name)
                time.sleep(1)
                
                if match:
                    result = {
                        "input": item,
                        "wikidata_id": match.qid,
                        "wikidata_label": match.label,
                        "wikidata_description": match.description,
                        "confidence_score": match.score,
                        "wikidata_url": f"https://www.wikidata.org/wiki/{match.qid}"
                    }
                else:
                    result = {
                        "input": item,
                        "matched": False
                    }
                
                subsection_items.append(result)
            
            subsection_results[subsection.name] = subsection_items
        
        results[section.name] = {
            "main_items": section_results,
            "subsections": subsection_results
        }
    
    return results

def main():
    # File path
    file_path = Path("prompting-blocks/extracted-entities.md")
    
    # Parse the markdown file
    sections = parse_markdown_file(file_path)
    
    # Initialize reconciler
    reconciler = WikidataReconciliation(language="en")
    
    # Process all sections
    results = process_sections(sections, reconciler)
    
    # Save results
    output_path = Path("wikidata_reconciliation_results.json")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"\nResults saved to {output_path}")

if __name__ == "__main__":
    main()