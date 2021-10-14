&НаКлиенте
Перем МестныйКэш Экспорт;
// функции для совместимости кода 
&НаКлиенте
Функция сбисПолучитьФорму(ИмяФормы)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Попытка
			ЭтотОбъект="";
		Исключение
		КонецПопытки;
		Возврат ПолучитьФорму("ВнешняяОбработка.СБИС.Форма."+ИмяФормы);
	КонецЕсли;
	Возврат ЭтотОбъект.ПолучитьФорму(ИмяФормы);
КонецФункции
&НаКлиенте
Функция сбисЭлементФормы(Форма,ИмяЭлемента)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Форма.Элементы.Найти(ИмяЭлемента);
	КонецЕсли;
	Возврат Форма.ЭлементыФормы.Найти(ИмяЭлемента);
КонецФункции
&НаКлиенте
Функция ПоказатьРезультатОтправки(Кэш) Экспорт
	МестныйКэш = Кэш;
	РезультатОтправки = Кэш.РезультатОтправки;	
	Если Не ЭтаФорма.Открыта() Тогда
		ЭтаФорма.Открыть();
	Иначе
		ПриОткрытии("");
	КонецЕсли;
КонецФункции
&НаКлиенте
Функция ЗаполнитьСлева(ИсходнаяСтрока,ТребуемаяДлина, СимволЗаполнения)
// функция формирует отступ в надписи для красивого отображения списка ошибок	
	РезСтрока = ИсходнаяСтрока;
	КолвоСимволов = ТребуемаяДлина-СтрДлина(ИсходнаяСтрока);
	Если КолвоСимволов>0 Тогда
		Для сч = 1 По КолвоСимволов Цикл
			РезСтрока = СимволЗаполнения+РезСтрока;
		КонецЦикла;
	КонецЕсли;
	Возврат РезСтрока;
КонецФункции

