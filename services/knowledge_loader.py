import os

def load_knowledge():
    knowledge_folder = "knowledge"
    combined_knowledge = ""

    for filename in os.listdir(knowledge_folder):
        file_path = os.path.join(knowledge_folder, filename)

        if filename.endswith(".txt"):
            with open(file_path, "r") as f:
                combined_knowledge += f"\n\n--- {filename} ---\n"
                combined_knowledge += f.read()

    return combined_knowledge