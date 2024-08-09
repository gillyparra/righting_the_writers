import os
from bs4 import BeautifulSoup
import pandas as pd
import wayback
from concurrent.futures import ThreadPoolExecutor
from tqdm import tqdm
# from config import username, password, host, port

# Sets the proxy for the requests, credentials imported from the config file (Optional)
# os.environ['HTTP_PROXY'] = f'https://{username}:{password}@{host}:{port}'
# os.environ['HTTPS_PROXY'] = f'https://{username}:{password}@{host}:{port}'

# Function to get the articles from the wayback machine
def get_articles(url):
    client = wayback.WaybackClient()
    # If the request fails, return an empty dataframe
    try:
        items = client.search(url)
    except:
        data_list = pd.DataFrame(columns=['date', 'content'])
        return data_list
    data_list = []
    # For each snapshot, get the content
    for item in tqdm(items, desc='Processing snapshots'):
        item_data = {}
        item_data['date'] = item.timestamp
        # If the snapshot does not have any text, set the content to None
        try:
            content = client.get_memento(item).content
            soup = BeautifulSoup(content, 'html.parser')
            text = soup.get_text()
            item_data['content'] = text
        except:
            item_data['content'] = None
        data_list.append(item_data)
    data_list = pd.DataFrame(data_list)
    return data_list

# Function to process each politician (defined to enable parallel processing)
def process_row(row):
    url = row['url']
    name = row['name']
    article = get_articles(url)
    article['name'] = name
    article['url'] = url
    article = article[['date', 'name', 'url', 'content']]
    print('Saving data for', name)
    article.to_csv('wip/treatment.csv', mode='a', header=False, index=False)

# Main function to get all the articles
def get_all(df):
    # If the main file does not exist, create it
    if not os.path.exists('wip/treatment.csv'):
        article = pd.DataFrame(columns=['date', 'name', 'url', 'content'])
        article.to_csv('wip/treatment.csv', index=False)
    # For each row in the dataframe, get the articles
    with ThreadPoolExecutor(max_workers=3000) as executor:
        futures = [executor.submit(process_row, row) for index, row in df.iterrows()]
        for future in futures:
            future.result()  # Wait for all futures to complete

# Load the data
df = pd.read_csv('raw/treatment.csv') # Change the path to the file containing the data
df.rename(columns={'Name': 'name', 'Wikipedia_Link': 'url'}, inplace=True)
df = df[['name', 'url']]

# links = pd.read_csv('raw/updated.csv')
# links.rename(columns={'Name': 'name', 'Wikipedia_Link': 'url'}, inplace=True)

# links = links[links['name'].isin(df['name'])]

# done = pd.read_csv('wip/analyzed_score.csv')
# done = done[['name', 'url']]

# temp = pd.read_csv('wip/articles.csv')
# temp = temp[['name', 'url']]
# done = pd.concat([done, temp])

# df = df[~df['url'].isin(done['url'])]

# Main function
get_all(df)