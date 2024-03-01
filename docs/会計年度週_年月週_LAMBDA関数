会計年度週
FYW:

```
=LAMBDA(_date,_start_month,
LET(
  _year,  YEAR(_date), 
  _month, MONTH(_date),
  _day, DAY(_date),
  _week,  WEEKNUM(_date,2),
  _fiscal_year, IF(_month < _start_month, _year-1, _year),
  _fiscal_start, DATE(_fiscal_year,_start_month, 1),
  _fiscal_start_week, WEEKNUM(_fiscal_start, 2),
  _fiscal_week, IF(_week < _fiscal_start_week, _week + 52 - _fiscal_start_week + 1, _week - _fiscal_start_week + 1),
  _return, TEXT(_year,"0000") & TEXT(_fiscal_week, "00"),
  _return
 )
)
```

会計年度週と構造がすごく似てる。
年月週
YMW:

```
=LAMBDA(_date,
  LET(
    _year, YEAR(_date),
    _month, MONTH(_date),
    _day, DAY(_date),
    _month_start, DATE(_year, _month, 1),
    _month_start_week_day, WEEKDAY(_month_start, 2),
    _month_start_week, WEEKNUM(_month_start, 2),
    _week, WEEKNUM(_date, 2),
    _month_week, IF(_week < _month_start_week, _week + 52 - _month_start_week + 1, _week - _month_start_week + 1),
    _return, TEXT(_year,"000") &TEXT(_month,"00") &_month_week
    _return
  )
)
```
