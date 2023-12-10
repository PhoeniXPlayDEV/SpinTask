# Описание Spin-модели движения поездов

## Введение

Этот проект представляет собой модель системы движения поездов для рещения задачи с разъездом поездов, разработанную на языке Promela для Spin. 

## Постановка задачи
Решите с помощью SPIN следующую головоломку («Разъезд поездов»). На одноколейной железной дороге встретились 2 поезда, у каждого из которых по 80 вагонов. Рядом между ними есть тупик с возможностью вместить 40 вагонов и локомотив. Как разъехаться поездам?

## Описание обозначений

- `trainID`: Идентификатор поезда (0 – первый поезд, 1 – второй поезд).
- `dir`: Направление (0 – слева/влево, 1 – справа/вправо). `dir` не соответствует направлению головы поезда, а привязан к карте.
- `N`: Любое натуральное число.
- `moveToDeadend_U(trainID)`: Перемещение поезда `trainID` из текущей локации в тупик.
- `moveFromDeadend(trainID, dir)`: Перемещение поезда `trainID` из тупика по направлению `dir`.
- `doStepsMove(trainID, dir)`: Перемещение поезда `trainID` по направлению `dir` до тех пор, пока это возможно, не въезжая в тупик.
- `disconnectCars(trainID, dir, N)`: Отсоединение `N` вагонов у поезда `trainID` со стороны `dir` в текущей локации. `dir` не является идентификатором того, отцепляются вагоны с головы или с хвоста поезда. Если голова поезда направлена по направлению движения слева направо, то dir = 0 будет означать, что N вагонов отделяется с конца состава, а dir = 1 – с головы поезда. Если же голова поезда направления по направлению движения справа налево, то dir = 0 будет означать, что N вагонов отделяются с головы поезда, а dir = 1 – c конца состава.
- `connectCars(trainID, dir, N)`: Подсоединение `N` вагонов к поезду `trainID` со стороны `dir` в текущей локации. Аналогично, `dir` не является идентификатором того, подсоединяются вагоны к голове или хвосту поезда.
- `doSpecialConnection(trainID, dir, N)`: Аналогично `connectCars(trainID, dir, N)`, но вагоны берутся из соседней локации, а не из текущей.

## Вывод Spin
Вывод получен с помощью команды `spin -run -bit trains.pml.trail`

```spin
doStepsMove(0, 1)  			// Поезд 1 перемещается вправо и встает перед поездом 2 [голова поезда 1 смотрит вправо]
doStepsMove(0, 0)			// Поезд 1 перемещается влево в свою начальную точку [голова поезда 1 смотрит вправо]
doStepsMove(0, 1)			// Поезд 1 перемещается вправо и встает перед поездом 2 [голова поезда 1 смотрит вправо]
disconnectCars(1, 1, 1)		// Поезд 2 отсоединяет 1 вагон справа (со своего конца) [голова поезда 2 смотрит влево]
doStepsMove(0, 0)			// Поезд 1 перемещается влево в свою начальную точку [голова поезда 1 смотрит вправо]
moveToDeadend_U(1)			// Поезд 2 перемещается в тупик из правой части карты [голова поезда 2 смотрит вверх]
moveFromDeadend(1, 0)		// Поезд 2 выезжает из тупика в левую часть карты [теперь голова поезда 2 смотрит вправо]
moveToDeadend_U(1)			// Поезд 2 перемещается в тупик из левой части карты [голова поезда 2 смотрит вверх] 
moveFromDeadend(1, 0)		// Поезд 2 выезжает из тупика в левую часть карты [теперь голова поезда 2 смотрит вправо]
doStepsMove(1, 1)			// Поезд 2 перемещается вправо на свое начальное место [голова поезда 2 смотрит вправо]
moveToDeadend_U(1)			// Поезд 2 перемещается в тупик из правой части карты [голова поезда 2 смотрит вниз]
moveFromDeadend(1, 0)		// Поезд 2 выезжает из тупика в левую часть карты [теперь голова поезда 2 смотрит влево]
moveToDeadend_U(1)			// Поезд 2 перемещается в тупик из левой части карты [голова поезда 2 смотрит вниз]
moveFromDeadend(1, 0)		// Поезд 2 выезжает из тупика в левую часть карты [голова поезда 2 смотрит влево] 
doStepsMove(1, 1)			// Поезд 2 перемещается вправо на свое начальное место [голова поезда 2 смотрит влево]
moveToDeadend_U(1)			
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
disconnectCars(0, 0, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
disconnectCars(0, 0, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
doStepsMove(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
connectCars(0, 0, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
doStepsMove(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
disconnectCars(0, 1, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
disconnectCars(0, 1, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
disconnectCars(0, 1, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 0)
doStepsMove(1, 1)
disconnectCars(1, 0, 1)
connectCars(0, 0, 1)
doStepsMove(1, 0)
disconnectCars(0, 0, 1)
moveToDeadend_U(1)
moveFromDeadend(1, 1)
connectCars(0, 1, 1)
connectCars(1, 1, 1)
moveToDeadend_U(0)
doStepsMove(1, 0)
disconnectCars(1, 1, 1)
disconnectCars(0, 1, 1)
moveFromDeadend(0, 0)
moveToDeadend_U(0)
disconnectCars(1, 1, 1)
connectCars(0, 1, 1)
moveFromDeadend(0, 0)
connectCars(1, 1, 1)
doStepsMove(0, 1)
connectCars(1, 0, 1)
connectCars(1, 1, 1)
doStepsMove(0, 0)
doStepsMove(0, 1)
doStepsMove(1, 1)
doStepsMove(1, 0)
disconnectCars(0, 1, 1)
moveToDeadend_U(0)
doStepsMove(1, 1)
moveFromDeadend(0, 1)
disconnectCars(1, 1, 1)
moveToDeadend_U(0)
moveFromDeadend(0, 0)
doStepsMove(0, 1)
disconnectCars(1, 0, 1)
doSpecialConnection(0, 1, 1)
moveToDeadend_U(0)
connectCars(1, 1, 1)
doStepsMove(1, 0)
moveFromDeadend(0, 1)
connectCars(0, 1, 1)

```

## Использование

Для прочтения существующего вывода spin, содержащегося в файле `trains.pml.trail` используйте команду `spin -t trains.pml`.

Вывод модели на корректность можно проверить с помощью программы, написанной на Java в каталоге `TrainsJava`, вводя в консоль последовательно команды из вывода. Дополнительно добавлены команды: 
- `q`: Остановка программы;
- `trainsStatus`: Отображения текущей информации о состоянии поездов (местоположение, направление головы, количество вагонов спереди и сзади, идентификаторы подсоединенных вагонов с сохранением последовательности их расположения в виде стека);
- `locsStatus`: Отображение текущей информации о локаций (их занятость и положение отцепленных вагонов);
- `status`:Объединение вывода `trainsStatus` и `locsStatus`.
---