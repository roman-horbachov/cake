require 'json'

# Функція для пошуку всіх можливих прямокутників заданої площі, які містять певну родзинку
def find_possible_rectangles(cake, o_pos, area, other_o_positions)
  h = cake.size
  w = cake[0].size
  r, c = o_pos
  possible_rects = []

  # Перебираємо всі можливі висоти та ширини, такі що висота * ширина = площа
  (1..area).each do |height|
    if area % height == 0
      width = area / height
      # Для кожного розміру прямокутника знаходимо можливі верхні ліві позиції
      min_top = [0, r - (height - 1)].max
      max_top = [r, h - height].min
      min_left = [0, c - (width - 1)].max
      max_left = [c, w - width].min

      (min_top..max_top).each do |top|
        (min_left..max_left).each do |left|
          # Перевіряємо, чи прямокутник не містить інших родзинок
          contains_other_o = false
          other_o_positions.each do |other_o|
            orow, ocol = other_o
            if orow >= top && orow < top + height && ocol >= left && ocol < left + width
              contains_other_o = true
              break
            end
          end
          unless contains_other_o
            possible_rects << { top: top, left: left, height: height, width: width }
          end
        end
      end
    end
  end
  # Сортуємо прямокутники за спаданням ширини
  possible_rects.sort_by { |rect| -rect[:width] }
end

# Функція для конвертації прямокутника у його представлення у вигляді масиву рядків
def rectangle_grid(cake, rect)
  top = rect[:top]
  left = rect[:left]
  height = rect[:height]
  width = rect[:width]
  grid = []
  (top...(top + height)).each do |r|
    grid << cake[r][left, width]
  end
  grid
end

# Рекурсивна функція для призначення прямокутників родзинкам без перекриттів
def assign_rectangles(cake, o_positions, n, area, rects_per_o, current_assignments, used_cells, index, solution)
  if index == n
    # Всі родзинки призначені, зберігаємо рішення
    solution.replace(current_assignments.map { |rect| rectangle_grid(cake, rect) })
    return true
  end

  # Отримуємо поточну родзинку для призначення
  o = o_positions[index]
  rects = rects_per_o[index]

  rects.each do |rect|
    # Перевіряємо, чи прямокутник не перекривається з вже використаними клітинками
    overlap = false
    (rect[:top]...(rect[:top] + rect[:height])).each do |r|
      (rect[:left]...(rect[:left] + rect[:width])).each do |c|
        if used_cells[r][c]
          overlap = true
          break
        end
      end
      break if overlap
    end
    next if overlap

    # Призначаємо цей прямокутник
    (rect[:top]...(rect[:top] + rect[:height])).each do |r|
      (rect[:left]...(rect[:left] + rect[:width])).each do |c|
        used_cells[r][c] = true
      end
    end

    current_assignments << rect

    # Рекурсивно призначаємо наступну родзинку
    if assign_rectangles(cake, o_positions, n, area, rects_per_o, current_assignments, used_cells, index + 1, solution)
      return true
    end

    # Відміняємо призначення (бек-трекінг)
    (rect[:top]...(rect[:top] + rect[:height])).each do |r|
      (rect[:left]...(rect[:left] + rect[:width])).each do |c|
        used_cells[r][c] = false
      end
    end

    current_assignments.pop
  end

  return false
end

# Основна функція для розрізання торта
def split_cake(cake)
  h = cake.size
  w = cake[0].size
  # Знаходимо позиції всіх родзинок
  o_positions = []
  cake.each_with_index do |row, r|
    row.each_char.with_index do |ch, c|
      o_positions << [r, c] if ch == 'o' || ch == 'о' # Обробляємо як латинське, так і кириличне "о"
    end
  end
  n = o_positions.size
  if n < 2 || n >= 10
    puts "Кількість родзинок (n) повинна бути від 2 до 9"
    return []
  end
  total_area = h * w
  if total_area % n != 0
    puts "Неможливо розрізати торт на #{n} шматочків з рівною площею"
    return []
  end
  area = total_area / n
  # Передобчислюємо можливі прямокутники для кожної родзинки
  rects_per_o = []
  o_positions.each_with_index do |o, idx|
    # Інші родзинки - всі крім поточної
    other_o_positions = o_positions[0...idx] + o_positions[(idx + 1)..-1]
    rects = find_possible_rectangles(cake, o, area, other_o_positions)
    rects_per_o << rects
  end
  # Щоб пріоритезувати рішення з найбільшою шириною першого шматочка, сортуємо родзинки за максимальною шириною можливих прямокутників
  o_max_widths = rects_per_o.map { |rects| rects.empty? ? 0 : rects.first[:width] }
  sorted_indices = (0...n).sort_by { |i| -o_max_widths[i] }
  sorted_o_positions = sorted_indices.map { |i| o_positions[i] }
  sorted_rects_per_o = sorted_indices.map { |i| rects_per_o[i] }
  # Ініціалізуємо масив використаних клітинок
  used_cells = Array.new(h) { Array.new(w, false) }
  # Ініціалізуємо призначення
  current_assignments = []
  # Ініціалізуємо рішення
  solution = []
  # Виконуємо призначення
  if assign_rectangles(cake, sorted_o_positions, n, area, sorted_rects_per_o, current_assignments, used_cells, 0, solution)
    # Переставляємо рішення відповідно до початкового порядку родзинок
    reordered_solution = Array.new(n)
    sorted_indices.each_with_index do |orig_idx, sorted_idx|
      reordered_solution[orig_idx] = solution[sorted_idx]
    end
    return reordered_solution
  else
    puts "Рішення не знайдено"
    return []
  end
end

# Функція для виводу результату у форматі масиву з використанням JSON
def print_result(result)
  puts JSON.pretty_generate(result)
end

# Приклад використання:
# Визначаємо торт як масив рядків
cake1 = [
  "........",
  "..o.....",
  "...o....",
  "........"
]

cake2 = [
  ".о.о....",
  "........",
  "....о...",
  "........",
  ".....о..",
  "........"
]

# Розрізаємо торт
result1 = split_cake(cake1)
puts "Результат 1:"
print_result(result1)

result2 = split_cake(cake2)
puts "Результат 2:"
print_result(result2)
