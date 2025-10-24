import re

# Словарь кодов операций
# localparam NOP = 0, LTM = 1, MTR = 2, RTR = 3, JL = 4, SUB = 5, SUM = 6, MTRK = 7, RTM = 8, JMP = 9;

ma = 5 # memory address
lt = 10 # literal
ra = 4 # register address
pc = 4 # prog counter

opcodes = {
    'NOP': 0b0000,
    'LTM': 0b0001,
    'MTR': 0b0010,
    'RTR': 0b0011,
    'JL': 0b0100,
    'SUB': 0b0101,
    'SUM': 0b0110,
    'MTRK': 0b0111,
    'RTM': 0b1000,
    'JMP': 0b1001
}

bytes = [
    [],
    [ma, lt],
    [ma, ra],
    [ra, ra],
    [ra, ra, pc],
    [ra, ra, ra],
    [ra, ra, ra],
    [ra, ra],
    [ra, ra],
    [pc]
]

def parse_line(line):
    """Разбирает строку и возвращает команду и аргументы"""
    # Удаляем комментарии и лишние символы
    line = re.sub(r'//.*', '', line).strip()
    if not line:
        return None
    
    # Ищем команду после номера строки (например, "0: LTM 0 5")
    parts = re.split(r'\s+', line)
    if len(parts) < 2:
        return None
    
    # Пропускаем номер строки (формат "X:")
    if ':' in parts[0]:
        cmd_parts = parts[1:]
    else:
        cmd_parts = parts
    
    command = cmd_parts[0]
    args = []
    
    # Обработка аргументов команды
    for arg in cmd_parts[1:]:
        # Обработка аргументов с метками (например, "l1(21)")
        match = re.match(r'.*\((\d+)\)', arg)
        if match:
            args.append(int(match.group(1)))
        else:
            # Обычные числовые аргументы
            try:
                args.append(int(arg))
            except ValueError:
                continue
    
    return command, args

def to_binary(command, args):
    """Преобразует команду в бинарное представление"""
    if command not in opcodes:
        raise ValueError(f"Неизвестная команда: {command}")
    
    # Код операции (4 бита)
    opcode_bin = format(opcodes[command], '04b')
    # print(f"opcode: {opcode_bin}", end=" : ")
    # Аргументы (каждый по 4 бита)
    args_bin = []


    if(command == 'JL'):
        args_bin.append(format(args[0], '04b'))
        args_bin.append(format(args[1], '04b'))
        args_bin.append('00')
        args_bin.append(format(args[2], '05b'))
    elif(command == 'JMP'):
        args_bin.append('0' * 10)
        args_bin.append(format(args[0], '05b'))
    elif(command == "MTR"):
        args_bin.append(format(args[1], '05b'))
        args_bin.append(format(args[0], '04b'))
    else:
        for i in range(len(bytes[opcodes[command]])):
            if i < len(args):
                temp = format(args[i], f'0{bytes[opcodes[command]][i]}b')
                # print(f"[{i}] arg: {temp}", end=" | ")
                args_bin.append(temp)
            else:
                args_bin.append('0000', end=" | ")  # Заполняем нулями отсутствующие аргументы
    

            
    
    # Объединяем в 19-битную строку
    binary_string = opcode_bin + ''.join(args_bin)
    
    binary_string = binary_string.ljust(19, '0')
    # Проверяем длину
    if len(binary_string) != 19:
        raise ValueError(f"Некорректная длина бинарной строки: {len(binary_string)}")
    
    return binary_string

def main():
    with open('commands.txt', 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        result = parse_line(line)
        # print("RESULT: ", result)
        if not result:
            continue
            
        command, args = result
        try:
            binary = to_binary(command, args)
            # print(f"{binary} // {command} {args}")
            print(f"{binary}")
        except ValueError as e:
            print(f"Ошибка обработки строки: {line.strip()} -> {e}")

if __name__ == "__main__":
    main()