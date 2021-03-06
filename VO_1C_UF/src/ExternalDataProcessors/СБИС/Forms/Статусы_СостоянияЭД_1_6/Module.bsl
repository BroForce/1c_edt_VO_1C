//Форма исключительно для УФ

&НаСервереБезКонтекста
Процедура ЗаписатьИзмененияПоДокументам1С(МассивДокументов, Ини, КаталогНастроек) Экспорт
	// дублирует статусы по идентификаторам пакетов при получении списка изменений
	Для Каждого СоставПакета Из МассивДокументов Цикл
		Если СоставПакета.Свойство("Документы1С") Тогда  
			Для Каждого Строка Из СоставПакета.Документы1С Цикл
				ДублироватьСостояние(СоставПакета, Строка.значение);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗаписатьПараметрыДокументовСБИС(ДанныеПоСтатусам,Ини,КаталогНастроек) Экспорт
	// добавляет свойства для документа 1С (при сопоставлении и загрузке документов)	
	Для Каждого Элемент Из ДанныеПоСтатусам Цикл
		СоставПакета=новый структура("Состояние",новый структура());
		СоставПакета.Состояние.вставить("Название",Элемент.СтруктураСвойств.ДокументСБИС_Статус);
		СоставПакета.вставить("Идентификатор", 	Элемент.СтруктураСвойств.ДокументСБИС_Ид);
		ДублироватьСостояние(СоставПакета, Элемент.Документ1С);
	КонецЦикла;
КонецФункции

