MODULE Utf8;

IMPORT Out, SYSTEM;

TYPE
  Char* = LONGINT;  (* Unicode code point *)

(* Return number of bytes needed to encode this codepoint *)
PROCEDURE EncodeLen*(u: Char): INTEGER;
BEGIN
  IF u < 80H THEN RETURN 1
  ELSIF u < 800H THEN RETURN 2
  ELSIF u < 10000H THEN RETURN 3
  ELSE RETURN 4
  END
END EncodeLen;

(* Encode a codepoint into UTF-8 bytes *)
PROCEDURE Chr*(u: Char; VAR s: ARRAY OF CHAR; VAR n: INTEGER);
VAR
  b: INTEGER;
BEGIN
  IF u < 80H THEN
    s[0] := CHR(u);
    n := 1
  ELSIF u < 800H THEN
    s[0] := CHR(0C0H + u DIV 40H);
    s[1] := CHR(080H + u MOD 40H);
    n := 2
  ELSIF u < 10000H THEN
    s[0] := CHR(0E0H + u DIV 1000H);
    s[1] := CHR(080H + (u DIV 40H) MOD 40H);
    s[2] := CHR(080H + u MOD 40H);
    n := 3
  ELSE
    s[0] := CHR(0F0H + u DIV 40000H);
    s[1] := CHR(080H + (u DIV 1000H) MOD 40H);
    s[2] := CHR(080H + (u DIV 40H) MOD 40H);
    s[3] := CHR(080H + u MOD 40H);
    n := 4
  END
END Chr;

PROCEDURE Ord*(VAR s(*-*): ARRAY OF CHAR; pos: INTEGER; VAR u: Char; VAR size: INTEGER): BOOLEAN;
VAR c, c1, c2, c3: INTEGER;
BEGIN
  c := ORD(s[pos]);

  IF c < 80H THEN
    u := c;
    size := 1;
    RETURN TRUE
  ELSIF (c >= 0C0H) & (c < 0E0H) THEN
    c1 := ORD(s[pos+1]);
    IF (c1 >= 080H) & (c1 < 0C0H) THEN
      u := (c - 0C0H) * 40H + (c1 - 080H);
      size := 2;
      RETURN TRUE
    END
  ELSIF (c >= 0E0H) & (c < 0F0H) THEN
    c1 := ORD(s[pos+1]); c2 := ORD(s[pos+2]);
    IF (c1 >= 080H) & (c1 < 0C0H) & (c2 >= 080H) & (c2 < 0C0H) THEN
      u := (c - 0E0H) * 1000H + (c1 - 080H) * 40H + (c2 - 080H);
      size := 3;
      RETURN TRUE
    END
  ELSIF (c >= 0F0H) & (c < 0F8H) THEN
    c1 := ORD(s[pos+1]); c2 := ORD(s[pos+2]); c3 := ORD(s[pos+3]);
    IF (c1 >= 080H) & (c1 < 0C0H) & (c2 >= 080H) & (c2 < 0C0H) & (c3 >= 080H) & (c3 < 0C0H) THEN
      u := (c - 0F0H) * 40000H + (c1 - 080H) * 1000H + (c2 - 080H) * 40H + (c3 - 080H);
      size := 4;
      RETURN TRUE
    END
  END;

  u := -1; size := 1;
  RETURN FALSE
END Ord;

(* Return next position in string after one UTF-8 character *)
PROCEDURE Next*(VAR s(*-*): ARRAY OF CHAR; VAR pos: INTEGER; VAR u: Char): BOOLEAN;
VAR size: INTEGER;
BEGIN
  IF Ord(s, pos, u, size) THEN
    INC(pos, size);
    RETURN TRUE
  ELSE
    INC(pos);  (* fallback *)
    RETURN FALSE
  END
END Next;

PROCEDURE OutChar*(u: Char);
VAR
  buf: ARRAY 8 OF CHAR;
  n: INTEGER;
BEGIN
  Chr(u, buf, n);
  buf[n] := 0X;
  Out.String(buf)
END OutChar;

PROCEDURE OutString*(VAR s(*-*): ARRAY OF CHAR);
VAR
  pos: INTEGER;
  u: Char;
BEGIN
  pos := 0;
  WHILE s[pos] # 0X DO
    IF Next(s, pos, u) THEN
      OutChar(u)
    END
  END
END OutString;

END Utf8.

