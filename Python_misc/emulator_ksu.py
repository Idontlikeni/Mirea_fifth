class CPU:
    def __init__(self, memory_size=256, reg_count=16):
        # Регистры процессора
        self.PC = 0  # Program Counter - счетчик команд
        self.cmd_reg = None  # Регистр команды
        self.RF = [0] * reg_count  # RegFile - регистровый файл
        self.mem = [0] * memory_size  # Memory - оперативная память
        self.cmd_mem = []  # Память команд

        # Инициализация RF как указано
        self.RF[0] = 0
        self.RF[1] = 1

        # Регистры для хранения промежуточных данных
        self.operand1 = 0
        self.operand2 = 0
        self.operand3 = 0
        self.result = 0
        self.jump_condition = False

        # Словарь для дешифрации команд
        self.instruction_set = {
            "0000": "NOP",
            "0001": "LTM",
            "0010": "MTR",
            "0011": "RTR",
            "0100": "JL",
            "0101": "SUB",
            "0110": "SUM",
            "0111": "MTRK",
            "1000": "RTM",
            "1001": "JMP"
        }

        # Обработчики команд
        self.executors = {
            "NOP": self.execute_nop,
            "LTM": self.execute_ltm,
            "MTR": self.execute_mtr,
            "RTR": self.execute_rtr,
            "JL": self.execute_jl,
            "SUB": self.execute_sub,
            "SUM": self.execute_sum,
            "MTRK": self.execute_mtrk,
            "RTM": self.execute_rtm,
            "JMP": self.execute_jmp
        }

    def fetch(self):
        """1 такт: выборка команды"""
        if self.PC < len(self.cmd_mem):
            self.cmd_reg = self.cmd_mem[self.PC]
            print(f"FETCH: PC={self.PC}, Загружена команда {self.cmd_reg}")
        else:
            self.cmd_reg = None
            print("FETCH: Нет команд для выполнения")

    def decode1(self):
        """2 такт: выборка первого операнда"""
        if self.cmd_reg:
            opcode = self.cmd_reg[0]
            if opcode in ["LTM", "MTR", "RTR", "MTRK", "RTM"]:
                self.operand1 = self.cmd_reg[1]
                print(f"DECODE1: Операнд1 = {self.operand1}")
            elif opcode in ["JL", "SUB", "SUM"]:
                self.operand1 = self.cmd_reg[1]
                print(f"DECODE1: Адрес операнда1 RF[{self.operand1}]")
            elif opcode == "JMP":
                self.operand1 = self.cmd_reg[1]
                print(f"DECODE1: Адрес перехода = {self.operand1}")

    def decode2(self):
        """3 такт: выборка второго операнда"""
        if self.cmd_reg:
            opcode = self.cmd_reg[0]
            if opcode in ["LTM"]:
                self.operand2 = self.cmd_reg[2]  # Literal value
                print(f"DECODE2: Literal = {self.operand2}")
            elif opcode in ["MTR", "RTR", "MTRK", "RTM"]:
                self.operand2 = self.cmd_reg[2]
                print(f"DECODE2: Операнд2 = {self.operand2}")
            elif opcode in ["JL", "SUB", "SUM"]:
                self.operand2 = self.cmd_reg[2]
                print(f"DECODE2: Адрес операнда2 RF[{self.operand2}]")

            # Для команд с тремя операндами
            if opcode in ["JL", "SUB", "SUM"] and len(self.cmd_reg) > 3:
                self.operand3 = self.cmd_reg[3]
                print(f"DECODE2: Операнд3 = {self.operand3}")

    def execute(self):
        """4 такт: исполнение команды"""
        if self.cmd_reg:
            opcode = self.cmd_reg[0]
            if opcode in self.executors:
                self.executors[opcode]()
                print(f"EXECUTE: Выполнена операция {opcode}")

    def writeback(self):
        """5 такт: запись результата"""
        if self.cmd_reg:
            opcode = self.cmd_reg[0]



            # Обновление PC
            if opcode == "JMP" and self.jump_condition:
                self.PC = self.operand1
                print(f"WRITEBACK: Безусловный переход на PC={self.PC}")
            elif opcode == "JL":
                if self.jump_condition:
                    # Если условие истинно (A < B), увеличиваем PC на 1
                    self.PC += 1
                    print(f"WRITEBACK: PC увеличен до {self.PC} (A < B)")
                else:
                    # Если условие ложно (A >= B), переходим по адресу
                    self.PC = self.operand3
                    print(f"WRITEBACK: Условный переход на PC={self.PC} (A >= B)")
            else:
                self.PC += 1
                print(f"WRITEBACK: PC увеличен до {self.PC}")

            # Сброс условия перехода
            self.jump_condition = False

    # Реализации команд
    def execute_nop(self):
        """NOP - пустая команда"""
        pass

    def execute_ltm(self):
        """LTM - literal to memory"""
        self.mem[self.operand1] = self.operand2
        self.result = self.operand2

    def execute_mtr(self):
        """MTR - memory to register"""
        self.RF[self.operand1] = self.mem[self.operand2]
        self.result = self.mem[self.operand2]

    def execute_rtr(self):
        """RTR - register to register"""
        self.RF[self.operand1] = self.RF[self.operand2]
        self.result = self.RF[self.operand2]

    def execute_jl(self):
        """JL - jump less"""
        a = self.RF[self.operand1]
        b = self.RF[self.operand2]
        self.jump_condition = (a < b)
        print(f"JL: RF[{self.operand1}]={a} < RF[{self.operand2}]={b} -> {self.jump_condition}")

    def execute_sub(self):
        """SUB - вычитание"""
        a = self.RF[self.operand1]
        b = self.RF[self.operand2]
        self.RF[self.operand3] = a - b
        self.result = a - b

    def execute_sum(self):
        """SUM - сложение"""
        a = self.RF[self.operand1]
        b = self.RF[self.operand2]
        self.RF[self.operand3] = a + b
        self.result = a + b

    def execute_mtrk(self):
        """MTRK - memory to register (косвенная адресация)"""
        mem_addr = self.RF[self.operand2]
        self.RF[self.operand1] = self.mem[mem_addr]
        self.result = self.mem[mem_addr]

    def execute_rtm(self):
        """RTM - register to memory (косвенная адресация)"""
        mem_addr = self.RF[self.operand2]
        self.mem[mem_addr] = self.RF[self.operand1]
        self.result = self.RF[self.operand1]

    def execute_jmp(self):
        """JMP - безусловный переход"""
        self.jump_condition = True

    def run_instruction(self):
        """Выполнение одной команды по пятитактному циклу"""
        print("\n" + "=" * 60)
        print(f"Начало выполнения команды (PC={self.PC})")
        print("=" * 60)

        self.fetch()  # Такт 1
        self.decode1()  # Такт 2
        self.decode2()  # Такт 3
        self.execute()  # Такт 4
        self.writeback()  # Такт 5

        print("=" * 60)
        print("Завершение выполнения команды")
        print("=" * 60)

        return self.PC < len(self.cmd_mem)

    def load_program(self, program):
        """Загрузка программы в память команд"""
        self.cmd_mem = program
        self.PC = 0

    def print_state(self):
        """Вывод текущего состояния процессора"""
        print("\nТекущее состояние процессора:")
        print(f"PC = {self.PC}")
        print(f"RF = {self.RF[:10]}")  # Показываем первые 10 регистров
        print(f"mem[0:10] = {self.mem[:10]}")  # Показываем первые 10 ячеек памяти
        if self.PC < len(self.cmd_mem):
            print(f"Следующая команда: {self.cmd_mem[self.PC]}")
        else:
            print("Следующая команда: КОНЕЦ ПРОГРАММЫ")


