﻿Функция СведенияОВнешнейОбработке() Экспорт

	ПараметрыРегистрации = Новый Структура;

	МетаданныеОбъекта = ЭтотОбъект.Метаданные();

	//регистрация
	МассивНазначений = Новый Массив;
	МассивНазначений.Добавить("Справочник.Контрагенты");
	МассивНазначений.Добавить("Документ.РеализацияТоваровУслуг");
	
	ПараметрыРегистрации.Вставить("Вид", "ПечатнаяФорма");
	ПараметрыРегистрации.Вставить("Назначение", МассивНазначений);
	ПараметрыРегистрации.Вставить("Наименование", МетаданныеОбъекта.Синоним);
	ПараметрыРегистрации.Вставить("Версия", МетаданныеОбъекта.Комментарий);
	ПараметрыРегистрации.Вставить("БезопасныйРежим", ЛОЖЬ);
	ПараметрыРегистрации.Вставить("Информация", МетаданныеОбъекта.Синоним);
	ПараметрыРегистрации.Вставить("ВерсияБСП", "2.3.4.71");

	//команды
	ТаблицаКоманд = Новый ТаблицаЗначений;
	ТаблицаКоманд.Колонки.Добавить("Представление");
	ТаблицаКоманд.Колонки.Добавить("Идентификатор");
	ТаблицаКоманд.Колонки.Добавить("Использование");
	ТаблицаКоманд.Колонки.Добавить("ПоказыватьОповещение");

	НоваяКоманда = ТаблицаКоманд.Добавить();
	НоваяКоманда.Представление = "Печать конвертов";
	НоваяКоманда.Идентификатор = "ПечатьКонвертов";
	НоваяКоманда.Использование = "ОткрытиеФормы";

	ПараметрыРегистрации.Вставить("Команды", ТаблицаКоманд);

	Возврат ПараметрыРегистрации;

КонецФункции

#Область ПечатьКонвертов

// Возвращает контейнер для заполнения в конверте сведений о получателе.
// 
// Возвращаемое значение:
//   - Структура
//       * Представление - Строка - Представление получателя.
//       * Индекс - Строка - Индекс получателя.
//       * Адрес - Строка - Адрес получателя, части адреса должны быть разделены запятыми.
//                          Например, "ул.Новая, дом 1, корпус 1, кв. 1, г.Москва, Россия".
//
Функция НовыйСведенияОПолучателеКонверта() Экспорт
	
	СведенияОУчастникеПереписки = Новый Структура();
	СведенияОУчастникеПереписки.Вставить("Представление", "");
	СведенияОУчастникеПереписки.Вставить("Индекс",     "");
	СведенияОУчастникеПереписки.Вставить("Адрес",      "");
	Возврат СведенияОУчастникеПереписки;
	
КонецФункции

// Возвращает контейнер для заполнения в конверте сведений об отправителе.
// 
// Возвращаемое значение:
//   - Структура
//       * Представление - Строка - Представление отправителя.
//       * Индекс - Строка - Индекс отправителя.
//       * Адрес - Строка - Адрес отправителя, части адреса должны быть разделены запятыми.
//                          Например, "ул.Новая, дом 1, корпус 1, кв. 1, г.Москва, Россия".
//       * ПечататьЛоготип - Булево - Нужно ли выводить логотип на конверт.
//       * Логотип - ДвоичныеДанные - Двоичные данные картинки логотипа.
//
Функция НовыйСведенияОбОтправителеКонверта() Экспорт
	
	СведенияОУчастникеПереписки = Новый Структура();
	СведенияОУчастникеПереписки.Вставить("Представление", "");
	СведенияОУчастникеПереписки.Вставить("Индекс", "");
	СведенияОУчастникеПереписки.Вставить("Адрес", "");
	СведенияОУчастникеПереписки.Вставить("ПечататьЛоготип", Ложь);
	СведенияОУчастникеПереписки.Вставить("Логотип", Неопределено);
	Возврат СведенияОУчастникеПереписки;
	
КонецФункции

