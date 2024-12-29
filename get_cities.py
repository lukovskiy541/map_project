import requests
import pandas as pd

def get_ukraine_cities():
    """
    Отримує дані про міста України з OpenStreetMap через Overpass API
    """
    overpass_url = "https://overpass-api.de/api/interpreter"
    
    overpass_query = """
    [out:json][timeout:300];
    area["ISO3166-1"="UA"][admin_level=2]->.ukraine;
    (
      node["place"~"city|town"]["name:uk"](area.ukraine);
      way["place"~"city|town"]["name:uk"](area.ukraine);
      relation["place"~"city|town"]["name:uk"](area.ukraine);
    );
    out center;
    """
    
    print("Завантаження даних про міста з OpenStreetMap...")
    try:
        response = requests.post(overpass_url, data=overpass_query)
        response.raise_for_status()
        data = response.json()
        
        cities = []
        for element in data['elements']:
            if element['type'] == 'node':
                lat = element['lat']
                lon = element['lon']
            else:
                lat = element.get('center', {}).get('lat')
                lon = element.get('center', {}).get('lon')
            
            tags = element.get('tags', {})
            
            place_type = tags.get('place', '')
            ukr_type = 'місто' if place_type == 'city' else 'містечко'
            
            if 'name:uk' in tags and lat and lon:
                cities.append({
                    'назва': tags['name:uk'],
                    'широта': lat,
                    'довгота': lon,
                    'тип': ukr_type,
                    'область': tags.get('addr:region:uk', tags.get('addr:region', '')),
                    'населення': tags.get('population', '0')
                })
        
        # Створюємо DataFrame
        df = pd.DataFrame(cities)
        
        # Конвертуємо населення в числа
        df['населення'] = pd.to_numeric(df['населення'], errors='coerce').fillna(0).astype(int)
        
        # Видаляємо дублікати
        df = df.drop_duplicates(subset=['назва', 'тип'], keep='first')
        
        # Сортуємо за населенням
        df = df.sort_values('населення', ascending=False)
        
        # Зберігаємо у файл
        output_file = 'міста_україни.csv'
        df.to_csv(output_file, index=False, encoding='utf-8')
        
        print(f"\nЗавантажено {len(df)} унікальних міст")
        print(f"Дані збережено у файл: {output_file}")
        print("\nПриклад даних (топ-5 за населенням):")
        print(df.head().to_string())
        
        return df
        
    except Exception as e:
        print(f"Помилка при завантаженні даних: {e}")
        return None

if __name__ == "__main__":
    print("Починаємо завантаження даних про міста України...")
    get_ukraine_cities()
