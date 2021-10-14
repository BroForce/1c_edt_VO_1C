//Форма исключительно для УФ

&НаСервереБезКонтекста
функция ДублироватьСостояние(СоставПакета, ДокСсылка, XMLДокумента=неопределено, СтруктураФайла=неопределено) экспорт
	Если	Метаданные.РегистрыСведений.Найти("СостоянияЭД") = Неопределено
		Или	Метаданные.Справочники.Найти("СоглашенияОбИспользованииЭД") = Неопределено  Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	СтатусЭД = СоставПакета.Состояние.Название;
	СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.НеСформирован;
	Соглашение = Неопределено;
	
	НастройкиЭД = ОпределитьНастройкиОбменаЭДПоИсточнику(ДокСсылка, Ложь);
	Если НастройкиЭД= Ложь тогда
		Возврат Ложь;
	КонецЕсли;	
	Если Не ЗначениеЗаполнено(НастройкиЭД) тогда
		Соглашение = СоздатьНастройкиЭДО(ДокСсылка);
		Если Соглашение <> Неопределено тогда
			НастройкиЭД= ОпределитьНастройкиОбменаЭДПоИсточнику(ДокСсылка); 
		КонецЕсли;
	Иначе
		Соглашение=НастройкиЭД.СоглашениеЭД;
		Попытка
			Если Соглашение.СостояниеСоглашения = Перечисления.СостоянияСоглашенийЭД.ПроверкаТехническойСовместимости 
				И СоставПакета.свойство("Событие") Тогда // подтверждение технической совместимости
				ОбъектСоглашение= Соглашение.ПолучитьОбъект();
				ОбъектСоглашение.СостояниеСоглашения=Перечисления.СостоянияСоглашенийЭД.Действует;
				ОбъектСоглашение.Записать();
			КонецЕсли;
		Исключение
		КонецПопытки;
	КонецЕсли;
	Если ЗначениеЗаполнено(НастройкиЭД) тогда
		НаборЗаписей = РегистрыСведений.СостоянияЭД.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.СсылкаНаОбъект.Установить(ДокСсылка);
		НаборЗаписей.Прочитать();
		Если НаборЗаписей.Количество()>0 тогда
			НоваяЗаписьНабора = НаборЗаписей.Получить(0);
		Иначе
			НоваяЗаписьНабора = НаборЗаписей.Добавить();
			НоваяЗаписьНабора.СсылкаНаОбъект=ДокСсылка;
		КонецЕсли;
		_СтатусЭД = Нрег(СтатусЭД);
		Попытка
			Если Найти(_СтатусЭД, "выгружен")=1 или Найти(_СтатусЭД, "загружен на сервер")=1 или Найти(_СтатусЭД, "документ редактируется")=1 или Найти(_СтатусЭД, "есть документ")=1 Тогда     // Выгружен или загружен на сервер
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ОжидаетсяПодтверждение;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				статусФайла=Перечисления.СтатусыЭД.ПереданОператору;
			ИначеЕсли Найти(_СтатусЭД, "отослано приглашение")=1 Тогда      // Отправлено приглашение
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ОжидаетсяОтправкаПолучателю;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ПригласитьКОбмену;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				статусФайла=Перечисления.СтатусыЭД.ОтправленоИзвещение;
			ИначеЕсли Найти(_СтатусЭД, "отправлен")=1 Тогда     // Отправлен
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ОжидаетсяИзвещениеОПолучении;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				статусФайла=Перечисления.СтатусыЭД.Отправлен;
			ИначеЕсли Найти(_СтатусЭД, "ошибка")>0 или Найти(_СтатусЭД, "проблемы при доставке")>0 Тогда     // Ошибки при отправке или при доставке
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ОшибкаПередачи;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
				статусФайла=Перечисления.СтатусыЭД.ОшибкаПередачи;
			ИначеЕсли Найти(_СтатусЭД,"на утверждении")=1 или Найти(_СтатусЭД,"доставлен")=1 Тогда                        // Доставлен
				ДокСФ=Ложь;
				Попытка
					Если ТипЗнч(ДокСсылка) = Тип("ДокументСсылка.СчетФактураВыданный") тогда
						ДокСФ=истина;
					КонецЕсли;
				Исключение
				КонецПопытки;	
				Попытка
					Если ТипЗнч(ДокСсылка) = Тип("ДокументСсылка.СчетФактураПолученный") тогда
						ДокСФ=истина;
					КонецЕсли;
				Исключение
				КонецПопытки;	
				Попытка
					Если ТипЗнч(ДокСсылка) = Тип("ДокументСсылка.СчетФактура") тогда
						ДокСФ=истина;
					КонецЕсли;
				Исключение
				КонецПопытки;	
				Если ДокСФ Тогда
					СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ОбменЗавершен;
					НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ВсеВыполнено;
					НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ВсеВыполнено;
				Иначе
					СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.НаУтверждении;
					НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
					НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				КонецЕсли;
				статусФайла=Перечисления.СтатусыЭД.Доставлен;
			ИначеЕсли Найти(_СтатусЭД, "выполнение завершено с проблемами")=1 Тогда                        // Отклонен
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.Отклонен;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.Отклонен;
				статусФайла=Перечисления.СтатусыЭД.Отклонен;
			ИначеЕсли Найти(_СтатусЭД, "выполнение завершено успешно")=1 Тогда                        // Утвержден
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ОбменЗавершен;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ВсеВыполнено;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ВсеВыполнено;
				статусФайла=Перечисления.СтатусыЭД.Утвержден;
			ИначеЕсли Найти(_СтатусЭД, "удален")=1 Тогда                        // Удален контрагентом
				Если метаданные.Перечисления.СостоянияВерсийЭД.ЗначенияПеречисления.Найти("Аннулирован") <> Неопределено тогда
					СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.Аннулирован;
				Иначе
					СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ЗакрытПринудительно;
				КонецЕсли;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
				Если метаданные.Перечисления.СтатусыЭД.ЗначенияПеречисления.Найти("Аннулирован") <> Неопределено тогда
					статусФайла=Перечисления.СтатусыЭД.Аннулирован;
				Иначе
					статусФайла=Перечисления.СтатусыЭД.Приостановлен;
				КонецЕсли;
			ИначеЕсли Найти(_СтатусЭД, "отозван мной")=1 Тогда                        // Удален мной
				Если метаданные.Перечисления.СостоянияВерсийЭД.ЗначенияПеречисления.Найти("Аннулирован") <> Неопределено тогда
					СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.Аннулирован;
				Иначе
					СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ЗакрытПринудительно;
				КонецЕсли;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.Отклонен;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
				Если метаданные.Перечисления.СтатусыЭД.ЗначенияПеречисления.Найти("Аннулирован") <> Неопределено тогда
					статусФайла=Перечисления.СтатусыЭД.Аннулирован;
				Иначе
					статусФайла=Перечисления.СтатусыЭД.Приостановлен;
				КонецЕсли;
			Иначе
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.НеСформирован;
				НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
				НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
				статусФайла=Перечисления.СтатусыЭД.НеСформирован;
			КонецЕсли;
		Исключение // Вероятно Какое- то из перечислений оказалось Не определено
			Если метаданные.Перечисления.СостоянияВерсийЭД.ЗначенияПеречисления.Найти("ТребуютсяДействия") <> Неопределено тогда
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ТребуютсяДействия;
			Иначе
				СостояниеВерсииЭД = Перечисления.СостоянияВерсийЭД.ТребуетсяУточнитьДокумент;
			КонецЕсли;
			НоваяЗаписьНабора.ДействияСНашейСтороны = Перечисления.СводныеСостоянияЭД.ТребуютсяДействия;
			НоваяЗаписьНабора.ДействияСоСтороныДругогоУчастника = Перечисления.СводныеСостоянияЭД.ДействийНеТребуется;
			статусФайла=Перечисления.СтатусыЭД.ОшибкаПередачи;
			Сообщить(ОписаниеОшибки());
		КонецПопытки;
		НоваяЗаписьНабора.СостояниеВерсииЭД = СостояниеВерсииЭД;
		
		Если метаданные.Документы.Найти("ЭлектронныйДокументИсходящий")<> Неопределено И 
			метаданные.Документы.Найти("ЭлектронныйДокументВходящий")<> Неопределено тогда // новые конфигурации 
			Если СоставПакета.свойство("направление") И СоставПакета.направление = "Входящий" Тогда
				ДокументНаправление = "ЭлектронныйДокументВходящий";
			Иначе	//СоставПакета.направление = "Исходящий" 
				ДокументНаправление = "ЭлектронныйДокументИсходящий";
			КонецЕсли;
			запрос=новый запрос("ВЫБРАТЬ
			|	ЭД.Ссылка КАК Ссылка
			|ИЗ
			|	Документ."+ДокументНаправление+" КАК ЭД
			|ГДЕ
			|	ЭД.ВидЭД = &ВидЭД
			|	И ЭД.ДокументыОснования.ДокументОснование = &ДокументОснование");
			запрос.Параметры.Вставить("ВидЭД", НастройкиЭД.ВидЭД);
			запрос.Параметры.Вставить("ДокументОснование", ДокСсылка);
			результат=запрос.Выполнить().Выбрать();
			Если результат.Следующий() тогда
				ЭлектронныйДокумент =  результат.ссылка.ПолучитьОбъект();
			Иначе	//	ОбменСКонтрагентамиСлужебный.СоздатьЭлектронныйДокумент(СтруктураЭД);
				ЭлектронныйДокумент = Документы[ДокументНаправление].СоздатьДокумент();
				НоваяСтрока = ЭлектронныйДокумент.ДокументыОснования.Добавить();
				НоваяСтрока.ДокументОснование = ДокСсылка;
				ЭлектронныйДокумент.ВерсияРегламентаЭДО = НастройкиЭД.ВерсияРегламентаЭДО;
				ЭлектронныйДокумент.ВидЭД = НастройкиЭД.ВидЭД; //- вид электронного документа.
				ЭлектронныйДокумент.ДатаДокументаОтправителя= ?(СоставПакета.свойство("Дата"),СоставПакета.Дата,ДокСсылка.Дата); //- дата электронного документа в информационной базе отправителя.
				ЭлектронныйДокумент.НомерДокументаОтправителя = ?(СоставПакета.свойство("Номер"),СоставПакета.Номер,ДокСсылка.Номер); // номер электронного документа в информационной базе отправителя.
				ЭлектронныйДокумент.Дата= ЭлектронныйДокумент.ДатаДокументаОтправителя;
				//ЭлектронныйДокумент.Номер= ЭлектронныйДокумент.НомерДокументаОтправителя;
				ЭлектронныйДокумент.УникальныйИД	= СоставПакета.Идентификатор;
				ЭлектронныйДокумент.Комментарий= ?(СоставПакета.свойство("Название"),СоставПакета.Название,"");
				ЭлектронныйДокумент.Организация= НастройкиЭД.Организация;
				ЭлектронныйДокумент.Контрагент= НастройкиЭД.Контрагент;
				ЭлектронныйДокумент.НастройкаЭДО = Соглашение;
				ЭлектронныйДокумент.ПрофильНастроекЭДО = Соглашение.ПрофильНастроекЭДО;    //     - СправочникСсылка.ПрофилиНастроекЭДО - ссылка на профиль настроек ЭДО.
				ЭлектронныйДокумент.ТребуетсяИзвещение	= НастройкиЭД.ТребуетсяИзвещение;
				ЭлектронныйДокумент.ТребуетсяПодтверждение= НастройкиЭД.ТребуетсяПодтверждение;
				Попытка
					Ответственный =Вычислить("ОбменСКонтрагентамиПереопределяемый.ПолучитьОтветственногоПоЭД(НастройкиЭД.Контрагент,Соглашение);");
				Исключение
					Ответственный ="";
				КонецПопытки;	
				Если Не ЗначениеЗаполнено(Ответственный) Тогда 
					//Ответственный = Пользователи.АвторизованныйПользователь();
					//Ответственный = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь, "ОсновнойОтветственный");
					//ТекушийПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
					//ПользовательСсылка = Справочники.Пользователи.НайтиПоКоду(СокрЛП(ТекушийПользователь));
					Ответственный = ПараметрыСеанса.ТекущийПользователь;
				КонецЕсли;
				ЭлектронныйДокумент.Ответственный= Ответственный; // хорошо бы взять из СоставПакета.Ответственный
				//     * СуммаДокумента - Число - итоговая сумма электронного документа.
			КонецЕсли;
			//СоставПакета.Редакция	Массив	Массив
			//СоставПакета.Событие	Массив	Массив
			//СоставПакета.Состояние	Структура	Структура
			//	Код	"7"	Строка
			//	Название	"Выполнение завершено успешно"	Строка
			//	Описание	""	Строка
			//СсылкаДляКонтрагент	"https://online.sbis.ru/reg/showdoc.html?params=eyJHVUlEIjoiYzg4MWM5MjQtNjkwNC00NTUwLTk4OGMtZDA3MjY1MGQzN2Q0Iiwi0JjQndCd%0AIjoiNjAwMDAwMDAwMSIsItCa0J%2FQnyI6IjYwMDEwMTAwMSJ9"	Строка
			//СсылкаДляНашаОрганизация	"https://online.sbis.ru/opendoc.html?guid=c881c924-6904-4550-988c-d072650d37d4"	Строка
			//СсылкаНаPDF	""	Строка
			//СсылкаНаАрхив	"https://online.sbis.ru/service/?method=%D0%92%D0%B5%D1%80%D1%81%D0%B8%D1%8F%D0%92%D0%BD%D0%B5%D1%88%D0%BD%D0%B5%D0%B3%D0%BE%D0%94%D0%BE%D0%BA%D1%83%D0%BC%D0%B5%D0%BD%D1%82%D0%B0.%D0%A1%D0%BE%D1%85%D1%80%D0%B0%D0%BD%D0%B8%D1%82%D1%8C%D0%9D%D0%B0%D0%94%D0%B8%D1%81%D0%BA%D0%A0%D0%B5%D0%B4%D0%B0%D0%BA%D1%86%D0%B8%D1%8E&params=eyLQmNC00J4iOjM1NDE5Mn0%3D&protocol=3&id=0&srv=1"	Строка
			//Сумма	"17700.00"	Строка
			//СоставПакета.Тип	"ФактураИсх"	Строка
			//СоставПакета.Удален	"Нет"	Строка
			Если СоставПакета.свойство("Примечание") тогда
				ЭлектронныйДокумент.Текст= СоставПакета.Примечание;
			КонецЕсли;
			Если СоставПакета.Состояние.свойство("Примечание") тогда
				Если Не ЗначениеЗаполнено(ЭлектронныйДокумент.Текст) тогда
					ЭлектронныйДокумент.Текст= СоставПакета.Состояние.Примечание;
				КонецЕсли;
				ЭлектронныйДокумент.ПричинаОтклонения = СоставПакета.Состояние.Примечание;
			КонецЕсли;
			//ЭлектронныйДокумент.ДатаИзмененияСостоянияЭДО    //СоставПакета.ДатаВремяСоздания	14.09.2017 13:36:12	Дата
			ЭлектронныйДокумент.СостояниеЭДО= СостояниеВерсииЭД;
			ЭлектронныйДокумент.Записать();
			
			НоваяЗаписьНабора.ЭлектронныйДокумент=ЭлектронныйДокумент.Ссылка;
		Иначе
			Если ЗначениеЗаполнено(НоваяЗаписьНабора.ЭлектронныйДокумент) тогда
				ЭлектронныйДокумент = НоваяЗаписьНабора.ЭлектронныйДокумент.ПолучитьОбъект();
				ЭлектронныйДокумент.ДатаИзмененияСтатусаЭД=	текущаядата();
				ЭлектронныйДокумент.СтатусЭД			=	статусФайла;
				ЭлектронныйДокумент.Записать();
			Иначе
				ЭлектронныйДокумент=Справочники.ЭДПрисоединенныеФайлы.СоздатьЭлемент();
				ЭлектронныйДокумент.Наименование	=	"СБИС";
				Если метаданные.Справочники.ЭДПрисоединенныеФайлы.реквизиты.Найти("ВидЭД")<> Неопределено тогда
					ЭлектронныйДокумент.ВидЭД = НастройкиЭД.ВидЭД;
				КонецЕсли;
				ЭлектронныйДокумент.ВладелецФайла	=	ДокСсылка;
				ЭлектронныйДокумент.ДатаИзмененияСтатусаЭД=текущаядата();
				ЭлектронныйДокумент.СтатусЭД		=	статусФайла;
				ЭлектронныйДокумент.Описание		=	"обмен через СБИС";
				ЭлектронныйДокумент.Расширение		=	"XML";
				ЭлектронныйДокумент.Записать();
				НоваяЗаписьНабора.ЭлектронныйДокумент=ЭлектронныйДокумент.Ссылка;
			КонецЕсли;
		КонецЕсли;
		Попытка
			НаборЗаписей.Записать();
		Исключение // Возможно по данному типу документа Не предусмотрено ведение состояниеЭД
			//			Сообщить(ОписаниеОшибки());
		КонецПопытки;
	КонецЕсли;
конецФункции

&НаСервереБезКонтекста
Функция ОпределитьНастройкиОбменаЭДПоИсточнику(Источник,
				ВыводитьСообщения = Ложь,
				ПараметрыСертификатов = Неопределено,
				ЭД = Неопределено,
				ВидЭД = Неопределено)
	Если не значениеЗаполнено(ВидЭД) тогда
		Попытка
			ПараметрыЭД = вычислить("ОбменСКонтрагентамиСлужебный.ЗаполнитьПараметрыЭДПоИсточнику(Источник, истина)");
		Исключение
			Ошибка = ОписаниеОшибки();
			Попытка
				ПараметрыЭД = Новый структура("ВидЭД,НаправлениеЭД,Организация,Контрагент,ДоговорКонтрагента");
				выполнить("ЭлектронныеДокументыПереопределяемый.ЗаполнитьПараметрыЭДПоИсточнику(Источник, ПараметрыЭД, истина)");
			Исключение
				Ошибка = Ошибка+" "+ОписаниеОшибки();
				сообщить("Форма работы со статусами 'Статусы_СостоянияЭД' не поддерживается для данной конфигурации "+ Ошибка);
				НастройкиЭД=ложь;
			КонецПопытки;	
		КонецПопытки;	
		Если ЗначениеЗаполнено(ПараметрыЭД.ВидЭД) тогда
			ВидЭД= ПараметрыЭД.ВидЭД;
		иначе
			ВидЭД= перечисления.видыЭД.ПроизвольныйЭД;
		конецЕсли;
	конецЕсли;
	Попытка
		//НастройкиЭД =вычислить("ОбменСКонтрагентамиСлужебный.ОпределитьНастройкиОбменаЭДПоИсточнику(Источник,ВыводитьСообщения,ПараметрыСертификатов,ЭД,ВидЭД)");
		НастройкиЭД =вычислить("ОбменСКонтрагентамиСлужебный.ОпределитьНастройкиОбменаЭДПоИсточнику(Источник,ВыводитьСообщения)");		
	Исключение
		Ошибка = ОписаниеОшибки();
		Попытка
			НастройкиЭД =вычислить("ЭлектронныеДокументыСлужебный.ОпределитьНастройкиОбменаЭДПоИсточнику(Источник,ВыводитьСообщения,ПараметрыСертификатов,ЭД,ВидЭД)");
		Исключение
			Ошибка = Ошибка+" "+ОписаниеОшибки();
			сообщить("Форма работы со статусами 'Статусы_СостоянияЭД' не поддерживается для данной конфигурации "+ Ошибка);
			НастройкиЭД=ложь;
		КонецПопытки;	
	КонецПопытки;	
	возврат НастройкиЭД;
конецфункции

&НаСервереБезКонтекста
Функция	СоздатьНастройкиЭДО(ДокСсылка)
	параметрыЭД=новый структура("СпособыОбменаЭД,организация, Контрагент,договор",Перечисления.СпособыОбменаЭД.ЧерезКаталог);
	Соглашение = Неопределено;
	ИскомоеСоглашение = Неопределено;
	Если докСсылка.Метаданные().реквизиты.найти("Организация")<> Неопределено тогда 
		параметрыЭД.организация=ДокСсылка.Организация;
	Иначе
		Если докСсылка.Метаданные().реквизиты.найти("ДокументОснование")<> Неопределено
			И ДокСсылка.ДокументОснование.Метаданные().реквизиты.найти("Организация")<> Неопределено тогда 
			параметрыЭД.организация=ДокСсылка.ДокументОснование.Организация;
		КонецЕсли;
	КонецЕсли;
	Если ДокСсылка.Метаданные().реквизиты.найти("Контрагент")<> Неопределено тогда 
		параметрыЭД.Контрагент=ДокСсылка.Контрагент;
	Иначе
		Если ДокСсылка.Метаданные().реквизиты.найти("ДокументОснование")<> Неопределено
			И ДокСсылка.ДокументОснование.Метаданные().реквизиты.найти("Контрагент")<> Неопределено тогда 
			параметрыЭД.Контрагент=ДокСсылка.ДокументОснование.Контрагент;
		КонецЕсли;
	КонецЕсли;
	//Если ДокСсылка.Метаданные().реквизиты.найти("Договор")<> Неопределено тогда 
	//	параметрыЭД.договор=ДокСсылка.Договор;
	//ИначеЕсли ДокСсылка.Метаданные().реквизиты.найти("ДоговорКонтрагента")<> Неопределено тогда 
	// 	параметрыЭД.договор=ДокСсылка.ДоговорКонтрагента;
	//Иначе
	//	Если ДокСсылка.Метаданные().реквизиты.найти("ДокументОснование")<> Неопределено
	//			И ДокСсылка.ДокументОснование.Метаданные().реквизиты.найти("Договор")<> Неопределено тогда 
	//		параметрыЭД.договор=ДокСсылка.ДокументОснование.Договор;
	//	КонецЕсли;
	//КонецЕсли;
	Попытка
		Если ЗначениеЗаполнено(параметрыЭД.организация) И ЗначениеЗаполнено(параметрыЭД.Контрагент) тогда
			УстановитьПривилегированныйРежим(Истина); // Получаем настройки ЭДО безусловно
			
			Запрос = Новый Запрос;
			Запрос.УстановитьПараметр("Организация",параметрыЭД.Организация);
			Запрос.УстановитьПараметр("Контрагент", параметрыЭД.Контрагент);
			Попытка
				ДопустимыеСостояния= новый списокЗначений();
				ДопустимыеСостояния.Добавить(Перечисления.СостоянияСоглашенийЭД.ПроверкаТехническойСовместимости);
				ДопустимыеСостояния.Добавить(Перечисления.СостоянияСоглашенийЭД.Действует);
				Запрос.УстановитьПараметр("ДопустимыеСостояния", ДопустимыеСостояния);
				условияДопустимыеСостояния=" И СоглашенияОбИспользованииЭД.СостояниеСоглашения В(&ДопустимыеСостояния)" 
			Исключение
				условияДопустимыеСостояния="";
			КонецПопытки;
			
			Если ЗначениеЗаполнено(параметрыЭД.договор) И метаданные.справочники.СоглашенияОбИспользованииЭД.реквизиты.найти("ДоговорКонтрагента")<> Неопределено тогда 
				Запрос.Текст ="ВЫБРАТЬ
				|	СоглашенияОбИспользованииЭД.Ссылка КАК Ссылка
				|ИЗ
				|	Справочник.СоглашенияОбИспользованииЭД КАК СоглашенияОбИспользованииЭД
				|ГДЕ
				|	СоглашенияОбИспользованииЭД.Контрагент = &Контрагент
				|	И СоглашенияОбИспользованииЭД.ДоговорКонтрагента = &ДоговорКонтрагента
				|	И СоглашенияОбИспользованииЭД.Организация = &Организация
				|	И НЕ СоглашенияОбИспользованииЭД.ПометкаУдаления
				|	И СоглашенияОбИспользованииЭД.СтатусСоглашения = ЗНАЧЕНИЕ(Перечисление.СтатусыСоглашенийЭД.Действует)"+условияДопустимыеСостояния;
				Запрос.УстановитьПараметр("ДоговорКонтрагента", параметрыЭД.Договор);
				Выборка = Запрос.Выполнить().Выбрать();
				Выборка.Следующий();
				Соглашение=Выборка.Ссылка;
			КонецЕсли;
			Если Не ЗначениеЗаполнено(Соглашение) тогда
				Запрос.Текст ="ВЫБРАТЬ
				|	СоглашенияОбИспользованииЭД.Ссылка
				|ИЗ
				|	Справочник.СоглашенияОбИспользованииЭД КАК СоглашенияОбИспользованииЭД
				|ГДЕ
				|	СоглашенияОбИспользованииЭД.Контрагент = &Контрагент
				|	И СоглашенияОбИспользованииЭД.Организация = &Организация
				|	И НЕ СоглашенияОбИспользованииЭД.ПометкаУдаления
				|	И СоглашенияОбИспользованииЭД.СтатусСоглашения = ЗНАЧЕНИЕ(Перечисление.СтатусыСоглашенийЭД.Действует)"+условияДопустимыеСостояния;
				Выборка = Запрос.Выполнить().Выбрать();
				Выборка.Следующий();
				Соглашение=Выборка.Ссылка;
			КонецЕсли;
			Если Не ЗначениеЗаполнено(Соглашение) И метаданные.РегистрыСведений.найти("УчастникиОбменовЭДЧерезОператоровЭДО")<> Неопределено тогда
				Запрос.Текст ="ВЫБРАТЬ
				|	СоглашениеЧерезОЭДО.Ссылка
				|ИЗ
				|	РегистрСведений.УчастникиОбменовЭДЧерезОператоровЭДО КАК УчастникиОбменовЭДЧерезОператоровЭДО
				|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СоглашенияОбИспользованииЭД КАК СоглашениеЧерезОЭДО
				|		ПО УчастникиОбменовЭДЧерезОператоровЭДО.СоглашениеОбИспользованииЭД = СоглашениеЧерезОЭДО.Ссылка
				|ГДЕ
				|	НЕ СоглашениеЧерезОЭДО.ПометкаУдаления
				|	И СоглашениеЧерезОЭДО.СтатусСоглашения = ЗНАЧЕНИЕ(Перечисление.СтатусыСоглашенийЭД.Действует)
				|	И СоглашениеЧерезОЭДО.Организация = &Организация
				|	И УчастникиОбменовЭДЧерезОператоровЭДО.Участник = &Контрагент
				|	И УчастникиОбменовЭДЧерезОператоровЭДО.Статус = ЗНАЧЕНИЕ(Перечисление.СтатусыУчастниковОбменаЭД.Присоединен)";
				Выборка = Запрос.Выполнить().Выбрать();
				Выборка.Следующий();
				Соглашение=Выборка.Ссылка;
			КонецЕсли;
			Если ЗначениеЗаполнено(Соглашение) тогда
				ИскомоеСоглашение = Соглашение.ПолучитьОбъект();
				Если Не ЗначениеЗаполнено(ИскомоеСоглашение.Комментарий) тогда
					ИскомоеСоглашение.Комментарий	=	"СБИС";
				КонецЕсли;
				ЗаписатьОбъект = Ложь;
			Иначе // создать новое
				ИскомоеСоглашение= Справочники.СоглашенияОбИспользованииЭД.СоздатьЭлемент();
				ИскомоеСоглашение.наименование	=	"СБИС";
				ИскомоеСоглашение.Комментарий	=	"СБИС";
				ИскомоеСоглашение.Организация	=	параметрыЭД.Организация;
				ИскомоеСоглашение.Контрагент	=	параметрыЭД.Контрагент;
				ИскомоеСоглашение.СтатусСоглашения= Перечисления.СтатусыСоглашенийЭД.Действует;
				ИскомоеСоглашение.СпособОбменаЭД = параметрыЭД.СпособыОбменаЭД;
				Если ИскомоеСоглашение.Метаданные().Реквизиты.Найти("ДоговорКонтрагента")<> Неопределено тогда
					ИскомоеСоглашение.ДоговорКонтрагента=параметрыЭД.Договор;
				КонецЕсли;
				Если ИскомоеСоглашение.Метаданные().Реквизиты.Найти("СостояниеСоглашения")<> Неопределено тогда
					ИскомоеСоглашение.СостояниеСоглашения=Перечисления.СостоянияСоглашенийЭД.Действует;
				КонецЕсли;
				Если ИскомоеСоглашение.Метаданные().Реквизиты.Найти("СтатусПодключения")<> Неопределено тогда
					ИскомоеСоглашение.СтатусПодключения= Перечисления.СтатусыУчастниковОбменаЭД.Присоединен;
				КонецЕсли;
				если ИскомоеСоглашение.Метаданные().Реквизиты.Найти("ИспользуетсяДляОтправки")<> неопределено тогда
					ИскомоеСоглашение.ИспользуетсяДляОтправки= истина;
				конецесли;
				ЗаписатьОбъект = истина;
			КонецЕсли;
			
			Если ИскомоеСоглашение.Метаданные().реквизиты.найти("ПрофильНастроекЭДО")<> Неопределено тогда 
				Если Не ЗначениеЗаполнено(ИскомоеСоглашение.ПрофильНастроекЭДО) тогда
					отбор=новый структура("наименование,Организация,СпособОбменаЭД","СБИС",параметрыЭД.Организация,параметрыЭД.СпособыОбменаЭД);
					Запрос.Текст ="ВЫБРАТЬ
					|	профили.Ссылка
					|ИЗ
					|	Справочник.ПрофилиНастроекЭДО КАК профили
					|ГДЕ
					|	профили.наименование = &наименование
					|	И профили.Организация = &Организация
					|	И профили.СпособОбменаЭД = &СпособОбменаЭД 
					|	И НЕ профили.ПометкаУдаления";
					Запрос.УстановитьПараметр("наименование", отбор.наименование);
					Запрос.УстановитьПараметр("СпособОбменаЭД", отбор.СпособОбменаЭД);
					Выборка = Запрос.Выполнить().Выбрать();
					
					Если Выборка.Следующий() тогда
						профильСБИС= Выборка.Ссылка;
					Иначе
						профильСБИС=Справочники.ПрофилиНастроекЭДО.СоздатьЭлемент();
						заполнитьЗначенияСвойств(профильСБИС,отбор);
						//для каждого ЭлементПеречисления Из Метаданные.Перечисления.ВидыЭД.ЗначенияПеречисления цикл
						//	НоваяСтрока = профильСБИС.ИсходящиеДокументы.Добавить();
						//	НоваяСтрока.ИсходящийДокумент = ЭлементПеречисления;
						//	Перечисления.ВидыЭД.(ЭлементПеречисления.имя)
						//	НоваяСтрока.Формировать       = истина;
						//конеццикла;
						профильСБИС.Записать();
					КонецЕсли;
					ИскомоеСоглашение.ПрофильНастроекЭДО=профильСБИС.Ссылка;
					ЗаписатьОбъект = истина;
				КонецЕсли;
			КонецЕсли;
			
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.ТОРГ12, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.ТОРГ12Продавец, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.ТОРГ12Покупатель, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.АктИсполнитель, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.АктЗаказчик, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.СчетФактура, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.СчетНаОплату, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Исходящий",ИскомоеСоглашение, Перечисления.ВидыЭД.ПроизвольныйЭД, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;  // alo по ошибке
			КонецЕсли;
			Если ПроверитьВидЭД("Входящий",ИскомоеСоглашение, Перечисления.ВидыЭД.ТОРГ12, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Входящий",ИскомоеСоглашение, Перечисления.ВидыЭД.ТОРГ12Продавец, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Входящий",ИскомоеСоглашение, Перечисления.ВидыЭД.ТОРГ12Покупатель, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Входящий",ИскомоеСоглашение, Перечисления.ВидыЭД.АктВыполненныхРабот, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Входящий",ИскомоеСоглашение, Перечисления.ВидыЭД.СчетФактура, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			Если ПроверитьВидЭД("Входящий",ИскомоеСоглашение, Перечисления.ВидыЭД.СчетНаОплату, параметрыЭД.СпособыОбменаЭД) тогда
				ЗаписатьОбъект = Истина;
			КонецЕсли;
			
			Если ЗаписатьОбъект Тогда
				Попытка
					ИскомоеСоглашение.Записать();
				Исключение
					Сообщить("ДоговорКонтрагента "+ИскомоеСоглашение.ДоговорКонтрагента);
					Попытка
						Для каждого Реквизит Из ИскомоеСоглашение.Метаданные().Реквизиты Цикл
							Сообщить(Реквизит.Имя + " " + ИскомоеСоглашение[Реквизит]);
						КонецЦикла;
					Исключение
					КонецПопытки;
					ИскомоеСоглашение = Неопределено;
				КонецПопытки;
			КонецЕсли;
		КонецЕсли;
	Исключение
		Сообщить("неудачное создание настройки ЭДО :"+ОписаниеОшибки());
	КонецПопытки;
	Если ИскомоеСоглашение = Неопределено тогда
		Возврат ИскомоеСоглашение;
	Иначе
		Возврат ИскомоеСоглашение.Ссылка;
	КонецЕсли;
конецФункции

&НаСервереБезКонтекста       
Функция	ПроверитьВидЭД(Направление, ИскомоеСоглашение, ВидЭД, СпособыОбменаЭД)
	Если Направление="Входящий" тогда
		ПолеВидЭД="ВходящийДокумент";
		ТЧ_ЭлДокументы="ВходящиеДокументы";
	Иначе
		ПолеВидЭД="ИсходящийДокумент";
		ТЧ_ЭлДокументы="ИсходящиеДокументы";
	КонецЕсли;
	ЗаписатьОбъект=Ложь;
	строкаЭД = ИскомоеСоглашение[ТЧ_ЭлДокументы].Найти(ВидЭД, ПолеВидЭД);
	ЕстьСпособОбменаЭД= (ИскомоеСоглашение.Метаданные().ТабличныеЧасти[ТЧ_ЭлДокументы].Реквизиты.Найти("СпособОбменаЭД")<> Неопределено);
	Если строкаЭД = Неопределено Тогда
		строкаЭД = ИскомоеСоглашение[ТЧ_ЭлДокументы].Добавить();
		строкаЭД[ПолеВидЭД]       = ВидЭД;
		Если ЕстьСпособОбменаЭД тогда
			строкаЭД.СпособОбменаЭД		= СпособыОбменаЭД;
		КонецЕсли;
		строкаЭД.Формировать             = истина;
		ЗаписатьОбъект = Истина;
	Иначе
		Если Не строкаЭД.Формировать тогда
			строкаЭД.Формировать=Истина;
			ЗаписатьОбъект = Истина;
		КонецЕсли;
		Если ЕстьСпособОбменаЭД тогда
			Если строкаЭД.СпособОбменаЭД	<> СпособыОбменаЭД тогда
				строкаЭД.СпособОбменаЭД = СпособыОбменаЭД;
				ЗаписатьОбъект = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	Возврат ЗаписатьОбъект;
конецФункции
