I_MEM_SIZE = 2048
mem = [0] * I_MEM_SIZE

# ---------------------------
# R/I-Type ADDI Encoder
# ---------------------------
def encode_addi(rs1, rd, imm):
    instr = 0
    instr |= (0b00 << 30)           # major_op
    instr |= (rs1 & 0xF) << 25      # Rs1
    instr |= (0 & 0xF) << 21        # Rs2 unused
    instr |= (rd & 0xF) << 17       # Rd
    instr |= (0b0000 << 13)         # ALU op ADD
    instr |= (1 << 12)              # alu_src = immediate
    instr |= (imm & 0xFFF)          # 12-bit imm
    return instr

# ---------------------------
# SW Encoder
# ---------------------------
def encode_sw(base, data, offset):
    instr = 0
    instr |= (0b10 << 30)              # major_op
    instr |= (base & 0xF) << 25        # base register
    instr |= (data & 0xF) << 21        # data register
    instr |= (offset & 0x1FFFFF)       # 21-bit offset
    return instr

# ============================================================
# THREAD 0 (base address 0)
# ============================================================

mem[0] = encode_addi(0, 1, 10)     # R1 = 10
mem[1] = encode_addi(0, 2, 20)     # R2 = 20
mem[2] = encode_addi(1, 1, 1)      # R1 = R1 + 1
mem[3] = encode_sw(0, 1, 0)        # SW R1 → mem[0]
mem[4] = encode_addi(2, 2, 1)      # R2 = R2 + 1
mem[5] = encode_sw(0, 2, 1)        # SW R2 → mem[1]

# ============================================================
# THREAD 1 (base address 512)
# ============================================================

mem[512] = encode_addi(0, 1, 100)
mem[513] = encode_addi(0, 2, 200)
mem[514] = encode_addi(1, 1, 1)
mem[515] = encode_sw(0, 1, 16)     # separate memory region
mem[516] = encode_addi(2, 2, 1)
mem[517] = encode_sw(0, 2, 17)

# ============================================================
# THREAD 2 (base address 1024)
# ============================================================

mem[1024] = encode_addi(0, 1, 300)
mem[1025] = encode_addi(0, 2, 400)
mem[1026] = encode_addi(1, 1, 1)
mem[1027] = encode_sw(0, 1, 32)
mem[1028] = encode_addi(2, 2, 1)
mem[1029] = encode_sw(0, 2, 33)

# ============================================================
# THREAD 3 (base address 1536)
# ============================================================

mem[1536] = encode_addi(0, 1, 500)
mem[1537] = encode_addi(0, 2, 600)
mem[1538] = encode_addi(1, 1, 1)
mem[1539] = encode_sw(0, 1, 48)
mem[1540] = encode_addi(2, 2, 1)
mem[1541] = encode_sw(0, 2, 49)

# ============================================================
# Write COE File
# ============================================================

with open("lab6.coe", "w") as f:
    f.write("memory_initialization_radix=16;\n")
    f.write("memory_initialization_vector=\n")
    for i in range(I_MEM_SIZE):
        line = f"{mem[i]:08X}"
        if i != I_MEM_SIZE - 1:
            line += ","
        f.write(line + "\n")
    f.write(";\n")

# ============================================================
# Write HEX File (for topreg loader)
# ============================================================

with open("imem.hex", "w") as f:
    for i in range(I_MEM_SIZE):
        f.write(f"{mem[i]:08X}\n")