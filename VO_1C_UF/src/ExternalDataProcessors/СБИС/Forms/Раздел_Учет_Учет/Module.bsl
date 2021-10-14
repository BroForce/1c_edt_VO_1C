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
Функция сбисПолучитьСтраницу(Элемент, ИмяСтраницы)
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		Возврат Элемент.ПодчиненныеЭлементы[ИмяСтраницы];
	КонецЕсли;
	Возврат Элемент.Страницы[ИмяСтраницы];
КонецФункции
//------------------------------------------------------
&НаКлиенте
Функция ОбновитьКонтент(Кэш) Экспорт
	Если Не ЗначениеЗаполнено(Кэш) Тогда
		Возврат Ложь;
	КонецЕсли;
		Возврат Кэш.ГлавноеОкно.ПерейтиВРаздел("АккордеонПриходныйОрдер77");	
КонецФункции
&НаКлиенте
Процедура НастроитьКолонки(Кэш) Экспорт
КонецПроцедуры
&НаКлиенте
Процедура НаСменуРаздела(Кэш) Экспорт
	// Процедура обновляет панель массовых операций, панель фильтра, контекстное меню при смене раздела	
	СписокСостояний = Новый СписокЗначений();
	СписокСостояний.Добавить("Все документы");
	СписокСостояний.Добавить("Утвержденные");
	СписокСостояний.Добавить("Черновики");
		
	ГлавноеОкно = Кэш.ГлавноеОкно;
	ГлавноеОкно.СписокСостояний = СписокСостояний;
	Если ЗначениеЗаполнено(Кэш.Парам.ФильтрыПоРазделам["Учет"]) Тогда
		Кэш.ГлавноеОкно.сбисВосстановитьФильтр(Кэш, Кэш.Парам.ФильтрыПоРазделам["Учет"]);
	Иначе
		ФильтрОчистить(Кэш);
	КонецЕсли;
	//ГлавноеОкно.ФильтрСостояние = СписокСостояний.НайтиПоИдентификатору(0).Значение;
	ГлавноеОкно.ФильтрОбновитьПанель();
	
	ГлавноеОкно.сбисУстановитьКонтекстноеМеню("Таблица_РеестрДокументов", "КонтекстноеМенюПолученные");
	ГлавноеОкно.сбисУстановитьКонтекстноеМеню("Таблица_РеестрСобытий", "КонтекстноеМенюПолученныеРеестрСобытий");
	ПанельМассовыхОпераций = сбисЭлементФормы(ГлавноеОкно,"ПанельМассовыхОпераций");
	ПанельМассовыхОпераций.ТекущаяСтраница = сбисПолучитьСтраницу(ПанельМассовыхОпераций,"Полученные");
	сбисЭлементФормы(ГлавноеОкно,"ПанельМассовыхОпераций").Видимость = Истина;//aa.uferov раздел задач
	сбисЭлементФормы(ГлавноеОкно,"ПанельТулбар").Видимость = Истина;
	сбисЭлементФормы(ГлавноеОкно,"МассовыеОперацииСопоставить2").Видимость = Ложь;
	сбисЭлементФормы(ГлавноеОкно,"МассовыеОперацииУтвердить1").Видимость = Ложь;
	сбисЭлементФормы(ГлавноеОкно,"Сохранить1").Видимость = Истина;
	
	сбисЭлементФормы(ГлавноеОкно,"ПанельФильтра").Видимость = Истина;
	сбисЭлементФормы(ГлавноеОкно,"ПоказатьПанельФильтра").Видимость = Истина;
	//  << alo_ТекущийЭтап
	сбисЭлементФормы(ГлавноеОкно,"Таблица_РеестрДокументов").ПодчиненныеЭлементы.Таблица_РеестрДокументовТекущийЭтап.Видимость = Истина;
	//  alo_ТекущийЭтап >>