Функция ПечатьКонверта(МассивОбъектов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	Результат = Новый ТабличныйДокумент;
	
	ПараметрыВыводаВМакет = ПараметрыВыводаВМакет(ПараметрыПечати);
	УстановитьПараметрыПечатиКонверта(Результат, ПараметрыВыводаВМакет);
	
	Макет = ЭтотОбъект.ПолучитьМакет(ПараметрыПечати.ИмяМакета);
	
	ДанныеДляПечатиКонвертов = ДанныеДляПечатиКонвертов(МассивОбъектов, ПараметрыПечати);
	
	ПервыйКонверт = Истина;
	Для Каждого ДанныеПечатиКонверта Из ДанныеДляПечатиКонвертов Цикл
		
		Если ПервыйКонверт Тогда
			ПервыйКонверт = Ложь;
		Иначе
			Результат.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		НомерСтрокиНачало = Результат.ВысотаТаблицы + 1;
		
		Если ЗначениеЗаполнено(Макет.Области.Найти("Заголовок")) Тогда
			ОбластьЗаголовок = Макет.ПолучитьОбласть("Заголовок");
			ЗаполнитьЗаголовокКонверта(ОбластьЗаголовок, ДанныеПечатиКонверта, ПараметрыВыводаВМакет);
			Результат.Вывести(ОбластьЗаголовок);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Макет.Области.Найти("Индекс")) Тогда
			ОбластьИндекс = Макет.ПолучитьОбласть("Индекс");
			ЗаполнитьКодовыйШтамп(ОбластьИндекс, ДанныеПечатиКонверта.СведенияОПолучателеКонверта);
			Результат.Вывести(ОбластьИндекс);
		КонецЕсли;
		
		//УправлениеПечатью.ЗадатьОбластьПечатиДокумента(Результат,
		//	НомерСтрокиНачало, ОбъектыПечати, ДанныеПечатиКонверта.ОбъектПечати);
		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ДанныеДляПечатиКонвертов(МассивОбъектов, ПараметрыПечати)
	
	ДанныеДляПечатиКонвертов = Новый ТаблицаЗначений;
	ДанныеДляПечатиКонвертов.Колонки.Добавить("ОбъектПечати");
	ДанныеДляПечатиКонвертов.Колонки.Добавить("СведенияОПолучателеКонверта");
	ДанныеДляПечатиКонвертов.Колонки.Добавить("СведенияОбОтправителеКонверта"); 
	
	Если ПараметрыПечати.Свойство("СведенияОПолучателеКонверта")
		И ЗначениеЗаполнено(ПараметрыПечати.СведенияОПолучателеКонверта) Тогда
		
		ЗаполнитьДанныеДляПечатиКонвертаПоСведениюОПолучателе(
			ДанныеДляПечатиКонвертов, ПараметрыПечати.СведенияОПолучателеКонверта, ПараметрыПечати) 
			
	ИначеЕсли МассивОбъектов.Количество() > 0 Тогда
		
		ЗаполнитьДанныеДляПечатиКонвертовПоМассивуОбъектов(ДанныеДляПечатиКонвертов, МассивОбъектов, ПараметрыПечати);
		
	КонецЕсли;
	
	Возврат ДанныеДляПечатиКонвертов;
	
КонецФункции

Процедура ЗаполнитьДанныеДляПечатиКонвертаПоСведениюОПолучателе(ДанныеДляПечатиКонвертов, СведенияОПолучателеКонверта, ПараметрыПечати)
	
	СтрокаОбъектаПечати = ДанныеДляПечатиКонвертов.Добавить();
	СтрокаОбъектаПечати.СведенияОПолучателеКонверта = СведенияОПолучателеКонверта;
	СтрокаОбъектаПечати.СведенияОбОтправителеКонверта = СведенияОбОрганизацииДляКонверта(
		ПараметрыПечати.Организация, ПараметрыПечати.ПечататьЛоготип);
	
КонецПроцедуры

Процедура ЗаполнитьДанныеДляПечатиКонвертовПоМассивуОбъектов(ДанныеДляПечатиКонвертов, МассивОбъектов, ПараметрыПечати)
	
	УчастникиПерепискиДляКонвертов = УчастникиПерепискиДляКонвертов(МассивОбъектов, ПараметрыПечати);
	
	Если НЕ ЗначениеЗаполнено(УчастникиПерепискиДляКонвертов) Тогда
		Возврат;
	КонецЕсли;
	
	СведенияОбОрганизациях = Новый Соответствие;
	СведенияОКонтрагентах  = Новый Соответствие;
	
	Для Каждого УчастникиПерепискиКонверта Из УчастникиПерепискиДляКонвертов Цикл
		СтрокаОбъектаПечати = ДанныеДляПечатиКонвертов.Добавить();
		СтрокаОбъектаПечати.ОбъектПечати = УчастникиПерепискиКонверта.ОбъектПечати;
		
		СведенияОПолучателеКонверта = СведенияОКонтрагентах.Получить(УчастникиПерепискиКонверта.Получатель);
		Если СведенияОПолучателеКонверта = Неопределено Тогда
			СведенияОПолучателеКонверта = СведенияОКонтрагентеДляКонверта(
				УчастникиПерепискиКонверта.Получатель, ПараметрыПечати.ВидАдресаКонтрагента);
			СведенияОКонтрагентах.Вставить(УчастникиПерепискиКонверта.Получатель, СведенияОПолучателеКонверта);
		КонецЕсли;
		СтрокаОбъектаПечати.СведенияОПолучателеКонверта = СведенияОПолучателеКонверта;
		
		СведенияОбОтправителеКонверта = СведенияОбОрганизациях.Получить(УчастникиПерепискиКонверта.Отправитель);
		Если СведенияОбОтправителеКонверта = Неопределено Тогда
			СведенияОбОтправителеКонверта = СведенияОбОрганизацииДляКонверта(
				УчастникиПерепискиКонверта.Отправитель, ПараметрыПечати.ПечататьЛоготип);
			СведенияОбОрганизациях.Вставить(УчастникиПерепискиКонверта.Отправитель, СведенияОбОтправителеКонверта);
		КонецЕсли;
		СтрокаОбъектаПечати.СведенияОбОтправителеКонверта = СведенияОбОтправителеКонверта;
	КонецЦикла;
	
