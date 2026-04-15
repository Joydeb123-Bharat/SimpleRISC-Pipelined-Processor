isa_opcodes = {
    "ADD":  "00000", "SUB":  "00001", "MUL":  "00010", "DIV":  "00011",
    "MOD":  "00100", "CMP":  "00101", "AND":  "00110", "OR":   "00111",
    "NOT":  "01000", "MOV":  "01001", "LSL":  "01010", "LSR":  "01011",
    "ASR":  "01100", "NOP":  "01101", "LD":   "01110", "ST":   "01111",
    "BEQ":  "10000", "BGT":  "10001", "B":    "10010", "CALL": "10011",
    "RET":  "10100", "XOR":  "10101", "HLT":  "10110"
}

registers = {
    "R0":  "0000", "R1":  "0001", "R2":  "0010", "R3":  "0011",
    "R4":  "0100", "R5":  "0101", "R6":  "0110", "R7":  "0111",
    "R8":  "1000", "R9":  "1001", "R10": "1010", "R11": "1011",
    "R12": "1100", "R13": "1101", "R14": "1110", "R15": "1111"
}
# Removing the Comment lines
def read_from_file(filename):
    lines = []
    with open(filename, 'r') as file:
        for line in file:
            no_comments = line.split('//')[0]
            clean_line = no_comments.strip().upper()
            if clean_line:
                lines.append(clean_line)
    return lines

#Extracting the opcode, registers and immediates
def parse_line(line):
    clean_line = line.replace(',', ' ').replace('[', ' ').replace(']', ' ')
    parts = clean_line.split()
    return parts

# Identifies which register to write to and read from
def get_accessed_registers(parts):
    if not parts or parts[0] == "NOP":
        return None, []
    op = parts[0]
    # Strip modifier (U/H) for checking
    if op[-1] in ["U", "H"] and op[:-1] in isa_opcodes:
        op = op[:-1]
    writes_to = None
    reads_from = []
    alu_ops = ["ADD", "SUB", "MUL", "DIV", "MOD", "AND", "OR", "XOR", "LSL", "LSR", "ASR"]
    if op in alu_ops:
        if len(parts) > 1 and parts[1] in registers: writes_to = parts[1]
        if len(parts) > 2 and parts[2] in registers: reads_from.append(parts[2])
        if len(parts) > 3 and parts[3] in registers: reads_from.append(parts[3])
    elif op in ["MOV", "NOT"]:
        if len(parts) > 1 and parts[1] in registers: writes_to = parts[1]
        if len(parts) > 2 and parts[2] in registers: reads_from.append(parts[2])
    elif op == "CMP":
        # CMP only sets flags, it doesn't write to a register
        if len(parts) > 1 and parts[1] in registers: reads_from.append(parts[1])
        if len(parts) > 2 and parts[2] in registers: reads_from.append(parts[2])
    elif op == "LD":
        if len(parts) > 1 and parts[1] in registers: writes_to = parts[1]
        if len(parts) > 3 and parts[3] in registers: reads_from.append(parts[3]) # Reads base address
    elif op == "ST":
        if len(parts) > 1 and parts[1] in registers: reads_from.append(parts[1]) # Reads data to store
        if len(parts) > 3 and parts[3] in registers: reads_from.append(parts[3]) # Reads base address
    elif op == "CALL":
        writes_to = "R15" # CALL implicitly writes the return address to R15
    # R0 is hardwired to 0
    reads_from = [r for r in reads_from if r != "R0"]
    if writes_to == "R0": writes_to = None

    return writes_to, reads_from

#Constructing the Symbol table
def first_pass(lines):
    symbol_table = {}
    clean_instructions = []
    pc = 0
    # Array to track the destination registers of the last 2 instructions
    # Index 0 is the immediate previous instruction. Index 1 is the one before that.
    recent_writes = [None, None]
    for line in lines:
        if ':' in line:
            parts = line.split(':')
            label_name = parts[0].strip()
            symbol_table[label_name] = pc
            instruction = parts[1].strip()
        else:
            instruction = line.strip()
        if instruction:
            inst_parts = parse_line(instruction)
            # Data Hazard
            writes_to, reads_from = get_accessed_registers(inst_parts)
            nops_needed = 0
            # Check immediately previous instruction (needs 2 NOPs)
            if recent_writes[0] and recent_writes[0] in reads_from:
                nops_needed = 2
            # Check the instruction before that (needs 1 NOP)
            elif recent_writes[1] and recent_writes[1] in reads_from:
                nops_needed = 1
            # Insert the required Data Hazard NOPs
            for a in range(nops_needed):
                clean_instructions.append("NOP")
                pc += 4
                recent_writes = [None, recent_writes[0]]
            clean_instructions.append(instruction)
            pc += 4
            # Update history for the NEXT instruction to look at
            recent_writes = [writes_to, recent_writes[0]]
            # CONTROL HAZARD
            if inst_parts and inst_parts[0] in ["BEQ", "BGT", "B", "CALL", "RET"]:
                clean_instructions.append("NOP")
                pc += 4
                recent_writes = [None, recent_writes[0]]
                clean_instructions.append("NOP")
                pc += 4
                recent_writes = [None, recent_writes[0]]
    return symbol_table, clean_instructions

