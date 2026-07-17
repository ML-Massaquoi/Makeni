import json

with open(r'assets\data\content_items.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Count items with replacement chars
bad_items = []
for item in data:
    text = item.get('text', '')
    title = item.get('title', '')
    if '\ufffd' in text:
        count = text.count('\ufffd')
        bad_items.append((title, count))

print(f'Items with replacement chars: {len(bad_items)}')
for title, count in bad_items[:10]:
    print(f'  - {title}: {count} chars')

# Count items with question marks
qm_items = []
for item in data:
    text = item.get('text', '')
    title = item.get('title', '')
    if '?' in text:
        count = text.count('?')
        qm_items.append((title, count))

print(f'\nItems with ?: {len(qm_items)}')
for title, count in qm_items[:10]:
    print(f'  - {title}: {count} ?')

# Check for numbered items like "1." "2." etc
num_items = []
for item in data:
    text = item.get('text', '')
    title = item.get('title', '')
    import re
    nums = re.findall(r'^\d+\.\s', text, re.MULTILINE)
    if nums:
        num_items.append((title, len(nums)))

print(f'\nItems with numbered lines: {len(num_items)}')
for title, count in num_items[:10]:
    print(f'  - {title}: {count} numbered lines')