КонецПроцедуры

Функция УчастникиПерепискиДляКонвертов(МассивОбъектов, ПараметрыПечати)
	
	ОбъектПечати = МассивОбъектов[0];
	МетаданныеОбъектаПечати = ОбъектПечати.Метаданные();
	
	Запрос = Новый Запрос;
	Если ТипЗнч(ОбъектПечати) = Тип("СправочникСсылка.Контрагенты") Тогда
		
		Запрос.Текст = ТекстЗапросаПечатьКонвертовИзКонтрагентов();
		Запрос.УстановитьПараметр("Организация", ПараметрыПечати.Организация);
		
	ИначеЕсли ТипЗнч(ОбъектПечати) = Тип("СправочникСсылка.ДоговорыКонтрагентов") Тогда
		
		Запрос.Текст = ТекстЗапросаПечатьКонвертовИзДоговоровКонтрагентов();
		
	ИначеЕсли ОбщегоНазначения.ЕстьРеквизитОбъекта("Организация", МетаданныеОбъектаПечати)
		И ОбщегоНазначения.ЕстьРеквизитОбъекта("Контрагент", МетаданныеОбъектаПечати) Тогда
		
		Запрос.Текст = ТекстЗапросаПечатьКонвертов(МетаданныеОбъектаПечати);
		
	Иначе
		
		Возврат Неопределено;
		
	КонецЕсли;
	
	Запрос.УстановитьПараметр("ОбъектыПечати", МассивОбъектов);
	Возврат Запрос.Выполнить().Выгрузить();
	
КонецФункции

Функция СведенияОКонтрагентеДляКонверта(Контрагент, ВидАдреса = Неопределено) 
	
	// 20240501 Заяш
		Если Не ЗначениеЗаполнено(ВидАдреса) Тогда
			ВидАдреса = Справочники.ВидыКонтактнойИнформации.ПочтовыйАдресКонтрагента;
			
		КонецЕсли;
	
	СведенияОКонтрагенте = НовыйСведенияОПолучателеКонверта();
	СведенияОКонтрагенте.Представление = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Контрагент, "НаименованиеПолное");
	
	ПочтовыеАдреса = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(
		Контрагент, ВидАдреса, ТекущаяДата(),Ложь);
	
	Если ПочтовыеАдреса.Количество() > 0 Тогда
		// 20240105 Заяш
		адресJSON = ПочтовыеАдреса[0].Значение;
		//{
		//"value": "223016, Минская обл. Минский р-н., Новодворский с\\с, д. 6, пом. 10",
		//"type": "Адрес",
		//"country": "БЕЛАРУСЬ",
		//"addressType": "ВСвободнойФорме",
		//"countryCode": "112",
		//"ZIPcode": "223016"
		//}
	    чтение = Новый ЧтениеJSON;
		чтение.УстановитьСтроку(адресJSON);
		соотвАдрес = ПрочитатьJSON(чтение, Истина);
		СведенияОКонтрагенте.Индекс = соотвАдрес["ZIPcode"];
		СведенияОКонтрагенте.Адрес = соотвАдрес["value"]; 

	КонецЕсли;
	
	Возврат СведенияОКонтрагенте;
	
КонецФункции

Функция СведенияОбОрганизацииДляКонверта(Организация, ПечататьЛоготип)
	
	РеквизитыОрганизации = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Организация,
		"ЮридическоеФизическоеЛицо, ИндивидуальныйПредприниматель, НаименованиеСокращенное");
	
	СведенияОбОрганизации = НовыйСведенияОбОтправителеКонверта();
	СведенияОбОрганизации.Представление = ?(РеквизитыОрганизации.ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ФизическоеЛицо,
		СокрЛП(СтрШаблон("%1 %2 %3", РеквизитыОрганизации.ИндивидуальныйПредприниматель.Фамилия, РеквизитыОрганизации.ИндивидуальныйПредприниматель.Имя, РеквизитыОрганизации.ИндивидуальныйПредприниматель.Отчество)),
		РеквизитыОрганизации.НаименованиеСокращенное);
	
	ПочтовыеАдресаОрганизации = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(
		Организация, Справочники.ВидыКонтактнойИнформации.ПочтовыйАдресОрганизации, ТекущаяДата(),Ложь);
		
	// 20240105 Заяш
	Если ПочтовыеАдресаОрганизации.Количество() > 0 Тогда
		адресJSON = ПочтовыеАдресаОрганизации[0].Значение;
		//{
		//"value": "223016, Минская обл. Минский р-н., Новодворский с\\с, д. 6, пом. 10",
		//"type": "Адрес",
		//"country": "БЕЛАРУСЬ",
		//"addressType": "ВСвободнойФорме",
		//"countryCode": "112",
		//"ZIPcode": "223016"
		//}
	    чтение = Новый ЧтениеJSON;
		чтение.УстановитьСтроку(адресJSON);
		соотвАдрес = ПрочитатьJSON(чтение, Истина);
		СведенияОбОрганизации.Индекс = соотвАдрес["ZIPcode"];
		СведенияОбОрганизации.Адрес = соотвАдрес["value"]; 
		
	КонецЕсли;
	
	Если ПечататьЛоготип Тогда
		ДвоичныеДанныеКартинки = ДвоичныеДанныеКартинкиОрганизации(
			Организация, "ФайлЛоготип");
		Если ЗначениеЗаполнено(ДвоичныеДанныеКартинки) Тогда
			СведенияОбОрганизации.ПечататьЛоготип = Истина;
			СведенияОбОрганизации.Логотип = ДвоичныеДанныеКартинки;
		КонецЕсли;
	КонецЕсли;
	
	Возврат СведенияОбОрганизации;
	
