﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("Заказ", Заказ);
	
	ЗаполнитьТоварыЗаказа();
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	// Проверяем, что таблица не поменялась в целом
	тзТоварыИсходные = ТоварыИсходные.Выгрузить(, "Номенклатура, Количество");
	тзТоварыИсходные.Свернуть("Номенклатура", "Количество");
	
	тзТовары = Товары.Выгрузить(, "Номенклатура, Количество");
	тзТовары.Свернуть("Номенклатура", "Количество");
	
	ХешИсходной = ХешТаблицы(тзТоварыИсходные, "Номенклатура");
	ХешТекущей = ХешТаблицы(тзТовары, "Номенклатура");
	
	Если ХешИсходной <> ХешТекущей Тогда
		Отказ = Истина;
		Сообщить(
			"Состав товаров и/или их количество изменилось!
			|Сохранение невозможно!"
		);
		Возврат;
	КонецЕсли;
	
	// Контроль содержимого строк
	Для Каждого СтрТаб Из Товары Цикл
		
		// Колонка "Коробка" должна быть заполнена
		Если НЕ ЗначениеЗаполнено(СтрТаб.Коробка) Тогда
			Сообщить(СтрШаблон(
				"Не выбрана коробка для товара: %1",
				СтрТаб.Номенклатура
			));
			Отказ = Истина;
		КонецЕсли;
		
		// Колонка "Код" должна быть заполнена
		Если НЕ ЗначениеЗаполнено(СтрТаб.Код) Тогда
			Сообщить(СтрШаблон(
				"Не определен код товара: %1",
				СтрТаб.Номенклатура
			));
			Отказ = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы
// Код процедур и функций
#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыТовары
// Код процедур и функций
#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Готово(Команда)
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	Коробки = Новый Соответствие;
	Для Каждого СтрТаб Из Товары Цикл
		
		ТоварыКоробки = Коробки.Получить(СтрТаб.Коробка);
		Если ТоварыКоробки = Неопределено Тогда
			ТоварыКоробки = Новый Массив;
			Коробки.Вставить(СтрТаб.Коробка, ТоварыКоробки);
		КонецЕсли;
		
		ОписаниеСтрокиЗаказа = ОписаниеСтрокиЗаказа(СтрТаб);
		ТоварыКоробки.Добавить(ОписаниеСтрокиЗаказа);
		
	КонецЦикла;
	
	Результат = Новый Структура;
	Результат.Вставить("КоробкиЗаказа", Новый Массив);
	
	Для НомерКоробки = 1 По Элементы.ТоварыКоробка.МаксимальноеЗначение Цикл
		
		ТоварыКоробки = Коробки.Получить(НомерКоробки);
		Если ТоварыКоробки = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		Коробка = Новый Структура;
		Коробка.Вставить("Товары", ТоварыКоробки);
		Результат.КоробкиЗаказа.Добавить(Коробка);
		
	КонецЦикла;
	
	Закрыть(Результат);
	
КонецПроцедуры

&НаКлиенте
Процедура СтрокаВКоробку(Команда)
	
	Сч = 1;
	Для Каждого СтрТаб Из Товары Цикл
		СтрТаб.Коробка = Сч;
		Сч = Сч + 1;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ШтукаВКоробку(Команда)
	
	ТоварыТаблицы = Новый Соответствие;
	
	Для Каждого СтрТаб Из Товары Цикл
		
		ДанныеТовара = ТоварыТаблицы.Получить(СтрТаб.Номенклатура);
		Если ДанныеТовара = Неопределено Тогда
			ДанныеТовара = ДанныеТовара(СтрТаб);
			ТоварыТаблицы[СтрТаб.Номенклатура] = ДанныеТовара;
		КонецЕсли;
		
		ДанныеТовара.Количество = ДанныеТовара.Количество + СтрТаб.Количество;
		
	КонецЦикла;
	
	Товары.Очистить();
	
	Кор = 1;
	Для Каждого Элемент Из ТоварыТаблицы Цикл
		ДанныеТовара = Элемент.Значение;
		Для Сч = 1 По ДанныеТовара.Количество Цикл
			СтрТаб = Товары.Добавить();
			СтрТаб.Номенклатура = Элемент.Ключ;
			СтрТаб.Код = ДанныеТовара.Код;
			СтрТаб.Количество = 1;
			СтрТаб.Коробка = Кор;
			Кор = Кор + 1;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ВсеВКоробку(Команда)
	
	ТоварыТаблицы = Новый Соответствие;
	
	Для Каждого СтрТаб Из Товары Цикл
		
		ДанныеТовара = ТоварыТаблицы.Получить(СтрТаб.Номенклатура);
		Если ДанныеТовара = Неопределено Тогда
			ДанныеТовара = ДанныеТовара(СтрТаб);
			ТоварыТаблицы[СтрТаб.Номенклатура] = ДанныеТовара;
		КонецЕсли;
		
		ДанныеТовара.Количество = ДанныеТовара.Количество + СтрТаб.Количество;
		
	КонецЦикла;
	
	Товары.Очистить();
	
	Для Каждого Элемент Из ТоварыТаблицы Цикл
		ДанныеТовара = Элемент.Значение;
		СтрТаб = Товары.Добавить();
		СтрТаб.Номенклатура = Элемент.Ключ;
		СтрТаб.Код = ДанныеТовара.Код;
		СтрТаб.Количество = ДанныеТовара.Количество;
		СтрТаб.Коробка = 1;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Функция ДанныеТовара(СтрокаЗаказа)
	
	ДанныеТовара = Новый Структура;
	
	ДанныеТовара.Вставить("Код", СтрокаЗаказа.Код);
	ДанныеТовара.Вставить("Количество", 0);
	
	Возврат ДанныеТовара;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ОписаниеСтрокиЗаказа(СтрокаЗаказа)
	
	ОписаниеСтроки = Новый Структура("Номенклатура, Код, Количество");
	ЗаполнитьЗначенияСвойств(ОписаниеСтроки, СтрокаЗаказа);
	
	Возврат ОписаниеСтроки;
	
