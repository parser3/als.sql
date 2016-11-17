# Als/Sql

Классы для работы с MySQL, Oracle, MSSQL и PgSQL.


## Info

Рекомендуется предварительно ознакомиться со [статьей](http://www.parser.ru/examples/sql/) о переносимости SQL запросов.

Так уж сложилось что меня не совсем устраивал стандартный функционал ^table::sql{}, ^hash::sql{} & Co. Например мне хотелось периодически получать информацию о времени выполнения запросов, количестве запросов выполненных при формировании документа, собирать в лог информацию о «медленных» запросах, кешировать результаты сложных запросов, выполнять connect автоматически и т.д.

Т.к. вносить изменения в код парсера для решения подобных задач мне показалось не правильным, то я написал SQL классы, которые обеспечивают требуемый мне функционал.


## Installation

```bash
$ composer require als/sql
```


## Basic Usage

Для подключения соответствующего класса в методе `@auto[]` корневого auto.p добавляем например строку:

```ruby
$oSql[^Als/Sql/MySql::create[$SQL.connect-string;
	$.sCacheDir[/../data/sql_cache]
]]
```

Более подробный пример можно посмотреть в файл [auto.p](doc/example/auto.p)


## References

- Bugs and feature request are tracked on [GitHub](https://github.com/parser3/als.sql/issues)
