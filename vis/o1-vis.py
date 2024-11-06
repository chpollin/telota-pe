import xml.etree.ElementTree as ET
import pandas as pd
import requests
from dateutil.parser import parse as parse_date
import plotly.express as px

# Define the TEI namespace
NS = {'tei': 'http://www.tei-c.org/ns/1.0'}

def parse_tei_xml(file_path):
    """
    Parses the TEI XML file and extracts place names, dates, and observations.

    Parameters:
    - file_path: str, path to the TEI XML file.

    Returns:
    - df: pandas DataFrame containing the extracted data.
    """
    # Parse the TEI XML file
    tree = ET.parse('H0016412.xml')
    root = tree.getroot()
    
    # Find the <body> element
    body = root.find('.//tei:body', NS)
    
    # Initialize a list to store data
    data = []
    
    # Recursive function to process <div> elements
    def process_div(div_element):
        # Iterate through child elements
        for child in div_element:
            # If the element is a <div>, process it recursively
            if child.tag == '{http://www.tei-c.org/ns/1.0}div':
                process_div(child)
            elif child.tag == '{http://www.tei-c.org/ns/1.0}p':
                process_paragraph(child)
    
    # Function to process a <p> element
    def process_paragraph(paragraph):
        # Initialize variables
        place_names = paragraph.findall('.//tei:placeName', NS)
        dates = paragraph.findall('.//tei:date', NS)
        observation_text = ''.join(paragraph.itertext()).strip()
        
        # Extract place names and refs
        places = []
        for pname in place_names:
            place_text = pname.text.strip() if pname.text else ''
            ref = pname.get('ref')
            places.append({'name': place_text, 'ref': ref})
        
        # Extract dates
        dates_list = []
        for date_elem in dates:
            date_text = date_elem.text.strip() if date_elem.text else ''
            when = date_elem.get('when')
            not_before = date_elem.get('notBefore')
            not_after = date_elem.get('notAfter')
            dates_list.append({'text': date_text, 'when': when, 'notBefore': not_before, 'notAfter': not_after})
        
        # If there are multiple places and dates, create combinations
        if places and dates_list:
            for place in places:
                for date in dates_list:
                    data.append({
                        'place_name': place['name'],
                        'place_ref': place['ref'],
                        'date_text': date['text'],
                        'date_when': date['when'],
                        'date_notBefore': date['notBefore'],
                        'date_notAfter': date['notAfter'],
                        'observation': observation_text
                    })
        elif places:
            for place in places:
                data.append({
                    'place_name': place['name'],
                    'place_ref': place['ref'],
                    'date_text': None,
                    'date_when': None,
                    'date_notBefore': None,
                    'date_notAfter': None,
                    'observation': observation_text
                })
        elif dates_list:
            for date in dates_list:
                data.append({
                    'place_name': None,
                    'place_ref': None,
                    'date_text': date['text'],
                    'date_when': date['when'],
                    'date_notBefore': date['notBefore'],
                    'date_notAfter': date['notAfter'],
                    'observation': observation_text
                })
        else:
            data.append({
                'place_name': None,
                'place_ref': None,
                'date_text': None,
                'date_when': None,
                'date_notBefore': None,
                'date_notAfter': None,
                'observation': observation_text
            })
    
    # Start processing from the body
    process_div(body)
    
    # Convert data to DataFrame
    df = pd.DataFrame(data)
    return df

def geocode_place(place_name):
    """
    Geocodes a place name using Nominatim (OpenStreetMap) and returns latitude and longitude.

    Parameters:
    - place_name: str, the name of the place to geocode.

    Returns:
    - lat: float, latitude of the place.
    - lon: float, longitude of the place.
    """
    base_url = 'https://nominatim.openstreetmap.org/search'
    params = {
        'q': place_name,
        'format': 'json',
        'limit': 1
    }
    headers = {
        'User-Agent': 'TEIParser/1.0 (your_email@example.com)'
    }
    try:
        response = requests.get(base_url, params=params, headers=headers)
        if response.status_code == 200:
            data = response.json()
            if data:
                lat = float(data[0]['lat'])
                lon = float(data[0]['lon'])
                return lat, lon
    except Exception as e:
        print(f"Error geocoding {place_name}: {e}")
    return None, None

