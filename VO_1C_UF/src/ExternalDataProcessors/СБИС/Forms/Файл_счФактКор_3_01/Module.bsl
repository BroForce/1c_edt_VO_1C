&НаКлиенте
Функция ПолучитьДанныеИзДокумента1С(Кэш,Контекст) Экспорт
// вызываем ту же функцию из формы Файл_СчФктр_3_01	
	фрм = Кэш.ГлавноеОкно.сбисНайтиФормуФункции("ПолучитьДанныеИзДокумента1С","Файл_СчФктр_3_01","", Кэш);
	Возврат фрм.ПолучитьДанныеИзДокумента1С(Кэш,Контекст);		
КонецФункции
