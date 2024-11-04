# TEI Document Structure

## TEI Root Element
- `<TEI xmlns="http://www.tei-c.org/ns/1.0">`

## TEI Header
### fileDesc (required)
- **titleStmt**
  - title
  - author (optional)
  - editor (optional)
- **publicationStmt**
  - publisher
  - date
  - availability
- **sourceDesc**
  - description of source document

### encodingDesc
- **classDecl**
  - **taxonomy** (@xml:id="terms")
    - **category** (@xml:id="FLORA")
      - catDesc
      - subcategories
    - **category** (@xml:id="FAUNA")
      - catDesc
    - **category** (@xml:id="MEASURES")
      - catDesc
    - **category** (@xml:id="FEATURES")
      - catDesc

## standOff
### listPlace
- **place** (@xml:id="place.1")
  - placeName
  - placeName (@type="modern")
  - location
  - note

### listPerson
- **person** (@xml:id="pers.1")
  - persName
  - birth (@when)
  - death (@when)
  - occupation
  - note

### listEvent
- **event** (@when)
  - label
  - desc

## text
- **body**
  - p (paragraphs)

# Key Features of This Structure

1. **Modular Organization**
   - Clear separation of metadata (teiHeader)
   - Standalone entity lists (standOff)
   - Main text content (text)

2. **Controlled Vocabularies**
   - Taxonomies for classification
   - Standardized categories
   - Hierarchical term organization

3. **Entity Management**
   - Structured place records
   - Person information
   - Event documentation

4. **Reference System**
   - XML IDs for cross-referencing
   - Consistent identifier patterns
   - Linked data preparation

# Important Conventions

1. **ID Patterns**
   - Places: `place.{n}`
   - Persons: `pers.{n}`
   - Terms: `term.{n}`
   - Organisations: `org.{n}`

2. **Dates**
   - ISO format (YYYY-MM-DD)
   - Partial dates allowed (YYYY-MM or YYYY)

3. **DO NOT:**
   - Coordinates
   - revisionDesc

4. **Types**
   - Modern vs. historical names
   - Occupational categories
   - Feature classifications

# Required Elements

1. **Minimum teiHeader**
   - fileDesc with titleStmt
   - publicationStmt
   - sourceDesc

2. **standOff**
   - listBibl for bibliography
   - listEvent for evetns
   - listPerson for persons
   - listPlace for places
   - listOrg for organizations
   - additional taxonomies

3. **Rich Text Features**
   - div elements for structure
   - pb for page breaks
   - note for editorial commentary