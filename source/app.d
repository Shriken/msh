import deimos.ncurses.ncurses;

import std.file;
import std.stdio;
import std.string;

import state;
import window;

Window wind;

void main() {
	ShellState state;
	string line;
	wind = new Window();

	while (state.running) {
		// prompt, get line
		wind.refresh();
		line = wind.getLine("msh$ ");
		
		// output
		parse(state, line);
	}
	endwin();
}

void parse(ref ShellState state, string line) {
	string[] tokens = tokenize(line);

	switch (tokens[0]) {
		case "pwd":
			wind.pushLine(getcwd());
			break;
		case "ls":
			ls();
			break;
		case "cd":
			cd(tokens);
			break;
		case "exit":
			state.running = false;
			break;
		default:
			wind.pushLine("msh: " ~ tokens[0] ~ ": command not found");
			break;
	}
}

string[] tokenize(string line) {
	string[] tokens = line.split();
	return tokens;
}

void ls() {
	foreach (string dirname; dirEntries(".", SpanMode.shallow)) {
		string trimmed = dirname[2 .. $];
		wind.pushLine(" " ~ trimmed);
	}
}

void cd(string[] tokens) {
	if (tokens.length < 2) {
		wind.pushLine("cd: must provide a target dir");
		return;
	}

	if (exists(tokens[1])) chdir(tokens[1]);
	else wind.pushLine("cd: directory " ~ tokens[1] ~ " does not exist");
}
