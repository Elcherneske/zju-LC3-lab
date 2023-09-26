// Lab.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include <iostream>
#include<vector>
#include<string>
#include<stdio.h>

using namespace std;

class BinaryCode {
private:
    string code;
    unsigned short address;
public:
    BinaryCode() {
        address = 0;
    }
    BinaryCode(string code, unsigned short address) 
    {
        this->code = code;
        this->address = address;
    }
    BinaryCode(unsigned short digit, unsigned short address)
    {
        char temp[17];
        temp[16] = '\0';
        for (int i = 15; i >= 0; i--, digit /= 2) {
            unsigned short remain;
            remain = digit % 2;
            if (remain == 1)temp[i] = '1';
            else temp[i] = '0';
        }
        this->code = temp;
        this->address = address;
    }
    string getInstruction(void)
    {
        return code.substr(0, 4);
        
    }
    
    string getCode(void)
    {
        return code;
    }

    unsigned short transferToDigit(void)
    {
        unsigned short result = 0;
        for (int i = 0; i <16 ; i++) {
            result = 2 * result;
            if (code[i] == '1')result += 1;
        }
        return result;
    }
    
    unsigned short getAddress(void)
    {
        return this->address;
    }

};



unsigned short mRegister[8] = { 0x7777,0x7777,0x7777,0x7777,0x7777,0x7777,0x7777,0x7777 };

unsigned short beginAddr = 0;

vector<BinaryCode> instructions;
vector<BinaryCode> storage;

void input(void)
{
    string str;
    cin >> str;
    BinaryCode code(str, 0);
    beginAddr = code.transferToDigit();
    //get the begin address


    char check;
    char c[17];//store the instruction
    unsigned short shift = 0;
    check = cin.get();
    while (check != EOF) {
        c[0] = cin.get();//check
        if (c[0] == EOF)break;
        for (int i = 1; i < 16; i++) {
            c[i] = cin.get();
        }
        c[16] = '\0';
        str = c;
        BinaryCode inst(str, beginAddr + shift);
        instructions.push_back(inst);
        shift++;
        check = cin.get();//check


    }

    
}


unsigned short stringToDigit(string str)
{
    unsigned short result = 0;
    for (int i = 0; i < str.size(); i++) {
        result = 2 * result;
        if (str[i] == '1')result += 1;
    }
    return result;
}

unsigned short signExtension5(unsigned short imm5)
{
    unsigned short result = imm5;
    if (imm5 >= 16) {
        result = 0xffe0 | result;
    }
    return result;
}

unsigned short signExtension6(unsigned short offset6)
{
    unsigned short result = offset6;
    if (offset6 >= 0x20) {
        result = 0xffc0 | result;
    }
    return result;
}

unsigned short signExtension9(unsigned short offset9)
{
    unsigned short result = offset9;
    if (offset9 >= 0x100) {
        result = 0xfe00 | result;
    }
    return result;
}

unsigned short signExtension11(unsigned short offset11)
{
    unsigned short result = offset11;
    if (offset11 >= 0x400) {
        result = 0xf800 | result;
    }
    return result;
}

void insertToStorage(BinaryCode code)
{
    bool inserted = false;
    vector<BinaryCode>::iterator p;
    for (p = storage.begin(); p < storage.end(); p++) {
        if ((*p).getAddress() == code.getAddress()) {
            (*p) = code;
            inserted = true;
            break;
        }
        if ((*p).getAddress() > code.getAddress()) {
            storage.insert(p, code);
            inserted = true;
            break;
        }
    }
    if (inserted == false)
    {
        storage.push_back(code);
    }
}


void add(BinaryCode code, unsigned short& nzp)
{
    if (code.getCode()[10] == '0') {
        unsigned short dr, sr1, sr2;
        dr = stringToDigit(code.getCode().substr(4, 3));
        sr1 = stringToDigit(code.getCode().substr(7, 3));
        sr2 = stringToDigit(code.getCode().substr(13, 3));
        mRegister[dr] = mRegister[sr1] + mRegister[sr2];
        short check = (short)mRegister[dr];
        if (check > 0) nzp = 1;
        else if (check == 0) nzp = 2;
        else nzp = 4;
    }
    else {
        unsigned short dr, sr1, imm5;
        dr = stringToDigit(code.getCode().substr(4, 3));
        sr1 = stringToDigit(code.getCode().substr(7, 3));
        imm5 = stringToDigit(code.getCode().substr(11, 5));
        mRegister[dr] = mRegister[sr1] + signExtension5(imm5);
        short check = (short)mRegister[dr];
        if (check > 0) nzp = 1;
        else if (check == 0) nzp = 2;
        else nzp = 4;
    }
}

