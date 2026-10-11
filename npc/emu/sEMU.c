#include <stdio.h>
#include <stdint.h>

#define ROM_SIZE    256
#define GPRS_NUM    4

typedef enum{
    OP_ADD = 0,
    OP_LI = 2,
    OP_BNER0 =3 
}Opcode;
// init the sMEU
static int sEMU_init(const char* path, uint8_t rom[ROM_SIZE], size_t* cnt_inst){

    FILE *fp = fopen(path, "r");
    if(fp == NULL){
        perror(path);
        return -1;
    }

    *cnt_inst = 0;
    unsigned value;
    int result;

    while((result = fscanf(fp, "%x", &value)) == 1) {
        if(*cnt_inst >= ROM_SIZE || value > 0xffu){
            fprintf(stderr, "%s: ROM is full or the machine code is too long\n", path);
            fclose(fp);
            return -1;
        }
        rom[(*cnt_inst)++] = (uint8_t)value;
    }
    if(result != EOF || ferror(fp) || *cnt_inst == 0){
        fprintf(stderr, "%s: hex format error or the file is empty\n", path);
        fclose(fp);
        return -1;
    }
    fclose(fp);
    return 0;
}

int exec_step(uint8_t* rom, uint8_t* p_pc, uint8_t* gprs){
    // fetch
    uint8_t inst = rom[*p_pc];
    // decode
    Opcode op_code = (Opcode)((inst >> 6) & 0x03u);
    uint8_t rd = (inst >> 4) & 0x03;
    uint8_t rs1 = (inst >> 2) & 0x03;
    uint8_t rs2 = inst & 0x03;
    uint8_t s = (inst >> 2) & 0x03;
    uint8_t imm = inst & 0x03;
    uint8_t offset4 = (inst >> 2) & 0x0f;
    int offset = (offset4 & 0x08) ?  (int)offset4 - 16 : (int)offset4;

    uint8_t next_pc = (uint8_t)(*p_pc + 1);
    // execution
    switch(op_code){
        case OP_ADD:
            gprs[rd] = (uint8_t)(gprs[rs1] + gprs[rs2]);
            break;
        case OP_LI:
            gprs[rd] = (uint8_t)(imm << (s * 2));
            break;
        case OP_BNER0:
            if(gprs[rs2] != gprs[0])
                next_pc = (uint8_t)(*p_pc + offset);
            break;
        default: return -1;
    }
    
    *p_pc = next_pc;
    return 0;
}

void print_state(uint8_t* pc, uint8_t* gprs){
    printf("sEMU: pc = %d, r0 = %u, r1 = %u, r2 = %u, r3 = %u\n", *pc, 
        (unsigned)gprs[0], (unsigned)gprs[1], (unsigned)gprs[2], (unsigned)gprs[3]);
}

int main(int argc, char** argv){
    if(argc != 2){
        fprintf(stderr, "use: %s program.hex\n", argv[0]);
        return 1;
    }

    uint8_t rom[ROM_SIZE] = {0};
    uint8_t gprs[GPRS_NUM] = {0};
    uint8_t pc = 0; 
    size_t cnt_inst = 0;
    char command[32];
    
    if(sEMU_init(argv[1], rom, &cnt_inst)!= 0){
        return 1;
    }
    printf("load %zu instructions\n", cnt_inst);
    print_state(&pc, gprs);

    while(1){
        fputs("sEMU> ", stdout);
        fflush(stdout);

        if(fgets(command, sizeof command, stdin) == NULL)
            break;
        if(command[0] == 'q')
            break;
        if(command[0] != 'c'){
            puts("input 'c' to execute an instruction and input 'q' to exit");
            continue;
        }
        if((size_t)pc >= cnt_inst) {
            fprintf(stderr, "PC = %u, it exceeds the program\n", (unsigned)pc);
            return 1;
        }
        if(exec_step(rom, &pc, gprs) != 0) {
            fprintf(stderr, "PC = %u, the instruction is not supported\n", (unsigned)pc);
            return 1;
        }
        print_state(&pc, gprs);
    }
    return 0;
}
