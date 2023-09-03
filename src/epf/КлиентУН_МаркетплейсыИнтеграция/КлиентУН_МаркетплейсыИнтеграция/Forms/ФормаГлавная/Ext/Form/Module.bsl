﻿
&НаКлиенте
Перем мТекущиеЗапросыСервисаУН;

#Область СобытияФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбработкаОбъект = ЭтотОбъект();
	ОткрытаИзФайла = ОбработкаОбъект.ОбработкаОткрытаИзФайла();
	
	ОбработкаОбъект.УстановитьЗаголовок(ЭтотОбъект);
	
	Параметры.Свойство("ДополнительнаяОбработкаСсылка", Объект.ОбработкаСсылка);
	
	Элементы.ОбработкаСсылка.Видимость = (
		ОткрытаИзФайла
		ИЛИ НЕ ЗначениеЗаполнено(Объект.ОбработкаСсылка)
	);
	
	// ЗАГЛУШКА / УДАЛИТЬ ПОСЛЕ ТЕСТИРОВАНИЯ
	//Элементы.ФормаОтправления.Видимость = ОткрытаИзФайла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ЭтотОбъект.Активизировать();
КонецПроцедуры

&НаКлиенте
Процедура ПриАктивизацииФормы() Экспорт
	//
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "КлиентУН_ИзмененоСостояниеОтладки" И Источник <> ЭтотОбъект Тогда
		Объект.Отладка = Параметр;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СобытияЭлементовФормы

&НаКлиенте
Процедура ОткрытьФормуВТекущемОкне(Команда)
	ОткрытьФормуОбработки(Команда.Имя, ЭтотОбъект);
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаСсылкаПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Объект.ОбработкаСсылка) Тогда
		Параметры.ДополнительнаяОбработкаСсылка = Объект.ОбработкаСсылка;
		Элементы.ОбработкаСсылка.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ЗапросыСервисаИнтеграции

&НаКлиенте
Функция ТекущиеЗапросыСервисаУН() Экспорт
	
	Если ТипЗнч(мТекущиеЗапросыСервисаУН) = Тип("Структура") Тогда
		Возврат мТекущиеЗапросыСервисаУН;
	КонецЕсли;
	
	ЗапросыСервиса = Новый Структура;
	
	// Настройки ожидания
	ЗапросыСервиса.Вставить("ПериодОпросаРезультата",	2);
	ЗапросыСервиса.Вставить("ПериодХраненияРезультата",	300);
	ЗапросыСервиса.Вставить("ПериодХраненияОшибок",		600);
	
	// Состояние
	ЗапросыСервиса.Вставить("ОжиданиеРезультатов",	Ложь);
	ЗапросыСервиса.Вставить("Запросы",				Новый Массив);
	ЗапросыСервиса.Вставить("ЗапросыПоХешу",		Новый Соответствие);
	ЗапросыСервиса.Вставить("ЗапросыПоИд",			Новый Соответствие);
	
	мТекущиеЗапросыСервисаУН = ЗапросыСервиса;
	
	Возврат ЗапросыСервиса;
	
КонецФункции

&НаКлиенте
Функция ВидыЗапросовСервисаУН() Экспорт
	
	МассивВидов = Новый Массив;
	
	МассивВидов.Добавить("ПоставкаЗапросить");
	МассивВидов.Добавить("ПоставкаСоздать");
	МассивВидов.Добавить("ПоставкаЗакрыть");
	МассивВидов.Добавить("ПоставкаДобавитьЗаказы");
	// TODO: добавить остальные
	
	ВидыЗапросов = Новый Структура;
	Для Каждого Вид Из МассивВидов Цикл
		ВидыЗапросов.Вставить(Вид, Вид);
	КонецЦикла;
	
	Возврат ВидыЗапросов;
	
КонецФункции

&НаКлиенте
Функция ОбработчикРезультатаСервисаУН(ИмяПроцедуры, ФормаОбработчика, Знач ДопПараметры = Неопределено) Экспорт
	ДопПараметры = ЕслиПусто(ДопПараметры, Новый Структура);
	Возврат Новый ОписаниеОповещения(ИмяПроцедуры, ФормаОбработчика, ДопПараметры);
КонецФункции