КонецФункции

Функция ДвоичныеДанныеКартинкиОрганизации(Организация, ИмяРеквизита) Экспорт
	
	ДвоичныеДанныеКартинки = Неопределено;
	
	Если ЗначениеЗаполнено(Организация) Тогда
		
		ПрисоединенныйФайл = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Организация, ИмяРеквизита);
		Если ЗначениеЗаполнено(ПрисоединенныйФайл) Тогда
			ДанныеКартинки = РаботаСФайлами.ДанныеФайла(ПрисоединенныйФайл);
			ДвоичныеДанныеКартинки = ПолучитьИзВременногоХранилища(ДанныеКартинки.СсылкаНаДвоичныеДанныеФайла);
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат ДвоичныеДанныеКартинки;
	
КонецФункции

Функция ТекстЗапросаПечатьКонвертовИзКонтрагентов()
	
	Результат =
	"ВЫБРАТЬ
	|	Контрагенты.Ссылка КАК Получатель,
	|	Контрагенты.Ссылка КАК ОбъектПечати,
	|	Организации.Ссылка КАК Отправитель
	|ИЗ
	|	Справочник.Организации КАК Организации
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	|		ПО (Контрагенты.Ссылка В (&ОбъектыПечати))
	|			И (Организации.Ссылка = &Организация)
	|ГДЕ
	|	НЕ Контрагенты.Ссылка ЕСТЬ NULL ";
	
	Возврат Результат;
	
КонецФункции

Функция ТекстЗапросаПечатьКонвертовИзДоговоровКонтрагентов()
	
	Результат =
	"ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Владелец КАК Получатель,
	|	ДоговорыКонтрагентов.Ссылка КАК ОбъектПечати,
	|	ДоговорыКонтрагентов.Организация.Ссылка КАК Отправитель
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	ДоговорыКонтрагентов.Ссылка В(&ОбъектыПечати)";
	
	Возврат Результат;
	
КонецФункции

Функция ТекстЗапросаПечатьКонвертов(МетаданныеОбъектаПечати)
	
	Результат =
	"ВЫБРАТЬ
	|	Таблица.Контрагент КАК Получатель,
	|	Таблица.Ссылка КАК ОбъектПечати,
	|	Таблица.Организация КАК Отправитель
	|ИЗ
	|	" + МетаданныеОбъектаПечати.ПолноеИмя() + " КАК Таблица
	|ГДЕ
	|	Таблица.Ссылка В (&ОбъектыПечати)";
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаполнитьЗаголовокКонверта(ОбластьЗаголовок, ДанныеОбъектаПечати, ПараметрыВыводаВМакет)
	
	Если ЗначениеЗаполнено(ДанныеОбъектаПечати.СведенияОПолучателеКонверта) Тогда
		ЗаполнитьПолучателяКонверта(ОбластьЗаголовок, ДанныеОбъектаПечати.СведенияОПолучателеКонверта, ПараметрыВыводаВМакет);
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ДанныеОбъектаПечати.СведенияОбОтправителеКонверта) Тогда
		ЗаполнитьОтправителяКонверта(ОбластьЗаголовок, ДанныеОбъектаПечати.СведенияОбОтправителеКонверта, ПараметрыВыводаВМакет);
	КонецЕсли;
	
КонецПроцедуры

Функция ПараметрыВыводаВМакет(ПараметрыПечати)
	
	Если ПараметрыПечати.ФорматКонверта = "C4" Тогда
		РазмерСтраницы = "Envelope C4";
		ДлинаПервойСтроки = 50;
		ДлинаВторойСтроки = 56;
	ИначеЕсли ПараметрыПечати.ФорматКонверта = "C5" Тогда
		РазмерСтраницы = "Envelope C5";
		ДлинаПервойСтроки = 35;
		ДлинаВторойСтроки = 46;
	Иначе
		РазмерСтраницы = "Envelope DL";
		ДлинаПервойСтроки = 55;
		ДлинаВторойСтроки = 65;
	КонецЕсли;
	
	ПараметрыВыводаВМакет = Новый Структура;
	ПараметрыВыводаВМакет.Вставить("РазмерСтраницы"   , РазмерСтраницы);
	ПараметрыВыводаВМакет.Вставить("ДлинаПервойСтроки", ДлинаПервойСтроки);
	ПараметрыВыводаВМакет.Вставить("ДлинаВторойСтроки", ДлинаВторойСтроки);
	Возврат ПараметрыВыводаВМакет;
	
