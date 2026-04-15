import streamlit as st

# ==========================================
# 1. CORE ASSEMBLER DICTIONARIES
# ==========================================
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

# ==========================================
# 2. ASSEMBLER LOGIC (Refactored for Web)
# ==========================================
def process_input_text(raw_text):
    """Processes raw string input instead of a file."""
    lines = []
    for line in raw_text.splitlines():
        no_comments = line.split('//')[0]
        clean_line = no_comments.strip().upper()
        if clean_line:
            lines.append(clean_line)
    return lines

def parse_line(line):
    clean_line = line.replace(',', ' ').replace('[', ' ').replace(']', ' ')
    parts = clean_line.split()
    return parts

def get_accessed_registers(parts):
    if not parts or parts[0] == "NOP":
        return None, []
    op = parts[0]
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
        if len(parts) > 1 and parts[1] in registers: reads_from.append(parts[1])
        if len(parts) > 2 and parts[2] in registers: reads_from.append(parts[2])
    elif op == "LD":
        if len(parts) > 1 and parts[1] in registers: writes_to = parts[1]
        if len(parts) > 3 and parts[3] in registers: reads_from.append(parts[3])
    elif op == "ST":
        if len(parts) > 1 and parts[1] in registers: reads_from.append(parts[1])
        if len(parts) > 3 and parts[3] in registers: reads_from.append(parts[3])
    elif op == "CALL":
        writes_to = "R15"
    reads_from = [r for r in reads_from if r != "R0"]
    if writes_to == "R0": writes_to = None
    return writes_to, reads_from

def first_pass(lines):
    symbol_table = {}
    clean_instructions = []
    pc = 0
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
            writes_to, reads_from = get_accessed_registers(inst_parts)
            nops_needed = 0
            
            if recent_writes[0] and recent_writes[0] in reads_from:
                nops_needed = 2
            elif recent_writes[1] and recent_writes[1] in reads_from:
                nops_needed = 1
                
            for _ in range(nops_needed):
                clean_instructions.append("NOP")
                pc += 4
                recent_writes = [None, recent_writes[0]]
                
            clean_instructions.append(instruction)
            pc += 4
            recent_writes = [writes_to, recent_writes[0]]
            
            if inst_parts and inst_parts[0] in ["BEQ", "BGT", "B", "CALL", "RET"]:
                clean_instructions.append("NOP")
                pc += 4
                recent_writes = [None, recent_writes[0]]
                clean_instructions.append("NOP")
                pc += 4
                recent_writes = [None, recent_writes[0]]
                
    return symbol_table, clean_instructions

def dec_to_bin(num_str, bits):
    num = int(num_str)
    if num >= 0:
        return format(num, f'0{bits}b')
    else:
        return format((1 << bits) + num, f'0{bits}b')

def ass_0_type(parts):
    return isa_opcodes[parts[0]] + ("0" * 27)

def ass_1_type(parts, current_pc, symbol_table):
    if parts[1] in symbol_table:
        offset_int = int((symbol_table[parts[1]] - current_pc) / 4)
    else:
        offset_int = int(parts[1])
    return isa_opcodes[parts[0]] + dec_to_bin(str(offset_int), 27)

def ass_2_type_mov_not(parts, modifier):
    opcode = isa_opcodes[parts[0]]
    rd = registers[parts[1]]
    if parts[2] in registers:
        return opcode + "0" + rd + "0000" + registers[parts[2]] + ("0" * 14)
    else:
        mod = "01" if modifier == 'U' else "10" if modifier == 'H' else "00"
        return opcode + "1" + rd + "0000" + mod + dec_to_bin(parts[2], 16)

def ass_2_type_cmp(parts):
    opcode = isa_opcodes[parts[0]]
    rs1 = registers[parts[1]]
    if parts[2] in registers:
        return opcode + "00000" + rs1 + registers[parts[2]] + ("0" * 14)
    else:
        return opcode + "10000" + rs1 + dec_to_bin(parts[2], 18)

def ass_r_type(parts):
    return isa_opcodes[parts[0]] + "0" + registers[parts[1]] + registers[parts[2]] + registers[parts[3]] + ("0" * 14)

def ass_i_type(parts, modifier):
    mod = "01" if modifier == 'U' else "10" if modifier == 'H' else "00"
    return isa_opcodes[parts[0]] + "1" + registers[parts[1]] + registers[parts[2]] + mod + dec_to_bin(parts[3], 16)