&НаКлиенте
Функция ЗапросСервисаУН(Организация, Вид, Знач ПараметрыЗапроса = Неопределено, ОбработчикРезультата = Неопределено, Таймаут = 60) Экспорт
	
	ПараметрыЗапроса = ЕслиПусто(ПараметрыЗапроса, Новый Структура);
	
	ТекущиеЗапросы = ТекущиеЗапросыСервисаУН();
	
	Хеш = ХешЗапросаСервиса(Вид, ПараметрыЗапроса);
	
	НайденныйЗапросСервиса = ТекущиеЗапросы.ЗапросыПоХешу.Получить(Хеш);
	
	ЭтоПовтор = (
		НайденныйЗапросСервиса <> Неопределено
		И НЕ НайденныйЗапросСервиса.Ошибка
		И НЕ ЗначениеЗаполнено(НайденныйЗапросСервиса.ДатаОбработки)
	);
	
	ЗапросСервиса = Новый Структура;
	
	ЗапросСервиса.Вставить("Организация",	Организация);
	ЗапросСервиса.Вставить("Вид",			Вид);
	ЗапросСервиса.Вставить("Хеш",			Хеш);
	ЗапросСервиса.Вставить("Идентификатор",	"");
	ЗапросСервиса.Вставить("Обработчик",	ОбработчикРезультата);
	ЗапросСервиса.Вставить("ДатаСоздания",	ТекущаяДата());  // клиентская!
	ЗапросСервиса.Вставить("ДатаЗапроса",	'00010101');
	ЗапросСервиса.Вставить("ДатаПроверки",	'00010101');
	ЗапросСервиса.Вставить("ДатаОтвета",	'00010101');
	ЗапросСервиса.Вставить("ДатаРезультата",'00010101');
	ЗапросСервиса.Вставить("ДатаОбработки",	'00010101');
	ЗапросСервиса.Вставить("ДатаТаймаута",	ТекущаяДата() + Таймаут);
	ЗапросСервиса.Вставить("Параметры",		ПараметрыЗапроса);
	ЗапросСервиса.Вставить("ЭтоПовтор",		ЭтоПовтор);
	ЗапросСервиса.Вставить("Результат",		Неопределено);
	ЗапросСервиса.Вставить("Ошибка",		Ложь);
	ЗапросСервиса.Вставить("ТекстОшибки",	"");
	
	Если НайденныйЗапросСервиса <> Неопределено И НЕ ЭтоПовтор Тогда
		УдалитьЗапросСервисаУН(НайденныйЗапросСервиса);
	КонецЕсли;
	
	Возврат ЗапросСервиса;
	
КонецФункции