void m_and(BinaryCode code, unsigned short& nzp)
{
    if (code.getCode()[10] == '0') {
        unsigned short dr, sr1, sr2;
        dr = stringToDigit(code.getCode().substr(4, 3));
        sr1 = stringToDigit(code.getCode().substr(7, 3));
        sr2 = stringToDigit(code.getCode().substr(13, 3));
        mRegister[dr] = mRegister[sr1] & mRegister[sr2];
        short check = (short)mRegister[dr];
        if (check > 0) nzp = 1;
        else if (check == 0) nzp = 2;
        else nzp = 4;
    }
    else {
        unsigned short dr, sr1, imm5;
        dr = stringToDigit(code.getCode().substr(4, 3));
        sr1 = stringToDigit(code.getCode().substr(7, 3));
        imm5 = stringToDigit(code.getCode().substr(11, 5));
        mRegister[dr] = mRegister[sr1] & signExtension5(imm5);
        short check = (short)mRegister[dr];
        if (check > 0) nzp = 1;
        else if (check == 0) nzp = 2;
        else nzp = 4;
    }
}

void br(BinaryCode code, unsigned short& PC, unsigned short& nzp)
{
    unsigned short nzp_check = stringToDigit(code.getCode().substr(4, 3));
    unsigned short check = nzp_check & nzp;
    if (check == 0)return;
    else {
        PC = PC + signExtension9(stringToDigit(code.getCode().substr(7, 9)));
    }
}

void jump(BinaryCode code, unsigned short& PC)
{
    unsigned short register_number = stringToDigit(code.getCode().substr(7, 3));
    PC = mRegister[register_number];
}

void jsr(BinaryCode code, unsigned short& PC)
{
    unsigned short temp = PC;
    if (code.getCode()[4] == '0') {
        PC = mRegister[stringToDigit(code.getCode().substr(7, 3))];
    }
    else {
        PC += signExtension11(stringToDigit(code.getCode().substr(5, 11)));
    }
    //if (stringToDigit(code.getCode().substr(7, 3)) == 7)return;
    mRegister[7] = temp;
}

void ld(BinaryCode code, unsigned short& PC, unsigned short& nzp)
{
    unsigned short dr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short address = PC + signExtension9(stringToDigit(code.getCode().substr(7, 9)));

    if (address < beginAddr || address >= beginAddr + instructions.size()) {
        //mRegister[dr] = stringToDigit(instructions[0].getCode());//dr = mem[PC+sext(offset9)]

        for (vector<BinaryCode>::iterator p = storage.begin(); p < storage.end(); p++) {
            if ((*p).getAddress() == address) {
                mRegister[dr] = stringToDigit((*p).getCode());//dr = mem[PC+sext(offset9)]
            }
        }

    }
    else {
        mRegister[dr] = stringToDigit(instructions[address - beginAddr].getCode());//dr = mem[PC+sext(offset9)]
    }
    short check = (short)mRegister[dr];
    if (check > 0) nzp = 1;
    else if (check == 0) nzp = 2;
    else nzp = 4;
}

void ldi(BinaryCode code, unsigned short& PC, unsigned short& nzp) 
{
    unsigned short dr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short address_indirect = PC + signExtension9(stringToDigit(code.getCode().substr(7, 9)));
    unsigned short address;
    if (address_indirect < beginAddr || address_indirect >= beginAddr + instructions.size()) {
        //mRegister[dr] = stringToDigit(instructions[0].getCode());//dr = mem[PC+sext(offset9)]

        for (vector<BinaryCode>::iterator p = storage.begin(); p < storage.end(); p++) {
            if ((*p).getAddress() == address_indirect) {
                address = stringToDigit((*p).getCode());//dr = mem[PC+sext(offset9)]
            }
        }

    }
    else {
        address = stringToDigit(instructions[address_indirect - beginAddr].getCode());
    }



    if (address < beginAddr || address >= beginAddr + instructions.size()) {
        //mRegister[dr] = stringToDigit(instructions[0].getCode());//dr = mem[PC+sext(offset9)]

        for (vector<BinaryCode>::iterator p = storage.begin(); p < storage.end(); p++) {
            if ((*p).getAddress() == address) {
                mRegister[dr] = stringToDigit((*p).getCode());//dr = mem[PC+sext(offset9)]
            }
        }

    }
    else {
        mRegister[dr] = stringToDigit(instructions[address - beginAddr].getCode());//dr = mem[PC+sext(offset9)]
    }
    short check = (short)mRegister[dr];
    if (check > 0) nzp = 1;
    else if (check == 0) nzp = 2;
    else nzp = 4;
}

void ldr(BinaryCode code, unsigned short& nzp)
{
    unsigned short dr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short base_R = stringToDigit(code.getCode().substr(7, 3));
    unsigned short offset = signExtension6(stringToDigit(code.getCode().substr(10, 6)));
    unsigned short address = mRegister[base_R] + offset;
    
    if (address < beginAddr || address >= beginAddr + instructions.size()) {
        //mRegister[dr] = stringToDigit(instructions[0].getCode());//dr = mem[PC+sext(offset9)]
        
        for (vector<BinaryCode>::iterator p = storage.begin(); p < storage.end(); p++) {
            if ((*p).getAddress() == address) {
                mRegister[dr] = stringToDigit((*p).getCode());//dr = mem[PC+sext(offset9)]
            }
        }
        
    }
    else {
        mRegister[dr] = stringToDigit(instructions[address - beginAddr].getCode());//dr = mem[PC+sext(offset9)]
    }
    
    short check = (short)mRegister[dr];
    if (check > 0) nzp = 1;
    else if (check == 0) nzp = 2;
    else nzp = 4;
}

