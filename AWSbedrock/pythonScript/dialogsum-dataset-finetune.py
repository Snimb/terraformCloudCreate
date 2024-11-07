import pandas as pd
from datasets import load_dataset

# Load your company's data, assuming it's in CSV format
#df = pd.read_csv('your_company_data.csv')

# Modify column names as needed, e.g., 'input_text' for prompts and 'target_text' for completions
#df = df.rename(columns={"input_text": "prompt", "target_text": "completion"})

# Optionally limit the dataset to a certain size or sample rows
#df = df.sample(10000, random_state=42)

# Save the dataset in JSONL format
#df.to_json('company-data-finetune.jsonl', orient='records', lines=True)


# Load the dataset from the huggingface hub
dataset = load_dataset("knkarthick/dialogsum")

# Convert the dataset to a pandas DataFrame
dft = dataset['train'].to_pandas()

# Drop the columns that are not required for fine-tuning
dft = dft.drop(columns=['id', 'topic'])

# Rename the columns to prompt and completion as required for fine-tuning.
# Ref: https://docs.aws.amazon.com/bedrock/latest/userguide/model-customization-prereq.html#model-customization-prepare
dft = dft.rename(columns={"dialogue": "prompt", "summary": "completion"})

# Limit the number of rows to 10,000 for fine-tuning
dft = dft.sample(10000,
    random_state=42)

# Save DataFrame as a JSONL file, with each line as a JSON object
dft.to_json('dialogsum-train-finetune.jsonl', orient='records', lines=True)