def ass_mem_type(parts, modifier):
    mod = "01" if modifier == 'U' else "10" if modifier == 'H' else "00"
    return isa_opcodes[parts[0]] + "1" + registers[parts[1]] + registers[parts[3]] + mod + dec_to_bin(parts[2], 16)

def assemble_instruction(parts, current_pc, symbol_table):
    modifier = "N"
    if parts[0][-1] in ["U", "H"] and parts[0][:-1] in isa_opcodes:
        modifier = parts[0][-1]
        parts[0] = parts[0][:-1]

    if len(parts) == 1: return ass_0_type(parts)
    elif len(parts) == 2: return ass_1_type(parts, current_pc, symbol_table)
    elif len(parts) == 3:
        if parts[0] in ["MOV", "NOT"]: return ass_2_type_mov_not(parts, modifier)
        elif parts[0] == "CMP": return ass_2_type_cmp(parts)
    elif len(parts) == 4:
        if parts[0] in ["LD", "ST"]: return ass_mem_type(parts, modifier)
        elif parts[3] in registers: return ass_r_type(parts)
        else: return ass_i_type(parts, modifier)
    return "Invalid Instruction"

def run_assembler(raw_text):
    raw_lines = process_input_text(raw_text)
    symbol_table, clean_instructions = first_pass(raw_lines)
    machine_code = []
    current_pc = 0

    for instruction in clean_instructions:
        parts = parse_line(instruction)
        binary32 = assemble_instruction(parts, current_pc, symbol_table)
        
        if binary32 == "Invalid Instruction":
            return None, f"Error at PC 0x{current_pc:04X}: Invalid instruction '{instruction}'"
            
        machine_code.append(binary32)
        current_pc += 4

    return machine_code, None

# ==========================================
# 3. STREAMLIT UI 
# ==========================================
st.set_page_config(page_title="SimpleRISC Assembler", page_icon="⚙️", layout="wide")

# Sidebar
with st.sidebar:
    st.image("https://img.icons8.com/external-flaticons-flat-flat-icons/64/000000/external-cpu-computer-science-flaticons-flat-flat-icons.png", width=64)
    st.title("SimpleRISC Compiler")
    st.markdown("""
    **Pipeline Features:**
    - ⚡ 5-Stage Pipelining
    - 🛡️ Auto Data Hazard Mitigation (NOP Injection)
    - 🔀 Auto Control Hazard Mitigation (Delay Slots)
    """)
    st.divider()
    st.caption("Developed for the SimpleRISC Architecture.")

st.title("🚀 SimpleRISC Pipelined Assembler")
st.markdown("Upload your assembly file or write code directly in the browser to generate pipelined machine code.")

# Main layout
col1, col2 = st.columns(2, gap="large")

with col1:
    st.subheader("📝 Input Assembly")
    
    # File Uploader
    uploaded_file = st.file_uploader("Upload .txt or .asm file", type=["txt", "asm"])
    
    # Text Area for manual editing
    default_code = "// Write your SimpleRISC assembly here...\nMOV R1, 10\nMOV R2, 20\nADD R3, R1, R2\nHLT\n"
    if uploaded_file is not None:
        default_code = uploaded_file.getvalue().decode("utf-8")
        
    code_input = st.text_area("Assembly Code", value=default_code, height=450, label_visibility="collapsed")
    
    # Trigger Button
    assemble_clicked = st.button("⚙️ Compile & Assemble", use_container_width=True, type="primary")

with col2:
    st.subheader("💻 Machine Code (Output)")
    
    if assemble_clicked:
        if not code_input.strip():
            st.warning("⚠️ Please enter some assembly code first.")
        else:
            with st.spinner("Compiling with Pipeline Mitigations..."):
                machine_code, error_msg = run_assembler(code_input)
                
                if error_msg:
                    st.error(error_msg)
                else:
                    st.success(f"✅ Compilation Successful! Generated {len(machine_code)} instructions.")
                    
                    # Formatting output for display
                    output_text = "\n".join(machine_code)
                    
                    # Displaying output
                    st.text_area("32-bit Binary", value=output_text, height=350, label_visibility="collapsed")
                    
                    # Download Button
                    st.download_button(
                        label="📥 Download output.hex",
                        data=output_text,
                        file_name="output.hex",
                        mime="text/plain",
                        use_container_width=True
                    )
    else:
        st.info("👈 Upload a file or click 'Compile & Assemble' to generate machine code.")