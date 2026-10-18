# Generate a text file containing input data for the FIFO

WIDTH = 16
DEPTH = 32

data = []

# All 1s
data.extend([0xFFFF] * DEPTH)

# All 0s
data.extend([0x0000] * DEPTH)

# Alternating bit patterns
data.append(0xAAAA)
data.append(0x5555)

# FIFO-order test values
for i in range(DEPTH):
    data.append(i)

with open("input_data.txt", "w") as file:
    for value in data:
        file.write(f"{value:04X}\n")

print(f"Generated {len(data)} values")