-- Проект выполняется в интерактивном тренажере на платформе Яндекс.Практикума --
/* Состоит из 23 заданий на составление запросов к БД (PostgreSQL) на основе датасета о фондах и инвестициях */

/*  Отобразите все записи из таблицы company по компаниям, которые закрылись. */

SELECT COUNT(status)
FROM company
WHERE status = 'closed';

/* Задание 2. Отобразите количество привлечённых средств для новостных компаний США. 
Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total. */

SELECT funding_total
FROM company
WHERE category_code = 'news' AND country_code = 'USA'
ORDER BY funding_total DESC;

/* Задание 3. Найдите общую сумму сделок по покупке одних компаний другими в долларах. 
Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно. */

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash' AND
      EXTRACT(YEAR FROM acquired_at) BETWEEN 2011 AND 2013;

/* Задание 4. Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'. */

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

/* Задание 5. Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'. */

SELECT *
FROM people
WHERE twitter_username LIKE '%money%' 
      AND last_name LIKE 'K%';

/* Задание 6. Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране.
Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы. */ 

SELECT country_code, SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;

/* Задание 7. Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению. */

SELECT funded_at,  MIN(raised_amount), MAX(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING NOT MIN(raised_amount) = 0
       AND NOT MIN(raised_amount) = MAX(raised_amount);

/* Задание 8. 
Создайте поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.*/

SELECT *,
CASE
	WHEN invested_companies >= 100 THEN 'high_activity'
	WHEN invested_companies >= 20 THEN 'middle_activity'
	ELSE 'low_activity'
	END AS activity
FROM fund;

/* Задание 9. Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого 
числа среднее количество инвестиционных раундов, в которых фонд принимал участие. 
Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего. */

SELECT ROUND(AVG(investment_rounds)) AS avarage,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
       FROM fund
       GROUP BY activity
ORDER BY avarage;
	
/* Задание 10.Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, 
основанные с 2010 по 2012 год включительно. Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему. 
Затем добавьте сортировку по коду страны в лексикографическом порядке. */

SELECT country_code,
	MIN(invested_companies),
	MAX(invested_companies),
	AVG(invested_companies) AS average
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS date)) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING NOT MIN(invested_companies) = 0
ORDER BY average DESC,
country_code
LIMIT 10;

/* Задание 11. Отобразите имя и фамилию всех сотрудников стартапов. 
Добавьте поле с названием учебного заведения, которое окончил или в котором учится сотрудник, если эта информация известна */ 

SELECT p.first_name, 
	p.last_name, 
	e.instituition
FROM people AS p
LEFT OUTER JOIN education AS e ON e.person_id=p.id;

/* Задание 12. 
Для каждой компании найдите количество учебных заведений, которые окончили или в которых учатся сотрудники. 
Выведите название компании и число уникальных названий учебных заведений. 
Составьте топ-5 компаний по количеству университетов. */

WITH
a AS (SELECT p.company_id as newid, e.instituition as institut
      FROM people AS p
INNER JOIN education AS e ON e.person_id = p.id)
SELECT c.name, COUNT(DISTINCT a.institut)
FROM company as c 
LEFT JOIN a ON c.id=a.newid
GROUP BY c.name
ORDER BY COUNT(DISTINCT a.institut) DESC
LIMIT 5;

/* Задание 13. Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним. */

SELECT DISTINCT(name)
FROM company as c
JOIN funding_round as fr ON fr.company_id=c.id
WHERE status = 'closed' AND is_first_round = 1 and is_last_round = 1;

/* Задание 14. Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании. */

SELECT DISTINCT p.id
FROM (SELECT c.name, c.id
	FROM company as c
	JOIN funding_round as fr ON fr.company_id=c.id
	WHERE status = 'closed' AND is_first_round = 1 and is_last_round = 1) AS a
JOIN people as p on p.company_id=a.id;

/* Задание 15. Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник. */

SELECT DISTINCT p.id, e.instituition
FROM (SELECT c.name, c.id
	FROM company as c
	JOIN funding_round as fr ON fr.company_id=c.id
	WHERE status = 'closed' AND is_first_round = 1 and is_last_round = 1) AS a
JOIN people as p on p.company_id=a.id
JOIN education as e ON e.person_id=p.id;


/* Задание 16. Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. 
При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды. */

SELECT p.id, COUNT(e.instituition)
FROM people AS p
LEFT JOIN education AS e ON p.id = e.person_id
WHERE p.company_id IN
	(SELECT c.id
	FROM company AS c
	JOIN funding_round AS fr ON c.id = fr.company_id
	WHERE status ='closed'
	AND is_first_round = 1
	AND is_last_round = 1
	GROUP BY c.id)
GROUP BY p.id
HAVING NOT COUNT(e.instituition) = 0

/* Задание 17. Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), 
которые окончили сотрудники разных компаний. Нужно вывести только одну запись, группировка здесь не понадобится. */

WITH
a AS
	(SELECT p.id, COUNT(e.instituition)
	FROM people AS p
	LEFT JOIN education AS e ON p.id = e.person_id
	WHERE p.company_id IN
		(SELECT c.id
		FROM company AS c
		JOIN funding_round AS fr ON c.id = fr.company_id
		WHERE status ='closed'
			AND is_first_round = 1
			AND is_last_round = 1
		GROUP BY c.id)
	GROUP BY p.id
	HAVING NOT COUNT(e.instituition) = 0)
