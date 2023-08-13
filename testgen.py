import random

def generate_matrix(rows, cols):
    return [[random.randint(0, 20) for _ in range(cols)] for _ in range(rows)]
    # generate matrix values

def matrix_multiply(a, b):
    result = [[0 for _ in range(len(b[0]))] for _ in range(len(a))]
    for i in range(len(a)):
        for j in range(len(b[0])):
            for k in range(len(b)):
                result[i][j] += a[i][k] * b[k][j]
    return result

def transpose(matrix):
    r = len(matrix)
    c = len(matrix[0])
    new = [[matrix[i][j] for i in range(r)] for j in range(c)]
    return new

def gen_test():
    num_pairs = random.randint(1, 6) # n = number of matrices from 1 to 6
    test_case = [] # list of matrices (a,b)
    instructions = []
    for _ in range(num_pairs):
        x = random.randint(1, 10) # size of a matrix, make 16 later
        instructions.append(x)
        a = generate_matrix(4, x)
        b = generate_matrix(x, 4)
        test_case.append((a, transpose(b)))
    
    while len(instructions) < 8:
        instructions.append(0)

    result = []
    for case in test_case:
        res = matrix_multiply(case[0], transpose(case[1]))
        for i in res:
            for j in i:
                result.append(j)

    # print('num pairs', num_pairs)
    # print('inst', instructions)
    # print('case', test_case)
    # print('result', result)

    return num_pairs, instructions, test_case,  result

    

def generate_tests(count):
    test_cases = []
    for _ in range(count):
        test_cases.append(gen_test())
    return test_cases

tests = generate_tests(5)

def write_test_to_file(filename, test_tuple):
    num_pairs, instructions, test_case, result = test_tuple

    with open(filename, "w") as f:
        # Write num_pairs
        f.write(f"{num_pairs}\n")
        
        # Write instructions array
        f.write(" ".join(map(str, instructions)) + "\n")

        # Write array of matrices a
        for a, _ in test_case:
            for row in a:
                f.write(" ".join(map(str, row)) + "\n")
        
        # Write array of matrices b
        for _, b in test_case:
            for row in b:
                f.write(" ".join(map(str, row)) + "\n")

        # Write result matrices
        f.write(" ".join(map(str, result)) + "\n")


# Assume tests is a list of test tuples
for idx, test in enumerate(tests, start=1):
    filename = f"test_{idx}.txt"
    write_test_to_file(filename, test)