&НаКлиенте
Процедура ДобавитьЗапросСервисаУН(ЗапросСервисаУН) Экспорт
	
	ТекущиеЗапросы = ТекущиеЗапросыСервисаУН();
	
	ЗапросСервисаУН.ДатаЗапроса = ТекущаяДата();
	
	ТекущиеЗапросы.Запросы.Добавить(ЗапросСервисаУН);
	ТекущиеЗапросы.ЗапросыПоХешу.Вставить(ЗапросСервисаУН.Хеш, ЗапросСервисаУН);
	ТекущиеЗапросы.ЗапросыПоИд.Вставить(ЗапросСервисаУН.Идентификатор, ЗапросСервисаУН);
	
	// TODO: реализовать
	// СохранитьЗапросыСервисаУН(ТекущиеЗапросы);
	
	Если ЕстьАктивныеЗапросыСервисаУН() Тогда
		НачатьОжиданиеРезультатовЗапросовУН();
	КонецЕсли;
	
	Оповестить("ОбновитьОчередьЗапросовСервисаУН", , ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Процедура НачатьОжиданиеРезультатовЗапросовУН()
	
	ТекущиеЗапросы = ТекущиеЗапросыСервисаУН();
	
	ПодключитьОбработчикОжидания(
		"ПроверитьРезультатЗапросаСервисаУН",
		ТекущиеЗапросы.ПериодОпросаРезультата,
		Истина
	);
	ТекущиеЗапросы.ОжиданиеРезультатов = Истина;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверитьРезультатЗапросаСервисаУН()
	ОтключитьОбработчикОжидания("ПроверитьРезультатЗапросаСервисаУН");
	
	// Обходим текущие запросы и получаем от них результаты
	ТекущиеЗапросы = ТекущиеЗапросыСервисаУН();
	ТекущиеЗапросы.ОжиданиеРезультатов = Ложь;
	
	МассивЗапросов = ТекущиеЗапросы.Запросы;
	
	ЗапросыОрганизаций = Новый Соответствие;
	Для Каждого Запрос Из МассивЗапросов Цикл
		
		Если Запрос.Ошибка Тогда
			Продолжить;
		КонецЕсли;
		
		ИдентификаторыЗапросов = ЗапросыОрганизаций.Получить(Запрос.Организация);
		
		Если ИдентификаторыЗапросов = Неопределено Тогда
			ИдентификаторыЗапросов = Новый Массив;
			ЗапросыОрганизаций[Запрос.Организация] = ИдентификаторыЗапросов;
		КонецЕсли;
		
		ИдентификаторыЗапросов.Добавить(Запрос.Идентификатор);
		
		Запрос.ДатаПроверки = ТекущаяДата();
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ЗапросыОрганизаций) Тогда
		
		РезультатыЗапросов = РезультатыЗапросовСервисаУН(ЗапросыОрганизаций);
		
		// Фиксируем ответы
		Для Каждого РезультатЗапроса Из РезультатыЗапросов Цикл
			Запрос = ТекущиеЗапросы.ЗапросыПоИд.Получить(РезультатЗапроса.Идентификатор);
			
			Запрос.ДатаОтвета = ТекущаяДата();
			
			Если РезультатЗапроса.Ошибка Тогда
				Запрос.Ошибка = Истина;
				Запрос.ТекстОшибки = РезультатЗапроса.ТекстОшибки;
			КонецЕсли;
			
			Если НЕ РезультатЗапроса.Обработано Тогда
				Продолжить;
			КонецЕсли;
			
			Запрос.Ошибка = Ложь;
			Запрос.ТекстОшибки = "";
			
			Запрос.ДатаРезультата = РезультатЗапроса.ДатаОбработки;
			Запрос.Результат = РезультатЗапроса.Результат;
			
		КонецЦикла;
		
	КонецЕсли;
	
	// Проверяем на наличие результатов
	Для Каждого Запрос Из МассивЗапросов Цикл
		
		Если ЭтоАктивныйЗапросСервисаУН(Запрос) И ТекущаяДата() > Запрос.ДатаТаймаута Тогда
			Запрос.Ошибка = Истина;
			Запрос.ТекстОшибки = "Таймаут ожидания результата запроса!";
		КонецЕсли;
		
		Если ЗначениеЗаполнено(Запрос.ДатаОбработки) Тогда
			Продолжить;  // уже обработан ранее
		КонецЕсли;
		
		Если НЕ ЗначениеЗаполнено(Запрос.ДатаРезультата) И НЕ Запрос.Ошибка Тогда
			Продолжить;  // не было ни ошибки, ни получения результата, ждём ещё
		КонецЕсли;
		
		Если Запрос.Обработчик <> Неопределено Тогда
			Попытка
				ВыполнитьОбработкуОповещения(Запрос.Обработчик, Запрос);
			Исключение
				ОшибкиДоИсключения = "";
				Если ЗначениеЗаполнено(Запрос.ТекстОшибки) Тогда
					ОшибкиДоИсключения = Запрос.ТекстОшибки + Символы.ПС + Символы.ПС;
				КонецЕсли;
				Запрос.ТекстОшибки = ОшибкиДоИсключения + ОписаниеОшибки();
				Запрос.Ошибка = Истина;
				ТекстИсключения = СтрШаблон(
					"Ошибка при обработке результата запроса:
					|Организация: %1
					|Вид: %2
					|Идентификатор: %3
					|Текст ошибки:
					|%4",
					Запрос.Организация,
					Запрос.Вид,
					Запрос.Идентификатор,
					Запрос.ТекстОшибки
				);
				ВызватьИсключение ТекстИсключения;
			КонецПопытки;
		КонецЕсли;
		
		Запрос.ДатаОбработки = ТекущаяДата();
	КонецЦикла;
	
	// Удаляем неактуальные запросы (обходим их массив с конца)
	Для Индекс = -МассивЗапросов.ВГраница() По 0 Цикл
		Запрос = МассивЗапросов[-Индекс];
		УдалитьЗапрос = Ложь;
		
		Если ЗначениеЗаполнено(Запрос.ДатаОбработки)
			И ТекущаяДата() - Запрос.ДатаОбработки > ТекущиеЗапросы.ПериодХраненияРезультата
			Тогда
			УдалитьЗапрос = Истина;
		КонецЕсли;
		
		Если Запрос.Ошибка
			И ТекущаяДата() - Запрос.ДатаСоздания > ТекущиеЗапросы.ПериодХраненияОшибок
			Тогда
			УдалитьЗапрос = Истина;
		КонецЕсли;
		
		Если УдалитьЗапрос Тогда
			//ТекущиеЗапросы.ЗапросыПоХешу.Удалить(Запрос.Хеш);
			//ТекущиеЗапросы.ЗапросыПоИд.Удалить(Запрос.Идентификатор);
			//МассивЗапросов.Удалить(-Индекс);
			УдалитьЗапросСервисаУН(Запрос);
		КонецЕсли;
		
	КонецЦикла;
	
	// Если есть активные запросы - продолжаем ожидание
	Если ЕстьАктивныеЗапросыСервисаУН() Тогда
		НачатьОжиданиеРезультатовЗапросовУН();
	КонецЕсли;

	Оповестить("ОбновитьОчередьЗапросовСервисаУН", , ЭтотОбъект);
	