&НаСервереБезКонтекста
функция ДублироватьСостояние(СоставПакета, ДокСсылка, XMLДокумента=неопределено, СтруктураФайла=неопределено) экспорт
	ПараметрыЭД = Новый Структура("ВидЭД,НаправлениеЭД,Организация,Контрагент,ДоговорКонтрагента,СоглашениеЭД,Партнер");
	ОбменСКонтрагентамиПереопределяемый.ЗаполнитьПараметрыЭДПоИсточнику(ДокСсылка, ПараметрыЭД, Истина); // будут обработаны только те документы, которые поддерживает конфигурация
	
	если значениеЗаполнено(ПараметрыЭД.Организация) И значениеЗаполнено(ПараметрыЭД.Контрагент)тогда
		ИдентификаторОрганизации= ПараметрыЭД.Организация.ИНН+"_"+ПараметрыЭД.Организация.КПП;
		ИдентификаторКонтрагента= ПараметрыЭД.Контрагент.ИНН+"_"+ПараметрыЭД.Контрагент.КПП;
		СпособОбменаЭД= Перечисления.СпособыОбменаЭД.ЧерезЭлектроннуюПочту;
		// проверить наличия приглашения
		Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	ПриглашенияКОбменуЭлектроннымиДокументами.Наименование КАК Наименование
	                      |ИЗ
	                      |	РегистрСведений.ПриглашенияКОбменуЭлектроннымиДокументами КАК ПриглашенияКОбменуЭлектроннымиДокументами
	                      |ГДЕ
	                      |	ПриглашенияКОбменуЭлектроннымиДокументами.ИдентификаторОрганизации = &ИдентификаторОрганизации
	                      |	И ПриглашенияКОбменуЭлектроннымиДокументами.Контрагент = &Контрагент
	                      |	И ПриглашенияКОбменуЭлектроннымиДокументами.Статус = &Статус");
	
		Запрос.УстановитьПараметр("Контрагент", ПараметрыЭД.Контрагент);
		Запрос.УстановитьПараметр("ИдентификаторОрганизации", ИдентификаторОрганизации);
		Запрос.УстановитьПараметр("Статус", Перечисления.СтатусыПриглашений.Принято);
		ТаблицаПриглашений = Запрос.Выполнить().Выгрузить();
		Если ТаблицаПриглашений.Количество() = 0 Тогда	// создать приглашение
			Набор = РегистрыСведений.УчетныеЗаписиЭДО.СоздатьНаборЗаписей();
			Набор.Отбор.ИдентификаторЭДО.Установить(ИдентификаторОрганизации);
			Набор.Прочитать();
			Если Не ЗначениеЗаполнено(Набор) Тогда
				Запись = Набор.Добавить();
				Запись.ИдентификаторЭДО = ИдентификаторОрганизации;
				Запись.Организация = ПараметрыЭД.Организация;
				Запись.СпособОбменаЭД = СпособОбменаЭД;
				Запись.ОператорЭДО                    = "2BE";
				Запись.НаименованиеУчетнойЗаписи      = "СБИС";
				//Запись.НазначениеУчетнойЗаписи        = СтрокаОператора.НазначениеУчетнойЗаписи;
				//Запись.ПодробноеОписаниеУчетнойЗаписи = СтрокаОператора.ПодробноеОписаниеУчетнойЗаписи;
				Запись.ПринятыУсловияИспользования    = "Истина";
				Набор.Записать();
			Конецесли;
			ТаблицаПриглашений = ИнициализироватьТаблицуДанныхУчастниковОбмена();

			приглашение=ТаблицаПриглашений.Добавить();
			приглашение.ИдентификаторОрганизации=	ИдентификаторОрганизации;
			приглашение.Контрагент	= ПараметрыЭД.Контрагент;
			приглашение.Наименование= ПараметрыЭД.Контрагент.наименование;
			приглашение.ИНН=  ПараметрыЭД.Контрагент.ИНН;
			приглашение.КПП=  ПараметрыЭД.Контрагент.КПП;
			приглашение.Идентификатор= 	ИдентификаторКонтрагента;
			приглашение.ТекстПриглашения= "СБИС";
			приглашение.Состояние= Перечисления.СтатусыПриглашений.Принято;
			приглашение.ОписаниеОшибки="";
			приглашение.Изменен=ТекущаяДата();
			приглашение.ВнешнийИД= "СБИС";
	
			Выполнить("ОбменСКонтрагентамиСлужебный.СохранитьПриглашения(ТаблицаПриглашений)");
		конецесли;
		НастройкиЭД=ложь;
		// << alo входящий
		СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.НеСформирован;
		ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
		ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
		ОпределитьСостояние(СоставПакета.Состояние.Название, ДокСсылка, СостояниеВерсииЭД, ДействияСНашейСтороны, ДействияСоСтороныДругогоУчастника);
		
		Если СоставПакета.Свойство("Направление") И СоставПакета.Направление =  "Входящий" Тогда
			СсылкаНаВладельца = СоздатьЭлектронныйДокумент(ДокСсылка, СоставПакета, СпособОбменаЭД,
				ПараметрыЭД.Организация, ПараметрыЭД.Контрагент, ИдентификаторОрганизации, ИдентификаторКонтрагента, 
				СостояниеВерсииЭД, XMLДокумента);
		Иначе
			СсылкаНаВладельца = ДокСсылка;
		Конецесли;
		ОпределитьДействующуюНастройкуЭДО = Ложь;
		Выполнить("ОпределитьДействующуюНастройкуЭДО = ОбменСКонтрагентамиСлужебный.ОпределитьДействующуюНастройкуЭДО(СсылкаНаВладельца, НастройкиЭД, Неопределено, Истина)");
		Если не ОпределитьДействующуюНастройкуЭДО  тогда
		// alo входящий >>
			возврат ложь;
		КонецЕсли;
	
		если значениеЗаполнено(НастройкиЭД) тогда
			НаборЗаписей = РегистрыСведений.СостоянияЭД.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.СсылкаНаОбъект.Установить(ДокСсылка);
			НаборЗаписей.Прочитать();
			если НаборЗаписей.Количество()>0 тогда
				НоваяЗаписьНабора = НаборЗаписей.Получить(0);
			иначе
				НоваяЗаписьНабора = НаборЗаписей.Добавить();
				НоваяЗаписьНабора.СсылкаНаОбъект=ДокСсылка;
			конецесли;
			НоваяЗаписьНабора.ДействияСНашейСтороны = ДействияСНашейСтороны;
			НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = ДействияСоСтороныДругогоУчастника;
			НоваяЗаписьНабора.ЭлектронныйДокумент = СсылкаНаВладельца;
			НоваяЗаписьНабора.СостояниеВерсииЭД = СостояниеВерсииЭД;
			попытка
				НаборЗаписей.Записать();
			исключение // Возможно по данному типу документа не предусмотрено ведение состояниеЭД
				Сообщить(ОписаниеОшибки());
			конецпопытки;
		конецесли;
	конецесли;
конецфункции

