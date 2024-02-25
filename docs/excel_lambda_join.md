# 対称差集合
=LAMBDA(_left,_left_keys,_right,_right_keys,
  LET(
    _left_join_keys,     BYROW(_left,  LAMBDA(_left_row,  TEXTJOIN(CHAR(9), TRUE, INDEX(_left_row, ,  _left_keys )))),
    _right_join_keys,    BYROW(_right, LAMBDA(_right_row, TEXTJOIN(CHAR(9), TRUE, INDEX(_right_row, , _right_keys)))),
    _left_unique_keys,   UNIQUE(_left_join_keys),
    _right_unique_keys,  UNIQUE(_right_join_keys),
    _left_only_keys,     FILTER(_left_unique_keys,  NOT(ISNUMBER(BYROW(_left_unique_keys,  LAMBDA(_left_key,  IFERROR(MATCH(TRUE, EXACT(_left_key,  _right_unique_keys), 0), FALSE)))))),
    _right_only_keys,    FILTER(_right_unique_keys, NOT(ISNUMBER(BYROW(_right_unique_keys, LAMBDA(_right_key, IFERROR(MATCH(TRUE, EXACT(_right_key, _left_unique_keys),  0), FALSE)))))),
    _left_only_records,  IFERROR(INDEX(_left, BYROW(_left_only_keys, LAMBDA(d, MATCH(TRUE, EXACT(d, _left_join_keys), 0))), SEQUENCE(1, COLUMNS(_left))), REPT(" ", COLUMNS(_left))),
    _right_only_records, IFERROR(INDEX(_right, BYROW(_right_only_keys, LAMBDA(d, MATCH(TRUE, EXACT(d, _right_join_keys), 0))), SEQUENCE(1, COLUMNS(_right))), REPT(" ", COLUMNS(_right))),
    _left_null_records,  IFERROR(HSTACK(_left_only_records, IF(LEN(_left_only_records), REPT(" ", COLUMNS(_right)), "")), ""),
    _right_null_records, IFERROR(HSTACK(IF(LEN(_right_only_records), REPT(" ", COLUMNS(_left)), ""), _right_only_records), ""),
    _return,             VSTACK(_left_null_records, _right_null_records),
   _return
  )
)(T_before, {1,2}, T_after, {1,2})
