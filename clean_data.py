import json
import re

# Clean content_items.json
for fname in ['content_items.json', 'search_index.json']:
    path = f'assets/data/{fname}'
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except:
        continue

    cleaned = 0
    if isinstance(data, list):
        for item in data:
            if 'text' in item:
                old = item['text']
                # Replace unicode replacement chars
                new = old.replace('\ufffd', "'")
                # Clean up multiple spaces
                new = re.sub(r' {2,}', ' ', new)
                # Clean up multiple newlines
                new = re.sub(r'\n{3,}', '\n\n', new)
                if new != old:
                    cleaned += 1
                item['text'] = new
            if 'keywords' in item:
                item['keywords'] = [k.replace('\ufffd', "'") for k in item['keywords']]

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f'{fname}: cleaned {cleaned} items')

# Also clean hymns.json
for fname in ['hymns.json']:
    path = f'assets/data/{fname}'
    try:
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except:
        continue

    cleaned = 0
    if isinstance(data, list):
        for item in data:
            if 'text' in item:
                old = item['text']
                new = old.replace('\ufffd', "'")
                new = re.sub(r' {2,}', ' ', new)
                new = re.sub(r'\n{3,}', '\n\n', new)
                if new != old:
                    cleaned += 1
                item['text'] = new
            if 'title' in item:
                item['title'] = item['title'].replace('\ufffd', "'")

    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f'{fname}: cleaned {cleaned} items')