# Создаем процессор
cpu = CPU()



# Загружаем тестовую программу
program = [
    ["LTM", 0, 5],  # 0: mem[0] = 5
    ["LTM", 1, 7],  # 1: mem[1] = 7
    ["LTM", 2, 3],  # 2: mem[2] = 3
    ["LTM", 3, 3],  # 3: mem[3] = 3
    ["MTR", 2, 3],  # 4: RF[2] = mem[3] / N=3
    ["RTR", 3, 0],  # 5: RF[3] = RF[0] / i=0
    ["JL", 3, 2, 21],  # 6: if ~(RF[3] < RF[2]) jump to 21
    ["RTR", 4, 0],  # 7: RF[4] = RF[0] / j=0
    ["SUB", 2, 3, 5],  # 8: RF[5] = RF[2] - RF[3]
    ["SUB", 5, 1, 5],  # 9: RF[5] = RF[5] - RF[1]
    ["JL", 4, 5, 19],  # 10: if ~(RF[4] < RF[5]) jump to 19
    ["SUM", 4, 1, 6],  # 11: RF[6] = RF[4] + RF[1]
    ["MTRK", 7, 4],  # 12: RF[7] = mem[RF[4]]
    ["MTRK", 8, 6],  # 13: RF[8] = mem[RF[6]]
    ["JL", 8, 7, 17],  # 14: if ~(RF[7] < RF[8]) jump to 17
    ["RTM", 7, 6],  # 15: mem[RF[7]] = RF[6] ?
    ["RTM", 8, 4],  # 16: mem[RF[8]] = RF[4] ?
    ["SUM", 4, 1, 4],  # 17: RF[4] = RF[4] + RF[1]
    ["JMP", 8],  # 18: jump to 8
    ["SUM", 3, 1, 3],  # 19: RF[3] = RF[3] + RF[1]
    ["JMP", 6],  # 20: jump to 6
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"],  # 21: конец программы
    ["NOP"]  # 21: конец программы

]
cpu.load_program(program)

print("НАЧАЛЬНОЕ СОСТОЯНИЕ:")
cpu.print_state()

# Выполняем программу
max_instructions = 100  # Ограничение для предотвращения бесконечного цикла
instructions_executed = 0

while cpu.PC < len(cpu.cmd_mem) and instructions_executed < max_instructions:
    cpu.run_instruction()
    cpu.print_state()
    instructions_executed += 1

    if instructions_executed >= max_instructions:
        print("\nПРЕРВАНО: достигнут лимит выполненных команд")
        break

print("\nФИНАЛЬНОЕ СОСТОЯНИЕ:")
cpu.print_state()
print(f"\nВсего выполнено команд: {instructions_executed}")
