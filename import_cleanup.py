def clean_file(file, supplied_patterns={}) -> list[str]:
    line_numbers = []
    general_patterns = [
        'null',
        '{}',
        '""',
        '[]'
    ]

    with open(file, 'r') as f:
        for line_number, line in enumerate(f):
            for pattern in general_patterns:
                if pattern in line:
                    line_numbers.append(line_number)
            for key, value in supplied_patterns.items():
                values = [key, value]
                if all(resource in line for resource in values):
                    line_numbers.append(line_number)
        f.close()

    line_numbers.reverse()
    with open(file, 'r') as f:
        lines = f.readlines()
        f.close()
    for line in line_numbers:
        del lines[line]

    return lines


def main() -> None:

    remove = {}
    file = clean_file('generated_resources.tf.original', remove)
    with open('generated_resources.tf.cleaned', 'w') as f:
        f.writelines(file)


if __name__ == "__main__":
    main()