КонецПроцедуры

&НаКлиенте
Функция ЕстьАктивныеЗапросыСервисаУН()
	
	ТекущиеЗапросы = ТекущиеЗапросыСервисаУН();
	
	// Если есть активные запросы - продолжаем ожидание
	Для Каждого Запрос Из ТекущиеЗапросы.Запросы Цикл
		Если ЭтоАктивныйЗапросСервисаУН(Запрос) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

&НаКлиенте
Функция ЭтоАктивныйЗапросСервисаУН(Запрос)
	Возврат НЕ ЗначениеЗаполнено(Запрос.ДатаОбработки);
КонецФункции

&НаКлиенте
Функция УдалитьЗапросСервисаУН(ЗапросСервисаУН)
	
	ТекущиеЗапросы = ТекущиеЗапросыСервисаУН();
	ТекущиеЗапросы.ЗапросыПоХешу.Удалить(ЗапросСервисаУН.Хеш);
	ТекущиеЗапросы.ЗапросыПоИд.Удалить(ЗапросСервисаУН.Идентификатор);
	
	ТекущиеЗапросы.Запросы.Удалить(ТекущиеЗапросы.Запросы.Найти(ЗапросСервисаУН));
	
КонецФункции

&НаКлиенте
Функция РезультатыЗапросовСервисаУН(ЗапросыОрганизаций)
	
	Если ОткрытаИзФайла Тогда
		Возврат РезультатыЗапросовСервисаУННаСервере(ЗапросыОрганизаций);
	Иначе
		Возврат РезультатыЗапросовСервисаУННаСервереБезКонтекста(Объект.ОбработкаСсылка, ЗапросыОрганизаций, Объект.Отладка)
	КонецЕсли;
	
КонецФункции

&НаСервере
Функция РезультатыЗапросовСервисаУННаСервере(ЗапросыОрганизаций)
	
	РезультатыЗапросов = Новый Массив;
	
	ОбработкаОбъект = ЭтотОбъект();
	
	Для Каждого ЗапросыОрганизации Из ЗапросыОрганизаций Цикл
		Организация = ЗапросыОрганизации.Ключ;
		ИдентификаторыЗапросов = ЗапросыОрганизации.Значение;
		
		МассивРезультатов = ОбработкаОбъект.КомандыПолучитьРезультатСервиса(Организация, ИдентификаторыЗапросов);
		Для Каждого Элемент Из МассивРезультатов Цикл
			РезультатыЗапросов.Добавить(Элемент);
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат РезультатыЗапросов;
	
КонецФункции

&НаСервереБезКонтекста
Функция РезультатыЗапросовСервисаУННаСервереБезКонтекста(ОбработкаСсылка, ЗапросыОрганизаций, Отладка = Ложь)
	
	РезультатыЗапросов = Новый Массив;
	
	ОбработкаОбъект = ОбработкаОбъект(ОбработкаСсылка, Отладка);
	
	Для Каждого ЗапросыОрганизации Из ЗапросыОрганизаций Цикл
		Организация = ЗапросыОрганизации.Ключ;
		ИдентификаторыЗапросов = ЗапросыОрганизации.Значение;
		
		МассивРезультатов = ОбработкаОбъект.КомандыПолучитьРезультатСервиса(Организация, ИдентификаторыЗапросов);
		Для Каждого Элемент Из МассивРезультатов Цикл
			РезультатыЗапросов.Добавить(Элемент);
		КонецЦикла;
		
	КонецЦикла;
	
	Возврат РезультатыЗапросов;
	