&НаСервереБезКонтекста       
Функция ИнициализироватьТаблицуДанныхУчастниковОбмена()
	
	КС12 = Новый КвалификаторыСтроки(12);
	КС255 = Новый КвалификаторыСтроки(255);
	КС1024 = Новый КвалификаторыСтроки(1024);
	КД = Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя);
	
	Массив = Новый Массив;
	Массив.Добавить(Тип("Строка"));
	
	ОписаниеТиповС12 = Новый ОписаниеТипов(Массив, , КС12);
	ОписаниеТиповС255 = Новый ОписаниеТипов("Строка", , КС255);
	ОписаниеТиповС1024 = Новый ОписаниеТипов("Строка", , КС1024);
	ОписаниеТиповДата = Новый ОписаниеТипов("Дата", , , КД);
	ОписаниеТиповСтатусыУчастников = Новый ОписаниеТипов("ПеречислениеСсылка.СтатусыПриглашений");
	ОписаниеТиповКонтрагент = Новый ОписаниеТипов("СправочникССылка.Контрагенты");
	
	ТЗ = Новый ТаблицаЗначений;
	ТЗ.Колонки.Добавить("ИдентификаторОрганизации", ОписаниеТиповС255);
	ТЗ.Колонки.Добавить("Контрагент",	ОписаниеТиповКонтрагент);
	ТЗ.Колонки.Добавить("Наименование",  ОписаниеТиповС255);
	ТЗ.Колонки.Добавить("ИНН",           ОписаниеТиповС12);
	ТЗ.Колонки.Добавить("КПП",           ОписаниеТиповС255);
	ТЗ.Колонки.Добавить("Идентификатор", ОписаниеТиповС255);
	ТЗ.Колонки.Добавить("ТекстПриглашения", ОписаниеТиповС1024);
	ТЗ.Колонки.Добавить("Состояние",     ОписаниеТиповСтатусыУчастников);
	ТЗ.Колонки.Добавить("ОписаниеОшибки",ОписаниеТиповС255);
	ТЗ.Колонки.Добавить("Изменен",       ОписаниеТиповДата);
	ТЗ.Колонки.Добавить("ВнешнийИД",     ОписаниеТиповС255);
	
	Возврат ТЗ;
	
КонецФункции