&НаКлиенте
Процедура Переотправить(Команда)
// Процедура переотправляет пакеты, которые не удалось отправить	
	//МассивНеотправленныхПакетов = Новый Массив;
	//Для Каждого СоставПакета Из МестныйКэш.РезультатОтправки.МассивПакетов Цикл
	//	Если Не СоставПакета.Свойство("Отправлен")	Тогда
	//		МассивНеотправленныхПакетов.Добавить(СоставПакета);	
	//	КонецЕсли;
	//КонецЦикла;
	//МестныйКэш.Вставить("РезультатОтправки", Новый Структура("ТипыОшибок,Отправлено,НеОтправлено,НеСформировано,Ошибок", Новый СписокЗначений,0,0,0,0));
	//МестныйКэш.Интеграция.ОтправитьПакетыДокументов(МестныйКэш, МассивНеотправленныхПакетов);
	//МестныйКэш.РезультатОтправки.НеОтправлено = МассивНеотправленныхПакетов.Количество()-МестныйКэш.РезультатОтправки.Отправлено;
	//МестныйКэш.РезультатОтправки.Вставить("МассивПакетов", МассивНеотправленныхПакетов);
	//ПриОткрытии("");
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	сбисЗаполнитьЗаголовкиФормы();
	Отправлено = МестныйКэш.РезультатОтправки.Отправлено;
	НеОтправлено = МестныйКэш.РезультатОтправки.НеОтправлено;
	НеСформировано = МестныйКэш.РезультатОтправки.НеСформировано;
	Если НеОтправлено = 0 Тогда
		сбисЭлементФормы(ЭтаФорма, "Причины").Видимость = Ложь;
		//сбисЭлементФормы(ЭтаФорма, "Переотправить").Видимость = Ложь;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "Причины").Видимость = Истина;
		ЗаполнитьДеревоОшибок(МестныйКэш.РезультатОтправки);
		//сбисЭлементФормы(ЭтаФорма, "Переотправить").Видимость = Истина;
		//ТипыОшибок = "";
		//Для Каждого Элемент Из МестныйКэш.РезультатОтправки.ТипыОшибок Цикл
		//	ТипыОшибок = ТипыОшибок + ЗаполнитьСлева(Элемент.Представление,5, " ") + "  -  " + Элемент.Значение + Символы.ПС;
		//КонецЦикла;
	КонецЕсли;
	Если НеСформировано = 0 Тогда
		сбисЭлементФормы(ЭтаФорма, "НеСформировано").Видимость = Ложь;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "НеСформировано").Видимость = Истина;
		
	КонецЕсли;
	Если МестныйКэш.РезультатОтправки.Свойство("ВремяФормирования") Тогда
		сбисЭлементФормы(ЭтаФорма, "ВремяФормирования").Видимость = Истина;
		ВремяФормирования = МестныйКэш.РезультатОтправки.ВремяФормирования;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ВремяФормирования").Видимость = Ложь;
	КонецЕсли;
	Если МестныйКэш.РезультатОтправки.Свойство("ВремяОтправки") Тогда
		сбисЭлементФормы(ЭтаФорма, "ВремяОтправки").Видимость = Истина;
		ВремяОтправки = МестныйКэш.РезультатОтправки.ВремяОтправки;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ВремяОтправки").Видимость = Ложь;
	КонецЕсли;
	Если МестныйКэш.РезультатОтправки.Свойство("ВремяНачала") Тогда
		сбисЭлементФормы(ЭтаФорма, "ОбщееВремя").Видимость = Истина;
		ОбщееВремя = (ТекущаяУниверсальнаяДатаВМиллисекундах() - МестныйКэш.РезультатОтправки.ВремяНачала)/1000;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ОбщееВремя").Видимость = Ложь;
	КонецЕсли;
	Если МестныйКэш.РезультатОтправки.Свойство("ВремяЗаписиСтатусов") Тогда
		сбисЭлементФормы(ЭтаФорма, "ВремяЗаписиСтатусов").Видимость = Истина;
		ВремяЗаписиСтатусов = МестныйКэш.РезультатОтправки.ВремяЗаписиСтатусов;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ВремяЗаписиСтатусов").Видимость = Ложь;
	КонецЕсли;
	Если МестныйКэш.РезультатОтправки.Свойство("ВремяПолученияДанных") Тогда
		сбисЭлементФормы(ЭтаФорма, "ВремяПолученияДанных").Видимость = Истина;
		ВремяПолученияДанных = МестныйКэш.РезультатОтправки.ВремяПолученияДанных;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ВремяПолученияДанных").Видимость = Ложь;
	КонецЕсли;
	Если МестныйКэш.РезультатОтправки.Свойство("ВремяОжиданияОтвета") Тогда
		сбисЭлементФормы(ЭтаФорма, "ВремяОжиданияОтвета").Видимость = Истина;
		ВремяОжиданияОтвета = МестныйКэш.РезультатОтправки.ВремяОжиданияОтвета;
	Иначе
		сбисЭлементФормы(ЭтаФорма, "ВремяОжиданияОтвета").Видимость = Ложь;
	КонецЕсли;

КонецПроцедуры
Процедура ЗаполнитьДеревоОшибок(РезультатОтправки)
	ДеревоОшибок = РеквизитФормыВЗначение("ТипыОшибок");
	ДеревоОшибок.Строки.Очистить();
	Для Каждого Элемент Из РезультатОтправки.ТипыОшибок Цикл
		НоваяСтрока=ДеревоОшибок.Строки.Добавить();            
		НоваяСтрока.ТекстОшибки=Элемент.Значение;            
		НоваяСтрока.Количество=Элемент.Представление;
		
		//AU изменена структура в детализации ошибок для возможности проброса дампа в сервис статистики
		ЭлементСоответствия =РезультатОтправки.ДетализацияОшибок.Получить(Элемент.Значение);
		Если ЭлементСоответствия<>Неопределено Тогда
			Для Каждого Документ1С Из ЭлементСоответствия Цикл
				НоваяПодСтрока=НоваяСтрока.Строки.Добавить();            
				НоваяПодСтрока.Документ1С=Документ1С.ОбработанДокумент1С; 
				НоваяПодСтрока.ТекстОшибки=Документ1С.Сообщение;
			КонецЦикла;
		КонецЕсли
	КонецЦикла;	
	ЗначениеВРеквизитФормы(ДеревоОшибок, "ТипыОшибок");
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
// процедура обновляет форму главного окна	
	ФормаГлавногоОкна = МестныйКэш.ГлавноеОкно;
	Если ФормаГлавногоОкна.Открыта() Тогда
		ФормаГлавногоОкна.ОбновитьКонтент();
	КонецЕсли;	
