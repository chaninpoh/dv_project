#!/bin/python3
import os
import sys

def rename_content(old_text, new_text,file_extension="*.txt"):
    current_dir = os.getcwd()
    print(f"Scanning directory: {current_dir}")



    for filename in os.listdir(current_dir):

        if filename.endswith(file_extension.split("*")[-1]):

            file_path = os.path.join(current_dir, filename)

            try:

                with open(file_path, 'r', encoding='utf-8') as f:

                    content = f.read()

                updated_content = content.replace(old_text, new_text)

                with open(file_path, 'w', encoding='utf-8') as f:

                    f.write(updated_content)

                print(f"Updated: {filename}")
                new_filename=filename.replace(old_text, new_text)
                if new_filename != filename:
                    os.rename(filename, new_filename)
                    print(f"Renamed file: {filename} → {new_filename}")
                else:
                    new_filename = filename  # No change


            except Exception as e:

                print(f"Error processing {filename}: {e}")









old_text = sys.argv[1]
new_text = sys.argv[2]






if __name__ == "__main__":
    # Replace these with your actual values
    file_path = "."
    rename_content(old_text, new_text, "*.sv")


