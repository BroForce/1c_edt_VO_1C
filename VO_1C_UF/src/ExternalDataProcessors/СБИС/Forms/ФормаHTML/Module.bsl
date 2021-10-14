&НаКлиенте
Перем МестныйКэш Экспорт;

//author UAA, VII

///////////////////////////////////////////////////
///////////////////////События/////////////////////
///////////////////////////////////////////////////

//При открытии документа на форме просмотра авторизуемся по токену текущей сессии обработки
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Токен = МестныйКэш.Интеграция.ПолучитьТикетДляТекущегоПользователя(МестныйКэш);
	АдресHTML = Адрес + "&ticket=" + Токен + "&nocheck=1";
КонецПроцедуры

///////////////////////////////////////////////////
///////////////////////Команды/////////////////////
///////////////////////////////////////////////////

//Запускаем выгрузку текущего документа в 1С
&НаКлиенте
Процедура ВыгрузитьВ1С(Команда)
	Отказ = Ложь;	
	Если Не ЗначениеЗаполнено(ИмяСБИС) Тогда
		Сообщить("Загрузка документов не подерживается.");
		Возврат;
	ИначеЕсли Не СбисДоступныАпи3Объекты(МестныйКэш) Тогда
		Сообщить("Загрузка документов не подерживается. Необходимо выбрать способ обмена 'API' и способ храниения настроек 'На сервере'");
		Возврат;
	КонецЕсли;
	Если ИменаСбисКАпи3.Свойство(ИмяСБИС) Тогда
		ИмяСБИС = ИменаСбисКАпи3[ИмяСБИС];
	КонецЕсли;
	Если Не (ИмяСБИС = "АвансовыйОтчет" Или ИмяСБИС = "Задача") Тогда 
		Сообщить("Загрузка данного типа документов не поддерживается.");
		Возврат;
	КонецЕсли;
		
	СтруктураСинхОбъекта = Новый Структура("Data,Type,SbisId,Id,Action", Новый Структура, ИмяСБИС, ИдСБИС, ИдСБИС, 2);
    МассивСинхОбъектов = Новый Массив;
    МассивСинхОбъектов.Добавить(СтруктураСинхОбъекта);
    СтруктураСинхДокумента = Новый Структура("ConnectionId,ExtSyncDoc,ExtSyncObj", ИдентификаторПодключения, Новый Структура("Direction", Число(0)), МассивСинхОбъектов);
	
	// Выполянем Write, Prepare на сервисе 
	ИдентификаторПосылки = МестныйКэш.Интеграция.ЗаписатьПосылкуСОбъектами(МестныйКэш, СтруктураСинхДокумента, Отказ);
	Если Отказ Тогда
		МестныйКэш.ГлавноеОкно.СбисСообщитьОбОшибке(МестныйКэш, ИдентификаторПосылки);
		Возврат;
	КонецЕсли;
	
	РезультатПодготовки = МестныйКэш.Интеграция.ПодготовитьПосылкуСОбъектами(МестныйКэш, ИдентификаторПосылки, Отказ);
	Если Отказ Тогда
		МестныйКэш.ГлавноеОкно.СбисСообщитьОбОшибке(МестныйКэш, РезультатПодготовки);
		Возврат;
	КонецЕсли;
	
    РезультатЗагрузки = ЗагрузитьПосылку(МестныйКэш, ИдентификаторПосылки, Отказ);
	Если Отказ Тогда
		МестныйКэш.ГлавноеОкно.СбисСообщитьОбОшибке(МестныйКэш, РезультатЗагрузки);
		Возврат;
	КонецЕсли;
	Для Каждого ОбъектСОшибкой Из РезультатЗагрузки.Ошибки Цикл
		СтруктураОшибки = ОбъектСОшибкой.Data.error;
		Если СтруктураОшибки.code = 610 Тогда 
			Сообщить("Загрузка документов " + ОбъектСОшибкой.Data.data.ИмяСБИС + " не подерживается");
		Иначе	
			Сообщить(СтруктураОшибки.message + ": " + СтруктураОшибки.details);
		КонецЕсли;
	КонецЦикла;
	ЗаполнитьСсылкуДокумента1С(МестныйКэш);
	Если РезультатЗагрузки.Ошибки.Количество() Тогда
		Сообщить("Загрузка завершена с ошибками");
	Иначе
		Сообщить("Загрузка завершена успешно. Обработано " + РезультатЗагрузки.Успешно.Количество() + " объектов");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьВСБИС(Команда)
	Если Не СбисДоступныАпи3Объекты(МестныйКэш) Тогда
		Сообщить("Загрузка документов не подерживается. Необходимо выбрать способ обмена 'API' и способ храниения настроек 'На сервере'");
		Возврат;
	КонецЕсли;
	Если ДокументСсылка = Неопределено Тогда
		Сообщить("Отсутствует связанный документ 1С");
		Возврат;
	КонецЕсли;
	Если ИменаСбисКАпи3.Свойство(ИмяСБИС) Тогда
		ИмяСБИС = ИменаСбисКАпи3[ИмяСБИС];
	КонецЕсли;
	Если ИмяСБИС <> "АвансовыйОтчет" Тогда 
		Сообщить("Выгрузка данного типа документов не поддерживается.");
		Возврат;
	КонецЕсли;
	
	Отказ = Ложь;	
	ПараметрыЗагрузки = Новый Структура("Ссылка, ИмяСБИС, ИдСБИС", ДокументСсылка, ИмяСБИС, ИдСБИС);
	РезультатЗагрузки = ВыполнитьЗагрузкуВСБИС(МестныйКэш, ПараметрыЗагрузки, Отказ);
	Если Отказ Тогда
		Сообщить("Выгрузка завершено с ошибками");
		МестныйКэш.ГлавноеОкно.СбисСообщитьОбОшибке(МестныйКэш, РезультатЗагрузки);
	КонецЕсли;
	ВыполнитьОбновлениеОтображения(МестныйКэш);
