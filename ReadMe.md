# Розрізання Торта з Родзинками на Прямокутники

## Опис

Цей Ruby-скрипт призначений для розрізання торта, представленого у вигляді масиву рядків, на рівні прямокутні шматочки. Кожен шматочок містить одну родзинку (`'o'` або `'о'`), причому шматочки не перекриваються між собою. Алгоритм знаходить усі можливі прямокутники заданої площі для кожної родзинки та рекурсивно призначає їх, забезпечуючи відсутність перекриттів.

## Основні Функції

- **find_possible_rectangles**: Знаходить усі можливі прямокутники заданої площі, що містять певну родзинку та не включають інші родзинки.
- **rectangle_grid**: Конвертує прямокутник у його представлення у вигляді масиву рядків.
- **assign_rectangles**: Рекурсивно призначає прямокутники родзинкам без перекриттів за допомогою бек-трекінгу.
- **split_cake**: Основна функція, яка здійснює розрізання торта на шматочки.
- **print_result**: Виводить результат у форматі JSON.
- **visualize_cake**: Візуалізує розрізаний торт, замінюючи кожен шматочок унікальним символом.