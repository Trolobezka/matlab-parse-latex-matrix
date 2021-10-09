# MATLAB ParseLatexMatrix WIP
ParseLatexMatrix is a set of scripts for parsing latex matrices inside MATLAB.

## Basic usage
```matlab
parseLatexMatrix(latex, debug = false)
```
* return value is vertical cell array of size (matrix count, 1)
* if the latex matrix is badly formatted, parser can ignore it or parse it wrongly (but there should not be any errors)
* if the latex matrix has uneven number of columns in every row, parser will fill missing elements with zeros
* if the latex matrix has non-numeric values as elements, parses will convert them to NaN