КонецПроцедуры

//Обновление страницы с документом на форме.
&НаКлиенте
Процедура ОбновитьСтраницу(Команда)
	ВыполнитьОбновлениеОтображения(МестныйКэш);
КонецПроцедуры

//Открытие ранее загруженного документа в 1С 	
&НаКлиенте
Процедура ОткрытьВ1С(Команда)
	Если ДокументСсылка = Неопределено Тогда
		Сообщить("Отсутствует связанный документ 1С");
		Возврат;
	КонецЕсли;
	МестныйКэш.ГлавноеОкно.СбисПоказатьЗначение(МестныйКэш, ДокументСсылка); 
КонецПроцедуры

///////////////////////////////////////////////////
///////////////////////Вызовы//////////////////////
///////////////////////////////////////////////////

//Делает обновление страницы
&НаКлиенте
Процедура ВыполнитьОбновлениеОтображения(Кэш)
	Если АдресHTML = Адрес + "&nocheck=1" Тогда
		АдресHTML = Адрес + "&nocheck=1&a=1"
	Иначе
		АдресHTML = Адрес + "&nocheck=1";
	КонецЕсли
КонецПроцедуры

//Делает загрузку в СБИС по параметрам
&НаКлиенте
Функция ВыполнитьЗагрузкуВСБИС(Кэш, ПараметрыЗагрузки, Отказ)
	СтруктураДокумента = Кэш.Интеграция.ПрочитатьАПИОбъектСБИС(Кэш, ПараметрыЗагрузки.ИдСБИС, ПараметрыЗагрузки.ИмяСБИС, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(СтруктураДокумента, "ФормаHTML.ВыполнитьЗагрузкуВСБИС");	
	КонецЕсли;
	
	СтруктураОбъекта = Кэш.ОбщиеФункции.СбисПолучитьСтруктуруОбъекта1С(ПараметрыЗагрузки.Ссылка, СтруктураДокумента, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(СтруктураОбъекта, "ФормаHTML.ВыполнитьЗагрузкуВСБИС");	
	КонецЕсли;
	
	РезультатОбновления = Кэш.Интеграция.ОбновитьОбъектСБИСИзОбъекта1С(Кэш, СтруктураОбъекта, Кэш.Парам.ИдентификаторНастроек, Отказ);
	Если Отказ Тогда
	    РезультатОбновления = Кэш.ОбщиеФункции.СбисИсключение(РезультатОбновления, "ФормаHTML.ВыполнитьЗагрузкуВСБИС");	
	КонецЕсли;
	Возврат РезультатОбновления;
КонецФункции

//Получение объектов для загрузку в 1С, загрузка в 1С.
&НаКлиенте
Функция ЗагрузитьАПИ3Объект(Кэш, СтруктураОбъекта, ИдентификаторПосылки, Отказ)
	Перем ИмяИни;
	ИмяОбъекта = СтруктураОбъекта.ИмяСБИС;
	ОбъектыСинх = Новый Структура();
	ОбъектыСинх.Вставить("ЧастноеЛицо", "СинхЗагрузка_ЧастноеЛицо");
	ОбъектыСинх.Вставить("АвансовыйОтчет", "СинхЗагрузка_АвансовыйОтчет");
	ОбъектыСинх.Вставить("Договор", "СинхЗагрузка_Договор");
	ОбъектыСинх.Вставить("ЕдиницаИзмерения", "СинхЗагрузка_ЕдиницаИзмерения");
	ОбъектыСинх.Вставить("Контрагент", "СинхЗагрузка_Контрагент");
	ОбъектыСинх.Вставить("Номенклатура", "СинхЗагрузка_Номенклатура");
	ОбъектыСинх.Вставить("Склад", "СинхЗагрузка_Склад");
	ОбъектыСинх.Вставить("Задача", "СинхЗагрузка_Задача");
	
	ОбъектыСинх.Свойство(ИмяОбъекта, ИмяИни);	
	//СписокОбъектовСинхронизации = Кэш.ФормаНастроек.Ини(Кэш, "ОбъектыСинх");
	//Для Каждого Элемент Из СписокОбъектовСинхронизации.Объекты Цикл
	//	Если Элемент.Имя = ИмяОбъекта Тогда
	//		Если Элемент.Свойство("Загрузка") Тогда
	//			Если Элемент.Загрузка.Количество() > 0 Тогда
	//				ИмяИни = Элемент.Загрузка[0];
	//			КонецЕсли;
	//		КонецЕсли;
	//		Прервать;
	//	КонецЕсли;
	//КонецЦикла;
	Если ИмяИни = Неопределено Тогда
		Отказ = Истина;
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗагрузитьАПИ3Объект", 610, "Отсутствует файл настроек для данного типа данных", "Не найден ини файл для загрузки объекта " + ИмяОбъекта);	
	КонецЕсли;
	
	ОбъектыНаЗапись = МестныйКэш.Интеграция.РассчитатьОбъектыНаЗапись(МестныйКэш, СтруктураОбъекта, ИдентификаторПосылки, ИмяИни, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(ОбъектыНаЗапись, "ФормаHTML.ЗагрузитьАПИ3Объект");	
	КонецЕсли;

	СписокРезультат = Новый Массив;
	Для Каждого ОбъектНаЗапись Из ОбъектыНаЗапись Цикл
		Результат = ЗаписатьАПИ3ОбъектВ1С(МестныйКэш, ОбъектНаЗапись.Значение, СтруктураОбъекта, ИмяИни, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.СбисИсключение(Результат, "ФормаHTML.ЗагрузитьАПИ3Объект");	
		КонецЕсли;
		СписокРезультат.Добавить(Результат);
		Если ИмяОбъекта = ИмяСБИС Тогда
			СтруктураСвойств = Новый Структура("ДокументСБИС_Ид,ДокументСБИС_ИдВложения,ДокументСБИС_Статус", УИдСБИС, УИдСБИС, "");
	        фрм = МестныйКэш.ГлавноеОкно.сбисНайтиФормуФункции("ЗаписатьПараметрыДокументаСБИС",Кэш.ФормаРаботыСоСтатусами,"",МестныйКэш);
	        фрм.ЗаписатьПараметрыДокументаСБИС(СтруктураСвойств, Результат.Ссылка, МестныйКэш.Ини.Конфигурация, МестныйКэш.ГлавноеОкно.КаталогНастроек);
		КонецЕсли;
	КонецЦикла;
	Возврат СписокРезультат;
КонецФункции

//Создание объектов в учетной системе на основании структуры объекта (с идентификаторами)
// СтруктураОбъекта - Структура, соответствующая загружаемому объекту, с определением типов данных.
// АПИ3Объект - Полученные данные объекта
// ТипИмяОбъекта - имя типа объекта
// ИмяИни - Имя ИНИ по которой рассчитывается объект
&НаКлиенте
Функция ЗаписатьАПИ3ОбъектВ1С(Кэш, СтруктураОбъекта, АПИ3Объект, ИмяИни, Отказ)
	Перем ТипИмяОбъекта;
	Если Не	(	(	СтруктураОбъекта.Свойство("Идентификатор")
				И	СтруктураОбъекта.Идентификатор.Свойство("Объект", ТипИмяОбъекта)) 
			Или	(	СтруктураОбъекта.Свойство("Ref")
				И	СтруктураОбъекта.Ref.Свойство("Объект", ТипИмяОбъекта))) Тогда
		Отказ = Истина;                 
		СбисДамп = Новый Структура("ИмяИни, АПИ3Объект", ИмяИни, АПИ3Объект);
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С", 780, , "В структуре АПИ3 объекта отсутствуют данные для идентификации", СбисДамп);	
	КонецЕсли;
	
	ТипыСинхИни = Новый Массив;
	ТипыСинхИни.Добавить("СинхВыгрузка");
	ТипыСинхИни.Добавить("СинхЗагрузка");
	ЗначениеИниФайла = Кэш.ФормаНастроек.Ини(Кэш, ИмяИни, Новый Структура("ДоступныеТипыИни", ТипыСинхИни),Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(ЗначениеИниФайла, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С");	
	КонецЕсли;
	
	ПараметрыОбработкиАпи3Объекта = Новый Структура("Тип, СтруктураОбъекта", ТипИмяОбъекта, СтруктураОбъекта);
	Если АПИ3Объект.Свойство("ИдИС") Тогда
		ПараметрыОбработкиАпи3Объекта.Вставить("Идентификатор", АПИ3Объект.ИдИС);
	КонецЕсли;
	Если ЗначениеИниФайла.Свойство("Ключи") Тогда
		//Чтобы не отдавать всю ини на сервер, забираем только узел с ключами если есть такое
		ПараметрыОбработкиАпи3Объекта.Вставить("Ключи", ЗначениеИниФайла.Ключи);
	КонецЕсли;
	ДанныеОбъекта1С = Кэш.ОбщиеФункции.ВыполнитьОбработкуАпи3Объекта(Кэш, ПараметрыОбработкиАпи3Объекта, Отказ);
	Если Отказ Тогда
	    Возврат Кэш.ОбщиеФункции.СбисИсключение(ДанныеОбъекта1С, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С");	
	КонецЕсли;
		
	Если ДанныеОбъекта1С.Свойство("ДанныеМаппинга") Тогда
		Фильтр = Новый Структура("Type,Id,IdType,ConnectionId", АПИ3Объект.ИмяСБИС, АПИ3Объект.ИдСБИС, 1, ИдентификаторПодключения);
		РезультатОбновленияСопоставления = МестныйКэш.Интеграция.ОбновитьЗаписьСопоставления(МестныйКэш, Фильтр, ДанныеОбъекта1С.ДанныеМаппинга, Отказ);
		Если Отказ Тогда
	   		Возврат Кэш.ОбщиеФункции.СбисИсключение(РезультатОбновленияСопоставления, "ФормаHTML.ЗаписатьАПИ3ОбъектВ1С");	
		КонецЕсли;
	КонецЕсли;
	Возврат ДанныеОбъекта1С;
КонецФункции

//Загружает посылку в 1С по идентификатору. В случае успешной/частично успешной загрузки структура с полями Ошибки,Успешно.
&НаКлиенте
Функция ЗагрузитьПосылку(Кэш, ИдентификаторПосылки, Отказ)
	Перем СтруктураАпи3Объекта;
	Результат = Новый Структура("Ошибки,Успешно",Новый Массив, Новый Массив);
	Для СбисСчетчик = 0 По 100 Цикл
        ОбъектНаЗагрузку = Кэш.Интеграция.ПолучитьОбъектНаЗагрузку(Кэш, ИдентификаторПосылки, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.СбисИсключение(ОбъектНаЗагрузку, "ФормаHTML.ЗагрузитьПосылку");
		ИначеЕсли Не ЗначениеЗаполнено(ОбъектНаЗагрузку) Тогда
			//Кончились объекты, прервать
			Прервать;
		КонецЕсли;
	
		ОшибкаЗагрузкиОбъекта = Ложь;
		Если		Не ОбъектНаЗагрузку.Свойство("Data", СтруктураАпи3Объекта) Тогда
			ОшибкаЗагрузкиОбъекта = Истина;
			ОбъектНаЗагрузку.Вставить("Data", Новый Структура);
			СбисСтруктураОшибки = Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗагрузитьПосылку", 779,,"Не удалось получить даные объекта");
		ИначеЕсли	Не СтруктураАпи3Объекта.Свойство("data", СтруктураАпи3Объекта) Тогда
			ОшибкаЗагрузкиОбъекта = Истина;
			СбисСтруктураОшибки = Кэш.ОбщиеФункции.СбисИсключение(, "ФормаHTML.ЗагрузитьПосылку", 779,,"Не удалось получить даные объекта");
		Иначе
			РезультатЗагрузки = ЗагрузитьАПИ3Объект(Кэш, СтруктураАпи3Объекта, ИдентификаторПосылки, ОшибкаЗагрузкиОбъекта);
			Если ОшибкаЗагрузкиОбъекта Тогда
				СбисСтруктураОшибки = Кэш.ОбщиеФункции.СбисИсключение(РезультатЗагрузки, "ФормаHTML.ЗагрузитьПосылку");
			КонецЕсли;
		КонецЕсли;
		
		Если ОшибкаЗагрузкиОбъекта Тогда
			ОбъектНаЗагрузку.Вставить("StatusId", "Ошибка");
			ОбъектНаЗагрузку.Вставить("StatusMsg", Новый Массив);
			ТекстОшибки = "Ошибка загрузки объекта";
			ИндексНачалаСообщения = СтрНайти(СбисСтруктураОшибки.details, "Объект");
			ИндексКонцаСообщения  = СтрНайти(СбисСтруктураОшибки.details, "не сопоставлен");
			Если ИндексНачалаСообщения > 0 И ИндексКонцаСообщения > 0 Тогда
				ТекстОшибки = Сред(СбисСтруктураОшибки.details, ИндексНачалаСообщения, ИндексКонцаСообщения - ИндексНачалаСообщения +14);
			ИначеЕсли СтрНайти(СбисСтруктураОшибки.details, "не уникально") > 0 Тогда
				ТекстОшибки = СбисСтруктураОшибки.details;
			КонецЕсли;
			ОбъектНаЗагрузку.StatusMsg.Добавить("Ошибка загрузки объекта. " + СбисСтруктураОшибки.details);
			ОбъектНаЗагрузку.Data.Вставить("error", СбисСтруктураОшибки);
			Результат.Ошибки.Добавить(ОбъектНаЗагрузку);
		Иначе
			ОбъектНаЗагрузку.Вставить("StatusId", "Синхронизирован");
			Результат.Успешно.Добавить(ОбъектНаЗагрузку);
		КонецЕсли;			
	
		МассивОбъектовСинхронизации = Новый Массив;
		МассивОбъектовСинхронизации.Добавить(ОбъектНаЗагрузку);
		СтруктураСинхДокумента = Новый Структура("ConnectionId,ExtSyncDoc,ExtSyncObj", ИдентификаторПодключения, Новый Структура("Uuid", ИдентификаторПосылки), МассивОбъектовСинхронизации);
		ИдентификаторПосылки = МестныйКэш.Интеграция.ЗаписатьПосылкуСОбъектами(МестныйКэш, СтруктураСинхДокумента, Отказ);
		Если Отказ Тогда
			Возврат Кэш.ОбщиеФункции.СбисИсключение(ИдентификаторПосылки, "ФормаHTML.ЗагрузитьПосылку");
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

//Процедура открывает форму просмотра пакета документов	
&НаКлиенте
Процедура ПоказатьДокументОнлайн(Кэш, ВебАдрес, Пакет) Экспорт
	МестныйКэш = Кэш;
	ИдентификаторПодключения = МестныйКэш.Парам.ИдентификаторНастроек;
	УИдСБИС = Пакет.Идентификатор;
	Пакет.Свойство("ИдСБИС", ИдСБИС);
	Пакет.Свойство("ИмяСБИС", ИмяСБИС);
	Адрес = СтрЗаменить(СтрЗаменить(ВебАдрес, "6343037#", ""), "4490677#", "");
	ИменаСбисКАпи3 = Новый Структура("ДоговорДок,ДокОтгрВх,ДокОтгрИсх,ВнутрПрм,АвансОтчет", "Договор", "Поступление", "Реализация", "ВнутреннееПеремещение", "АвансовыйОтчет");
	ЗаполнитьСсылкуДокумента1С(Кэш);
	Если Пакет.Свойство("Название") Тогда
		Заголовок = Пакет.Название;
	Иначе
		Заголовок = Адрес;
	КонецЕсли;
	ЭтаФорма.Открыть();	
КонецПроцедуры

//Находим ссылку на документ 1С по иденитфикатору пакета	
&НаКлиенте
Процедура ЗаполнитьСсылкуДокумента1С(Кэш) Экспорт
	фрм = Кэш.ГлавноеОкно.СбисНайтиФормуФункции("ДокументыПоИдПакета", Кэш.ФормаРаботыСоСтатусами,"",Кэш);
	МассивСсылок = фрм.ДокументыПоИдПакета(УИдСБИС, Кэш.Ини.Конфигурация);
	ДокументСсылка = Неопределено;
	Если МассивСсылок.Количество() = 1 Тогда
		ДокументСсылка = МассивСсылок[0];
	ИначеЕсли МассивСсылок.Количество() > 1 Тогда
		СтруктураСвойств = Новый Структура("ДокументСБИС_Ид,ДокументСБИС_ИдВложения,ДокументСБИС_Статус", УИдСБИС, УИдСБИС, "");
		фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ЗаписатьПараметрыДокументаСБИС",Кэш.ФормаРаботыСоСтатусами,"",Кэш);
		Для Каждого ОбъектСсылка из МассивСсылок Цикл
			фрм.ЗаписатьПараметрыДокументаСБИС(СтруктураСвойств, ОбъектСсылка, Кэш.Ини.Конфигурация, Кэш.ГлавноеОкно.КаталогНастроек);
		КонецЦикла;
	КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Функция СбисДоступныАпи3Объекты(Кэш)
	Возврат МестныйКэш.Парам.СпособХраненияНастроек = 1
		И	МестныйКэш.Парам.СпособОбмена = 3;
КонецФункции
