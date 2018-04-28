## SQL_QUIZ; 

# Loading libraries: 

library(tidyverse)
library(gsubfn)
library(proto)
library(RSQLite)
library(sqldf)

# Data for the quiz: 4 tibbles: COURSES, ENROLLMENT, PERSONS, SESSIONS

COURSES <- tribble (
  ~CID, ~CTITLE, ~CDUR,
       7890, "Probability", 5, 
       7910, "MathStat",    4,
       8500, "TimeSeries",  5,
       8000, "GLM",         5,
       9000, "Inference",   3

  )


ENROLLMENT <- tribble(
    ~E_SNO, ~E_PNO, ~ECANCEL,
     10, 4,  0,
     10, 7,   "C",
     11, 45,  0,
     11, 13,  0,
     12, 4,   0,
     13, 15, "C",
     13, 36,  0,
     14, 3,  0,
     14, 18,"C",
     14, 1,  0,
     15, 4,  0,
     15, 7,  0,
     16, 3,  0,
     16, 18, 0
)

PERSONS <- tribble(
  
 ~PNO, ~PNAME, ~P_CONO, 
  1, "SMITH", 3,
  2, "TORIO", 3,
  3, "BAPTISTE",3, 
  4, "LAU", 5,
  5, "IDE", 5,
  6, "BLAKE", 10,
  7, "NAGAI", 2,
  8, "SPENCER", 10,
  9, "PARK", 1,
  10, "BENOIT", 1,
  11, "LOOSE", 0,
  13, "PARKER", 6,
  15, "BEAMER", 7,
  17, "HOOSER", 4,
  18, "GELADE", 2,
  33, "LEE", 9,
  36, "ADAMSON", 8,
  45, "MOORS", 4,
  50, "MAK", 0
)

SESSIONS <- tribble(
  ~SNO, ~S_CID, ~SDATE, ~SINS_PNO, ~SCANCEL,
  10, 7890, "12/2/2015", 3, 0,
  11, 7910, "11/4/2015", 1, 0,
  12, 7890, "1/8/2016", 3, "c",
  13, 7890, "2/2/2016", 3, 0,
  14, 8000, "4/5/2016", 2, "c", 
  15, 7910, "1/8/2016", 36, "c", 
  16, 8500, "4/5/2016", 36, 0,
  17, 9000, "6/7/2016", 36, 0
)



#Q1. Which ones of the following queries produce exactly one result row? 
# Ans: A, B and E
#A. YES

sqldf("SELECT COUNT(*)
      FROM PERSONS
      WHERE PNO > 100"
)

#B. YES
sqldf("SELECT PNO, COUNT(*)
      FROM PERSONS
      WHERE PNO = 2"
      )

#c. Not this

sqldf("SELECT COUNT(*)
      FROM PERSONS
      GROUP BY PNO"
      )

#d. NOt this

sqldf("SELECT PNAME
      FROM PERSONS INNER JOIN SESSIONS ON PNO = SINS_PNO
      WHERE PNO = 36"
      )

#E.YES

sqldf("SELECT PNAME
      FROM PERSONS LEFT OUTER JOIN ENROLLMENT ON PNO = E_PNO
      WHERE PNO = 2
      GROUP BY PNAME"
      )

#F.NOT THIS

sqldf("SELECT SUM(CDUR)
      FROM COURSES, SESSIONS, ENROLLMENT
      WHERE CID = S_CID AND SNO = E_SNO
      GROUP BY CID"
      )


#2. How many result rows are produced by this query?
# Ans: 8 rows

sqldf("SELECT E_SNO
      FROM ENROLLMENT
      UNION
      SELECT SNO
      FROM SESSIONS
      WHERE SNO BETWEEN 15 AND 17")

#3. Which queries produce the following table? 
# Ans: D, E and F

#A. 
sqldf("SELECT PNO, PNAME, 'ENROLLEE OR INSTRUCTOR'
      FROM PERSONS INNER JOIN SESSIONS ON PNO = SINS_PNO
      INNER JOIN ENROLLMENT ON PNO = E_PNO
      ORDER BY 3, 1"
      )

#B
sqldf("SELECT PNO, PNAME, CASE PNO WHEN E_PNO THEN 'ENROLLEE' ELSE 'INSTRUCTOR' END
      FROM PERSONS INNER JOIN SESSIONS ON PNO = SINS_PNO
      INNER JOIN ENROLLMENT ON PNO = E_PNO
      ORDER BY 3, 1"
      )

#C 
sqldf("SELECT PNO, PNAME, 'INSTRUCTOR'
      FROM PERSONS
      WHERE PNO IN (SELECT SINS_PNO
      FROM SESSIONS)
      UNION ALL
      SELECT PNO, PNAME, 'ENROLLEE'
      FROM PERSONS INNER JOIN ENROLLMENT ON PNO = E_PNO
      ORDER BY 3, 1"
      )

#D YES 
sqldf("SELECT DISTINCT PNO, PNAME, 'INSTRUCTOR'
      FROM PERSONS
      INNER JOIN SESSIONS ON PNO = SINS_PNO
      UNION ALL
      SELECT PNO, PNAME, 'ENROLLEE'
      FROM PERSONS
      WHERE PNO IN (SELECT E_PNO
      FROM ENROLLMENT)
      ORDER BY 3, 1"
      )

#E YES
sqldf("SELECT PNO, PNAME, 'INSTRUCTOR'
      FROM PERSONS INNER JOIN SESSIONS ON PNO = SINS_PNO
      UNION
      SELECT PNO, PNAME, 'ENROLLEE'
      FROM PERSONS
      WHERE PNO IN (SELECT E_PNO
      FROM ENROLLMENT)
      ORDER BY 3, 1"
      )

#F YES
sqldf("SELECT DISTINCT PNO, PNAME, 'INSTRUCTOR'
      FROM PERSONS INNER JOIN SESSIONS ON PNO = SINS_PNO
      UNION
      SELECT PNO, PNAME, 'ENROLLEE'
      FROM PERSONS P
      WHERE EXISTS (SELECT E_PNO
      FROM ENROLLMENT
      WHERE E_PNO = P.PNO)
      ORDER BY 3, 1"
      )