КонецФункции

Процедура УстановитьПараметрыПечатиКонверта(ТабличныйДокумент, ПараметрыВыводаВМакет)
	
	ТабличныйДокумент.КлючПараметровПечати    = "ПАРАМЕТРЫ_ПЕЧАТИ_Конверт";
	ТабличныйДокумент.ПолеСверху              = 5;
	ТабличныйДокумент.ПолеСнизу               = 5;
	ТабличныйДокумент.ПолеСправа              = 5;
	ТабличныйДокумент.ПолеСлева               = 5;
	ТабличныйДокумент.РазмерСтраницы          = ПараметрыВыводаВМакет.РазмерСтраницы;
	ТабличныйДокумент.ОриентацияСтраницы      = ОриентацияСтраницы.Ландшафт;
	ТабличныйДокумент.АвтоМасштаб             = Истина;
	
КонецПроцедуры

Процедура ЗаполнитьПолучателяКонверта(ОбластьЗаголовок, СведенияОПолучателеКонверта, ПараметрыВыводаВМакет)
	
	ЧастиПредставлениеПолучателя = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивСлов(
		СведенияОПолучателеКонверта.Представление, " ");
	ЗаполнитьСекциюКонверта(ОбластьЗаголовок, "Кому", ЧастиПредставлениеПолучателя, ПараметрыВыводаВМакет);
	
	ЧастиАдреса = ЧастиАдресаДляВыводаВМакет(СведенияОПолучателеКонверта.Адрес);
	ЗаполнитьСекциюКонверта(ОбластьЗаголовок, "Куда", ЧастиАдреса, ПараметрыВыводаВМакет);
	
КонецПроцедуры

