import random

# range -0xfff to 0xfff
def generate_random_hex():
    num = random.randint(-4095, 4095)
    # print(num)
    if num >= 0:
        return hex(num)[2:].zfill(4)
    else:
        # Take two's complement for negative numbers
        return hex((1 << 16) + num)[2:].zfill(4)

for i in range(500):
    hex_nums_a = [generate_random_hex() for _ in range(16)]

    # hex_nums_a = ["f001" for _ in range(16)]

    if i == 0:
        with open("input_values_a.txt", "w") as file1:
            file1.write("".join(hex_nums_a) + "\n")
    else:
        with open("input_values_a.txt", "a") as file1:
            file1.write("".join(hex_nums_a) + "\n")

    hex_nums_b = [generate_random_hex() for _ in range(16)]

    # hex_nums_b = ["0fff" for _ in range(16)]

    if i == 0:
        with open("input_values_b.txt", "w") as file2:
            file2.write("".join(hex_nums_b) + "\n")
    else:
        with open("input_values_b.txt", "a") as file2:
            file2.write("".join(hex_nums_b) + "\n")
    print(hex_nums_a)
    print(hex_nums_b)

    # conv hex to int
    nums_a = [int(hex_nums_a, 16) - 0x10000 if int(hex_nums_a, 16) >= 4096 else int(hex_nums_a, 16) for hex_nums_a in hex_nums_a]
    nums_b = [int(hex_nums_b, 16) - 0x10000 if int(hex_nums_b, 16) >= 4096 else int(hex_nums_b, 16) for hex_nums_b in hex_nums_b]
    # print(nums_a)
    # print(nums_b)
    nums_a_matrix = [[nums_a[0], nums_a[1], nums_a[2], nums_a[3]],
                    [nums_a[4], nums_a[5], nums_a[6], nums_a[7]],
                    [nums_a[8], nums_a[9], nums_a[10], nums_a[11]],
                    [nums_a[12], nums_a[13], nums_a[14], nums_a[15]]]
    nums_b_matrix = [[nums_b[0], nums_b[1], nums_b[2], nums_b[3]],
                    [nums_b[4], nums_b[5], nums_b[6], nums_b[7]],
                    [nums_b[8], nums_b[9], nums_b[10], nums_b[11]],
                    [nums_b[12], nums_b[13], nums_b[14], nums_b[15]]]
    
    # mat mul
    result = [[0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0],
            [0, 0, 0, 0]]
    for j in range(4):
        for k in range(4):
            for l in range(4):
                result[j][k] += nums_a_matrix[j][l] * nums_b_matrix[l][k]
    # print(result)

    hex_result = [[hex((num + 0x100000000) if num < 0 else num)[2:].zfill(8) for num in row] for row in result]

    flatten_matrix = [str(element) for row in hex_result for element in row]

    # write
    if i == 0:
        with open("output_comp.txt", "w") as result_file:
            result_file.write(''.join(flatten_matrix) + "\n")
    else:
        with open("output_comp.txt", "a") as result_file:
            result_file.write(''.join(flatten_matrix) + "\n")