КонецФункции

&НаСервереБезКонтекста
Процедура СохранитьЗапросыСервисаУН(ТекущиеЗапросы)
	// TODO: добавить сохранение в настройках или файле на
	// сервере текущих запросов, чтобы при падении клиента
	// и повторном входе в форму можно было восстановить их
КонецПроцедуры

&НаСервереБезКонтекста
Функция ХешЗапросаСервиса(Знач Вид, Знач ПараметрыЗапроса = Неопределено)
	
	Если ПараметрыЗапроса = Неопределено Тогда
		ПараметрыЗапроса = Новый Структура;
	КонецЕсли;
	
	СтруктураЗапроса = Новый Структура("Вид, Параметры", Вид, ПараметрыЗапроса);
	
	Контейнер = Новый ХранилищеЗначения(СтруктураЗапроса);
	
	// TODO: определить хеш
	Хешер = Новый ХешированиеДанных(ХешФункция.SHA1);
	Хешер.Добавить(XMLСтрока(Контейнер));
	
	Возврат XMLСтрока(Хешер.ХешСумма);
	
КонецФункции

&НаКлиенте
Функция ПоказатьОчередьЗапросовСервисаУН() Экспорт
	
	ИмяФормыОчереди = СтрШаблон("ВнешняяОбработка.%1.Форма.%2", ИмяОбработки(), "ФормаОчередьЗапросов");
	
	ФормаОчереди = ОткрытьФорму(ИмяФормыОчереди, , ЭтотОбъект, , , , , РежимОткрытияОкнаФормы.Независимый);
	ФормаОчереди.ЗакрыватьПриЗакрытииВладельца = Истина;
	ФормаОчереди.ОбновитьОчередьЗапросовСервисаУН();
	
КонецФункции

#КонецОбласти

#Область ВспомогательныеМетоды

&НаКлиенте
Функция ОткрытьФормуОбработки(ИмяФормы, ФормаИсточник = Неопределено, ПараметрыОткрытия = Неопределено) Экспорт
	
	Если НЕ ЗначениеЗаполнено(Объект.ОбработкаСсылка) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ПолноеИмяОткрываемойФормы = СтрШаблон(
		"ВнешняяОбработка.%1.Форма.%2",
		ИмяОбработки(), ИмяФормы
	);
	
	Если ФормаИсточник = Неопределено Тогда
		ФормаИсточник = ЭтотОбъект;
	КонецЕсли;
	
	Если ПолноеИмяОткрываемойФормы = ФормаИсточник.ИмяФормы Тогда
		Возврат ФормаИсточник;
	КонецЕсли;
	
	Для Каждого ОткрытаяФорма Из ЭтотОбъект.Окно.Содержимое Цикл
		Если ОткрытаяФорма.ИмяФормы = ПолноеИмяОткрываемойФормы Тогда
			ОткрытаяФорма.Активизировать();
			Попытка
				ОткрытаяФорма.ПриАктивизацииФормы();
			Исключение
				// Методо "ПриАктивизацииФормы" необязательный у формы
				ТекстОшибки = ОписаниеОшибки();
			КонецПопытки;
			Возврат ОткрытаяФорма;
		КонецЕсли;
	КонецЦикла;
	
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ДополнительнаяОбработкаСсылка", Объект.ОбработкаСсылка);
	
	Если ПараметрыОткрытия = Неопределено Тогда
		ПараметрыОткрытия = Новый Структура;
	КонецЕсли;
	Для Каждого Элемент Из ПараметрыОткрытия Цикл
		ПараметрыФормы.Вставить(Элемент.Ключ, Элемент.Значение);
	КонецЦикла;
	
	Возврат ОткрытьФорму(
		ПолноеИмяОткрываемойФормы,
		ПараметрыФормы,
		ЭтотОбъект,
		,  // Уникальность
		ЭтотОбъект.Окно
	);
	
КонецФункции

