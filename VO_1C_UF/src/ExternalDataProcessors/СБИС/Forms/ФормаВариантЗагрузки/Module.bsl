&НаКлиенте
Процедура КнопкаВыполнитьНажатие(Команда)
// возвращает выбранный способ загрузки	
	ЭтаФорма.Закрыть(СпособЗагрузки);
КонецПроцедуры
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// Вставить содержимое обработчика.
	ЭтаФорма.Элементы.СпособЗагрузки.СписокВыбора[0].Представление = ЭтаФорма.Параметры.Режим[0].Представление;
КонецПроцедуры