#For Decimal to Binary
def dec_to_bin(num_str, bits):
    num = int(num_str)
    if num >= 0:
        return format(num, f'0{bits}b')
    else:
        return format((1 << bits) + num, f'0{bits}b')

#Instruction Encodings
def ass_0_type(parts):
    opcode = isa_opcodes[parts[0]]
    padding = "0" * 27
    return opcode + padding

def ass_1_type(parts, current_pc, symbol_table):
    if parts[1] in symbol_table:
        offset_int = int((symbol_table[parts[1]] - current_pc) / 4)
    else:
        offset_int = int(parts[1])
    offset_bin = dec_to_bin(str(offset_int), 27)
    opcode = isa_opcodes[parts[0]]
    return opcode + offset_bin

def ass_2_type_mov_not(parts, modifier):
    opcode = isa_opcodes[parts[0]]
    rd = registers[parts[1]]
    empty_rs1 = "0000"
    if parts[2] in registers:
        r_i = "0"
        rs2 = registers[parts[2]]
        padding = "0" * 14
        return opcode + r_i + rd + empty_rs1 + rs2 + padding
    else:
        r_i = "1"
        mod = "00"
        if modifier == 'U':
            mod = "01"
        elif modifier == 'H':
            mod = "10"
        imm = dec_to_bin(parts[2], 16)
        return opcode + r_i + rd + empty_rs1 + mod + imm

def ass_2_type_cmp(parts):
    opcode = isa_opcodes[parts[0]]
    rd = "0000"
    rs1 = registers[parts[1]]
    if parts[2] in registers:
        r_i = "0"
        rs2 = registers[parts[2]]
        padding = "0" * 14
        return opcode + r_i + rd + rs1 + rs2 + padding
    else:
        r_i = "1"
        imm = dec_to_bin(parts[2], 18)
        return opcode + r_i + rd + rs1 + imm

def ass_r_type(parts):
    opcode = isa_opcodes[parts[0]]
    r = "0"
    rd = registers[parts[1]]
    rs1 = registers[parts[2]]
    rs2 = registers[parts[3]]
    padding = "0" * 14
    return opcode + r + rd + rs1 + rs2 + padding

def ass_i_type(parts, modifier):
    opcode = isa_opcodes[parts[0]]
    i = "1"
    rd = registers[parts[1]]
    rs1 = registers[parts[2]]
    mod = "00"
    if modifier == 'U':
        mod = "01"
    elif modifier == 'H':
        mod = "10"
    imm = dec_to_bin(parts[3], 16)
    return opcode + i + rd + rs1 + mod + imm

def ass_mem_type(parts, modifier):
    opcode = isa_opcodes[parts[0]]
    r_i = "1"
    rd = registers[parts[1]]
    mod = "00"
    if modifier == 'U':
        mod = "01"
    elif modifier == 'H':
        mod = "10"
    imm = dec_to_bin(parts[2], 16)
    rs1 = registers[parts[3]]
    return opcode + r_i + rd + rs1 + mod + imm

def assemble_instruction(parts, current_pc, symbol_table):
    modifier = "N"

    if parts[0][-1] in ["U", "H"] and parts[0][:-1] in isa_opcodes:
        modifier = parts[0][-1]
        parts[0] = parts[0][:-1]

    if len(parts) == 1:
        return ass_0_type(parts)

    elif len(parts) == 2:
        return ass_1_type(parts, current_pc, symbol_table)

    elif len(parts) == 3:
        if parts[0] in ["MOV", "NOT"]:
            return ass_2_type_mov_not(parts, modifier)
        elif parts[0] == "CMP":
            return ass_2_type_cmp(parts)

    elif len(parts) == 4:
        if parts[0] in ["LD", "ST"]:
            return ass_mem_type(parts, modifier)
        elif parts[3] in registers:
            return ass_r_type(parts)
        else:
            return ass_i_type(parts, modifier)

    return "Invalid Instruction"

def run_assembler(filename):
    raw_lines = read_from_file(filename)
    symbol_table, clean_instructions = first_pass(raw_lines)

    machine_code = []
    current_pc = 0

    for instruction in clean_instructions:
        parts = parse_line(instruction)
        binary32 = assemble_instruction(parts, current_pc, symbol_table)

        if binary32 == "Invalid Instruction":
            print(f"Invalid instruction: {instruction}")
            return None

        machine_code.append(binary32)
        current_pc += 4

    return machine_code

final_binary = run_assembler(input("Enter the name of the file: "))
if final_binary:
    for line in final_binary:
        print(line)