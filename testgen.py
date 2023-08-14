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

def transform(mat, first):
    col = len(mat[0])
    newcol = col + (6 if first else 7)
    newmat = [[0 for i in range(newcol)] for j in range(len(mat))]
    for i in range(len(mat)):
        for j in range(col):
            newmat[i][i + j] = mat[i][j]
    return newmat

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
    
    proc_mat = []
    for i in range(len(test_case)):
        flag = True if i == 0 else False
        proc_mat.append((transform(test_case[i][0],flag),transform(test_case[i][1],flag)))
    return num_pairs, instructions, proc_mat,  result

def generate_tests(count):
    test_cases = []
    for _ in range(count):
        test_cases.append(gen_test())
    return test_cases

tests = generate_tests(1)



def write_test_to_file(filename, test_tuple):
    num_pairs, instructions, test_case, result = test_tuple

    with open(filename, "w") as f:
        # n
        f.write(f"{num_pairs}\n")
        
        # instructions
        f.write(" ".join(map(str, instructions)) + "\n")


        # result
        f.write(" ".join(map(str, result)) + "\n")

        # a
        for a, _ in test_case:
            for row in a:
                f.write(" ".join(map(str, row)) + "\n")
        
        # b
        for _, b in test_case:
            for row in b:
                f.write(" ".join(map(str, row)) + "\n")


for idx, test in enumerate(tests, start=1):
    filename = f"test_{idx}.txt"
    write_test_to_file(filename, test)