Процедура ЗаполнитьОтправителяКонверта(ОбластьЗаголовок, СведенияОбОтправителеКонверта, ПараметрыВыводаВМакет)
	
	ЧастиПредставленияОтправителя = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивСлов(
		СведенияОбОтправителеКонверта.Представление, " ");
	ЗаполнитьСекциюКонверта(ОбластьЗаголовок, "ОтКого", ЧастиПредставленияОтправителя, ПараметрыВыводаВМакет);
	
	ЧастиАдреса = ЧастиАдресаДляВыводаВМакет(СведенияОбОтправителеКонверта.Адрес);
	ЗаполнитьСекциюКонверта(ОбластьЗаголовок, "Откуда", ЧастиАдреса, ПараметрыВыводаВМакет);
	
	ОбластьЗаголовок.Параметры.ИндексОткуда = СведенияОбОтправителеКонверта.Индекс;
	
	Если СведенияОбОтправителеКонверта.ПечататьЛоготип Тогда
		ЗаполнитьЛоготип(ОбластьЗаголовок, СведенияОбОтправителеКонверта.Логотип);
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьКодовыйШтамп(ОбластьИндекс, СведенияОПолучателеКонверта)
	
	Если ЗначениеЗаполнено(СведенияОПолучателеКонверта) Тогда
		ИндексПолучателя = СведенияОПолучателеКонверта.Индекс;
	Иначе
		ИндексПолучателя = "";
	КонецЕсли; 
	
	// 20240520 Заяш 
	ИндексПолучателя = Строка_ПолучитьЦифры(ИндексПолучателя);
	
	Если ЗначениеЗаполнено(ИндексПолучателя) И СтрДлина(ИндексПолучателя) = 6 Тогда
		Для Каждого Рисунок Из ОбластьИндекс.Рисунки Цикл
			Если СтрНачинаетсяС(Рисунок.Имя, "Индекс") Тогда
				ПозицияИндекса = Прав(Рисунок.Имя, 1);
				ЦифраИндекса = Сред(ИндексПолучателя, ПозицияИндекса, 1);
				Если Не СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(ЦифраИндекса) Тогда
					Продолжить;
				КонецЕсли;
				Рисунок.Картинка = Новый Картинка(ЭтотОбъект.ПолучитьМакет("ИндексЦифра" + ЦифраИндекса));//БиблиотекаКартинок["ИндексЦифра" + ЦифраИндекса];
			Иначе
				Продолжить;
			КонецЕсли;
		КонецЦикла;
		ИндексКуда = Новый Структура("ИндексКуда", ИндексПолучателя);
		ОбластьИндекс.Параметры.Заполнить(ИндексКуда);
	Иначе
		Для Каждого Рисунок Из ОбластьИндекс.Рисунки Цикл
			Если СтрНачинаетсяС(Рисунок.Имя, "Индекс") Тогда
				Рисунок.Картинка = Новый Картинка(ЭтотОбъект.ПолучитьМакет("ИндексЦифраПустая"));//БиблиотекаКартинок.ИндексЦифраПустая;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьСекциюКонверта(Макет, ИмяСекции, Данные, ПараметрыВыводаВМакет)
	
	Если ИмяСекции = "ОтКого" Тогда
		ВысотаСекции = 1;
	ИначеЕсли ИмяСекции = "Кому" Тогда
		ВысотаСекции = 2;
	ИначеЕсли ИмяСекции = "Откуда" И ПараметрыВыводаВМакет.РазмерСтраницы = "Envelope DL" Тогда
		ВысотаСекции = 2;
	Иначе
		ВысотаСекции = 3;
	КонецЕсли;
	
	КоличествоВыведенныхВСекциюЭлементов = 0;
	ВГраницаМассиваДанных = Данные.ВГраница();
	Для НомерСекции = 1 По ВысотаСекции Цикл
		
		ИмяПараметра = ИмяСекции + НомерСекции;
		Если НомерСекции = 1 Тогда
			ДлинаСекции = ПараметрыВыводаВМакет.ДлинаПервойСтроки;
		Иначе
			ДлинаСекции = ПараметрыВыводаВМакет.ДлинаВторойСтроки;
		КонецЕсли;
		
		ЭлементыПараметра = Новый Массив;
		Пока КоличествоВыведенныхВСекциюЭлементов <= ВГраницаМассиваДанных 
			И СтрДлина(Данные[КоличествоВыведенныхВСекциюЭлементов]) <= ДлинаСекции Цикл
			
			ЭлементыПараметра.Добавить(Данные[КоличествоВыведенныхВСекциюЭлементов]);
			ДлинаСекции = ДлинаСекции - СтрДлина(Данные[КоличествоВыведенныхВСекциюЭлементов]);
			КоличествоВыведенныхВСекциюЭлементов = КоличествоВыведенныхВСекциюЭлементов + 1;
			
		КонецЦикла;
		ФинализироватьСекцию(ИмяПараметра, ЭлементыПараметра, Макет);
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаполнитьЛоготип(ОбластьЗаголовок, Логотип)
	
	Для Каждого Рисунок Из ОбластьЗаголовок.Рисунки Цикл
		Если Рисунок.Имя = "ЗонаИллюстраций" Тогда
			ОбластьЗаголовок.Рисунки.ЗонаИллюстраций.Картинка = Новый Картинка(Логотип);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ФинализироватьСекцию(ИмяПараметра, ЭлементыПараметра, Макет)
	
	ДанныеСекции = СтрСоединить(ЭлементыПараметра, " ");
	ДанныеСекции = СтрЗаменить(ДанныеСекции, "  ", " ");
	
	ЗначениеПараметра = Новый Структура(ИмяПараметра, ДанныеСекции);
	Макет.Параметры.Заполнить(ЗначениеПараметра);
	
КонецПроцедуры

Функция ЧастиАдресаДляВыводаВМакет(Адрес)
	
	ЧастиАдреса = СтрРазделить(Адрес, ",");
	Для НомерЧастиАдреса = 0 По ЧастиАдреса.Количество() - 2 Цикл
		ЧастиАдреса[НомерЧастиАдреса] =СокрЛП(ЧастиАдреса[НомерЧастиАдреса]) + "," + " ";
	КонецЦикла;
	Возврат ЧастиАдреса;
	
КонецФункции