КонецФункции

&НаСервере
Процедура ЗаполнитьТоварыЗаказа()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Заказ", Заказ);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ЗаказКлиентаТовары.Номенклатура КАК Номенклатура,
	|	ЗаказКлиентаТовары.Номенклатура.Код КАК Код,
	|	ЗаказКлиентаТовары.Количество КАК Количество
	|ИЗ
	|	Документ.ЗаказКлиента.Товары КАК ЗаказКлиентаТовары
	|ГДЕ
	|	ЗаказКлиентаТовары.Ссылка = &Заказ
	|
	|УПОРЯДОЧИТЬ ПО
	|	ЗаказКлиентаТовары.НомерСтроки";
	
	ТоварыЗаказа = Запрос.Выполнить().Выгрузить();
	
	ТоварыИсходные.Загрузить(ТоварыЗаказа);  // для дальнейшей валидации на количество
	Товары.Загрузить(ТоварыЗаказа);
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ХешТаблицы(Таблица, ПоляСортировки)
	
	Таблица.Сортировать(ПоляСортировки);
	ТипХеша = ХешФункция.SHA1;
	
	Возврат КонтрольнаяСуммаСтрокой(Таблица, ТипХеша);
	
КонецФункции

#Область ПроцедурыИФункцииОбщегоНазначения

// Вычисляет контрольную сумму для произвольных данных по указанному алгоритму.
//
// Параметры:
//  Данные   - Произвольный - любое сериализуемое значение.
//  Алгоритм - ХешФункция   - алгоритм расчета контрольной суммы. По умолчанию, MD5.
// 
// Возвращаемое значение:
//  Строка - контрольная сумма строкой без пробелов (например 32 символа).
//
&НаСервереБезКонтекста
Функция КонтрольнаяСуммаСтрокой(Знач Данные, Знач Алгоритм = Неопределено)
	
	Если Алгоритм = Неопределено Тогда
		Алгоритм = ХешФункция.MD5;
	КонецЕсли;
	
	ХешированиеДанных = Новый ХешированиеДанных(Алгоритм);
	Если ТипЗнч(Данные) <> Тип("Строка") И ТипЗнч(Данные) <> Тип("ДвоичныеДанные") Тогда
		Данные = ЗначениеВСтрокуXML(Данные);
	КонецЕсли;
	ХешированиеДанных.Добавить(Данные);
	
	Если ТипЗнч(ХешированиеДанных.ХешСумма) = Тип("ДвоичныеДанные") Тогда 
		Результат = СтрЗаменить(ХешированиеДанных.ХешСумма, " ", "");
	ИначеЕсли ТипЗнч(ХешированиеДанных.ХешСумма) = Тип("Число") Тогда
		Результат = Формат(ХешированиеДанных.ХешСумма, "ЧГ=");
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Преобразует (сериализует) любое значение в XML-строку.
// Преобразованы в могут быть только те объекты, для которых в синтакс-помощнике указано, что они сериализуются.
// См. также ЗначениеИзСтрокиXML.
//
// Параметры:
//  Значение - Произвольный - значение, которое необходимо сериализовать в XML-строку.
//
// Возвращаемое значение:
//  Строка - XML-строка.
//
&НаСервереБезКонтекста
Функция ЗначениеВСтрокуXML(Значение) Экспорт
	
	ЗаписьXML = Новый ЗаписьXML;
	ЗаписьXML.УстановитьСтроку();
	СериализаторXDTO.ЗаписатьXML(ЗаписьXML, Значение, НазначениеТипаXML.Явное);
	
	Возврат ЗаписьXML.Закрыть();
КонецФункции

#КонецОбласти

#КонецОбласти
