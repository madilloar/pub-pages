# OracleCHAR型とVARCHAR2型の挙動の違い

## テーブル作成
DROP TABLE T_CHARTEST;

CREATE TABLE T_CHARTEST (
  ID         NUMBER PRIMARY KEY,
  ITEM_CHAR1 CHAR(1),
  ITEM_CHAR5 CHAR(5),
  ITEM_VCHAR1 VARCHAR2(1),
  ITEM_VCHAR5 VARCHAR2(5)
);

## テスト観点
長さゼロの文字列
NULL
型で定義した桁数に満たない場合


## テストデータ
TRUNCATE TABLE T_CHARTEST;

INSERT INTO T_CHARTEST (ID, ITEM_CHAR1, ITEM_CHAR5, ITEM_VCHAR1, ITEM_VCHAR5) VALUES
(1, '', '', '', '');  -- 長さゼロの文字列（OracleではNULLとして扱われる）
 
INSERT INTO T_CHARTEST (ID, ITEM_CHAR1, ITEM_CHAR5, ITEM_VCHAR1, ITEM_VCHAR5) VALUES
(2, NULL, NULL, NULL, NULL);  -- 明示的にNULLを設定

INSERT INTO T_CHARTEST (ID, ITEM_CHAR1, ITEM_CHAR5, ITEM_VCHAR1, ITEM_VCHAR5) VALUES
(3, 'A', 'ABC', 'A', 'ABC');  -- 型で定義した桁数未満のデータ（CHARはスペースでパディング）

INSERT INTO T_CHARTEST (ID, ITEM_CHAR1, ITEM_CHAR5, ITEM_VCHAR1, ITEM_VCHAR5) VALUES
(4, 'X', 'ABCDE', 'X', 'ABCDE');  -- ちょうど型の桁数分のデータ

INSERT INTO T_CHARTEST (ID, ITEM_CHAR1, ITEM_CHAR5, ITEM_VCHAR1, ITEM_VCHAR5) VALUES
(5, ' ', ' ', ' ', '     '); -- TRIMして検索した場合などに使う

COMMIT;


## テスト結果
## 長さゼロの文字列はNULLとして扱われる
"ID"	"ITEM_CHAR1"	"ITEM_CHAR5"	"ITEM_VCHAR1"	"ITEM_VCHAR5"
1	""	""	""	""
2	""	""	""	""
3	"A"	"ABC  "	"A"	"ABC"
4	"X"	"ABCDE"	"X"	"ABCDE"
5	" "	"     "	" "	"     "

## トリムしたらどうなる？
NULL値にLENGTH関数を適用するとNULLになる。
末尾スペースをTRIMすると残った文字になり、それにLENGTH関数を適用すると、その文字数になる。
全桁スペースをTRIMすると長さゼロの文字列になりNULLとなるので、LENGTH関数を適用するとNULLになる。

SELECT
  ID,
  ITEM_CHAR5,
  LENGTH(ITEM_CHAR5),
  TRIM(ITEM_CHAR5),
  LENGTH(TRIM(ITEM_CHAR5))
FROM
  T_CHARTEST;

"ID"	"ITEM_CHAR5"	"LENGTH(ITEM_CHAR5)"	"TRIM(ITEM_CHAR5)"	"LENGTH(TRIM(ITEM_CHAR5))"
1	""		""	
2	""		""	
3	"ABC  "	5	"ABC"	3
4	"ABCDE"	5	"ABCDE"	5
5	"     "	5	""	

## 文字列連結したらどうなる？
CHAR型NULL "-" VARCHAR2型NULLは、NULLは長さゼロの文字列なので"-"が結果となる。
CHAR型"ABC   " "-" VARCHAR2型"ABC"、"ABC  -ABC"となる。VARCHAR2型の末尾に勝手にスペースはつかない。CHAR型はINSERTした時点で末尾スペースパディングされている。

SELECT
  ID,
  ITEM_CHAR5
  || '-'
  || ITEM_VCHAR5 AS CONCAT_RESULT
FROM
  T_CHARTEST;

"ID"	"CONCAT_RESULT"
1	"-"
2	"-"
3	"ABC  -ABC"
4	"ABCDE-ABCDE"
5	"     -     "


## 比較演算子はどうなる？
ITEM_CHAR5はINSERT時点で末尾スペースパディング済。
右辺は暗黙の型変換で末尾スペースパディングするので、ID=3が返ってくる。

SELECT
  *
FROM
  T_CHARTEST
WHERE
  ITEM_CHAR5 = 'ABC';

"ID"	"ITEM_CHAR1"	"ITEM_CHAR5"	"ITEM_VCHAR1"	"ITEM_VCHAR5"
3	"A"	"ABC  "	"A"	"ABC"

当然、明示的に右辺にスペースパディングしても``ITEM_CHAR5 = 'ABC  ';``、ID=3は検索できる。

ITEM_VCHAR5は末尾スペースパディングしないため、右辺にスペースをパディングすると、ヒットしない。
SELECT
  *
FROM
  T_CHARTEST
WHERE
  ITEM_VCHAR5 = 'ABC  ';


## LIKE演算子はどうなるか？
どちらも同じ結果になる。

SELECT
  *
FROM
  T_CHARTEST
WHERE
  ITEM_CHAR5 LIKE 'ABC%';

SELECT
  *
FROM
  T_CHARTEST
WHERE
  ITEM_VCHAR5 LIKE 'ABC%';

"ID"	"ITEM_CHAR1"	"ITEM_CHAR5"	"ITEM_VCHAR1"	"ITEM_VCHAR5"
3	"A"	"ABC  "	"A"	"ABC"
4	"X"	"ABCDE"	"X"	"ABCDE"


## NVL関数はどうなるか？
長さゼロの文字列はNULLになると考えれば、結果がどうなるかわかる。

SELECT
  ID,
  NVL(ITEM_CHAR5, 'DEFAULT')  AS CHAR_DEFAULT,
  NVL(ITEM_VCHAR5, 'DEFAULT') AS VCHAR_DEFAULT,
  NVL(TRIM(ITEM_CHAR5),
      'DEFAULT')              AS TRIM_CHAR_DEFAULT,
  NVL(TRIM(ITEM_VCHAR5),
      'DEFAULT')              AS TRIM_VCHAR_DEFAULT
FROM
  T_CHARTEST;

"ID"	"CHAR_DEFAULT"	"VCHAR_DEFAULT"	"TRIM_CHAR_DEFAULT"	"TRIM_VCHAR_DEFAULT"
1	"DEFAULT"	"DEFAULT"	"DEFAULT"	"DEFAULT"
2	"DEFAULT"	"DEFAULT"	"DEFAULT"	"DEFAULT"
3	"ABC  "	"ABC"	"ABC"	"ABC"
4	"ABCDE"	"ABCDE"	"ABCDE"	"ABCDE"
5	"     "	"     "	"DEFAULT"	"DEFAULT"
