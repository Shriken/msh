import std.algorithm;
import std.stdio;
import std.file;

import deimos.ncurses.ncurses;

class Window {
	int cols, rows;
	char[][] lines;
	File logFile;

	this() {
		cols = 20;
		rows = 20;

		initscr();
		noecho();
		.refresh();

		logFile = File("error.log", "w+");
	}

	void pushLine(char[] line) {
		line ~= '\0';
		lines ~= line;
		if (lines.length > rows)
			lines.remove(0);
	}

	void popLine() {
		lines = lines.remove(lines.length - 1);
	}

	void pushChar(char c) {
		char[] line = lines[$ - 1];

		if (lines[$ - 1].length > 0 && lines[$ - 1][$ - 1] == '\0') {
			lines[$ - 1].length--;
		}
		lines[$ - 1] ~= c;
		lines[$ - 1] ~= '\0';

		logFile.writeln("pushing char ", cast(int) c);
	}

	void popChar() {
		if (lines[$ - 1].length > 0) {
			lines[$ - 1].length--;
			lines[$ - 1][$ - 1] = '\0';
			logFile.writeln("popping char ", lines[$-1]);
		}
	}

	// write everything in lines to the screen
	void refresh() {
		clear();

		for (int i = 0; i < lines.length; i++)
			mvprintw(i, 0, lines[i].ptr);

		.refresh();
	}

	// prompt for and record/return a line up to newline/EOF
	char[] getLine(char[] prompt) {
		// display the prompt
		pushLine(prompt);
		refresh();

		char[] line;
		int c;
		do {
			c = getch();
			switch (c) {
				case 127: // delete
					popChar();
					refresh();
					break;
				default:
					pushChar(cast(char) c);
					line ~= c;
					refresh(); // TODO make this more efficient
					break;
			}
		} while (c != '\n' && c != -1); // not newline or EOF

		return line;
	}
};