Функция ПредставлениеПочтовогоАдреса(Адрес)
	
	Если Адрес.Свойство("ТипАдреса") И ВРег(Адрес.ТипАдреса) = ВРег("ВСвободнойФорме") Тогда
		Возврат Адрес.Представление;
	КонецЕсли;
	
	Результат = Новый Массив;
	ВыводитьСокращениеРегиона = Истина;
	
	Если Адрес.Свойство("Улица") И ЗначениеЗаполнено(Адрес.Улица) Тогда
		
		Если Адрес.Свойство("УлицаСокращение") И ЗначениеЗаполнено(Адрес.УлицаСокращение) Тогда
			Если Адрес.УлицаСокращение = "ул" Тогда
				ПредставлениеУлицы = Адрес.УлицаСокращение + ". " + Адрес.Улица;
			Иначе
				ПредставлениеУлицы = Адрес.Улица + " " + Адрес.УлицаСокращение + ".";
			КонецЕсли;
		Иначе
			ПредставлениеУлицы = Адрес.Улица;
		КонецЕсли;
		
		Результат.Добавить(ПредставлениеУлицы);
	КонецЕсли;
	
	Если Адрес.Свойство("ДополнительнаяТерритория") И ЗначениеЗаполнено(Адрес.ДополнительнаяТерритория) Тогда
		
		Если Адрес.Свойство("ДополнительнаяТерриторияСокращение") И ЗначениеЗаполнено(Адрес.ДополнительнаяТерриторияСокращение) Тогда
			ПредставлениеДопТерритории = Адрес.ДополнительнаяТерриторияСокращение + ". " + Адрес.ДополнительнаяТерритория;
		Иначе
			ПредставлениеДопТерритории = Адрес.ДополнительнаяТерритория;
		КонецЕсли;
		Результат.Добавить(ПредставлениеДопТерритории);
		
		Если Адрес.Свойство("ЭлементДополнительнойТерритории") И ЗначениеЗаполнено(Адрес.ЭлементДополнительнойТерритории) Тогда
			
			Если Адрес.Свойство("ЭлементДополнительнойТерриторииСокращение") И ЗначениеЗаполнено(Адрес.ЭлементДополнительнойТерриторииСокращение) Тогда
				
				Если Адрес.ЭлементДополнительнойТерриторииСокращение = "ул" Тогда
					ПредставлениеУлицы = Адрес.ЭлементДополнительнойТерриторииСокращение + ". " + Адрес.ЭлементДополнительнойТерритории;
				Иначе
					ПредставлениеУлицы = Адрес.ЭлементДополнительнойТерритории + " " + Адрес.ЭлементДополнительнойТерриторииСокращение;
				КонецЕсли;
			Иначе
				ПредставлениеУлицы = Адрес.ЭлементДополнительнойТерриторииСокращение;
			КонецЕсли;
			
			Результат.Добавить(ПредставлениеУлицы);
			
		КонецЕсли;
		
	КонецЕсли;
	
	Если Адрес.Свойство("Здание") И ЗначениеЗаполнено(Адрес.Здание.ТипЗдания) И ЗначениеЗаполнено(Адрес.Здание.Номер) Тогда
		ПредставлениеЗдания = НРег(Адрес.Здание.ТипЗдания) + " " + Адрес.Здание.Номер;
		Результат.Добавить(ПредставлениеЗдания);
	КонецЕсли;
	
	Если Адрес.Свойство("Корпуса") И ЗначениеЗаполнено(Адрес.Корпуса) Тогда
		ПредставлениеКорпусов = Новый Массив;
		Для Каждого Корпус Из Адрес.Корпуса Цикл
			ПредставлениеКорпусов.Добавить(НРег(Корпус.ТипКорпуса) + " " + Корпус.Номер);
		КонецЦикла;
		Результат.Добавить(СтрСоединить(ПредставлениеКорпусов, ", "));
	КонецЕсли;
	
	Если Адрес.Свойство("Помещения") И ЗначениеЗаполнено(Адрес.Помещения) Тогда
		ПредставлениеПомещений = Новый Массив;
		Для Каждого Помещение Из Адрес.Помещения Цикл
			Если НРег(Помещение.ТипПомещения) = "а/я" Или НРег(Помещение.ТипПомещения) = "в/ч" Тогда
				// Абонентский ящик - первый элемент адреса. Остальные элементы коллекции не имеют значения.
				Результат.Вставить(0, НРег(Помещение.ТипПомещения) + " " + Помещение.Номер);
				Прервать;
			КонецЕсли;
			ПредставлениеПомещений.Добавить(НРег(Помещение.ТипПомещения) + " " + Помещение.Номер);
		КонецЦикла;
		
		Если ЗначениеЗаполнено(ПредставлениеПомещений) Тогда
			Результат.Добавить(СтрСоединить(ПредставлениеПомещений, ", "));
		КонецЕсли;
	КонецЕсли;
	
	Если Адрес.Свойство("Город") И ЗначениеЗаполнено(Адрес.Город) Тогда
		Если Адрес.Свойство("ГородСокращение") И ЗначениеЗаполнено(Адрес.ГородСокращение) Тогда
			ПредставлениеГорода = НРег(Адрес.ГородСокращение) + ". " + Адрес.Город;
		Иначе
			ПредставлениеГорода = Адрес.Город;
		КонецЕсли;
		Результат.Добавить(ПредставлениеГорода);
		ВыводитьСокращениеРегиона = Ложь;
	КонецЕсли;
	
	Если Адрес.Свойство("ВнутригородскойРайон") И ЗначениеЗаполнено(Адрес.ВнутригородскойРайон) Тогда
		Если Адрес.Свойство("ВнутригородскойРайонСокращение") И ЗначениеЗаполнено(Адрес.ВнутригородскойРайонСокращение) Тогда
			ПредставлениеВнутригородскогоРайона = НРег(Адрес.ВнутригородскойРайонСокращение) + ". " + Адрес.ВнутригородскойРайон;
		Иначе
			ПредставлениеВнутригородскогоРайона = Адрес.ВнутригородскойРайон;
		КонецЕсли;
		Результат.Добавить(ПредставлениеВнутригородскогоРайона);
	КонецЕсли;
	
	Если Адрес.Свойство("НаселенныйПункт") И ЗначениеЗаполнено(Адрес.НаселенныйПункт) Тогда
		Если Адрес.Свойство("НаселенныйПунктСокращение") И ЗначениеЗаполнено(Адрес.НаселенныйПунктСокращение) Тогда
			ПредставлениеНаселенногоПункта = НРег(Адрес.НаселенныйПунктСокращение) + ". " + Адрес.НаселенныйПункт;
		Иначе
			ПредставлениеНаселенногоПункта = Адрес.НаселенныйПункт;
		КонецЕсли;
		Результат.Добавить(ПредставлениеНаселенногоПункта);
		ВыводитьСокращениеРегиона = Ложь;
	КонецЕсли;
	
	Если Адрес.Свойство("Район") И ЗначениеЗаполнено(Адрес.Район) Тогда
		Если Адрес.Свойство("РайонСокращение") И ЗначениеЗаполнено(Адрес.РайонСокращение) Тогда
			ПредставлениеРайона = Адрес.Район + " " + НРег(Адрес.РайонСокращение) + ".";
		Иначе
			ПредставлениеРайона = Адрес.Район;
		КонецЕсли;
		Результат.Добавить(ПредставлениеРайона);
	КонецЕсли;
	
	Если Адрес.Свойство("Округ") И ЗначениеЗаполнено(Адрес.Округ) Тогда
		Если Адрес.Свойство("ОкругСокращение") И ЗначениеЗаполнено(Адрес.ОкругСокращение) Тогда
			ПредставлениеОкруга = Адрес.Округ + " " + НРег(Адрес.ОкругСокращение) + ".";
		Иначе
			ПредставлениеОкруга = Адрес.Округ + " " + НРег(Адрес.ОкругСокращение) + ".";
		КонецЕсли;
		Результат.Добавить(ПредставлениеОкруга);
	КонецЕсли;
	
	Если Адрес.Свойство("Регион") И ЗначениеЗаполнено(Адрес.Регион) Тогда
		
		Если Адрес.КодРегиона = "77"           // Москва
			Или Адрес.КодРегиона = "78"        // Санкт-Петербург
			Или Адрес.КодРегиона = "92"        // Севастополь
			Или Адрес.КодРегиона = "99" Тогда  // Байконур
			
			// У города федерального значения префикс "г. " не пишется если речь идет о нас.пункте в составе города федерального значения.
			ПредставлениеРегиона = ?(ВыводитьСокращениеРегиона, "г. ", "") + Адрес.Регион;
		ИначеЕсли Адрес.КодРегиона = "21" Тогда // Чувашская республика - Чувашия
			ПредставлениеРегиона = НСтр("ru = 'Чувашская Республика - Чувашия'");
		Иначе
			Если Адрес.Свойство("РегионСокращение") И ЗначениеЗаполнено(Адрес.РегионСокращение) Тогда
				ПредставлениеРегиона = Адрес.Регион + " " + НРег(Адрес.РегионСокращение) + ".";
			Иначе
				ПредставлениеРегиона = Адрес.Регион;
			КонецЕсли;
			
		КонецЕсли;
		
		Результат.Добавить(ПредставлениеРегиона);
		
	КонецЕсли;
	
	Если Адрес.Свойство("Страна") И ЗначениеЗаполнено(Адрес.Страна) Тогда
		Результат.Добавить(ТРег(Адрес.Страна));
	КонецЕсли;
	
	Возврат СтрСоединить(Результат, "," + " ");
	