КонецПроцедуры
&НаКлиенте
Процедура ОткрытьДокументОнлайн(Команда)
	ТекущаяСтрока = Элементы.ТипыОшибок.ТекущиеДанные;
	Если ТекущаяСтрока<>Неопределено Тогда
		Документ1С = ТекущаяСтрока.Документ1С;
	
		фрм = МестныйКэш.ГлавноеОкно.сбисНайтиФормуФункции("ПрочитатьПараметрыДокументаСБИС",МестныйКэш.ФормаРаботыСоСтатусами,"",МестныйКэш);
		ИдДок = фрм.ПрочитатьПараметрыДокументаСБИС(Документ1С,МестныйКэш.ГлавноеОкно.КаталогНастроек,"ДокументСБИС_Ид",МестныйКэш.Ини);
		Если ЗначениеЗаполнено(ИдДок) Тогда
			СоставПакета = МестныйКэш.Интеграция.ПрочитатьДокумент(МестныйКэш,ИдДок);
			Если СоставПакета<>Ложь Тогда
				Ссылка = СоставПакета.СсылкаДляНашаОрганизация;
			Иначе
				Возврат;
			КонецЕсли;
		Иначе
			Сообщить("Нет связанного документа СБИС");
			Возврат;
		КонецЕсли;
		ЗапуститьПриложение(Ссылка);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьДокумент1С(Команда)
	ТекущаяСтрока = Элементы.ТипыОшибок.ТекущиеДанные;
	Если ТекущаяСтрока<>Неопределено Тогда
		ПоказатьЗначение(Неопределено, ТекущаяСтрока.Документ1С);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура НадписьТиповыеОшибкиНажатие(Элемент)
	ЗапуститьПриложение("https://sbis.ru/help/integration/1C_set/modul/typical_errors");
КонецПроцедуры

&НаКлиенте
Функция сбисЗаполнитьЗаголовкиФормы()
	Если РезультатОтправки.Свойство("ЗаголовкиФормыРезультатов") Тогда
		ЭтаФорма.Заголовок = РезультатОтправки.ЗаголовкиФормыРезультатов.Форма;
		ЭтаФорма.Элементы.Отправлено.Заголовок = РезультатОтправки.ЗаголовкиФормыРезультатов.ПоложительныйРезультат;
		ЭтаФорма.Элементы.Неотправлено.Заголовок = РезультатОтправки.ЗаголовкиФормыРезультатов.ОтрицательныйРезультат;
		ЭтаФорма.Элементы.ТипыОшибокДокумент1С.Заголовок = РезультатОтправки.ЗаголовкиФормыРезультатов.Объект1С;
		ЭтаФорма.Элементы.НадписьТиповыеОшибки.Заголовок = РезультатОтправки.ЗаголовкиФормыРезультатов.ТиповыеОшибки;
		ЭтаФорма.Элементы.ТипыОшибокКонтекстноеОткрытьДокументОнлайн.Видимость = Ложь;
	Иначе
		ЭтаФорма.Заголовок = "Результат отправки документов";
		ЭтаФорма.Элементы.Отправлено.Заголовок = "Отправлено";
		ЭтаФорма.Элементы.Неотправлено.Заголовок = "Не отправлено";
		ЭтаФорма.Элементы.ТипыОшибокДокумент1С.Заголовок = "Документ 1С";
		ЭтаФорма.Элементы.НадписьТиповыеОшибки.Заголовок = "Смотреть типовые ошибки отправки и их решение";
		ЭтаФорма.Элементы.ТипыОшибокКонтекстноеОткрытьДокументОнлайн.Видимость = Истина;
	КонецЕсли
КонецФункции