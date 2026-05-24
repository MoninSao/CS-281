import re
import sys

def extract_second_column(file_content):
    """
    Extracts the second column from the given file content and drops the "0x" prefix.
    
    Parameters:
    file_content (str): The content of the file to be processed.
    
    Returns:
    list: A list of the extracted second column values without the "0x" prefix.
    """
    result = []
    for line in file_content.splitlines():
        parts = line.split()
        if len(parts) >= 2:
            value = parts[1]
            value = re.sub(r'^0x', '', value)
            result.append(value)
            
    result += ["00000000"] * (1024 - len(result))
    return result



def format_output(values):
    """
    Formats the list of values into the desired output format.
    
    Parameters:
    values (list): A list of values to be formatted.
    
    Returns:
    str: The formatted output.
    """
    output = "v3.0 hex words addressed\n"
    for i in range(0, len(values), 8):
        row = f"{i:03X}: " + " ".join(values[i:i+8]) + "\n"
        output += row
    return output

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_file> <output_file>")
        #sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    try:
        with open(input_file, "r") as file:
            file_content = file.read()
        extracted_values = extract_second_column(file_content)
        formatted_output = format_output(extracted_values)

        with open(output_file, "w") as file:
            file.write(formatted_output)

        print(f"Output written to: {output_file}")
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
    except Exception as e:
        print(f"Error: {e}")