КонецПроцедуры
&НаКлиенте
Процедура НавигацияУстановитьПанель(Кэш) Экспорт
	// Процедура устанавливает панель навигации на 1ую страницу	
	ГлавноеОкно = Кэш.ГлавноеОкно;
	сбисЭлементФормы(ГлавноеОкно,"ПанельНавигации").Видимость=Истина;
	сбисЭлементФормы(ГлавноеОкно,"ЗаписейНаСтранице1С").Видимость=Ложь;
	сбисЭлементФормы(ГлавноеОкно,"ЗаписейНаСтранице").Видимость=Истина;	
КонецПроцедуры	
&НаКлиенте
Функция ПодготовитьСтруктуруДокумента(СтрокаСпискаДокументов, Кэш) Экспорт
	// функция формирует структуру данных по пакету электронных документов, необходимую для его предварительного просмотра и загрузки в 1С	
	Возврат Кэш.ОбщиеФункции.ПодготовитьСтруктуруДокументаСбис(СтрокаСпискаДокументов, Кэш);
КонецФункции
&НаКлиенте
Процедура ФильтрОчистить(Кэш) Экспорт
	// Процедура устанавливает значения фильтра по-умолчанию для текущего раздела	
	ГлавноеОкно = Кэш.ГлавноеОкно;
	Если ТипЗнч(ЭтаФорма) = Тип("УправляемаяФорма") Тогда
		ГлавноеОкно.ФильтрПериод = "За весь период";
	Иначе
		ГлавноеОкно.ФильтрПериод = "0";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрОрганизация") Тогда
		ГлавноеОкно.ФильтрОрганизация = Кэш.ТипыПолейФильтра.ФильтрОрганизация.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОрганизация = "";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрКонтрагент") Тогда
		ГлавноеОкно.ФильтрКонтрагент = Кэш.ТипыПолейФильтра.ФильтрКонтрагент.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрКонтрагент = "";
	КонецЕсли;
	Если Кэш.ТипыПолейФильтра.Свойство("ФильтрОтветственный") Тогда
		ГлавноеОкно.ФильтрОтветственный = Кэш.ТипыПолейФильтра.ФильтрОтветственный.ПривестиЗначение();
	Иначе	
		ГлавноеОкно.ФильтрОтветственный = "";
	КонецЕсли;
	ГлавноеОкно.ФильтрДатаНач = "";
	ГлавноеОкно.ФильтрДатаКнц = "";
	ГлавноеОкно.ФильтрСостояние = ГлавноеОкно.СписокСостояний.НайтиПоИдентификатору(0).Значение;
	ГлавноеОкно.ФильтрКонтрагентПодключен = "";
	ГлавноеОкно.ФильтрКонтрагентСФилиалами = Ложь;
	ГлавноеОкно.ФильтрСтраница = 1;
	ГлавноеОкно.ФильтрМаска = "";
	//++ Бухов А. Фильтр по умолчанию 	
	Если Кэш.Ини.Конфигурация.Свойство("ФильтрПоУмолчанию") И  Кэш.Ини.Конфигурация.ФильтрПоУмолчанию.Свойство(Кэш.Текущий.ТипДок) Тогда 
		Попытка
			Ини = Кэш.ОбщиеФункции.ПолучитьДанныеДокумента1С(Кэш.Ини.Конфигурация.ФильтрПоУмолчанию[Кэш.Текущий.ТипДок],Неопределено,Кэш.КэшЗначенийИни, Кэш.Парам);  // alo Меркурий
			Для Каждого Элем Из Ини Цикл 
				Если нрег(Лев(Элем.Ключ, 6)) = "фильтр" Тогда
					ГлавноеОкно[Элем.Ключ] = Элем.Значение;
				КонецЕсли;
			КонецЦикла;
		Исключение
		КонецПопытки;
	КонецЕсли;
	//-- Бухов А. Фильтр по умолчанию
КонецПроцедуры