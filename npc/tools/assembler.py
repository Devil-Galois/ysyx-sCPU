import argparse
from pathlib import Path

def clean_line(raw_line):
    return raw_line.split("#", 1)[0].strip()

def first_pass(lines):
    labels = {}
    instructions = []
    pc = 0

    for line_number, raw_line in enumerate(lines, start = 1):
        line = clean_line(raw_line)

        if not line:
            continue

        if ":" in line:
            label, line = line.split(":", 1)
            label = label.strip()
            line = line.strip()

            if not label.isidentifier():
                raise ValueError(f"line {line_number}: invalid label '{label}'")

            if label in labels:
                raise ValueError(f"line {line_number}: duplicate label '{label}'")

            labels[label] = pc

            if not line:
                continue

        instructions.append((line_number, pc, line))
        pc += 1
    return labels, instructions

def parse_register(token, line_number):
    token = token.lower()
    if not token.startswith("r") or not token[1:].isdigit():
        raise ValueError(f"line {line_number}: invalid register '{token}'")

    register = int(token[1:])

    if not 0 <= register <= 3:
        raise ValueError(
            f"line {line_number}: register must be r0-r3, got '{token}'"
        )
    return register

def parse_number(token, line_number):
    try:
        return int(token, 0)
    except ValueError:
        raise ValueError(
            f"line {line_number}: invalid number '{token}'"
        )from None

def encode_li_immediate(value, line_number):
    if not 0 <= value <= 255:
        raise ValueError(
            f"line {line_number}: li value must be 0-255, got {value}"
        )
    for s in range(4):
        shift = s << 1
        imm = value >> shift

        if 0 <= imm <= 3 and (imm << shift) == value :
            return s, imm

    raise ValueError(
        f"line {line_number}: value {value} cannot be represented "
        "by one li instruction"
    )


def check_oprand_count(mnemonic, operands, expected, line_number):
    if len(operands) != expected:
        raise ValueError(
            f"line {line_number}: '{mnemonic}' expects "
            f"{expected} oprands, got {len(operands)}"
        )

def encode_instruction(line_number, pc, line, labels):
    tokens = line.replace(",", " ").split()

    mnemonic = tokens[0].lower()
    operands = tokens[1:]

    if mnemonic == "add" :
        check_oprand_count(mnemonic, operands, 3, line_number)

        rd = parse_register(operands[0], line_number)
        rs1 = parse_register(operands[1], line_number)
        rs2 = parse_register(operands[2], line_number)

        return ((0b00 << 6) | (rd << 4) | (rs1 << 2) | rs2)

    if mnemonic == "li" :
        check_oprand_count(mnemonic, operands, 2, line_number)

        rd = parse_register(operands[0], line_number)
        value = parse_number(operands[1], line_number)
        s, imm = encode_li_immediate(value, line_number)

        return ((0b10 << 6) | (rd << 4) | (s << 2) | imm)

    if mnemonic in ("in", "out"):
        check_oprand_count(mnemonic, operands, 2, line_number)

        register = parse_register(operands[0], line_number)
        idx = parse_number(operands[1], line_number)
        if not 0 <= idx <= 7:
            raise ValueError(
                f"line {line_number}: I/O index must be 0-7, got {idx}"
            )

        io_write = 1 if mnemonic == "out" else 0
        return ((0b01 << 6) | (register << 4) | (io_write << 3) | idx)

    if mnemonic == "bner0":
        check_oprand_count(mnemonic, operands, 2, line_number)

        rs = parse_register(operands[0], line_number)
        target_text = operands[1]

        if target_text in labels:
            offset = labels[target_text] - pc
        else:
            offset = parse_number(target_text, line_number)

        if not -8 <= offset <= 7:
            raise ValueError(
                f"line {line_number}: branch target must be -8 to 7, "
                f"got {offset}"
            )
        return ((0b11 << 6) | ((offset & 0xF)  << 2) | rs)
    raise ValueError(
        f"line {line_number}: unknown instruction '{mnemonic}'"
    )

def second_pass(labels, instructions):
    encoded = []

    for line_number, pc, line in instructions:
        machine_code = encode_instruction(line_number, pc, line, labels)

        encoded.append((pc, machine_code, line))

    return encoded
    
def main():
    parser = argparse.ArgumentParser(description="Assembler for the 8-bit sCPU")

    parser.add_argument("source", type=Path, help="input assembly file")
    parser.add_argument("-o","--output", type=Path, help = "output hex file")
    args = parser.parse_args()

    source_text = args.source.read_text(encoding = "utf-8")

    lines = source_text.splitlines()
    # print(lines)

    labels, instructions = first_pass(lines)

    encoded = second_pass(labels, instructions)

    output_path = args.output

    if output_path is None:
        output_path = args.source.with_suffix(".hex")
    for pc, machine_code, line in encoded:
        print(f"{pc:02x}: {machine_code:02x}    {line}")
    hex_text = "\n".join(
        f"{machine_code:02x}"
        for _,machine_code, _ in encoded
    )

    hex_text += "\n"

    output_path.write_text(hex_text, encoding="utf-8")

    print(f"wrote {len(encoded)} instructions to {output_path}")

if __name__=="__main__":
    try:
        main()
    except ValueError as error:
        raise SystemExit(f"error: {error}")
