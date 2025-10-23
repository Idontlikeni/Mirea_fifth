import re

# Словарь кодов операций
opcodes = {
    'LTM': 0b0000,
    'RTM': 0b0001,
    'RTR': 0b0010,
    'JL': 0b0011,
    'SUB': 0b0100,
    'SUM': 0b0101,
    'MTRK': 0b0110,
    'JMP': 0b0111,
    'NOP': 0b1000
}

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
    
    # Аргументы (каждый по 4 бита)
    args_bin = []
    for i in range(3):
        if i < len(args):
            args_bin.append(format(args[i], '04b'))
        else:
            args_bin.append('0000')  # Заполняем нулями отсутствующие аргументы
    
    # Объединяем в 19-битную строку
    binary_string = opcode_bin + ''.join(args_bin)
    
    # Проверяем длину
    if len(binary_string) != 16:
        raise ValueError(f"Некорректная длина бинарной строки: {len(binary_string)}")
    
    return binary_string

def main():
    with open('commands.txt', 'r') as f:
        lines = f.readlines()
    
    for line in lines:
        result = parse_line(line)
        if not result:
            continue
            
        command, args = result
        try:
            binary = to_binary(command, args)
            print(f"{binary} // {command} {args}")
        except ValueError as e:
            print(f"Ошибка обработки строки: {line.strip()} -> {e}")

if __name__ == "__main__":
    main()