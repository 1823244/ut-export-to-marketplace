﻿
&НаСервере
Процедура ВыгрузитьСвободныеОстаткиНаСервере()
	РеквизитФормыВЗначение("Объект").ВыполнитьЭкспорт();
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьСвободныеОстатки(Команда)
	ВыгрузитьСвободныеОстаткиНаСервере();
КонецПроцедуры