SELECT AVG(a.COUNT)
FROM a;

/* Задание 18. Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Socialnet. */

WITH
a AS
	(SELECT p.id, COUNT(e.instituition)
	FROM people AS p
	LEFT JOIN education AS e ON p.id = e.person_id
	WHERE p.company_id IN
		(SELECT c.id
		FROM company AS c
		WHERE name = 'Socialnet'
		GROUP BY c.id)
	GROUP BY p.id
 	HAVING NOT COUNT(e.instituition) = 0)
SELECT AVG(a.COUNT)
FROM a;


/* Задание 19. Составьте таблицу из полей:
name_of_fund — название фонда;
name_of_company — название компании;
amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно. */

SELECT f.name AS name_of_fund,
c.name AS name_of_company,
fr.raised_amount AS amount

FROM investment AS i 
LEFT OUTER JOIN company as c ON c.id=i.company_id
LEFT OUTER JOIN fund AS f ON f.id=i.fund_id
RIGHT JOIN (SELECT *
            FROM funding_round
            WHERE EXTRACT(YEAR FROM CAST(funded_at AS date)) BETWEEN 2012 AND 2013) as fr ON fr.id=i.funding_round_id
WHERE c.milestones > 6;


/* Задание 20.Выгрузите таблицу, в которой будут такие поля:
название компании-покупателя;
сумма сделки;
название компании, которую купили;
сумма инвестиций, вложенных в купленную компанию;
доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями. */

WITH
acquiring AS
	(SELECT c.name AS name_acquiring,
	a.price_amount as price,
	a.id same 
	FROM acquisition as a
	JOIN company AS c ON c.id = a.acquiring_company_id),
acquired AS 
	(SELECT c.name as name_acquired,
	c.funding_total as invest,
	ac.id same
	FROM company as c
	JOIN acquisition as ac ON ac.acquired_company_id=c.id)
 
 SELECT acquiring.name_acquiring,
 acquiring.price,
 acquired.name_acquired,
 acquired.invest,
 ROUND(acquiring.price/acquired.invest)
FROM acquiring JOIN acquired ON acquired.same=acquiring.same
WHERE NOT acquired.invest = 0
ORDER BY acquiring.price DESC, acquired.name_acquired
LIMIT 10;

/* Задание 21. Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. 
Проверьте, что сумма инвестиций не равна нулю. 
Выведите также номер месяца, в котором проходил раунд финансирования. */

SELECT c.name, EXTRACT(MONTH FROM CAST(fr.funded_at AS date))
FROM company as c
JOIN funding_round AS fr ON fr.company_id=c.id
WHERE c.category_code = 'social' 
      AND EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2010 AND 2013
      AND fr.raised_amount != 0;

/* Задание 22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. 
Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
номер месяца, в котором проходили раунды;
количество уникальных названий фондов из США, которые инвестировали в этом месяце;
количество компаний, купленных за этот месяц;
общая сумма сделок по покупкам в этом месяце. */

WITH
a AS
	(SELECT COUNT(acquired_company_id) as acquired,
		SUM(price_amount) as price,
		EXTRACT(MONTH FROM CAST(acquired_at AS date)) AS month1
	FROM acquisition
	WHERE EXTRACT(YEAR FROM CAST(acquired_at AS date)) BETWEEN 2010 AND 2013
	GROUP BY month1),
b AS
 	(SELECT EXTRACT(MONTH FROM CAST(fr.funded_at AS date)) AS month2,
		COUNT(DISTINCT f.name) as companies
  	FROM fund AS f
  	JOIN investment as i ON f.id=i.fund_id
  	JOIN funding_round as fr ON fr.id=i.funding_round_id
  	WHERE EXTRACT(YEAR FROM CAST(fr.funded_at AS date)) BETWEEN 2010 AND 2013
  	AND f.country_code = 'USA'
	GROUP BY month2)
	
SELECT a.month1, b.companies, a.acquired, a.price
FROM a JOIN b ON a.month1=b.month2;


/* Задание 23. ССоставьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
Данные за каждый год должны быть в отдельном поле. 
Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему. */

WITH
     inv_2011 AS (SELECT country_code,
                  AVG(funding_total) AS y11
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at as date)) = 2011
                  GROUP BY country_code),
     inv_2012 AS (SELECT country_code,
                  AVG(funding_total) AS y12
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at as date)) = 2012
                  GROUP BY country_code),
     inv_2013 AS (SELECT country_code,
                  AVG(funding_total) AS y13
                  FROM company
                  WHERE EXTRACT(YEAR FROM CAST(founded_at as date)) = 2013
                  GROUP BY country_code)
SELECT inv_2011.country_code, inv_2011.y11, inv_2012.y12, inv_2013.y13
FROM inv_2011 
INNER JOIN inv_2012 ON inv_2011.country_code =inv_2012.country_code
INNER JOIN inv_2013 ON inv_2011.country_code = inv_2013.country_code
ORDER BY inv_2011.y11 DESC;

