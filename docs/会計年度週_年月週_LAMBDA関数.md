会計年度週と年月週を求める関数

- ``_date`` : ``_date``で渡された年月日を元に会計年度週か年月週を求めます。
- ``[_start_month]`` : オプション引数。``_start_month``に1から12までの月の数字を指定すると、その数字を基準に会計年度を求めます。4を指定したら4月1日を会計年度のはじまりとします。

使い方:
会計年度週を求める例:
第2引数を指定しているので、会計年度週を求めます。
``=FYW_YMW("2024/3/25",4)``とすると2023年度の最終週の52週で「202352」が返ってきます。

年度週を求める例:
第2引数を省略しているので、年度週を求めます。
=FYW_YMW("2024/3/25")とすると、2023年3月最後の週で「2024035」が返ってきます。

``I
FYW_YMW
=LAMBDA(_date,[_start_month],
  LET(
    _year, IF(MONTH(_date) < _start_month, YEAR(_date) - 1, YEAR(_date)),
    _month, IF(ISBLANK(_start_month), MONTH(_date), _start_month),
    _day, DAY(_date),
    _week, WEEKNUM(_date, 2),
    _month_start, DATE(_year, _month, 1),
    _month_start_week, WEEKNUM(_month_start, 2),
    _month_week, IF(_week < _month_start_week, _week + 52 - _month_start_week + 1, _week - _month_start_week + 1),
    _return, TEXT(_year,"000") & IF(ISBLANK(_start_month), TEXT(_month,"00") & _month_week, TEXT(_month_week, "00")),
    _return
  )
)
```
