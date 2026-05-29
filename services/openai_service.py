from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

client = OpenAI()

def invoke(prompt):
    response = client.responses.create(
        model="gpt-5.5",
        input=prompt
    )
    return response.output_text
