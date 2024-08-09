import torch.nn.functional as F
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import pandas as pd
from tqdm import tqdm
import os

# Function to analyze the sentiment of a text
def sentiment_analyzer(model, tokenizer, text, chunk_size=512):
    # Split the text into chunks
    chunks = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]

    # Initialize a list to store the predictions and their probabilities
    probabilities = []

    # Process each chunk
    for chunk in chunks:
        # Tokenize the chunk and convert it to tensors
        inputs = tokenizer(chunk, return_tensors='pt', truncation=True, max_length=512).to(model.device)

        # Get the model's output
        outputs = model(**inputs)

        # Apply the softmax function to get the probabilities
        probs = F.softmax(outputs.logits, dim=-1)
        probs = probs.tolist()[0]

        result = {
            'positive': probs[0],
            'neutral': probs[1],
            'negative': probs[2]
        }

        # Append the probabilities to the list
        probabilities.append(result)

    probabilities = pd.DataFrame(probabilities)
    probabilities = probabilities.mean().to_dict()

    return probabilities

print('Loading model and tokenizer...')
# Load your model and tokenizer
model = AutoModelForSequenceClassification.from_pretrained('lxyuan/distilbert-base-multilingual-cased-sentiments-student')
tokenizer = AutoTokenizer.from_pretrained('lxyuan/distilbert-base-multilingual-cased-sentiments-student')

# Move model to GPU
model.to('cuda')
print('Model and tokenizer loaded successfully!')

# Load the data
print('Loading data...')
df = pd.read_csv('articles.csv')
print('Data loaded!')

# Get the articles
articles = df['content']
del df
# Remove NaN values and duplicates
articles = articles.dropna()
articles = articles.drop_duplicates()

# df = pd.read_csv('sentiment_new.csv')
# df = set(df['content'])
# articles = [article for article in articles if article not in df]
# del df

# Define the batch size. Caches the results to a CSV file for every batch, just in case the process is interrupted
batch_size = 100
rows = []
batch_counter = 0
# Define the output file
output_file = 'sentiment_new.csv'

# Analyze the articles
for i in tqdm(range(0, len(articles), batch_size), desc='Analyzing articles'):
    batch = articles[i:i + batch_size]
    
    for article in batch:
        data = sentiment_analyzer(model, tokenizer, article)
        
        row = {
            'content': article,
            'positive': data['positive'],
            'neutral': data['neutral'],
            'negative': data['negative']
        }
        
        rows.append(row)
    
    # Convert rows to DataFrame
    df = pd.DataFrame(rows)
    
    # Write to CSV, append if not the first batch
    if not os.path.exists(output_file):
        df.to_csv(output_file, index=False)
    else:
        df.to_csv(output_file, mode='a', header=False, index=False)
    
    # Clear rows for the next batch
    rows = []
    batch_counter += 1