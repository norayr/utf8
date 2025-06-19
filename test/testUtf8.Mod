MODULE Utf8Test;
IMPORT Utf8, Out;

VAR
  s: ARRAY 128 OF CHAR;
  pos, n: INTEGER;
  c: Utf8.Char;
  buf: ARRAY 8 OF CHAR;

BEGIN
  s := "Բարեւ աշխարհ";
  pos := 0;

  (* Print codepoints *)
  WHILE s[pos] # 0X DO
    IF Utf8.Next(s, pos, c) THEN
      Out.Int(c, 1); Out.Char(" ")
    END
  END;
  Out.Ln;

  (* Print actual characters *)
  pos := 0;
  WHILE s[pos] # 0X DO
    IF Utf8.Next(s, pos, c) THEN
      Utf8.Chr(c, buf, n);
      buf[n] := 0X;  (* null-terminate for Out.String *)
      Out.String(buf)
    END
  END;
  Out.Ln
END Utf8Test.
