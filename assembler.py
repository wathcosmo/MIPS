fname = raw_input()
f = open(fname + '.asm')
lines = f.readlines()
for i in range(len(lines)):
    tmp = lines[i].replace(',', ' ')
    tmp = tmp.lower()
    lines[i] = tmp.strip()

dic = {'$zero':'00000', '$0':'00000',
       '$at':'00001', '$1':'00001',
       '$v0':'00010', '$2':'00010',
       '$v1':'00011', '$3':'00011',
       '$a0':'00100', '$4':'00100',
       '$a1':'00101', '$5':'00101',
       '$a2':'00110', '$6':'00110',
       '$a3':'00111', '$7':'00111',
       '$t0':'01000', '$8':'01000',
       '$t1':'01001', '$9':'01001',
       '$t2':'01010', '$10':'01010',
       '$t3':'01011', '$11':'01011',
       '$t4':'01100', '$12':'01100',
       '$t5':'01101', '$13':'01101',
       '$t6':'01110', '$14':'01110',
       '$t7':'01111', '$15':'01111',
       '$s0':'10000', '$16':'10000',
       '$s1':'10001', '$17':'10001',
       '$s2':'10010', '$18':'10010',
       '$s3':'10011', '$19':'10011',
       '$s4':'10100', '$20':'10100',
       '$s5':'10101', '$21':'10101',
       '$s6':'10110', '$22':'10110',
       '$s7':'10111', '$23':'10111',
       '$t8':'11000', '$24':'11000',
       '$t9':'11001', '$25':'11001',
       '$k0':'11010', '$26':'11010',
       '$k1':'11011', '$27':'11011',
       '$gp':'11100', '$28':'11100',
       '$sp':'11101', '$29':'11101',
       '$fp':'11110', '$30':'11110',
       '$ra':'11111', '$31':'11111',
       }
idx = 0
label = {}
code = []

def ext_hex(st, n):
    ans = st[2:]
    ans = '0x' + '0' * (n - len(ans)) + ans
    return ans

def ext_bin(st, n):
    ans = st[2:]
    ans = '0b' + '0' * (n - len(ans)) + ans
    return ans
    
for line in lines:
    if line:
        if line.find('.text') > -1:
            addr = line.split()
            addr = addr[1]
            if addr.find('x') > -1:
                idx = int(addr, 16) / 4
        elif line[-1] == ':':
            st = line[:-1]
            label[st] = idx
        else:
            if line.find(':') > -1:
                ed = line.find(':')
                st = line[:ed]
                label[st] = idx
                line = line[ed+1:]
                line = line.strip()
            code.append([line.split(), idx])
            idx = idx + 1

mch = []


for itm in code:
    line = itm[0]
    ind = itm[1]
    if line[0] == 'sll':
        nb = '0b000000' + '00000' + dic[line[2]] + dic[line[1]]
        shamt = ext_bin(bin(int(line[3])), 5)
        nb = nb + shamt[2:] + '000000'
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 8)
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'add':
        nb = '0b000000' + dic[line[2]] + dic[line[3]] + dic[line[1]] + '00000100000'
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 8)
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'sub':
        nb = '0b000000' + dic[line[2]] + dic[line[3]] + dic[line[1]] + '00000100010'
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 8)
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'and':
        nb = '0b000000' + dic[line[2]] + dic[line[3]] + dic[line[1]] + '00000100100'
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 8)
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'slt':
        nb = '0b000000' + dic[line[2]] + dic[line[3]] + dic[line[1]] + '00000101001'
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 8)
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'lui':
        nb = '0b00111100000' + dic[line[1]]
        if line[2].find('x') == -1:
            line[2] = hex(int(line[2]))
        imm = ext_hex(line[2], 4)
        nh = ext_hex(hex(int(nb, 2)), 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'sw':
        nb = '0b101011'
        st = line[2].split('(')
        nb = nb + dic[st[1][:-1]] + dic[line[1]]
        imm = hex(int(st[0]) & 0xffff)
        imm = ext_hex(imm, 4)
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'lw':
        nb = '0b100011'
        st = line[2].split('(')
        nb = nb + dic[st[1][:-1]] + dic[line[1]]
        imm = hex(int(st[0]) & 0xffff)
        imm = ext_hex(imm, 4)
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'beq':
        nb = '0b000100' + dic[line[1]] + dic[line[2]]
        imm = label[line[3]] - (ind + 1)
        imm = ext_hex(hex(imm & 0xffff), 4)
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'bne':
        nb = '0b000101' + dic[line[1]] + dic[line[2]]
        imm = label[line[3]] - (ind + 1)
        imm = ext_hex(hex(imm & 0xffff), 4)
        nh = hex(int(nb, 2))
        nh = ext_hex(nh, 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'addi':
        nb = '0b001000' + dic[line[2]] + dic[line[1]]
        if line[3].find('x') == -1:
            line[3] = hex(int(line[3]) & 0xffff)
        imm = ext_hex(line[3], 4)
        nh = ext_hex(hex(int(nb, 2)), 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'addiu':
        nb = '0b001001' + dic[line[2]] + dic[line[1]]
        if line[3].find('x') == -1:
            line[3] = hex(int(line[3]))
        imm = ext_hex(line[3], 4)
        nh = ext_hex(hex(int(nb, 2)), 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'andi':
        nb = '0b001100' + dic[line[2]] + dic[line[1]]
        if line[3].find('x') == -1:
            line[3] = hex(int(line[3]) & 0xffff)
        imm = ext_hex(line[3], 4)
        nh = ext_hex(hex(int(nb, 2)), 4) + imm[2:]
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'j':
        nb = '0b000010'
        jp = label[line[1]] 
        jp = ext_bin(bin(jp), 26)
        nb = nb + jp[2:]
        nh = ext_hex(hex(int(nb, 2)), 8)
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    elif line[0] == 'jr':
        nb = '0b000000' + dic[line[1]] + '000000000000000001000'
        nh = ext_hex(hex(int(nb, 2)), 8)
        nh = nh.replace('0x', "32'h")
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)
    else:
        nh = "32'h00000000"
        m_code = str(ind) + ': data <= ' + nh
        mch.append(m_code)

        


for i in mch:
    print i + ';'


        
                
    