//&НаСервереБезКонтекста
//функция определитьВидЭД(Источник) Экспорт
//	ТипИсточника = ТипЗнч(Источник);
//	Попытка
//		Если ТипИсточника = Тип("ДокументСсылка.ПоступлениеТоваровУслуг") или ТипИсточника = Тип("ДокументОбъект.ПоступлениеТоваровУслуг") Тогда
//			возврат Перечисления.ВидыЭД.ТОРГ12Покупатель;
//		Конецесли;
//	Исключение
//	КонецПопытки;
//	Попытка
//		Если ТипИсточника = Тип("ДокументСсылка.ПриобретениеТоваровУслуг") или ТипИсточника = Тип("ДокументОбъект.ПриобретениеТоваровУслуг") Тогда
//			возврат Перечисления.ВидыЭД.ТОРГ12Покупатель;
//		Конецесли;
//	Исключение
//	КонецПопытки;
//	Попытка
//		Если ТипИсточника = Тип("ДокументСсылка.СчетНаОплатуПокупателю")или ТипИсточника = Тип("ДокументОбъект.СчетНаОплатуПокупателю") Тогда
//			возврат Перечисления.ВидыЭД.СчетНаОплату;
//		Конецесли;
//	Исключение
//	КонецПопытки;
//	Попытка
//		Если ТипИсточника = Тип("ДокументСсылка.СчетНаОплатуПокупателю")или ТипИсточника = Тип("ДокументОбъект.СчетНаОплатуПокупателю") Тогда
//			возврат Перечисления.ВидыЭД.СчетНаОплату;
//		Конецесли;
//	Исключение
//	КонецПопытки;
//	ИначеЕсли ТипИсточника = Тип("ДокументСсылка.СчетНаОплатуПоставщика") или ТипИсточника = Тип("ДокументОбъект.СчетНаОплатуПоставщика") Тогда
//		возврат Перечисления.ВидыЭД.СчетНаОплату;
//	ИначеЕсли ТипИсточника = Тип("ДокументСсылка.РеализацияТоваровУслуг") или ТипИсточника = Тип("ДокументОбъект.РеализацияТоваровУслуг") Тогда
//		возврат Перечисления.ВидыЭД.ТОРГ12;
//	ИначеЕсли ТипИсточника = Тип("ДокументСсылка.СчетФактураВыданный") или ТипИсточника = Тип("ДокументОбъект.СчетФактураВыданный") Тогда
////		Если ЭтоКорректировочныйДокумент(Источник) Тогда
////			ПараметрыЭД.ВидЭД = Перечисления.ВидыЭД.КорректировочныйСчетФактура;
////		Иначе
//		возврат Перечисления.ВидыЭД.СчетФактура;
////		КонецЕсли;
//	ИначеЕсли ТипИсточника = Тип("ДокументСсылка.СчетФактураПолученный") или ТипИсточника = Тип("ДокументОбъект.СчетФактураПолученный") Тогда
////		Если ЭлектронноеВзаимодействиеБП.ЭтоКорректировочныйДокумент(Источник) Тогда
////			ПараметрыЭД.ВидЭД = Перечисления.ВидыЭД.КорректировочныйСчетФактура;
////		Иначе
//		возврат Перечисления.ВидыЭД.СчетФактура;
////		КонецЕсли;
//	ИначеЕсли ТипИсточника = Тип("ДокументСсылка.КорректировкаРеализации") или ТипИсточника = Тип("ДокументОбъект.КорректировкаРеализации") Тогда
//		попытка
//			ВидДКР=	Вычислить("ЭлектронноеВзаимодействиеБП.ВидЭлектронногоДокументаКорректировки(Источник)"); // Бух 3
//		исключение
//			попытка
//				ВидДКР=Перечисления.ВидыЭД.СоглашениеОбИзмененииСтоимостиОтправитель;
//			исключение
//				ВидДКР=Перечисления.ВидыЭД.ТОРГ12Продавец;
//			конецпопытки;
//		конецпопытки;
//		возврат ВидДКР;
//	ИначеЕсли ТипИсточника = Тип("ДокументСсылка.ОтчетКомитентуОПродажах") или ТипИсточника = Тип("ДокументОбъект.ОтчетКомитентуОПродажах") 
//				или ТипИсточника = Тип("ДокументСсылка.ОтчетКомиссионераОПродажах") или ТипИсточника = Тип("ДокументОбъект.ОтчетКомиссионераОПродажах") Тогда
//		возврат Перечисления.ВидыЭД.ОтчетОПродажахКомиссионногоТовара;
//	КонецЕсли;
//Конецфункции
&НаСервереБезКонтекста
Функция СоздатьЭлектронныйДокумент(ДокСсылка, СоставПакета, СпособОбменаЭД,
				Организация, Контрагент, ИдентификаторОрганизации, ИдентификаторКонтрагента, СостояниеВерсииЭД,
				XMLДокумента) экспорт
	запрос=новый запрос("ВЫБРАТЬ
	                    |	ЭД.Ссылка КАК Ссылка
	                    |ИЗ
	                    |	Документ.ЭлектронныйДокументВходящий КАК ЭД
	                    |ГДЕ
	                    |	ЭД.УникальныйИД = &УникальныйИД
						|	И ЭД.ДокументыОснования.ДокументОснование = &ДокументОснование");
	запрос.Параметры.Вставить("УникальныйИД", СоставПакета.Идентификатор);
	запрос.Параметры.Вставить("ДокументОснование", ДокСсылка);
	результат=запрос.Выполнить().Выбрать();
	если результат.Следующий() тогда
		СсылкаНаВладельца =  результат.ссылка;
	иначе	//	ОбменСКонтрагентамиСлужебный.СоздатьЭлектронныйДокумент(СтруктураЭД);
		НовыйЭлектронныйДокумент = Документы.ЭлектронныйДокументВходящий.СоздатьДокумент();
		НовыйЭлектронныйДокумент.Организация= Организация;
		НовыйЭлектронныйДокумент.Контрагент= Контрагент;
		НовыйЭлектронныйДокумент.ИдентификаторКонтрагента = ИдентификаторКонтрагента;
		НовыйЭлектронныйДокумент.ИдентификаторОрганизации = ИдентификаторОрганизации;
		НовыйЭлектронныйДокумент.СпособОбменаЭД           = СпособОбменаЭД;
		НовыйЭлектронныйДокумент.ВидЭД = Перечисления.ВидыЭД.ПроизвольныйЭД; //определитьВидЭД(ДокСсылка);
//			ЭлектронныйДокумент.ВерсияРегламентаЭДО = НастройкиЭД.ВерсияРегламентаЭДО;
		НовыйЭлектронныйДокумент.ДатаДокументаОтправителя= ?(СоставПакета.свойство("Дата"),СоставПакета.Дата,ДокСсылка.Дата); //- дата электронного документа в информационной базе отправителя.
		НовыйЭлектронныйДокумент.НомерДокументаОтправителя = ?(СоставПакета.свойство("Номер"),СоставПакета.Номер,ДокСсылка.Номер); // номер электронного документа в информационной базе отправителя.
		НовыйЭлектронныйДокумент.Дата= НовыйЭлектронныйДокумент.ДатаДокументаОтправителя;
		НовыйЭлектронныйДокумент.УникальныйИД	= СоставПакета.Идентификатор;
		НовыйЭлектронныйДокумент.Комментарий= ?(СоставПакета.свойство("Название"),СоставПакета.Название,"");
		Ответственный = ПараметрыСеанса.ТекущийПользователь;
		Попытка
			ОбменСКонтрагентамиПереопределяемый.ПолучитьОтветственногоПоЭД(Контрагент, Организация, неопределено, Ответственный);
		Исключение
		КонецПопытки;	
		НовыйЭлектронныйДокумент.Ответственный= Ответственный; // хорошо бы взять из СоставПакета.Ответственный
		если СоставПакета.свойство("Примечание") тогда
			НовыйЭлектронныйДокумент.Текст	= СоставПакета.Примечание;
			НовыйЭлектронныйДокумент.Комментарий= СоставПакета.Примечание;
		конецесли;
		если СоставПакета.Состояние.свойство("Примечание") тогда
			если не значениеЗаполнено(НовыйЭлектронныйДокумент.Текст) тогда
				НовыйЭлектронныйДокумент.Текст= СоставПакета.Состояние.Примечание;
			конецесли;
			НовыйЭлектронныйДокумент.ПричинаОтклонения = СоставПакета.Состояние.Примечание;
		конецесли;
		НовыйЭлектронныйДокумент.СостояниеЭДО= СостояниеВерсииЭД;

		НоваяСтрока = НовыйЭлектронныйДокумент.ДокументыОснования.Добавить();
		НоваяСтрока.ДокументОснование = ДокСсылка;
	
		НовыйЭлектронныйДокумент.Записать();
		СсылкаНаВладельца = НовыйЭлектронныйДокумент.ссылка;
	Конецесли;
	Если ЗначениеЗаполнено(XMLДокумента) Тогда
		Поток = Новый ПотокВПамяти;
		Кодировка = ?(СтрНайти(XMLДокумента,"windows"), КодировкаТекста.ANSI, КодировкаТекста.UTF8);
		ЗаписьТекста = Новый ЗаписьТекста(Поток, Кодировка);
		ЗаписьТекста.Записать(XMLДокумента);
		ЗаписьТекста.Закрыть();
		ДанныеФайла = Поток.ЗакрытьИПолучитьДвоичныеДанные();
		
		АдресВоВременномХранилище = ПоместитьВоВременноеХранилище(ДанныеФайла);
		ПараметрыФайла = Новый Структура();
		ПараметрыФайла.Вставить("Автор", Пользователи.АвторизованныйПользователь());
		ПараметрыФайла.Вставить("ВладелецФайлов", СсылкаНаВладельца);
		ПараметрыФайла.Вставить("ИмяБезРасширения", "Файл");
		ПараметрыФайла.Вставить("РасширениеБезТочки", "xml");
		ПараметрыФайла.Вставить("ВремяИзмененияУниверсальное");
		ДобавленныйФайл = РаботаСФайлами.ДобавитьФайл(ПараметрыФайла, АдресВоВременномХранилище);	
	КонецЕсли;
	возврат СсылкаНаВладельца;
КонецФункции

&НаСервереБезКонтекста
Процедура ОпределитьСостояние(СтатусЭД, ДокСсылка, СостояниеВерсииЭД, ДействияСНашейСтороны, ДействияСоСтороныДругогоУчастника) экспорт
	попытка
		Если Найти(нрег(СтатусЭД), "выгружен")=1 или Найти(нрег(СтатусЭД), "загружен на сервер")=1 или Найти(нрег(СтатусЭД), "документ редактируется")=1 или Найти(нрег(СтатусЭД), "есть документ")=1 Тогда     // Выгружен или загружен на сервер
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ОжидаетсяПодтверждение;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			//статусФайла=перечисления.СтатусыЭД.ПереданОператору;
		ИначеЕсли Найти(нрег(СтатусЭД), "отослано приглашение")=1 Тогда      // Отправлено приглашение
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ОжидаетсяОтправкаПолучателю;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ПригласитьКОбмену;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			//статусФайла=перечисления.СтатусыЭД.ОтправленоИзвещение;
		ИначеЕсли Найти(нрег(СтатусЭД), "отправлен")=1 Тогда     // Отправлен
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ОжидаетсяИзвещениеОПолучении;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			статусФайла=перечисления.СтатусыЭД.Отправлен;
		ИначеЕсли Найти(нрег(СтатусЭД), "ошибка")>0 или Найти(нрег(СтатусЭД), "проблемы при доставке")>0 Тогда     // Ошибки при отправке или при доставке
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ОшибкаПередачи;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
			//статусФайла=перечисления.СтатусыЭД.ОшибкаПередачи;
		ИначеЕсли Найти(нрег(СтатусЭД),"на утверждении")=1 или Найти(нрег(СтатусЭД),"доставлен")=1 Тогда                        // Доставлен
			ДокСФ=ложь;
			Попытка
				если ТипЗнч(ДокСсылка) = Тип("ДокументСсылка.СчетФактураВыданный") тогда
					ДокСФ=истина;
				конецесли;
			Исключение
			КонецПопытки;	
			Попытка
				если ТипЗнч(ДокСсылка) = Тип("ДокументСсылка.СчетФактураПолученный") тогда
					ДокСФ=истина;
				конецесли;
			Исключение
			КонецПопытки;	
			Попытка
				если ТипЗнч(ДокСсылка) = Тип("ДокументСсылка.СчетФактура") тогда
					ДокСФ=истина;
				конецесли;
			Исключение
			КонецПопытки;	
			Если ДокСФ Тогда
				СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ОбменЗавершен;
				ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ВсеВыполнено;
				ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ВсеВыполнено;
			иначе
				СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.НаУтверждении;
				ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
				ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			конецесли;
			//статусФайла=перечисления.СтатусыЭД.Доставлен;
		ИначеЕсли Найти(нрег(СтатусЭД), "выполнение завершено с проблемами")=1 Тогда                        // Отклонен
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.Отклонен;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.Отклонен;
			//статусФайла=перечисления.СтатусыЭД.Отклонен;
		ИначеЕсли Найти(нрег(СтатусЭД), "выполнение завершено успешно")=1 Тогда                        // Утвержден
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ОбменЗавершен;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ВсеВыполнено;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ВсеВыполнено;
			//статусФайла=перечисления.СтатусыЭД.Утвержден;
		ИначеЕсли Найти(нрег(СтатусЭД), "в обработке")=1 Тогда                        
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.НаУтверждении;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ВсеВыполнено;
			//статусФайла=перечисления.СтатусыЭД.Получен;
		ИначеЕсли Найти(нрег(СтатусЭД), "удален")=1 Тогда                        // Удален контрагентом
			если метаданные.перечисления.СостоянияВерсийЭД.ЗначенияПеречисления.Найти("Аннулирован") <> неопределено тогда
				СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.Аннулирован;
			иначе
				СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ЗакрытПринудительно;
			конецесли;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
			//если метаданные.перечисления.СтатусыЭД.ЗначенияПеречисления.Найти("Аннулирован") <> неопределено тогда
			//	статусФайла=перечисления.СтатусыЭД.Аннулирован;
			//иначе
			//	статусФайла=перечисления.СтатусыЭД.Приостановлен;
			//конецесли;
		ИначеЕсли Найти(нрег(СтатусЭД), "отозван мной")=1 Тогда                        // Удален мной
			если метаданные.перечисления.СостоянияВерсийЭД.ЗначенияПеречисления.Найти("Аннулирован") <> неопределено тогда
				СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.Аннулирован;
			иначе
				СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ЗакрытПринудительно;
			конецесли;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.Отклонен;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			//если метаданные.перечисления.СтатусыЭД.ЗначенияПеречисления.Найти("Аннулирован") <> неопределено тогда
			//	статусФайла=перечисления.СтатусыЭД.Аннулирован;
			//иначе
			//	статусФайла=перечисления.СтатусыЭД.Приостановлен;
			//конецесли;
		Иначе
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.НеСформирован;
			ДействияСНашейСтороны = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
			ДействияСоСтороныДругогоУчастника = перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
			//статусФайла=перечисления.СтатусыЭД.НеСформирован;
		КонецЕсли;
	исключение // Вероятно Какое- то из перечислений оказалось не определено
		если метаданные.перечисления.СостоянияВерсийЭД.ЗначенияПеречисления.Найти("ТребуютсяДействия") <> неопределено тогда
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ТребуютсяДействия;
		иначе
			СостояниеВерсииЭД = перечисления.СостоянияВерсийЭД.ТребуетсяУточнитьДокумент;
		конецесли;
		//статусФайла=перечисления.СтатусыЭД.ОшибкаПередачи;
		Сообщить(ОписаниеОшибки());
	КонецПопытки;
КонецПроцедуры