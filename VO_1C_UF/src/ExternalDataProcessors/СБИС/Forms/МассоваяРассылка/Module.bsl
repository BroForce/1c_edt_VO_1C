&НаКлиенте
Перем МестныйКэш Экспорт;

&НаКлиенте
Функция сбисЭлементФормы(Форма,ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);
КонецФункции
&НаКлиенте
Процедура ПоказатьФорму(Кэш)Экспорт
	ЭтаФорма.Открыть();
	МестныйКэш = Кэш;
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьВложение(Команда)
	// Процедура добавляет внешний файл в кэш
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие); 
	ДиалогОткрытияФайла.МножественныйВыбор = Истина;
	ДиалогОткрытияФайла.Заголовок = "Выберите файлы";
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		МассивФайлов = ДиалогОткрытияФайла.ВыбранныеФайлы;
		Для Каждого ИмяФайла Из МассивФайлов Цикл
			Файл = Новый Файл(ИмяФайла);
			МестныйКэш.ДопВложение.Добавить(Новый Структура("ПолноеИмяФайла,ИмяФайла,Название,XMLДокумента",Файл.ПолноеИмя, Файл.Имя, Файл.Имя,""));
		КонецЦикла;
		ЗаполнитьТаблицу(МестныйКэш);
	КонецЕсли;
КонецПроцедуры
&НаКлиенте
Процедура УдалитьВложение(Команда)
	//Процедура удаляет вложение из пакета
	Если сбисЭлементФормы(ЭтаФорма,"ДополнительныеВложения").ТекущиеДанные<>Неопределено Тогда
		МестныйКэш.ДопВложение.Удалить(сбисЭлементФормы(ЭтаФорма,"ДополнительныеВложения").ТекущиеДанные.НомерВложенияВПакете);
		ЗаполнитьТаблицу(МестныйКэш);
	КонецЕсли;
КонецПроцедуры
&НаКлиенте
Процедура ЗаполнитьТаблицу(МестныйКэш) 
	ДополнительныеВложения.Очистить();
	сч = 0;
	Для Каждого Вложение Из МестныйКэш.ДопВложение Цикл
		НоваяСтр = ДополнительныеВложения.Добавить();
		НоваяСтр.НомерВложенияВПакете = сч;
		Если Вложение.Свойство("Название") Тогда
			НоваяСтр.Название = Вложение.Название;
		КонецЕсли;
		сч = сч+1;
	КонецЦикла;		
КонецПроцедуры

&НаКлиенте
Процедура ДополнительныеВложенияВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Если Поле.Имя = "ДополнительныеВложенияУдалить"  Тогда
		УдалитьВложение("");
	КонецЕсли;
КонецПроцедуры