void lea(BinaryCode code, unsigned short& PC)
{
    unsigned short dr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short address = PC + signExtension9(stringToDigit(code.getCode().substr(7, 9)));
    mRegister[dr] = address;
}

void m_not(BinaryCode code, unsigned short& nzp)
{
    unsigned short dr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short sr = stringToDigit(code.getCode().substr(7, 3));
    unsigned short content = mRegister[sr];
    content = content ^ 0xffff;
    mRegister[dr] = content;
    short check = (short)mRegister[dr];
    if (check > 0) nzp = 1;
    else if (check == 0) nzp = 2;
    else nzp = 4;
}

void rti(BinaryCode code)
{

}

void st(BinaryCode code, unsigned short& PC)
{
    unsigned short sr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short content = mRegister[sr];
    unsigned short address = PC + signExtension9(stringToDigit(code.getCode().substr(7, 9)));
    BinaryCode content_binary(content, address);
    if (address < beginAddr || address >= beginAddr + instructions.size()) {
        insertToStorage(content_binary);
    }
    else {
        instructions[address - beginAddr] = content_binary;
    }
    

}

void sti(BinaryCode code, unsigned short& PC)
{
    unsigned short sr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short content = mRegister[sr];
    unsigned short address_indirect = PC + signExtension9(stringToDigit(code.getCode().substr(7, 9)));
    unsigned short address; 

    if (address_indirect < beginAddr || address_indirect >= beginAddr + instructions.size()) {
        //mRegister[dr] = stringToDigit(instructions[0].getCode());//dr = mem[PC+sext(offset9)]

        for (vector<BinaryCode>::iterator p = storage.begin(); p < storage.end(); p++) {
            if ((*p).getAddress() == address_indirect) {
                address = stringToDigit((*p).getCode());//dr = mem[PC+sext(offset9)]
            }
        }

    }
    else {
        address = stringToDigit(instructions[address_indirect - beginAddr].getCode());
    }



    BinaryCode content_binary(content, address);
    if (address < beginAddr || address >= beginAddr + instructions.size()) {
        insertToStorage(content_binary);
    }
    else {
        instructions[address - beginAddr] = content_binary;
    }
}

void str(BinaryCode code)
{
    unsigned short sr = stringToDigit(code.getCode().substr(4, 3));
    unsigned short content = mRegister[sr];
    unsigned short base_R = stringToDigit(code.getCode().substr(7, 3));
    unsigned short address = mRegister[base_R] + signExtension6(stringToDigit(code.getCode().substr(10, 6)));
    BinaryCode content_binary(content, address);
    if (address < beginAddr || address >= beginAddr + instructions.size()) {
        insertToStorage(content_binary);
    }
    else {
        instructions[address - beginAddr] = content_binary;
    }
}

void run(void)
{
    BinaryCode current_code;
    unsigned short PC = beginAddr;
    unsigned short& PC_ref = PC;
    unsigned short nzp = 0;//use the 1\2\3 bit to indicate
    unsigned short& nzp_ref = nzp;
    while (true)
    {
        //fetch instruction
        current_code = instructions[PC - beginAddr];
        PC++;
        //decode and operate

        string opcode = current_code.getInstruction();
        if (opcode == "0001")add(current_code, nzp_ref);
        if (opcode == "0101")m_and(current_code, nzp_ref);
        if (opcode == "0000")br(current_code, PC_ref, nzp_ref);
        if (opcode == "1100")jump(current_code, PC_ref);
        if (opcode == "0100")jsr(current_code, PC_ref);
        if (opcode == "0010")ld(current_code, PC_ref, nzp_ref);
        if (opcode == "1010")ldi(current_code, PC_ref, nzp_ref);
        if (opcode == "0110")ldr(current_code, nzp_ref);
        if (opcode == "1110")lea(current_code, PC_ref);
        if (opcode == "1001")m_not(current_code, nzp_ref);
        if (opcode == "1000")rti(current_code);
        if (opcode == "0011")st(current_code, PC_ref);
        if (opcode == "1011")sti(current_code, PC_ref);
        if (opcode == "0111")str(current_code);
        if (opcode == "1111") {
            break;
        }//trap;
    }
}





void output(void)
{
    for (int i = 0; i < 8; i++) {
        printf("R%d = x%04hX\n", i, mRegister[i]);
    }
}


int main()
{
    input();

    run();


    output();
}

// 运行程序: Ctrl + F5 或调试 >“开始执行(不调试)”菜单
// 调试程序: F5 或调试 >“开始调试”菜单

// 入门使用技巧: 
//   1. 使用解决方案资源管理器窗口添加/管理文件
//   2. 使用团队资源管理器窗口连接到源代码管理
//   3. 使用输出窗口查看生成输出和其他消息
//   4. 使用错误列表窗口查看错误
//   5. 转到“项目”>“添加新项”以创建新的代码文件，或转到“项目”>“添加现有项”以将现有代码文件添加到项目
//   6. 将来，若要再次打开此项目，请转到“文件”>“打开”>“项目”并选择 .sln 文件