КонецФункции

Функция ПредставлениеИндекса(Адрес)
	
	Если Адрес.Свойство("ТипАдреса") И ВРег(Адрес.ТипАдреса) = ВРег("ВСвободнойФорме") Тогда
		Возврат ИндексИзПредставления(Адрес.Представление);
	КонецЕсли;
	
	Возврат Адрес.Индекс;
	
КонецФункции

Функция ИндексИзПредставления(ПредставлениеАдреса)
	
	ЧастиАдреса = СтрРазделить(ПредставлениеАдреса, ",");
	Для Каждого ЧастьАдреса Из ЧастиАдреса Цикл
		Если СтрДлина(СокрЛП(ЧастьАдреса)) = 6
			И СтроковыеФункцииКлиентСервер.ТолькоЦифрыВСтроке(СокрЛП(ЧастьАдреса)) Тогда
			Возврат СокрЛП(ЧастьАдреса);
		КонецЕсли;
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

#КонецОбласти 

// 20240520 Заяш 
#Область общ

// 20240520 Заяш 
Функция Строка_ПолучитьЦифры(пСтрока) Экспорт
	
	Возврат Строка_УбратьЛишниеСимволы(пСтрока, "0123456789");	
	
КонецФункции 

// 20240520 Заяш 
 Функция Строка_УбратьЛишниеСимволы(пСтрока, пПравильныеСимволы) Экспорт
	 
	строкаРезультат = "";
	Для Сч = 1 по СтрДлина(пСтрока) Цикл
		ТекСимв = Сред(пСтрока, Сч, 1);
		Если Найти(пПравильныеСимволы, ТекСимв) > 0 Тогда
			строкаРезультат = строкаРезультат + ТекСимв;
		КонецЕсли;
	КонецЦикла;
	
	Возврат строкаРезультат;
	
КонецФункции 

#КонецОбласти

