> quit
C-x C-c


> save
C-X C-s


> quit current command
C-g


> close current buffer
C-x k


> list buffers in current window


> split window in two, one under the other
C-x 2

> split window in two, side by side
C-x 5

> select another window
C-x o

> kill current window
C-x 0


> search and replace string in multiple files, asking you one-by-one
# emacs
>choose files by filelist
C-x d
       select directory
       move cursor with arrow keys
       mark file with 'm' and unmark with 'u'
       to select file matching a pattern do %m

> choose file by find
M-x find-dired

M-x dired-do-query-replace-regexp
	to finish the selection and do call
	enter 'dired-do-query-replace-regexp'
	to match a backslash (\) type \\\
	confirm the changes you want

M-x
	enter 'list-buffers'

C-x o
	to switch to other window
	move cursor to the file you want to save and press 's'