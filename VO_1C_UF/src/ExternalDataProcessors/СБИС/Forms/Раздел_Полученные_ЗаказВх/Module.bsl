&НаКлиенте
Функция сбисЭлементФормы(Форма,ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);
КонецФункции
&НаКлиенте
Процедура сбисОформлениеДопПолейРеестра(Кэш) Экспорт
	сбисЭлементФормы(Кэш.ГлавноеОкно,"Таблица_РеестрДокументов").ПодчиненныеЭлементы.Таблица_РеестрДокументовСрок.Видимость = Истина;
	сбисЭлементФормы(Кэш.ГлавноеОкно,"Таблица_РеестрДокументов").ПодчиненныеЭлементы.Таблица_РеестрДокументовЛицо2.Видимость = Истина;
	сбисЭлементФормы(Кэш.ГлавноеОкно,"Таблица_РеестрДокументов").ПодчиненныеЭлементы.Таблица_РеестрДокументовЛицо2.Заголовок = "Грузополучатель";
КонецПроцедуры

