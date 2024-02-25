# 対称差集合

```
=LAMBDA(_left,_left_keys,_right,_right_keys,
  LET(
    _left_join_keys,     BYROW(_left,  LAMBDA(_left_row,  TEXTJOIN(CHAR(9), TRUE, INDEX(_left_row, ,  _left_keys )))),
    _right_join_keys,    BYROW(_right, LAMBDA(_right_row, TEXTJOIN(CHAR(9), TRUE, INDEX(_right_row, , _right_keys)))),
    _left_unique_keys,   UNIQUE(_left_join_keys),
    _right_unique_keys,  UNIQUE(_right_join_keys),
    _left_only_keys,     FILTER(_left_unique_keys,  NOT(ISNUMBER(BYROW(_left_unique_keys,  LAMBDA(_left_key,  IFERROR(MATCH(TRUE, EXACT(_left_key,  _right_unique_keys), 0), FALSE)))))),
    _right_only_keys,    FILTER(_right_unique_keys, NOT(ISNUMBER(BYROW(_right_unique_keys, LAMBDA(_right_key, IFERROR(MATCH(TRUE, EXACT(_right_key, _left_unique_keys),  0), FALSE)))))),
    _left_only_records,  INDEX(_left,  BYROW(_left_only_keys,  LAMBDA(d, MATCH(TRUE, EXACT(d, _left_join_keys),  0))), SEQUENCE(1, COLUMNS(_left))),
    _right_only_records, INDEX(_right, BYROW(_right_only_keys, LAMBDA(d, MATCH(TRUE, EXACT(d, _right_join_keys), 0))), SEQUENCE(1, COLUMNS(_right))),
    _left_null_records,  HSTACK(_left_only_records, REPT("",SEQUENCE(ROWS(_left_only_records), COLUMNS(_right)))),
    _right_null_records, HSTACK(REPT("",SEQUENCE(ROWS(_right_only_records), COLUMNS(_left))),  _right_only_records),
    _return,             VSTACK(_left_null_records, _right_null_records),
   _return
  )
)(T_before, {1,2}, T_after, {1,2})
```
## 難解な部分の解説:
### ``_left_only_keys, FILTER(_left_unique_keys,  NOT(ISNUMBER(BYROW(_left_unique_keys,  LAMBDA(_left_key,  IFERROR(MATCH(TRUE, EXACT(_left_key,  _right_unique_keys), 0), FALSE))))))``:
左側のテーブル(_left)には存在するが、右側のテーブル(_right)には存在しない一意のキーを見つけるための処理です。ここでのキーとは、特定の列または列の組み合わせによって形成される一意の識別子です。

以下のステップでこの処理が行われます：

1. _left_unique_keysには、左側のテーブルの一意のキーが格納されています。
2. BYROW関数を使用して、_left_unique_keysの各キーに対して処理を行います。
3. LAMBDA関数が各キー(_left_key)を受け取り、右側のテーブルの一意のキー(_right_unique_keys)と比較します。
4. EXACT関数を使用して、大文字小文字を区別する比較を行います。EXACT関数は、二つの文字列が完全に一致する場合にTRUEを返します。
5. MATCH関数は、EXACT関数から返されたTRUEの位置を探します。ここで0を第三引数として使用しているため、厳密な一致を求めます。
6. IFERROR関数は、MATCH関数がエラー(つまり一致するものがない場合)を返したときにFALSEを返すようにしています。
7. FILTER関数は、BYROWとLAMBDAによって生成されたTRUEまたはFALSEの配列を使用して、一致するものがなかった(つまり右側のテーブルに存在しない)キーだけを抽出します。

結果として、_left_only_keysには左側のテーブルにのみ存在し、右側のテーブルには存在しないキーが格納されます。この処理により、二つのテーブル間で不一致のあるデータを特定することができます。

### ``_left_only_records, INDEX(_left, BYROW(_left_only_keys, LAMBDA(d, MATCH(TRUE, EXACT(d, _left_join_keys), 0))), SEQUENCE(1, COLUMNS(_left))),``:
_left_only_keysで特定されたキーに対応する左側のテーブル（_left）のレコードを取得する処理です。ここでの「レコード」とは、テーブルの行のことを指します。

以下のステップでこの処理が行われます：

1. ``BYROW(_left_only_keys, LAMBDA(d, MATCH(TRUE, EXACT(d, _left_join_keys), 0)))``:
- BYROW関数を使用して、_left_only_keysの各キーに対して処理を行います。
- LAMBDA関数が各キー(d)を受け取り、_left_join_keys内での位置をEXACT関数とMATCH関数を使って検索します。
- EXACT関数は大文字小文字を区別して比較を行い、MATCH関数は一致する位置を返します。
2. ``INDEX(_left, ..., SEQUENCE(1, COLUMNS(_left)))``:
- INDEX関数を使用して、_leftテーブルから対応する行を取得します。
- ``SEQUENCE(1, COLUMNS(_left))``は、取得する行のすべての列を指定しています。

この処理により、_left_only_recordsには、右側のテーブルには存在しない左側のテーブルのレコードが格納されます。これにより、左側のテーブルにのみ存在するデータを特定し、それらを処理することができます。