&НаСервере
Функция ИмяОбработки()
	Возврат ЭтотОбъект().Метаданные().Имя;
КонецФункции

&НаСервере
Функция ЭтотОбъект()
	Возврат РеквизитФормыВЗначение("Объект");
КонецФункции

&НаСервереБезКонтекста
Функция ОбработкаОбъект(Знач ОбработкаСсылка, Знач Отладка = Ложь)
	
	ОбработкаОбъект = ДополнительныеОтчетыИОбработки.ОбъектВнешнейОбработки(ОбработкаСсылка);
	ОбработкаОбъект.ОбработкаСсылка = ОбработкаСсылка;
	ОбработкаОбъект.Отладка = Отладка;
	
	Возврат ОбработкаОбъект;
	
КонецФункции

#КонецОбласти

#Область Общие

&НаКлиентеНаСервереБезКонтекста
Функция ЕстьРеквизит(Объект, ИмяРеквизита) Экспорт
	
	КлючУникальности   = Новый УникальныйИдентификатор;
	СтруктураРеквизита = Новый Структура(ИмяРеквизита, КлючУникальности);
	ЗаполнитьЗначенияСвойств(СтруктураРеквизита, Объект);
	
	Возврат СтруктураРеквизита[ИмяРеквизита] <> КлючУникальности;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ЕслиПусто(Значение, ЗначениеПоУмолчанию)
	Если ЗначениеЗаполнено(Значение) Тогда
		Возврат Значение;
	Иначе
		Возврат ЗначениеПоУмолчанию;
	КонецЕсли;
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция НовыйМассив(Знч1, Знч2 = Null, Знч3 = Null, Знч4 = Null, Знч5 = Null)
	
	НовыйМассив = Новый Массив;
	
	Для Сч = 1 По 5 Цикл
		ТекЗнч = Вычислить("Знч" + Сч);
		Если ТекЗнч <> Null Тогда
			НовыйМассив.Добавить(ТекЗнч);
		КонецЕсли;
	КонецЦикла;
	
	Возврат НовыйМассив;
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ТипЧисло(ЧислоРазрядов = 0, ЧислоРазрядовДробнойЧасти = 0, Неотрицательное = Ложь)
	
	Если Неотрицательное Тогда
		ДопустимыйЗнакЧисла = ДопустимыйЗнак.Неотрицательный;
	Иначе
		ДопустимыйЗнакЧисла = ДопустимыйЗнак.Любой;
	КонецЕсли;
	
	КвалификаторыЧисла = Новый КвалификаторыЧисла(
		ЧислоРазрядов,
		ЧислоРазрядовДробнойЧасти,
		ДопустимыйЗнакЧисла
	);
	
	Возврат Новый ОписаниеТипов("Число", КвалификаторыЧисла);
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ТипСтрока(Длина = 0, Фиксированная = Ложь)
	
	Если Фиксированная Тогда
		ДопустимаяДлинаСтроки = ДопустимаяДлина.Фиксированная;
	Иначе
		ДопустимаяДлинаСтроки = ДопустимаяДлина.Переменная;
	КонецЕсли;
	
	КвалификаторыСтроки = Новый КвалификаторыСтроки(Длина, ДопустимаяДлинаСтроки);
	
	Возврат Новый ОписаниеТипов("Строка", , КвалификаторыСтроки);
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ТипДата(СоставДаты = Неопределено)
	
	Если СоставДаты = Неопределено Тогда
		СоставДаты = ЧастиДаты.ДатаВремя;
	КонецЕсли;
	
	КвалификаторыДаты = Новый КвалификаторыДаты(СоставДаты);
	
	Возврат Новый ОписаниеТипов("Дата", , , КвалификаторыДаты);
	
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ТипБулево()
	Возврат Новый ОписаниеТипов("Булево");
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция ТипСсылка(ИмяТипа)
	Возврат Новый ОписаниеТипов(ИмяТипа);
КонецФункции

&НаКлиентеНаСервереБезКонтекста
Функция КлючиОбъекта(ОбъектКоллекцияСКлючами)
	
	Ключи = Новый Массив;
	
	Для Каждого Элемент Из ОбъектКоллекцияСКлючами Цикл
		Ключи.Добавить(Элемент.Ключ);
	КонецЦикла;
	
	Возврат Ключи;
	
КонецФункции

#КонецОбласти
