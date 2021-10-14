&НаКлиенте
Функция сбисЭлементФормы(Форма,ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы[ИмяЭлемента];
	КонецЕсли;
	Возврат Форма.ЭлементыФормы[ИмяЭлемента];
КонецФункции

&НаКлиенте
Процедура ОчиститьФильтр(Элемент) Экспорт
	ДельтаВыбор = 0;
	СтатусСопоставления = 0;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
КонецПроцедуры

&НаКлиенте
Процедура ОтобратьНажатие(Команда)
	ЭтаФорма.ВладелецФормы.ФильтрДельта = ДельтаВыбор;
	ЭтаФорма.ВладелецФормы.ФильтрСтатусСопоставления = СтатусСопоставления;

	ЭтаФорма.Закрыть(Истина);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ДельтаВыбор = ЭтаФорма.ВладелецФормы.ФильтрДельта;
	СтатусСопоставления = ЭтаФорма.ВладелецФормы.ФильтрСтатусСопоставления;
КонецПроцедуры