def get_coordinates(df):
    """
    Maps place names in the DataFrame to their geographical coordinates.

    Parameters:
    - df: pandas DataFrame containing the 'place_name' column.

    Returns:
    - df: pandas DataFrame with added 'latitude' and 'longitude' columns.
    """
    # Get unique place names
    place_names = df['place_name'].dropna().unique()
    
    # Create a dictionary to store coordinates
    coordinates = {}
    
    for place in place_names:
        lat, lon = geocode_place(place)
        if lat is not None and lon is not None:
            coordinates[place] = {'latitude': lat, 'longitude': lon}
        else:
            coordinates[place] = {'latitude': None, 'longitude': None}
    
    # Map coordinates back to the DataFrame
    df['latitude'] = df['place_name'].map(lambda x: coordinates.get(x, {}).get('latitude'))
    df['longitude'] = df['place_name'].map(lambda x: coordinates.get(x, {}).get('longitude'))
    return df

def parse_dates(df):
    """
    Parses date information from the DataFrame.

    Parameters:
    - df: pandas DataFrame containing date columns.

    Returns:
    - df: pandas DataFrame with an added 'parsed_date' column.
    """
    def parse_date_row(row):
        # Try 'when' attribute
        if pd.notnull(row['date_when']):
            try:
                return parse_date(row['date_when'])
            except:
                pass
        # Try 'notBefore' and 'notAfter' as a range
        if pd.notnull(row['date_notBefore']) and pd.notnull(row['date_notAfter']):
            try:
                date_start = parse_date(row['date_notBefore'])
                date_end = parse_date(row['date_notAfter'])
                # For visualization, take the midpoint
                date_mid = date_start + (date_end - date_start)/2
                return date_mid
            except:
                pass
        # Try 'date_text'
        if pd.notnull(row['date_text']):
            try:
                return parse_date(row['date_text'])
            except:
                pass
        return None
    
    df['parsed_date'] = df.apply(parse_date_row, axis=1)
    # Drop rows without a valid date
    df = df.dropna(subset=['parsed_date'])
    return df

def create_interactive_map(df):
    """
    Creates an interactive map visualization of the observations.

    Parameters:
    - df: pandas DataFrame containing the data to visualize.
    """
    # Ensure that latitude and longitude are numeric
    df = df.dropna(subset=['latitude', 'longitude'])
    df['latitude'] = pd.to_numeric(df['latitude'], errors='coerce')
    df['longitude'] = pd.to_numeric(df['longitude'], errors='coerce')
    df = df.dropna(subset=['latitude', 'longitude'])
    
    # Sort data by date
    df = df.sort_values(by='parsed_date')
    
    # Create a date string for display
    df['date_str'] = df['parsed_date'].dt.strftime('%Y-%m-%d')
    
    # Create the figure
    fig = px.scatter_mapbox(
        df,
        lat='latitude',
        lon='longitude',
        color='place_name',
        hover_name='place_name',
        hover_data={
            'Date': df['date_str'],
            'Observation': df['observation']
        },
        size_max=15,
        zoom=2,
        height=600,
        animation_frame='date_str',
        animation_group='place_name'
    )
    
    fig.update_layout(
        mapbox_style='open-street-map',
        title='Humboldt\'s Observations Over Time',
        showlegend=True
    )
    
    fig.show()

def main():
    # File path to the TEI XML file
    file_path = 'path_to_your_file.xml'  # Replace with your file path
    
    # Parse the TEI XML
    df = parse_tei_xml(file_path)
    
    # Parse dates
    df = parse_dates(df)
    
    # Get coordinates
    df = get_coordinates(df)
    
    # Create interactive map
    create_interactive_map(df)

if __name__ == '__main__':
    main()
